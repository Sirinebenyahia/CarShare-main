import 'package:flutter/material.dart';
import '../models/user.dart';

class AuthProvider with ChangeNotifier {
  User? _currentUser;
  bool _isLoading = false;
  bool _isAuthenticated = false;

  User? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _isAuthenticated;
  UserRole? get userRole => _currentUser?.role;

  // Mock login - remplacer par vraie API
  Future<void> login({required String email, required String password}) async {
    _isLoading = true;
    notifyListeners();

    try {
      // Simuler un délai réseau
      await Future.delayed(const Duration(seconds: 1));

      // Mock user
      _currentUser = User(
        id: '1',
        email: email,
        fullName: 'Utilisateur Test',
        phoneNumber: '+216 12 345 678',
        role: UserRole.driver,
        city: 'Tunis',
        isVerified: true,
        rating: 4.5,
        totalRides: 25,
        createdAt: DateTime.now().subtract(const Duration(days: 180)),
        updatedAt: DateTime.now(),
      );
      
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
      await Future.delayed(const Duration(seconds: 1));

      _currentUser = User(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        email: email,
        fullName: fullName,
        phoneNumber: phoneNumber,
        role: role,
        isVerified: false,
        rating: 0.0,
        totalRides: 0,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      
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
      await Future.delayed(const Duration(milliseconds: 500));
      
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
    await Future.delayed(const Duration(seconds: 1));
    // Mock: envoi de l'email de réinitialisation
  }

  void updateUser(User updatedUser) {
    _currentUser = updatedUser;
    notifyListeners();
  }

  void switchRole(UserRole newRole) {
    if (_currentUser != null) {
      _currentUser = _currentUser!.copyWith(role: newRole);
      notifyListeners();
    }
  }
}
