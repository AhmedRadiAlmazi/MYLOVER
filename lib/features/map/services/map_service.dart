import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class MapPinModel {
  final String id;
  final String title;
  final String location;
  final IconData icon;
  final double lat;
  final double lng;
  final DateTime createdAt;

  MapPinModel({
    required this.id,
    required this.title,
    required this.location,
    required this.icon,
    required this.lat,
    required this.lng,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'title': title,
        'location': location,
        'iconCodePoint': icon.codePoint,
        'iconFontFamily': icon.fontFamily,
        'lat': lat,
        'lng': lng,
        'createdAt': createdAt.toIso8601String(),
      };

  factory MapPinModel.fromMap(Map<String, dynamic> map, String id) {
    return MapPinModel(
      id: id,
      title: map['title'] ?? '',
      location: map['location'] ?? '',
      icon: map['iconCodePoint'] != null
          ? IconData(map['iconCodePoint'], fontFamily: map['iconFontFamily'])
          : Icons.location_on_rounded,
      lat: (map['lat'] ?? 0.0).toDouble(),
      lng: (map['lng'] ?? 0.0).toDouble(),
      createdAt: map['createdAt'] != null ? DateTime.parse(map['createdAt']) : DateTime.now(),
    );
  }
}

class MapService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String _getCoupleId(String uid1, String uid2) {
    final List<String> uids = [uid1, uid2];
    uids.sort();
    return uids.join('_');
  }

  CollectionReference<Map<String, dynamic>> _pinsCollection(String coupleId) {
    return _firestore.collection('couples').doc(coupleId).collection('map_pins');
  }

  Future<void> addPin({
    required MapPinModel pin,
    required String userId,
    required String partnerId,
  }) async {
    final coupleId = _getCoupleId(userId, partnerId);
    await _pinsCollection(coupleId).doc(pin.id).set(pin.toMap());
  }

  Stream<List<MapPinModel>> getPinsStream(String userId, String partnerId) {
    final coupleId = _getCoupleId(userId, partnerId);
    return _pinsCollection(coupleId)
        .orderBy('createdAt', descending: false)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => MapPinModel.fromMap(doc.data(), doc.id)).toList();
    });
  }
}
