import 'vehicle.dart';

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
    this.smokingAllowed = false,
    this.petsAllowed = false,
    this.luggageAllowed = true,
    this.musicAllowed = true,
    this.chattingAllowed = true,
  });

  factory RidePreferences.fromJson(Map<String, dynamic> json) {
    return RidePreferences(
      smokingAllowed: json['smokingAllowed'] as bool? ?? false,
      petsAllowed: json['petsAllowed'] as bool? ?? false,
      luggageAllowed: json['luggageAllowed'] as bool? ?? true,
      musicAllowed: json['musicAllowed'] as bool? ?? true,
      chattingAllowed: json['chattingAllowed'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'smokingAllowed': smokingAllowed,
      'petsAllowed': petsAllowed,
      'luggageAllowed': luggageAllowed,
      'musicAllowed': musicAllowed,
      'chattingAllowed': chattingAllowed,
    };
  }
}

class Ride {
  final String id;
  final String driverId;
  final String fromCity;
  final String toCity;
  final DateTime departureDate;
  final double pricePerSeat;
  final int availableSeats;
  final String? description;
  final RidePreferences? preferences;
  final RideStatus status;
  final DateTime createdAt;
  final DateTime updatedAt;
  final Map<String, dynamic>? vehicleInfo;

  Ride({
    required this.id,
    required this.driverId,
    required this.fromCity,
    required this.toCity,
    required this.departureDate,
    required this.pricePerSeat,
    required this.availableSeats,
    this.description,
    this.preferences,
    this.status = RideStatus.active,
    required this.createdAt,
    required this.updatedAt,
    this.vehicleInfo,
  });

  factory Ride.fromJson(Map<String, dynamic> json) {
    return Ride(
      id: json['id'] as String,
      driverId: json['driverId'] as String,
      fromCity: json['fromCity'] as String,
      toCity: json['toCity'] as String,
      departureDate: DateTime.parse(json['departureDate'] as String),
      pricePerSeat: (json['pricePerSeat'] as num).toDouble(),
      availableSeats: json['availableSeats'] as int,
      description: json['description'] as String?,
      preferences: json['preferences'] != null 
          ? RidePreferences.fromJson(json['preferences'] as Map<String, dynamic>)
          : null,
      status: RideStatus.values.firstWhere(
        (e) => e.toString() == 'RideStatus.${json['status']}',
        orElse: () => RideStatus.active,
      ),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      vehicleInfo: json['vehicleInfo'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'driverId': driverId,
      'fromCity': fromCity,
      'toCity': toCity,
      'departureDate': departureDate.toIso8601String(),
      'pricePerSeat': pricePerSeat,
      'availableSeats': availableSeats,
      'description': description,
      'preferences': preferences?.toJson(),
      'status': status.toString().split('.').last,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  // ==========================
  // copyWith
  // ==========================
  Ride copyWith({
    String? id,
    String? driverId,
    String? fromCity,
    String? toCity,
    DateTime? departureDate,
    int? availableSeats,
    double? pricePerSeat,
    String? description,
    Map<String, dynamic>? vehicleInfo,
    RidePreferences? preferences,
    RideStatus? status,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Ride(
      id: id ?? this.id,
      driverId: driverId ?? this.driverId,
      fromCity: fromCity ?? this.fromCity,
      toCity: toCity ?? this.toCity,
      departureDate: departureDate ?? this.departureDate,
      availableSeats: availableSeats ?? this.availableSeats,
      pricePerSeat: pricePerSeat ?? this.pricePerSeat,
      description: description ?? this.description,
      vehicleInfo: vehicleInfo ?? this.vehicleInfo,
      preferences: preferences ?? this.preferences,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
