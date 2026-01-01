import 'dart:typed_data';

import 'package:firebase_storage/firebase_storage.dart';

class StorageService {
  StorageService({FirebaseStorage? storage}) : _storage = storage ?? FirebaseStorage.instance;

  final FirebaseStorage _storage;

  Future<String> uploadUserCin({
    required String uid,
    required String fileName,
    required Uint8List bytes,
    required String contentType,
  }) async {
    final ref = _storage.ref('users/$uid/cin/$fileName');
    final metadata = SettableMetadata(contentType: contentType);
    await ref.putData(bytes, metadata);
    return ref.getDownloadURL();
  }
}
