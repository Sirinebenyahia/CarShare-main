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

  static DateTime _parseDate(dynamic value) {
    if (value == null) return DateTime.now();
    if (value is DateTime) return value;
    try {
      // Firestore Timestamp
      // ignore: avoid_dynamic_calls
      if (value.runtimeType.toString() == 'Timestamp') {
        // ignore: avoid_dynamic_calls
        return (value as dynamic).toDate() as DateTime;
      }
    } catch (_) {}
    if (value is String) {
      return DateTime.tryParse(value) ?? DateTime.now();
    }
    return DateTime.now();
  }

  factory Ride.fromJson(Map<String, dynamic> json) {
    return Ride(
      id: (json['id'] as String?) ?? '',
      driverId: json['driverId'] as String,
      driverName: json['driverName'] as String,
      driverImageUrl: json['driverImageUrl'] as String?,
      driverRating: (json['driverRating'] as num?)?.toDouble() ?? 0.0,
      fromCity: json['fromCity'] as String,
      toCity: json['toCity'] as String,
      departureDate: _parseDate(json['departureDate']),
      departureTime: json['departureTime'] as String,
      availableSeats: json['availableSeats'] as int,
      totalSeats: json['totalSeats'] as int,
      pricePerSeat: (json['pricePerSeat'] as num).toDouble(),
      vehicleId: json['vehicleId'] as String?,
      vehicle: json['vehicle'] != null
          ? Vehicle.fromJson(json['vehicle'] as Map<String, dynamic>)
          : null,
      intermediateStops: (json['intermediateStops'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      preferences: RidePreferences.fromJson(
          json['preferences'] as Map<String, dynamic>),
      status: RideStatus.values.firstWhere(
        (e) => e.toString() == 'RideStatus.${json['status']}',
        orElse: () => RideStatus.active,
      ),
      createdAt: _parseDate(json['createdAt']),
      updatedAt: _parseDate(json['updatedAt']),
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
      'departureTime': departureTime,
      'availableSeats': availableSeats,
      'totalSeats': totalSeats,
      'pricePerSeat': pricePerSeat,
      'vehicleId': vehicleId,
      'vehicle': vehicle?.toJson(),
      'intermediateStops': intermediateStops,
      'preferences': preferences.toJson(),
      'status': status.toString().split('.').last,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}
