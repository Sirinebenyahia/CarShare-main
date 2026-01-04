class RideMessage {
  final String id;
  final String rideId;
  final String senderId;
  final String senderName;
  final String? senderImageUrl;
  final String message;
  final DateTime timestamp;

  RideMessage({
    required this.id,
    required this.rideId,
    required this.senderId,
    required this.senderName,
    this.senderImageUrl,
    required this.message,
    required this.timestamp,
  });

  factory RideMessage.fromJson(Map<String, dynamic> json) {
    return RideMessage(
      id: json['id'] as String,
      rideId: json['rideId'] as String,
      senderId: json['senderId'] as String,
      senderName: json['senderName'] as String,
      senderImageUrl: json['senderImageUrl'] as String?,
      message: json['message'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'rideId': rideId,
      'senderId': senderId,
      'senderName': senderName,
      'senderImageUrl': senderImageUrl,
      'message': message,
      'timestamp': timestamp.toIso8601String(),
    };
  }
}