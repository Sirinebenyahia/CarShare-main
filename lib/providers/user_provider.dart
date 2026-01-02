import 'package:flutter/material.dart';
import '../models/user.dart';
import '../services/user_service.dart';

class UserProvider with ChangeNotifier {
  final UserService _userService = UserService();

  User? _user;
  bool _isLoading = false;

  User? get user => _user;
  bool get isLoading => _isLoading;

  // ========================
  // SET USER (login / startup)
  // ========================
  Future<void> loadUser(String uid) async {
    _isLoading = true;
    notifyListeners();

    _user = await _userService.getUserById(uid);

    _isLoading = false;
    notifyListeners();
  }

  // ========================
  // UPDATE PROFILE
  // ========================
  Future<void> updateProfile({
    String? fullName,
    String? phoneNumber,
    String? city,
    String? bio,
    DateTime? dateOfBirth,
  }) async {
    if (_user == null) return;

    _isLoading = true;
    notifyListeners();

    final data = <String, dynamic>{};

    if (fullName != null) data['fullName'] = fullName;
    if (phoneNumber != null) data['phoneNumber'] = phoneNumber;
    if (city != null) data['city'] = city;
    if (bio != null) data['bio'] = bio;
    if (dateOfBirth != null) {
      data['dateOfBirth'] = dateOfBirth.toIso8601String();
    }

    await _userService.updateUser(_user!.id, data);

    _user = _user!.copyWith(
      fullName: fullName,
      phoneNumber: phoneNumber,
      city: city,
      bio: bio,
      dateOfBirth: dateOfBirth,
      updatedAt: DateTime.now(),
    );

    _isLoading = false;
    notifyListeners();
  }

  // ========================
  // UPDATE PROFILE IMAGE
  // ========================
  Future<void> updateProfileImage(String imageUrl) async {
    if (_user == null) return;

    _isLoading = true;
    notifyListeners();

    await _userService.updateUser(
      _user!.id,
      {'profileImageUrl': imageUrl},
    );

    _user = _user!.copyWith(
      profileImageUrl: imageUrl,
      updatedAt: DateTime.now(),
    );

    _isLoading = false;
    notifyListeners();
  }

  // ========================
  // CLEAR USER (logout)
  // ========================
  void clearUser() {
    _user = null;
    notifyListeners();
  }
}
