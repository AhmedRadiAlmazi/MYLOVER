import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/models/app_models.dart';

class ChatService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // الحصول على معرف الغرفة الفريد بين المستخدمين
  String _getChatRoomId(String userId1, String userId2) {
    List<String> ids = [userId1, userId2];
    ids.sort();
    return ids.join('_');
  }

  // إرسال رسالة
  Future<void> sendMessage({
    required String senderId,
    required String receiverId,
    required String text,
    MessageType type = MessageType.text,
    String? mediaUrl,
    String? replyToId,
  }) async {
    final String chatRoomId = _getChatRoomId(senderId, receiverId);
    
    // إنشاء كائن الرسالة
    final MessageModel newMessage = MessageModel(
      id: _firestore.collection('chats').doc(chatRoomId).collection('messages').doc().id,
      senderId: senderId,
      text: text,
      type: type,
      mediaUrl: mediaUrl,
      timestamp: DateTime.now(),
      replyToId: replyToId,
    );

    // إضافة الرسالة إلى قاعدة البيانات
    await _firestore
        .collection('chats')
        .doc(chatRoomId)
        .collection('messages')
        .doc(newMessage.id)
        .set(_messageToMap(newMessage));
        
    // تحديث آخر رسالة في مستند الغرفة الرئيسي (لتسهيل عرض قائمة المحادثات مستقبلاً)
    await _firestore.collection('chats').doc(chatRoomId).set({
      'lastMessage': text,
      'lastMessageTime': newMessage.timestamp.toIso8601String(),
      'lastMessageType': type.toString(),
      'users': [senderId, receiverId],
    }, SetOptions(merge: true));
  }

  // جلب الرسائل كبث حي (Stream)
  Stream<List<MessageModel>> getMessages(String userId, String partnerId) {
    final String chatRoomId = _getChatRoomId(userId, partnerId);
    
    return _firestore
        .collection('chats')
        .doc(chatRoomId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => _messageFromMap(doc.data(), doc.id)).toList();
    });
  }
  
  // تعليم الرسائل كمقروءة
  Future<void> markMessagesAsRead(String userId, String partnerId) async {
    final String chatRoomId = _getChatRoomId(userId, partnerId);
    
    // جلب الرسائل التي لم تُقرأ وأرسلها الشريك
    final unreadMessages = await _firestore
        .collection('chats')
        .doc(chatRoomId)
        .collection('messages')
        .where('senderId', isEqualTo: partnerId)
        .where('isRead', isEqualTo: false)
        .get();
        
    final batch = _firestore.batch();
    
    for (var doc in unreadMessages.docs) {
      batch.update(doc.reference, {'isRead': true});
    }
    
    await batch.commit();
  }

  // دوال التحويل من وإلى Map لدعم الأنواع المعقدة
  Map<String, dynamic> _messageToMap(MessageModel msg) {
    return {
      'id': msg.id,
      'senderId': msg.senderId,
      'text': msg.text,
      'type': msg.type.index,
      'mediaUrl': msg.mediaUrl,
      'timestamp': msg.timestamp.toIso8601String(),
      'isRead': msg.isRead,
      'isDeleted': msg.isDeleted,
      'replyToId': msg.replyToId,
      'isPinned': msg.isPinned,
    };
  }

  MessageModel _messageFromMap(Map<String, dynamic> map, String id) {
    return MessageModel(
      id: id,
      senderId: map['senderId'] ?? '',
      text: map['text'] ?? '',
      type: MessageType.values[map['type'] ?? 0],
      mediaUrl: map['mediaUrl'],
      timestamp: map['timestamp'] != null ? DateTime.parse(map['timestamp']) : DateTime.now(),
      isRead: map['isRead'] ?? false,
      isDeleted: map['isDeleted'] ?? false,
      replyToId: map['replyToId'],
      isPinned: map['isPinned'] ?? false,
    );
  }
}
