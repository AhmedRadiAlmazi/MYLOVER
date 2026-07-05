import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ScheduledMsgModel {
  final String id;
  final String text;
  final DateTime scheduledTime;
  final bool isEnabled;
  final String repeatMode;
  final String senderId;

  ScheduledMsgModel({
    required this.id,
    required this.text,
    required this.scheduledTime,
    this.isEnabled = true,
    this.repeatMode = 'مرة واحدة',
    required this.senderId,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'text': text,
        'scheduledTime': scheduledTime.toIso8601String(),
        'isEnabled': isEnabled,
        'repeatMode': repeatMode,
        'senderId': senderId,
      };

  factory ScheduledMsgModel.fromMap(Map<String, dynamic> map, String id) {
    return ScheduledMsgModel(
      id: id,
      text: map['text'] ?? '',
      scheduledTime: map['scheduledTime'] != null ? DateTime.parse(map['scheduledTime']) : DateTime.now(),
      isEnabled: map['isEnabled'] ?? true,
      repeatMode: map['repeatMode'] ?? 'مرة واحدة',
      senderId: map['senderId'] ?? '',
    );
  }
}

class ScheduleService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String _getCoupleId(String uid1, String uid2) {
    final List<String> uids = [uid1, uid2];
    uids.sort();
    return uids.join('_');
  }

  CollectionReference<Map<String, dynamic>> _schedulesCollection(String coupleId) {
    return _firestore.collection('couples').doc(coupleId).collection('scheduled_messages');
  }

  Future<void> addMessage({
    required ScheduledMsgModel message,
    required String userId,
    required String partnerId,
  }) async {
    final coupleId = _getCoupleId(userId, partnerId);
    await _schedulesCollection(coupleId).doc(message.id).set(message.toMap());
  }

  Future<void> toggleMessageStatus({
    required String messageId,
    required bool isEnabled,
    required String userId,
    required String partnerId,
  }) async {
    final coupleId = _getCoupleId(userId, partnerId);
    await _schedulesCollection(coupleId).doc(messageId).update({'isEnabled': isEnabled});
  }

  Stream<List<ScheduledMsgModel>> getScheduledMessagesStream(String userId, String partnerId) {
    final coupleId = _getCoupleId(userId, partnerId);
    return _schedulesCollection(coupleId)
        .orderBy('scheduledTime', descending: false)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => ScheduledMsgModel.fromMap(doc.data(), doc.id)).toList();
    });
  }
}
