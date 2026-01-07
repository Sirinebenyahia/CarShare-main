import 'package:flutter/material.dart';

class RideRequest {
  final String id;
  final String passengerId;
  final String passengerName;
  final String passengerAvatar;
  final double passengerRating;
  final String origin;
  final String destination;
  final DateTime departureDate;
  final TimeOfDay departureTime;
  final int seatsNeeded;
  final double maxPrice;
  final String? notes;
  final RideRequestStatus status;
  final DateTime createdAt;
  final List<RideProposal> proposals;

  RideRequest({
    required this.id,
    required this.passengerId,
    required this.passengerName,
    required this.passengerAvatar,
    required this.passengerRating,
    required this.origin,
    required this.destination,
    required this.departureDate,
    required this.departureTime,
    required this.seatsNeeded,
    required this.maxPrice,
    this.notes,
    this.status = RideRequestStatus.active,
    required this.createdAt,
    this.proposals = const [],
  });

  RideRequest copyWith({
    String? id,
    String? passengerId,
    String? passengerName,
    String? passengerAvatar,
    double? passengerRating,
    String? origin,
    String? destination,
    DateTime? departureDate,
    TimeOfDay? departureTime,
    int? seatsNeeded,
    double? maxPrice,
    String? notes,
    RideRequestStatus? status,
    DateTime? createdAt,
    List<RideProposal>? proposals,
  }) {
    return RideRequest(
      id: id ?? this.id,
      passengerId: passengerId ?? this.passengerId,
      passengerName: passengerName ?? this.passengerName,
      passengerAvatar: passengerAvatar ?? this.passengerAvatar,
      passengerRating: passengerRating ?? this.passengerRating,
      origin: origin ?? this.origin,
      destination: destination ?? this.destination,
      departureDate: departureDate ?? this.departureDate,
      departureTime: departureTime ?? this.departureTime,
      seatsNeeded: seatsNeeded ?? this.seatsNeeded,
      maxPrice: maxPrice ?? this.maxPrice,
      notes: notes ?? this.notes,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      proposals: proposals ?? this.proposals,
    );
  }
}

class RideProposal {
  final String id;
  final String requestId;
  final String driverId;
  final String driverName;
  final String driverAvatar;
  final double driverRating;
  final String rideId;
  final String vehicleName;
  final double proposedPrice;
  final String? message;
  final ProposalStatus status;
  final DateTime createdAt;

  RideProposal({
    required this.id,
    required this.requestId,
    required this.driverId,
    required this.driverName,
    required this.driverAvatar,
    required this.driverRating,
    required this.rideId,
    required this.vehicleName,
    required this.proposedPrice,
    this.message,
    this.status = ProposalStatus.pending,
    required this.createdAt,
  });

  RideProposal copyWith({
    String? id,
    String? requestId,
    String? driverId,
    String? driverName,
    String? driverAvatar,
    double? driverRating,
    String? rideId,
    String? vehicleName,
    double? proposedPrice,
    String? message,
    ProposalStatus? status,
    DateTime? createdAt,
  }) {
    return RideProposal(
      id: id ?? this.id,
      requestId: requestId ?? this.requestId,
      driverId: driverId ?? this.driverId,
      driverName: driverName ?? this.driverName,
      driverAvatar: driverAvatar ?? this.driverAvatar,
      driverRating: driverRating ?? this.driverRating,
      rideId: rideId ?? this.rideId,
      vehicleName: vehicleName ?? this.vehicleName,
      proposedPrice: proposedPrice ?? this.proposedPrice,
      message: message ?? this.message,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

enum RideRequestStatus {
  active,
  accepted,
  rejected,
  completed,
  cancelled,
  matched,
  expired,
}

enum ProposalStatus {
  pending,
  accepted,
  rejected,
}
