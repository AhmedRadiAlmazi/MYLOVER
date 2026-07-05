import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';

// ─────────────────────────────────────────────────────────────────────────────
//  SecretModel
// ─────────────────────────────────────────────────────────────────────────────
class SecretModel {
  final String id;
  final String title;
  final String content;
  final DateTime createdAt;
  final String ownerId;
  final List<String> imageUrls; // Base64 data URLs ('base64:...')

  SecretModel({
    required this.id,
    required this.title,
    required this.content,
    required this.createdAt,
    required this.ownerId,
    this.imageUrls = const [],
  });

  Map<String, dynamic> toMap() {
    // Basic base64 encoding for text fields to maintain privacy in Firestore
    final encodedTitle = base64Encode(utf8.encode(title));
    final encodedContent = base64Encode(utf8.encode(content));

    return {
      'id': id,
      'title': encodedTitle,
      'content': encodedContent,
      'createdAt': createdAt.toIso8601String(),
      'ownerId': ownerId,
      'imageUrls': imageUrls, // Contains strings starting with 'base64:...'
    };
  }

  factory SecretModel.fromMap(Map<String, dynamic> map, String id) {
    String decodedTitle = '';
    String decodedContent = '';
    try {
      decodedTitle = utf8.decode(base64Decode(map['title'] ?? ''));
      decodedContent = utf8.decode(base64Decode(map['content'] ?? ''));
    } catch (_) {
      decodedTitle = map['title'] ?? 'خطأ في فك التشفير';
      decodedContent = map['content'] ?? '';
    }

    final rawUrls = map['imageUrls'];
    final List<String> urls = rawUrls is List
        ? rawUrls.map((e) => e.toString()).toList()
        : [];

    return SecretModel(
      id: id,
      title: decodedTitle,
      content: decodedContent,
      createdAt: map['createdAt'] != null
          ? DateTime.parse(map['createdAt'])
          : DateTime.now(),
      ownerId: map['ownerId'] ?? '',
      imageUrls: urls,
    );
  }

  SecretModel copyWith({
    String? id,
    String? title,
    String? content,
    DateTime? createdAt,
    String? ownerId,
    List<String>? imageUrls,
  }) {
    return SecretModel(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      createdAt: createdAt ?? this.createdAt,
      ownerId: ownerId ?? this.ownerId,
      imageUrls: imageUrls ?? this.imageUrls,
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  SecretService
// ─────────────────────────────────────────────────────────────────────────────
class SecretService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final ImagePicker _picker = ImagePicker();

  // ── Helpers ────────────────────────────────────────────────────
  String _getCoupleId(String uid1, String uid2) {
    final uids = [uid1, uid2]..sort();
    return uids.join('_');
  }

  CollectionReference<Map<String, dynamic>> _secretsCollection(
      String coupleId) {
    return _firestore
        .collection('couples')
        .doc(coupleId)
        .collection('secrets');
  }

  // ── Image Picking ───────────────────────────────────────────────
  Future<List<XFile>> pickImages({ImageSource source = ImageSource.gallery}) async {
    if (source == ImageSource.gallery) {
      final result = await _picker.pickMultiImage(imageQuality: 50, maxWidth: 800, maxHeight: 800);
      return result;
    } else {
      final result = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 50,
        maxWidth: 800,
        maxHeight: 800,
      );
      return result != null ? [result] : [];
    }
  }

  // ── Base64 Converter ────────────────────────────────────────────
  /// Converts an image file to a base64 string formatted for SmartImage
  Future<String> convertToBase64(File file) async {
    try {
      final bytes = await file.readAsBytes();
      final base64String = base64Encode(bytes);
      return 'base64:$base64String';
    } catch (e) {
      throw Exception('حدث خطأ أثناء معالجة الصورة: $e');
    }
  }

  /// Converts multiple picked files to base64 format strings
  Future<List<String>> convertMultipleToBase64(List<XFile> images) async {
    final base64List = <String>[];
    for (final xfile in images) {
      final b64 = await convertToBase64(File(xfile.path));
      base64List.add(b64);
    }
    return base64List;
  }

  // ── CRUD ────────────────────────────────────────────────────────
  Future<void> addSecret({
    required SecretModel secret,
    required String userId,
    required String partnerId,
  }) async {
    final coupleId = _getCoupleId(userId, partnerId);
    await _secretsCollection(coupleId).doc(secret.id).set(secret.toMap());
  }

  Future<void> updateSecretImages({
    required String secretId,
    required List<String> imageUrls,
    required String userId,
    required String partnerId,
  }) async {
    final coupleId = _getCoupleId(userId, partnerId);
    await _secretsCollection(coupleId)
        .doc(secretId)
        .update({'imageUrls': imageUrls});
  }

  Future<void> deleteSecret({
    required String secretId,
    required String userId,
    required String partnerId,
  }) async {
    final coupleId = _getCoupleId(userId, partnerId);
    await _secretsCollection(coupleId).doc(secretId).delete();
  }

  Stream<List<SecretModel>> getSecretsStream(
      String userId, String partnerId) {
    final coupleId = _getCoupleId(userId, partnerId);
    return _secretsCollection(coupleId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => SecretModel.fromMap(doc.data(), doc.id))
            .toList());
  }
}
