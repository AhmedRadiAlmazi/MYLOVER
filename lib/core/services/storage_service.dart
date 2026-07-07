import 'dart:io';
import 'dart:typed_data';
import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final storageServiceProvider = Provider<StorageService>((ref) => StorageService());

class StorageService {
  /// تحويل الملف إلى Base64 للحفظ كبيانات مباشرة في Firestore
  Future<String> uploadFile(File file, String folderName) async {
    try {
      final bytes = await file.readAsBytes();
      final base64String = base64Encode(bytes);
      return 'base64:$base64String';
    } catch (e) {
      throw Exception('حدث خطأ أثناء معالجة الملف: $e');
    }
  }

  /// تحويل البايتات إلى Base64 للحفظ كبيانات مباشرة في Firestore
  Future<String> uploadBytes(Uint8List bytes, String folderName, {String extension = 'png'}) async {
    try {
      final base64String = base64Encode(bytes);
      return 'base64:$base64String';
    } catch (e) {
      throw Exception('حدث خطأ أثناء معالجة الملف: $e');
    }
  }

  /// تحويل الصورة الشخصية إلى Base64 للحفظ كبيانات مباشرة في Firestore
  Future<String> uploadAvatar(File file, String userId) async {
    try {
      final bytes = await file.readAsBytes();
      final base64String = base64Encode(bytes);
      return 'base64:$base64String';
    } catch (e) {
      throw Exception('حدث خطأ أثناء معالجة الصورة الشخصية: $e');
    }
  }

  /// حذف ملف (لا يوجد شيء لحذفه في السيرفر بالنسبة للـ Base64)
  Future<void> deleteFileFromUrl(String fileUrl) async {
    // لا يتطلب أي إجراء لأن البيانات مخزنة في الوثيقة نفسها وتُحذف معها تلقائياً
  }
}
