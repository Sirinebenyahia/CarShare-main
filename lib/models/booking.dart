import 'package:cloud_firestore/cloud_firestore.dart';

enum BookingStatus {
  pending,
  accepted,
  rejected,
  completed,
  cancelled,
}

class Booking {
  final String id;
  final String rideId;
  final String passengerId;
  final String passengerName;
  final String? passengerImageUrl;
  final String driverId;
  final int seatsBooked;
  final double totalPrice;
  final BookingStatus status;
  final DateTime createdAt;
  final DateTime updatedAt;

  Booking({
    required this.id,
    required this.rideId,
    required this.passengerId,
    required this.passengerName,
    this.passengerImageUrl,
    required this.driverId,
    required this.seatsBooked,
    required this.totalPrice,
    this.status = BookingStatus.pending,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Booking.fromJson(Map<String, dynamic> json) {
    DateTime _parseDate(dynamic v) {
      if (v == null) return DateTime.now();
      if (v is Timestamp) return v.toDate();
      if (v is DateTime) return v;
      return DateTime.tryParse(v.toString()) ?? DateTime.now();
    }

    return Booking(
      id: json['id'] as String,
      rideId: json['rideId'] as String,
      passengerId: json['passengerId'] as String,
      passengerName: json['passengerName'] as String,
      passengerImageUrl: json['passengerImageUrl'] as String?,
      driverId: json['driverId'] as String,
      seatsBooked: json['seatsBooked'] as int,
      totalPrice: (json['totalPrice'] as num).toDouble(),
      status: BookingStatus.values.firstWhere(
        (e) => e.toString() == 'BookingStatus.${json['status']}',
        orElse: () => BookingStatus.pending,
      ),
      createdAt: _parseDate(json['createdAt']),
      updatedAt: _parseDate(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'rideId': rideId,
      'passengerId': passengerId,
      'passengerName': passengerName,
      'passengerImageUrl': passengerImageUrl,
      'driverId': driverId,
      'seatsBooked': seatsBooked,
      'totalPrice': totalPrice,
      'status': status.toString().split('.').last,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }
}
