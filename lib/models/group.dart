import 'package:cloud_firestore/cloud_firestore.dart';

enum GroupType {
  public_group,
  private_group,
}

class Group {
  final String id;
  final String name;
  final String description;
  final String? imageUrl;
  final String creatorId;
  final GroupType type;
  final List<String> memberIds;
  final int memberCount;
  final DateTime createdAt;
  final DateTime updatedAt;

  Group({
    required this.id,
    required this.name,
    required this.description,
    this.imageUrl,
    required this.creatorId,
    required this.type,
    required this.memberIds,
    required this.memberCount,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Group.fromJson(Map<String, dynamic> json) {
    DateTime _parseDate(dynamic value) {
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

    return Group(
      id: (json['id'] as String?) ?? '',
      name: json['name'] as String,
      description: json['description'] as String,
      imageUrl: json['imageUrl'] as String?,
      creatorId: json['creatorId'] as String,
      type: GroupType.values.firstWhere(
        (e) => e.toString() == 'GroupType.${json['type']}',
        orElse: () => GroupType.public_group,
      ),
      memberIds: (json['memberIds'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
          [],
      memberCount: json['memberCount'] as int,
      createdAt: _parseDate(json['createdAt']),
      updatedAt: _parseDate(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'imageUrl': imageUrl,
      'creatorId': creatorId,
      'type': type.toString().split('.').last,
      'memberIds': memberIds,
      'memberCount': memberCount,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}

class ChatMessage {
  final String id;
  final String groupId;
  final String senderId;
  final String senderName;
  final String? senderImageUrl;
  final String message;
  final DateTime timestamp;

  ChatMessage({
    required this.id,
    required this.groupId,
    required this.senderId,
    required this.senderName,
    this.senderImageUrl,
    required this.message,
    required this.timestamp,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    DateTime _parseDate(dynamic v) {
      if (v == null) return DateTime.now();
      if (v is Timestamp) return v.toDate();
      if (v is DateTime) return v;
      return DateTime.tryParse(v.toString()) ?? DateTime.now();
    }

    return ChatMessage(
      id: (json['id'] as String?) ?? '',
      groupId: json['groupId'] as String,
      senderId: json['senderId'] as String,
      senderName: json['senderName'] as String,
      senderImageUrl: json['senderImageUrl'] as String?,
      message: json['message'] as String,
      timestamp: _parseDate(json['timestamp']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'groupId': groupId,
      'senderId': senderId,
      'senderName': senderName,
      'senderImageUrl': senderImageUrl,
      'message': message,
      'timestamp': Timestamp.fromDate(timestamp),
    };
  }
}
