import 'package:cloud_firestore/cloud_firestore.dart';
import 'vehicle.dart';
import 'package:flutter/material.dart';

enum RideStatus {
  active,
  completed,
  cancelled,
}

class RidePreferences {
  final bool smokingAllowed;
  final bool petsAllowed;
  final bool luggageAllowed;
  final bool musicAllowed;
  final bool chattingAllowed;

  RidePreferences({
    required this.smokingAllowed,
    required this.petsAllowed,
    required this.luggageAllowed,
    required this.musicAllowed,
    required this.chattingAllowed,
  });

  Map<String, dynamic> toJson() {
    return {
      'smokingAllowed': smokingAllowed,
      'petsAllowed': petsAllowed,
      'luggageAllowed': luggageAllowed,
      'musicAllowed': musicAllowed,
      'chattingAllowed': chattingAllowed,
    };
  }

  factory RidePreferences.fromJson(Map<String, dynamic> json) {
    return RidePreferences(
      smokingAllowed: json['smokingAllowed'] as bool? ?? false,
      petsAllowed: json['petsAllowed'] as bool? ?? false,
      luggageAllowed: json['luggageAllowed'] as bool? ?? false,
      musicAllowed: json['musicAllowed'] as bool? ?? false,
      chattingAllowed: json['chattingAllowed'] as bool? ?? false,
    );
  }
}

class Ride {
  final String id;
  final String driverId;
  final String driverName;
  final String driverImageUrl;
  final double driverRating;
  final String fromCity;
  final String toCity;
  final DateTime departureDate;
  final TimeOfDay departureTime;
  final double pricePerSeat;
  final int availableSeats;
  final int totalSeats;
  final String? description;
  final RidePreferences? preferences;
  final RideStatus status;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final String? vehicleId;
  final Map<String, dynamic>? vehicleInfo;

  Ride({
    required this.id,
    required this.driverId,
    required this.driverName,
    required this.driverImageUrl,
    required this.driverRating,
    required this.fromCity,
    required this.toCity,
    required this.departureDate,
    required this.departureTime,
    required this.pricePerSeat,
    required this.availableSeats,
    required this.totalSeats,
    this.description,
    this.preferences,
    this.status = RideStatus.active,
    required this.createdAt,
    this.updatedAt,
    this.vehicleId,
    this.vehicleInfo,
  });

  factory Ride.fromJson(Map<String, dynamic> json) {
    return Ride(
      id: json['id'] as String? ?? '',
      driverId: json['driverId'] as String? ?? '',
      driverName: json['driverName'] as String? ?? '',
      driverImageUrl: json['driverImageUrl'] as String? ?? '',
      driverRating: (json['driverRating'] as num?)?.toDouble() ?? 0.0,
      fromCity: json['fromCity'] as String? ?? '',
      toCity: json['toCity'] as String? ?? '',
      departureDate: json['departureDate'] is Timestamp 
          ? (json['departureDate'] as Timestamp).toDate()
          : DateTime.now(),
      departureTime: json['departureTime'] != null
          ? TimeOfDay(
              hour: json['departureTime']['hour'] as int,
              minute: json['departureTime']['minute'] as int,
            )
          : const TimeOfDay(hour: 8, minute: 0),
      pricePerSeat: (json['pricePerSeat'] as num?)?.toDouble() ?? 0.0,
      availableSeats: (json['availableSeats'] as num?)?.toInt() ?? 1,
      totalSeats: (json['totalSeats'] as num?)?.toInt() ?? 1,
      description: json['description'] as String?,
      preferences: json['preferences'] != null
          ? RidePreferences.fromJson(json['preferences'] as Map<String, dynamic>)
          : null,
      status: RideStatus.values.firstWhere(
        (e) => e.toString() == 'RideStatus.${json['status']}',
        orElse: () => RideStatus.active,
      ),
      createdAt: json['createdAt'] is Timestamp
          ? (json['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
      updatedAt: json['updatedAt'] is Timestamp
          ? (json['updatedAt'] as Timestamp).toDate()
          : null,
      vehicleId: json['vehicleId'] as String?,
      vehicleInfo: json['vehicleInfo'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'driverId': driverId,
      'driverName': driverName,
      'driverImageUrl': driverImageUrl,
      'driverRating': driverRating,
      'fromCity': fromCity,
      'toCity': toCity,
      'departureDate': departureDate.toIso8601String(),
      'departureTime': {
        'hour': departureTime.hour,
        'minute': departureTime.minute,
      },
      'pricePerSeat': pricePerSeat,
      'availableSeats': availableSeats,
      'totalSeats': totalSeats,
      'description': description,
      'preferences': preferences?.toJson(),
      'status': status.toString().split('.').last,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'vehicleId': vehicleId,
      'vehicleInfo': vehicleInfo,
    };
  }

  Ride copyWith({
    String? id,
    String? driverId,
    String? driverName,
    String? driverImageUrl,
    double? driverRating,
    String? fromCity,
    String? toCity,
    DateTime? departureDate,
    TimeOfDay? departureTime,
    double? pricePerSeat,
    int? availableSeats,
    int? totalSeats,
    String? description,
    RidePreferences? preferences,
    RideStatus? status,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? vehicleId,
    Map<String, dynamic>? vehicleInfo,
  }) {
    return Ride(
      id: id ?? this.id,
      driverId: driverId ?? this.driverId,
      driverName: driverName ?? this.driverName,
      driverImageUrl: driverImageUrl ?? this.driverImageUrl,
      driverRating: driverRating ?? this.driverRating,
      fromCity: fromCity ?? this.fromCity,
      toCity: toCity ?? this.toCity,
      departureDate: departureDate ?? this.departureDate,
      departureTime: departureTime ?? this.departureTime,
      pricePerSeat: pricePerSeat ?? this.pricePerSeat,
      availableSeats: availableSeats ?? this.availableSeats,
      totalSeats: totalSeats ?? this.totalSeats,
      description: description ?? this.description,
      preferences: preferences ?? this.preferences,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      vehicleId: vehicleId ?? this.vehicleId,
      vehicleInfo: vehicleInfo ?? this.vehicleInfo,
    );
  }
}
