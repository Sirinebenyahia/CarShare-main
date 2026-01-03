enum TransactionType {
  recharge,
  payment,
  refund,
  earning,
}

class Transaction {
  final String id;
  final String userId;
  final TransactionType type;
  final double amount;
  final String description;
  final String? relatedId;
  final DateTime createdAt;

  Transaction({
    required this.id,
    required this.userId,
    required this.type,
    required this.amount,
    required this.description,
    this.relatedId,
    required this.createdAt,
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

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      id: (json['id'] as String?) ?? '',
      userId: json['userId'] as String,
      type: TransactionType.values.firstWhere(
        (e) => e.toString() == 'TransactionType.${json['type']}',
        orElse: () => TransactionType.payment,
      ),
      amount: (json['amount'] as num).toDouble(),
      description: json['description'] as String,
      relatedId: json['relatedId'] as String?,
      createdAt: _parseDate(json['createdAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'type': type.toString().split('.').last,
      'amount': amount,
      'description': description,
      'relatedId': relatedId,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
