import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../../core/models/app_models.dart';


class CalendarService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String _getCoupleId(String uid1, String uid2) {
    final List<String> uids = [uid1, uid2];
    uids.sort();
    return uids.join('_');
  }

  CollectionReference<Map<String, dynamic>> _eventsCollection(String coupleId) {
    return _firestore.collection('couples').doc(coupleId).collection('events');
  }

  // إضافة مناسبة جديدة
  Future<void> addEvent({
    required EventModel event,
    required String userId,
    required String partnerId,
  }) async {
    final coupleId = _getCoupleId(userId, partnerId);
    
    final eventData = {
      'id': event.id,
      'title': event.title,
      'date': event.date.toIso8601String(),
      'type': event.type,
      'iconCodePoint': event.icon.codePoint,
      'iconFontFamily': event.icon.fontFamily,
      'note': event.note,
      'isRecurring': event.isRecurring,
      'createdAt': FieldValue.serverTimestamp(),
    };

    await _eventsCollection(coupleId).doc(event.id).set(eventData);
  }

  // جلب المناسبات كبث حي
  Stream<List<EventModel>> getEventsStream(String userId, String partnerId) {
    final coupleId = _getCoupleId(userId, partnerId);
    return _eventsCollection(coupleId).snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return EventModel(
          id: data['id'] ?? '',
          title: data['title'] ?? '',
          date: data['date'] != null ? DateTime.parse(data['date']) : DateTime.now(),
          type: data['type'] ?? 'special',
          icon: data['iconCodePoint'] != null 
              ? IconData(data['iconCodePoint'], fontFamily: data['iconFontFamily']) 
              : Icons.event,
          note: data['note'],
          isRecurring: data['isRecurring'] ?? false,
        );
      }).toList();
    });
  }
}
