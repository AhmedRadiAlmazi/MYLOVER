import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:uuid/uuid.dart';
import 'package:path/path.dart' as p;

class SharedBookStorageService {
  final FirebaseStorage _storage;

  SharedBookStorageService({FirebaseStorage? storage})
      : _storage = storage ?? FirebaseStorage.instance;

  Future<String> uploadMedia(File file, String folder) async {
    try {
      final extension = p.extension(file.path);
      final fileName = '${const Uuid().v4()}$extension';
      final ref = _storage.ref().child('shared_book/$folder/$fileName');
      
      final uploadTask = ref.putFile(file);
      final snapshot = await uploadTask;
      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      throw Exception('Failed to upload media: $e');
    }
  }

  Future<List<String>> uploadMultipleMedia(List<File> files, String folder) async {
    List<String> downloadUrls = [];
    for (var file in files) {
      final url = await uploadMedia(file, folder);
      downloadUrls.add(url);
    }
    return downloadUrls;
  }
}
