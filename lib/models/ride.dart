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
  final String driverName;
  final String? driverImageUrl;
  final double driverRating;
  final String fromCity;
  final String toCity;
  final DateTime departureDate;
  final String departureTime;
  final int availableSeats;
  final int totalSeats;
  final double pricePerSeat;
  final String? vehicleId;
  final Vehicle? vehicle;
  final List<String> intermediateStops;
  final RidePreferences preferences;
  final RideStatus status;
  final DateTime createdAt;
  final DateTime updatedAt;

  Ride({
    required this.id,
    required this.driverId,
    required this.driverName,
    this.driverImageUrl,
    required this.driverRating,
    required this.fromCity,
    required this.toCity,
    required this.departureDate,
    required this.departureTime,
    required this.availableSeats,
    required this.totalSeats,
    required this.pricePerSeat,
    this.vehicleId,
    this.vehicle,
    this.intermediateStops = const [],
    required this.preferences,
    this.status = RideStatus.active,
    required this.createdAt,
    required this.updatedAt,
  });

  // ==========================
  // fromJson pour Firebase
  // ==========================
  factory Ride.fromJson(Map<String, dynamic> json) {
    return Ride(
      id: json['id'] as String,
      driverId: json['driverId'] as String,
      driverName: json['driverName'] ?? 'Conducteur',
      driverImageUrl: json['driverImageUrl'] as String?,
      driverRating: (json['driverRating'] as num?)?.toDouble() ?? 0.0,
      fromCity: json['from'] as String? ?? json['fromCity'] as String, // Compatibilité
      toCity: json['to'] as String? ?? json['toCity'] as String, // Compatibilité
      departureDate: json['departureDateTime'] != null 
          ? DateTime.parse(json['departureDateTime'] as String)
          : DateTime.parse(json['departureDate'] as String), // Compatibilité
      departureTime: json['departureTime'] as String? ?? '00:00',
      availableSeats: json['seatsAvailable'] as int? ?? json['availableSeats'] as int, // Compatibilité
      totalSeats: json['totalSeats'] as int? ?? json['seatsAvailable'] as int ?? 4, // Compatibilité
      pricePerSeat: (json['priceTnd'] as num?)?.toDouble() ?? (json['pricePerSeat'] as num?)?.toDouble() ?? 0.0, // Compatibilité
      vehicleId: json['vehicleId'] as String?,
      vehicle: json['vehicle'] != null
          ? Vehicle.fromJson(json['vehicle'] as Map<String, dynamic>)
          : null,
      intermediateStops: (json['intermediateStops'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      preferences: json['preferences'] != null
          ? RidePreferences.fromJson(json['preferences'] as Map<String, dynamic>)
          : RidePreferences(), // Valeur par défaut
      status: json['status'] != null
          ? RideStatus.values.firstWhere(
              (e) => e.toString() == 'RideStatus.${json['status']}',
              orElse: () => RideStatus.active,
            )
          : RideStatus.active,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : DateTime.now(),
    );
  }

  // ==========================
  // toJson pour Firebase
  // ==========================
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'driverId': driverId,
      'driverName': driverName,
      'driverImageUrl': driverImageUrl,
      'driverRating': driverRating,
      'from': fromCity, // Utiliser les noms de champs de Firebase
      'to': toCity, // Utiliser les noms de champs de Firebase
      'departureDateTime': departureDate.toIso8601String(), // Utiliser le nom de champ de Firebase
      'departureTime': departureTime,
      'seatsAvailable': availableSeats, // Utiliser le nom de champ de Firebase
      'totalSeats': totalSeats,
      'priceTnd': pricePerSeat, // Utiliser le nom de champ de Firebase
      'vehicleId': vehicleId,
      'vehicle': vehicle?.toJson(),
      'intermediateStops': intermediateStops,
      'preferences': preferences.toJson(),
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
    String? driverName,
    String? driverImageUrl,
    double? driverRating,
    String? fromCity,
    String? toCity,
    DateTime? departureDate,
    String? departureTime,
    int? availableSeats,
    int? totalSeats,
    double? pricePerSeat,
    String? vehicleId,
    Vehicle? vehicle,
    List<String>? intermediateStops,
    RidePreferences? preferences,
    RideStatus? status,
    DateTime? createdAt,
    DateTime? updatedAt,
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
      availableSeats: availableSeats ?? this.availableSeats,
      totalSeats: totalSeats ?? this.totalSeats,
      pricePerSeat: pricePerSeat ?? this.pricePerSeat,
      vehicleId: vehicleId ?? this.vehicleId,
      vehicle: vehicle ?? this.vehicle,
      intermediateStops: intermediateStops ?? this.intermediateStops,
      preferences: preferences ?? this.preferences,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
