import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import '../models/user.dart';

class UserProvider with ChangeNotifier {
  User? _currentUser;
  bool _isUploading = false;

  User? get currentUser => _currentUser;
  bool get isUploading => _isUploading;

  void setUser(User user) {
    _currentUser = user;
    notifyListeners();
  }

  void clearUser() {
    _currentUser = null;
    notifyListeners();
  }

  Future<void> updateProfile({
    String? fullName,
    String? phoneNumber,
    String? city,
    String? bio,
    DateTime? dateOfBirth,
  }) async {
    if (_currentUser == null) return;

    await Future.delayed(const Duration(seconds: 1));

    _currentUser = _currentUser!.copyWith(
      fullName: fullName,
      phoneNumber: phoneNumber,
      city: city,
      bio: bio,
      dateOfBirth: dateOfBirth,
      updatedAt: DateTime.now(),
    );

    // Persist to Firestore
    try {
      await FirebaseFirestore.instance.collection('users').doc(_currentUser!.id).set(_currentUser!.toJson(), SetOptions(merge: true));
    } catch (e) {
      // ignore errors for now
    }

    notifyListeners();
  }

  Future<void> updateProfileImage(String imageUrl) async {
    if (_currentUser == null) return;

    await Future.delayed(const Duration(seconds: 1));

    _currentUser = _currentUser!.copyWith(
      profileImageUrl: imageUrl,
      updatedAt: DateTime.now(),
    );

    // Persist
    try {
      await FirebaseFirestore.instance.collection('users').doc(_currentUser!.id).set({'profileImageUrl': imageUrl}, SetOptions(merge: true));
    } catch (e) {}

    notifyListeners();
  }

  Future<void> deleteProfileImage() async {
    if (_currentUser == null) return;

    // Attempt to delete from Firebase Storage if url exists
    if (_currentUser!.profileImageUrl != null && _currentUser!.profileImageUrl!.isNotEmpty) {
      try {
        final ref = FirebaseStorage.instance.refFromURL(_currentUser!.profileImageUrl!);
        await ref.delete();
      } catch (e) {
        // ignore
      }
    }

    _currentUser = _currentUser!.copyWith(
      profileImageUrl: null,
      updatedAt: DateTime.now(),
    );

    await FirebaseFirestore.instance.collection('users').doc(_currentUser!.id).set({'profileImageUrl': null}, SetOptions(merge: true));

    notifyListeners();
  }

  Future<void> uploadProfileImage(File file) async {
    if (_currentUser == null) return;

    _isUploading = true;
    notifyListeners();

    try {
      final storageRef = FirebaseStorage.instance.ref().child('users').child(_currentUser!.id).child('profile_${DateTime.now().millisecondsSinceEpoch}.jpg');
      final uploadTask = storageRef.putFile(file);
      await uploadTask;
      final url = await storageRef.getDownloadURL();

      _currentUser = _currentUser!.copyWith(profileImageUrl: url, updatedAt: DateTime.now());
      await FirebaseFirestore.instance.collection('users').doc(_currentUser!.id).set({'profileImageUrl': url}, SetOptions(merge: true));
    } finally {
      _isUploading = false;
      notifyListeners();
    }
  }

  Future<void> uploadIdDocument(File file) async {
    if (_currentUser == null) return;
    _isUploading = true;
    notifyListeners();

    try {
      final storageRef = FirebaseStorage.instance.ref().child('users').child(_currentUser!.id).child('documents').child('id_${DateTime.now().millisecondsSinceEpoch}.jpg');
      await storageRef.putFile(file);
      final url = await storageRef.getDownloadURL();

      _currentUser = _currentUser!.copyWith(idDocumentUrl: url, updatedAt: DateTime.now());
      await FirebaseFirestore.instance.collection('users').doc(_currentUser!.id).set({'idDocumentUrl': url}, SetOptions(merge: true));
    } finally {
      _isUploading = false;
      notifyListeners();
    }
  }

  Future<void> uploadLicenseDocument(File file) async {
    if (_currentUser == null) return;
    _isUploading = true;
    notifyListeners();

    try {
      final storageRef = FirebaseStorage.instance.ref().child('users').child(_currentUser!.id).child('documents').child('license_${DateTime.now().millisecondsSinceEpoch}.jpg');
      await storageRef.putFile(file);
      final url = await storageRef.getDownloadURL();

      _currentUser = _currentUser!.copyWith(licenseDocumentUrl: url, updatedAt: DateTime.now());
      await FirebaseFirestore.instance.collection('users').doc(_currentUser!.id).set({'licenseDocumentUrl': url}, SetOptions(merge: true));
    } finally {
      _isUploading = false;
      notifyListeners();
    }
  }


}
