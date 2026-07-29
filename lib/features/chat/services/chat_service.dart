import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/models/app_models.dart';
import '../../../core/services/cache_service.dart';
import '../../../core/services/encryption_service.dart';

class ChatService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final EncryptionService? _encryptionService;
  final CacheService? _cacheService;

  ChatService([this._encryptionService, this._cacheService]);

  // الحصول على معرف الغرفة الفريد بين المستخدمين
  String _getChatRoomId(String userId1, String userId2) {
    List<String> ids = [userId1, userId2];
    ids.sort();
    return ids.join('_');
  }

  // إرسال رسالة مع التخزين المحلي الفوري والتشفير الخياري E2EE
  Future<void> sendMessage({
    required String senderId,
    required String receiverId,
    required String text,
    MessageType type = MessageType.text,
    String? mediaUrl,
    String? thumbnailUrl,
    String? localPath,
    String? replyToId,
    bool enableEncryption = true,
  }) async {
    final String chatRoomId = _getChatRoomId(senderId, receiverId);

    // التشفير إن كان متاحاً ورسالة نصية
    String finalText = text;
    bool isEncrypted = false;

    if (enableEncryption && _encryptionService != null && type == MessageType.text && text.isNotEmpty) {
      try {
        finalText = await _encryptionService!.encryptText(text);
        isEncrypted = true;
      } catch (e) {
        finalText = text;
        isEncrypted = false;
      }
    }
    
    final String docId = _firestore.collection('chats').doc(chatRoomId).collection('messages').doc().id;

    // 1. إنشاء كائن الرسالة بحالة معلقة isPending = true
    final MessageModel newMessage = MessageModel(
      id: docId,
      senderId: senderId,
      text: finalText,
      type: type,
      mediaUrl: mediaUrl,
      thumbnailUrl: thumbnailUrl,
      localPath: localPath,
      timestamp: DateTime.now(),
      replyToId: replyToId,
      isEncrypted: isEncrypted,
      isPending: true, // تظهر فوراً مع حالة جاري الإرسال ⏳
    );

    // 2. حفظ فورياً في قاعدة البيانات المحلية Hive للظهور المباشر الشاشات
    if (_cacheService != null) {
      await _cacheService!.saveSingleLocalMessage(chatRoomId, newMessage);
    }

    final Map<String, dynamic> messageMap = _messageToMap(newMessage);
    
    // التخزين السحابي يحمل دائماً isPending = false لتعكس نجاح الاستلام
    final Map<String, dynamic> firestoreMap = Map<String, dynamic>.from(messageMap);
    firestoreMap['isPending'] = false;

    // 3. محاولة الإرسال للشبكة مباشر
    try {
      await _firestore
          .collection('chats')
          .doc(chatRoomId)
          .collection('messages')
          .doc(newMessage.id)
          .set(firestoreMap);
          
      await _firestore.collection('chats').doc(chatRoomId).set({
        'lastMessage': isEncrypted ? '🔒 [رسالة مشفرة]' : text,
        'lastMessageTime': newMessage.timestamp.toIso8601String(),
        'lastMessageType': type.name,
        'users': [senderId, receiverId],
      }, SetOptions(merge: true));

      // عند نجاح الإرسال يتم تغيير الحالة محلية إلى تم الإرسال ✔
      if (_cacheService != null) {
        await _cacheService!.markMessageSynced(chatRoomId, newMessage.id);
      }
    } catch (e) {
      // في حال انقطاع الشبكة، تُضاف إلى طابور الانتظار ليقوم SyncManager بإرسالها أوتوماتيكياً
      if (_cacheService != null) {
        await _cacheService!.addPendingAction({
          'id': newMessage.id,
          'actionType': 'SEND_MESSAGE',
          'chatRoomId': chatRoomId,
          'messageData': firestoreMap,
        });
      }
    }
  }

  // جلب الرسائل كبث حي مع الترقيم والدمج المحلي عند غياب الإنترنت
  Stream<List<MessageModel>> getMessages(
    String userId,
    String partnerId, {
    int limit = 20,
    DocumentSnapshot? startAfter,
  }) {
    final String chatRoomId = _getChatRoomId(userId, partnerId);
    
    Query<Map<String, dynamic>> query = _firestore
        .collection('chats')
        .doc(chatRoomId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .limit(limit);

    if (startAfter != null) {
      query = query.startAfterDocument(startAfter);
    }
    
    return query.snapshots().asyncMap((snapshot) async {
      final List<MessageModel> list = [];
      for (var doc in snapshot.docs) {
        final msg = _messageFromMap(doc.data(), doc.id);
        String textVal = msg.text;
        if (msg.isEncrypted && _encryptionService != null) {
          try {
            textVal = await _encryptionService!.decryptText(msg.text);
          } catch (_) {
            textVal = msg.text;
          }
        }
        
        // الرسائل القادمة من Firestore تم استلامها بنجاح، لذا تكون isPending دائمًا false
        list.add(MessageModel(
          id: msg.id,
          senderId: msg.senderId,
          text: textVal,
          type: msg.type,
          mediaUrl: msg.mediaUrl,
          thumbnailUrl: msg.thumbnailUrl,
          localPath: msg.localPath,
          timestamp: msg.timestamp,
          isRead: msg.isRead,
          isDeleted: msg.isDeleted,
          replyToId: msg.replyToId,
          isPinned: msg.isPinned,
          isEncrypted: msg.isEncrypted,
          isPending: false, // تم تأكيد وصولها للسيرفر
        ));
      }

      // دمج الرسائل المحلية المعلقة فقط التي لم تُرفع بعد إلى Firebase
      if (_cacheService != null) {
        final cached = _cacheService!.getCachedMessages(chatRoomId);
        for (var c in cached) {
          if (!list.any((m) => m.id == c.id) && c.isPending) {
            list.insert(0, c);
          }
        }
        await _cacheService!.cacheMessages(chatRoomId, list);
      }

      return list;
    }).handleError((error) {
      // استرجاع الكاش المحلي فورياً عند حدوث استثناء في الاتصال
      if (_cacheService != null) {
        return _cacheService!.getCachedMessages(chatRoomId);
      }
      return <MessageModel>[];
    });
  }
  
  // تعليم الرسائل كمقروءة
  Future<void> markMessagesAsRead(String userId, String partnerId) async {
    final String chatRoomId = _getChatRoomId(userId, partnerId);
    
    try {
      final unreadMessages = await _firestore
          .collection('chats')
          .doc(chatRoomId)
          .collection('messages')
          .where('senderId', isEqualTo: partnerId)
          .where('isRead', isEqualTo: false)
          .limit(100)
          .get();
          
      if (unreadMessages.docs.isEmpty) return;

      final batch = _firestore.batch();
      for (var doc in unreadMessages.docs) {
        batch.update(doc.reference, {'isRead': true});
      }
      await batch.commit();
    } catch (_) {}
  }

  // دوال التحويل من وإلى Map
  Map<String, dynamic> _messageToMap(MessageModel msg) {
    return {
      'id': msg.id,
      'senderId': msg.senderId,
      'text': msg.text,
      'type': msg.type.index,
      'mediaUrl': msg.mediaUrl,
      'thumbnailUrl': msg.thumbnailUrl,
      'localPath': msg.localPath,
      'timestamp': msg.timestamp.toIso8601String(),
      'isRead': msg.isRead,
      'isDeleted': msg.isDeleted,
      'replyToId': msg.replyToId,
      'isPinned': msg.isPinned,
      'isEncrypted': msg.isEncrypted,
      'isPending': msg.isPending,
    };
  }

  MessageModel _messageFromMap(Map<String, dynamic> map, String id) {
    return MessageModel(
      id: id,
      senderId: map['senderId'] ?? '',
      text: map['text'] ?? '',
      type: MessageType.values[(map['type'] is int) ? map['type'] : 0],
      mediaUrl: map['mediaUrl'],
      thumbnailUrl: map['thumbnailUrl'],
      localPath: map['localPath'],
      timestamp: map['timestamp'] != null ? DateTime.parse(map['timestamp']) : DateTime.now(),
      isRead: map['isRead'] ?? false,
      isDeleted: map['isDeleted'] ?? false,
      replyToId: map['replyToId'],
      isPinned: map['isPinned'] ?? false,
      isEncrypted: map['isEncrypted'] ?? false,
      isPending: map['isPending'] ?? false,
    );
  }
}
