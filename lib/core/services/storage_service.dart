import 'dart:io';
import 'dart:typed_data';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final storageServiceProvider = Provider<StorageService>((ref) => StorageService());

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  /// رفع ملف إلى Firebase Storage وإعادة رابط التحميل (Download URL)
  Future<String> uploadFile(File file, String folderName) async {
    try {
      final fileName = '${DateTime.now().millisecondsSinceEpoch}_${file.path.split('/').last}';
      final ref = _storage.ref().child(folderName).child(fileName);
      final uploadTask = await ref.putFile(file);
      return await uploadTask.ref.getDownloadURL();
    } catch (e) {
      throw Exception('حدث خطأ أثناء رفع الملف: $e');
    }
  }

  /// رفع بايتات إلى Firebase Storage وإعادة رابط التحميل (Download URL)
  Future<String> uploadBytes(Uint8List bytes, String folderName, {String extension = 'png'}) async {
    try {
      final fileName = '${DateTime.now().millisecondsSinceEpoch}.$extension';
      final ref = _storage.ref().child(folderName).child(fileName);
      final uploadTask = await ref.putData(bytes, SettableMetadata(contentType: 'image/$extension'));
      return await uploadTask.ref.getDownloadURL();
    } catch (e) {
      throw Exception('حدث خطأ أثناء رفع البيانات: $e');
    }
  }

  /// رفع الصورة الشخصية إلى Firebase Storage
  Future<String> uploadAvatar(File file, String userId) async {
    try {
      final ref = _storage.ref().child('avatars').child('$userId.jpg');
      final uploadTask = await ref.putFile(file);
      return await uploadTask.ref.getDownloadURL();
    } catch (e) {
      throw Exception('حدث خطأ أثناء رفع الصورة الشخصية: $e');
    }
  }

  /// حذف ملف عبر الرابط الخاص به من Firebase Storage
  Future<void> deleteFileFromUrl(String fileUrl) async {
    try {
      if (fileUrl.startsWith('http')) {
        final ref = _storage.refFromURL(fileUrl);
        await ref.delete();
      }
    } catch (e) {
      // Swallowed safely if file doesn't exist on server
    }
  }
}

