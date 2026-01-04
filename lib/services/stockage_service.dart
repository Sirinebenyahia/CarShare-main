import 'dart:typed_data';
import 'package:firebase_storage/firebase_storage.dart';

class StorageService {
  StorageService({FirebaseStorage? storage}) : _storage = storage ?? FirebaseStorage.instance;

  final FirebaseStorage _storage;

  // =========================
  // Upload CIN utilisateur
  // =========================
  Future<String> uploadUserCin({
    required String uid,
    required String fileName,
    required Uint8List bytes,
    required String contentType,
  }) async {
    try {
      final ref = _storage.ref('users/$uid/cin/$fileName');
      final metadata = SettableMetadata(contentType: contentType);
      await ref.putData(bytes, metadata);
      return await ref.getDownloadURL();
    } catch (e) {
      throw Exception('Erreur upload CIN: $e');
    }
  }

  // =========================
  // Upload image de profil utilisateur
  // =========================
  Future<String> uploadUserProfileImage({
    required String uid,
    required String fileName,
    required Uint8List bytes,
    required String contentType,
  }) async {
    try {
      final ref = _storage.ref('users/$uid/profile/$fileName');
      final metadata = SettableMetadata(contentType: contentType);
      await ref.putData(bytes, metadata);
      return await ref.getDownloadURL();
    } catch (e) {
      throw Exception('Erreur upload image de profil: $e');
    }
  }

  // =========================
  // Upload image véhicule
  // =========================
  Future<String> uploadVehicleImage({
    required String uid,
    required String vehicleId,
    required String fileName,
    required Uint8List bytes,
    required String contentType,
  }) async {
    try {
      final ref = _storage.ref('users/$uid/vehicles/$vehicleId/$fileName');
      final metadata = SettableMetadata(contentType: contentType);
      await ref.putData(bytes, metadata);
      return await ref.getDownloadURL();
    } catch (e) {
      throw Exception('Erreur upload image véhicule: $e');
    }
  }

  // =========================
  // Supprimer un fichier
  // =========================
  Future<void> deleteFile(String path) async {
    try {
      final ref = _storage.ref(path);
      await ref.delete();
    } catch (e) {
      throw Exception('Erreur suppression fichier: $e');
    }
  }
}
