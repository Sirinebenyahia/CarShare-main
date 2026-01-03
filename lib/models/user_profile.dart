import 'package:cloud_firestore/cloud_firestore.dart';

class UserProfile {
  final String email;
  final String? firstName;
  final String? lastName;
  final String? phoneNumber;
  final String? profileImageUrl;
  final String userType; // 'driver' or 'passenger'
  final DateTime createdAt;
  final DateTime? updatedAt;
  
  // Champs spécifiques au conducteur
  final String? driverLicense;
  final String? carModel;
  final String? carColor;
  final String? carPlateNumber;
  final int? yearOfExperience;
  final bool? isVerifiedDriver;
  
  // Préférences pour tous
  final bool? smokeAllowed;
  final bool? musicAllowed;
  final bool? petsAllowed;
  final bool? luggageAllowed;

  UserProfile({
    required this.email,
    this.firstName,
    this.lastName,
    this.phoneNumber,
    this.profileImageUrl,
    required this.userType,
    required this.createdAt,
    this.updatedAt,
    this.driverLicense,
    this.carModel,
    this.carColor,
    this.carPlateNumber,
    this.yearOfExperience,
    this.isVerifiedDriver,
    this.smokeAllowed,
    this.musicAllowed,
    this.petsAllowed,
    this.luggageAllowed,
  });

  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'firstName': firstName,
      'lastName': lastName,
      'phoneNumber': phoneNumber,
      'profileImageUrl': profileImageUrl,
      'userType': userType,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'driverLicense': driverLicense,
      'carModel': carModel,
      'carColor': carColor,
      'carPlateNumber': carPlateNumber,
      'yearOfExperience': yearOfExperience,
      'isVerifiedDriver': isVerifiedDriver,
      'smokeAllowed': smokeAllowed,
      'musicAllowed': musicAllowed,
      'petsAllowed': petsAllowed,
      'luggageAllowed': luggageAllowed,
    };
  }

  factory UserProfile.fromMap(Map<String, dynamic> map) {
    return UserProfile(
      email: map['email'] ?? '',
      firstName: map['firstName'],
      lastName: map['lastName'],
      phoneNumber: map['phoneNumber'],
      profileImageUrl: map['profileImageUrl'],
      userType: map['userType'] ?? 'passenger',
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      updatedAt: map['updatedAt'] != null ? (map['updatedAt'] as Timestamp).toDate() : null,
      driverLicense: map['driverLicense'],
      carModel: map['carModel'],
      carColor: map['carColor'],
      carPlateNumber: map['carPlateNumber'],
      yearOfExperience: map['yearOfExperience'],
      isVerifiedDriver: map['isVerifiedDriver'],
      smokeAllowed: map['smokeAllowed'],
      musicAllowed: map['musicAllowed'],
      petsAllowed: map['petsAllowed'],
      luggageAllowed: map['luggageAllowed'],
    );
  }

  UserProfile copyWith({
    String? firstName,
    String? lastName,
    String? phoneNumber,
    String? profileImageUrl,
    String? userType,
    String? driverLicense,
    String? carModel,
    String? carColor,
    String? carPlateNumber,
    int? yearOfExperience,
    bool? isVerifiedDriver,
    bool? smokeAllowed,
    bool? musicAllowed,
    bool? petsAllowed,
    bool? luggageAllowed,
  }) {
    return UserProfile(
      email: email,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      userType: userType ?? this.userType,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
      driverLicense: driverLicense ?? this.driverLicense,
      carModel: carModel ?? this.carModel,
      carColor: carColor ?? this.carColor,
      carPlateNumber: carPlateNumber ?? this.carPlateNumber,
      yearOfExperience: yearOfExperience ?? this.yearOfExperience,
      isVerifiedDriver: isVerifiedDriver ?? this.isVerifiedDriver,
      smokeAllowed: smokeAllowed ?? this.smokeAllowed,
      musicAllowed: musicAllowed ?? this.musicAllowed,
      petsAllowed: petsAllowed ?? this.petsAllowed,
      luggageAllowed: luggageAllowed ?? this.luggageAllowed,
    );
  }
}
