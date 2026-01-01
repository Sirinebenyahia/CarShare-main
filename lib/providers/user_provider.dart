import 'package:flutter/material.dart';
import '../models/user.dart';

class UserProvider with ChangeNotifier {
  User? _currentUser;

  User? get currentUser => _currentUser;

  void setUser(User user) {
    _currentUser = user;
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

    notifyListeners();
  }

  Future<void> updateProfileImage(String imageUrl) async {
    if (_currentUser == null) return;

    await Future.delayed(const Duration(seconds: 1));

    _currentUser = _currentUser!.copyWith(
      profileImageUrl: imageUrl,
      updatedAt: DateTime.now(),
    );

    notifyListeners();
  }
}
