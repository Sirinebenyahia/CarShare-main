import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../services/auth_service.dart';
import '../services/user_service.dart';
import '../models/user.dart' as app;

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  final UserService _userService = UserService();

  bool _isAuthenticated = false;
  bool _isLoading = false;
  app.User? _currentUser;

  bool get isAuthenticated => _isAuthenticated;
  bool get isLoading => _isLoading;
  app.User? get currentUser => _currentUser;

  /// ======================
  /// REGISTER
  /// ======================
  Future<void> register({
    required String email,
    required String password,
    required String fullName,
    required String phoneNumber,
    required app.UserRole role,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      // 1️⃣ Firebase Auth
      UserCredential cred = await _authService.signUp(
        email: email,
        password: password,
      );

      final uid = cred.user!.uid;

      // 2️⃣ Firestore user (OBLIGATOIRE)
      final user = app.User(
        id: uid,
        email: email,
        fullName: fullName,
        phoneNumber: phoneNumber,
        role: role,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await _userService.createUser(user);

      // 3️⃣ État local
      _currentUser = user;
      _isAuthenticated = true;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// ======================
  /// LOGIN
  /// ======================
  Future<void> login({
    required String email,
    required String password,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      UserCredential cred = await _authService.signIn(
        email: email,
        password: password,
      );

      final uid = cred.user!.uid;

      // Charger depuis Firestore
      _currentUser = await _userService.getUserById(uid);

      _isAuthenticated = true;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// ======================
  /// LOGOUT
  /// ======================
  Future<void> logout() async {
    _isLoading = true;
    notifyListeners();

    try {
      await _authService.signOut();
      _currentUser = null;
      _isAuthenticated = false;
      notifyListeners();
    } catch (e) {
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// ======================
  /// FORGOT PASSWORD
  /// ======================
  Future<void> forgotPassword({required String email}) async {
    await _authService.sendPasswordResetEmail(email);
  }

  /// ======================
  /// SWITCH ROLE
  /// ======================
  void switchRole(app.UserRole newRole) {
    if (_currentUser != null) {
      _currentUser = _currentUser!.copyWith(role: newRole);
      notifyListeners();
    }
  }

  /// ======================
  /// UPDATE USER
  /// ======================
  void updateUser(app.User updatedUser) {
    _currentUser = updatedUser;
    notifyListeners();
  }
}
