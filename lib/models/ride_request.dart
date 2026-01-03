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

  factory RideRequest.fromJson(Map<String, dynamic> json) {
    return RideRequest(
      id: (json['id'] as String?) ?? '',
      passengerId: json['passengerId'] as String,
      passengerName: json['passengerName'] as String,
      passengerAvatar: json['passengerAvatar'] as String,
      passengerRating: (json['passengerRating'] as num?)?.toDouble() ?? 0.0,
      origin: json['origin'] as String,
      destination: json['destination'] as String,
      departureDate: _parseDate(json['departureDate']),
      departureTime: TimeOfDay(
        hour: json['departureTime']?['hour'] ?? 0,
        minute: json['departureTime']?['minute'] ?? 0,
      ),
      seatsNeeded: json['seatsNeeded'] as int,
      maxPrice: (json['maxPrice'] as num?)?.toDouble() ?? 0.0,
      notes: json['notes'] as String?,
      status: RideRequestStatus.values.firstWhere(
        (e) => e.toString() == 'RideRequestStatus.${json['status']}',
        orElse: () => RideRequestStatus.active,
      ),
      createdAt: _parseDate(json['createdAt']),
      proposals: (json['proposals'] as List<dynamic>?)
          ?.map((p) => RideProposal.fromJson(Map<String, dynamic>.from(p)))
          .toList() ??
          [],
    );
  }

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

  factory RideProposal.fromJson(Map<String, dynamic> json) {
    return RideProposal(
      id: (json['id'] as String?) ?? '',
      requestId: json['requestId'] as String,
      driverId: json['driverId'] as String,
      driverName: json['driverName'] as String,
      driverAvatar: json['driverAvatar'] as String,
      driverRating: (json['driverRating'] as num?)?.toDouble() ?? 0.0,
      rideId: json['rideId'] as String,
      vehicleName: json['vehicleName'] as String,
      proposedPrice: (json['proposedPrice'] as num?)?.toDouble() ?? 0.0,
      message: json['message'] as String?,
      status: ProposalStatus.values.firstWhere(
        (e) => e.toString() == 'ProposalStatus.${json['status']}',
        orElse: () => ProposalStatus.pending,
      ),
      createdAt: RideRequest._parseDate(json['createdAt']),
    );
  }

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
  matched,
  cancelled,
  expired,
}

enum ProposalStatus {
  pending,
  accepted,
  rejected,
}

class TimeOfDay {
  final int hour;
  final int minute;

  TimeOfDay({required this.hour, required this.minute});

  String format24Hour() {
    return '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
  }

  @override
  String toString() => format24Hour();
}
