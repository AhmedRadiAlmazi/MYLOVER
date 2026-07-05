import 'dart:io';
import 'dart:convert';
import 'dart:typed_data';

class StorageService {
  /// رفع ملف (تحويله إلى Base64 بدلاً من Firebase Storage)
  Future<String> uploadFile(File file, String folderName) async {
    try {
      final bytes = await file.readAsBytes();
      final base64String = base64Encode(bytes);
      return 'base64:$base64String';
    } catch (e) {
      throw Exception('حدث خطأ أثناء معالجة الملف: $e');
    }
  }

  /// رفع ملف من الذاكرة
  Future<String> uploadBytes(Uint8List bytes, String folderName, {String extension = 'png'}) async {
    try {
      final base64String = base64Encode(bytes);
      return 'base64:$base64String';
    } catch (e) {
      throw Exception('حدث خطأ أثناء معالجة الصورة: $e');
    }
  }

  /// رفع صورة شخصية
  Future<String> uploadAvatar(File file, String userId) async {
    return uploadFile(file, 'avatars');
  }

  /// حذف ملف
  Future<void> deleteFileFromUrl(String fileUrl) async {
    // لا شيء لنحذفه لأنها نصوص محفوظة في Firestore
  }
}
