import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'cache_service.dart';

final syncManagerProvider = Provider<SyncManager>((ref) {
  final cacheService = ref.watch(cacheServiceProvider);
  return SyncManager(cacheService);
});

class SyncManager {
  final CacheService _cacheService;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool _isSyncing = false;
  Timer? _periodicSyncTimer;

  SyncManager(this._cacheService);

  /// بدء الاستماع والمزامنة الدورية وتلبية طابور الانتظار
  void start() {
    _periodicSyncTimer?.cancel();
    // تشغيل المزامنة كل 15 ثانية أو عند التوصيل بالشبكة
    _periodicSyncTimer = Timer.periodic(const Duration(seconds: 15), (_) {
      processPendingQueue();
    });
    // ممر أولي
    processPendingQueue();
  }

  void stop() {
    _periodicSyncTimer?.cancel();
  }

  /// معالجة طابور الرسائل والإجراءات المعلقة (Pending Queue)
  Future<void> processPendingQueue() async {
    if (_isSyncing) return;
    _isSyncing = true;

    try {
      final pendingActions = _cacheService.getPendingActions();
      if (pendingActions.isEmpty) {
        _isSyncing = false;
        return;
      }

      for (final action in List<Map<String, dynamic>>.from(pendingActions)) {
        final String actionId = action['id'] ?? '';
        final String actionType = action['actionType'] ?? '';

        if (actionType == 'SEND_MESSAGE') {
          final String chatRoomId = action['chatRoomId'];
          final Map<String, dynamic> messageData = Map<String, dynamic>.from(action['messageData']);
          messageData['isPending'] = false;

          try {
            await _firestore
                .collection('chats')
                .doc(chatRoomId)
                .collection('messages')
                .doc(messageData['id'])
                .set(messageData);

            await _firestore.collection('chats').doc(chatRoomId).set({
              'lastMessage': messageData['text'],
              'lastMessageTime': messageData['timestamp'],
              'lastMessageType': messageData['type'],
            }, SetOptions(merge: true));

            // إزالة الإجراء من طابور الانتظار وتحديث الحالة المحلية إلى Synced
            await _cacheService.removePendingAction(actionId);
            await _cacheService.markMessageSynced(chatRoomId, messageData['id']);
          } catch (_) {
            // سيتم إعادة المحاولة في الدورة القادمة عند توفر الاتصال
          }
        }
      }
    } catch (_) {
    } finally {
      _isSyncing = false;
    }
  }
}
