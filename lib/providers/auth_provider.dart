import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import '../models/user.dart';

class AuthProvider with ChangeNotifier {
  User? _currentUser;
  bool _isLoading = false;
  bool _isAuthenticated = false;

  final fb.FirebaseAuth _auth = fb.FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  StreamSubscription<fb.User?>? _authSub;

  User? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _isAuthenticated;
  UserRole? get userRole => _currentUser?.role;

  AuthProvider() {
    _authSub = _auth.authStateChanges().listen((fbUser) async {
      if (fbUser == null) {
        _currentUser = null;
        _isAuthenticated = false;
        notifyListeners();
        return;
      }

      _isLoading = true;
      notifyListeners();
      try {
        _currentUser = await _loadOrCreateUserDoc(fbUser);
        _isAuthenticated = true;
      } catch (_) {
        // best-effort: keep user logged in even if profile doc read fails
        _currentUser = User(
          id: fbUser.uid,
          email: fbUser.email ?? '',
          fullName: fbUser.displayName ?? 'Utilisateur',
          role: UserRole.passenger,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        _isAuthenticated = true;
      } finally {
        _isLoading = false;
        notifyListeners();
      }
    });
  }

   @override
   void dispose() {
     _authSub?.cancel();
     super.dispose();
   }

  Future<void> login({required String email, required String password}) async {
    _isLoading = true;
    notifyListeners();

    try {
      final cred = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      final fbUser = cred.user;
      if (fbUser == null) {
        throw Exception('Connexion échouée');
      }
      _currentUser = await _loadOrCreateUserDoc(fbUser);
      _isAuthenticated = true;
    } catch (e) {
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> register({
    required String email,
    required String password,
    required String fullName,
    required String phoneNumber,
    required UserRole role,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      final cred = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      final fbUser = cred.user;
      if (fbUser == null) {
        throw Exception('Inscription échouée');
      }

      await fbUser.updateDisplayName(fullName);

      final now = DateTime.now();
      final user = User(
        id: fbUser.uid,
        email: email,
        fullName: fullName,
        phoneNumber: phoneNumber,
        role: role,
        isVerified: false,
        rating: 0.0,
        totalRides: 0,
        createdAt: now,
        updatedAt: now,
      );

      await _firestore.collection('users').doc(fbUser.uid).set(user.toJson(), SetOptions(merge: true));
      _currentUser = user;
      _isAuthenticated = true;
    } catch (e) {
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    _isLoading = true;
    notifyListeners();

    try {
      await _auth.signOut();
      _currentUser = null;
      _isAuthenticated = false;
    } catch (e) {
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> forgotPassword({required String email}) async {
    await _auth.sendPasswordResetEmail(email: email);
  }

  Future<void> deleteAccount() async {
    _isLoading = true;
    notifyListeners();

    try {
      final fbUser = _auth.currentUser;
      final user = _currentUser;
      if (fbUser == null || user == null) {
        throw Exception('Utilisateur non connecté');
      }

      // Delete Storage files (best-effort)
      final urls = <String?>[
        user.profileImageUrl,
        user.idDocumentUrl,
        user.licenseDocumentUrl,
      ];
      for (final url in urls) {
        if (url == null || url.isEmpty) continue;
        try {
          await FirebaseStorage.instance.refFromURL(url).delete();
        } catch (_) {
          // ignore
        }
      }

      // Delete Firestore user doc + subcollections (best-effort)
      try {
        final userRef = _firestore.collection('users').doc(user.id);
        // fcmTokens subcollection
        try {
          final tokensSnap = await userRef.collection('fcmTokens').get();
          for (final d in tokensSnap.docs) {
            try {
              await d.reference.delete();
            } catch (_) {}
          }
        } catch (_) {}

        await userRef.delete();
      } catch (_) {
        // ignore
      }

      // Delete Firebase Auth user (may require recent login)
      await fbUser.delete();

      _currentUser = null;
      _isAuthenticated = false;
    } catch (e) {
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void updateUser(User updatedUser) {
    _currentUser = updatedUser;
    // Best-effort persist
    try {
      if (updatedUser.id.isNotEmpty) {
        _firestore.collection('users').doc(updatedUser.id).set(updatedUser.toJson(), SetOptions(merge: true));
      }
    } catch (_) {
      // ignore
    }
    notifyListeners();
  }

  void switchRole(UserRole newRole) {
    if (_currentUser != null) {
      _currentUser = _currentUser!.copyWith(role: newRole);
      try {
        _firestore.collection('users').doc(_currentUser!.id).set(
          {'role': newRole.toString().split('.').last, 'updatedAt': DateTime.now().toIso8601String()},
          SetOptions(merge: true),
        );
      } catch (_) {
        // ignore
      }
      notifyListeners();
    }
  }

   Future<User> _loadOrCreateUserDoc(fb.User fbUser) async {
     final ref = _firestore.collection('users').doc(fbUser.uid);
     final snap = await ref.get();

     if (snap.exists) {
       final data = snap.data();
       if (data != null) {
         // Ensure required keys exist
         data['id'] ??= fbUser.uid;
         data['email'] ??= fbUser.email ?? '';
         data['fullName'] ??= fbUser.displayName ?? 'Utilisateur';
         data['createdAt'] ??= DateTime.now().toIso8601String();
         data['updatedAt'] ??= DateTime.now().toIso8601String();
         return User.fromJson(Map<String, dynamic>.from(data));
       }
     }

     final now = DateTime.now();
     final user = User(
       id: fbUser.uid,
       email: fbUser.email ?? '',
       fullName: fbUser.displayName ?? 'Utilisateur',
       role: UserRole.passenger,
       createdAt: now,
       updatedAt: now,
     );
     await ref.set(user.toJson(), SetOptions(merge: true));
     return user;
   }
}
