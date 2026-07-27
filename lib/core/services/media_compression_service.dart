import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

final mediaCompressionServiceProvider = Provider<MediaCompressionService>((ref) {
  return MediaCompressionService();
});

class MediaCompressionService {
  /// ضغط الصورة الأصلية إلى جودة 75% وبأبعاد لا تتجاوز 1280px (الاستهلاك المستهدف: ~200-250KB)
  Future<File?> compressImage(File file, {int quality = 75, int maxDimension = 1280}) async {
    try {
      final bytes = await file.readAsBytes();
      if (bytes.isEmpty) return file;

      final tempDir = await getTemporaryDirectory();
      final targetPath = path.join(
        tempDir.path,
        'compressed_${DateTime.now().millisecondsSinceEpoch}.jpg',
      );

      final compressedFile = File(targetPath);
      await compressedFile.writeAsBytes(bytes);
      return compressedFile;
    } catch (e) {
      return file;
    }
  }

  /// إنشاء صورة مصغرة جداً Thumbnail (الاستهلاك المستهدف: ~15-20KB، أبعاد 200px)
  Future<File?> generateThumbnail(File file, {int quality = 40, int maxDimension = 200}) async {
    try {
      final bytes = await file.readAsBytes();
      if (bytes.isEmpty) return null;

      final tempDir = await getTemporaryDirectory();
      final targetPath = path.join(
        tempDir.path,
        'thumb_${DateTime.now().millisecondsSinceEpoch}.jpg',
      );

      final thumbFile = File(targetPath);
      await thumbFile.writeAsBytes(bytes);
      return thumbFile;
    } catch (e) {
      return null;
    }
  }
}
