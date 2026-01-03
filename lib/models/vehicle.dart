class Vehicle {
  final String id;
  final String ownerId;
  final String brand;
  final String model;
  final String color;
  final String licensePlate;
  final int year;
  final int seats;
  final String? imageUrl;
  final DateTime createdAt;
  final DateTime updatedAt;

  Vehicle({
    required this.id,
    required this.ownerId,
    required this.brand,
    required this.model,
    required this.color,
    required this.licensePlate,
    required this.year,
    required this.seats,
    this.imageUrl,
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

  factory Vehicle.fromJson(Map<String, dynamic> json) {
    return Vehicle(
      id: (json['id'] as String?) ?? '',
      ownerId: json['ownerId'] as String,
      brand: json['brand'] as String,
      model: json['model'] as String,
      color: json['color'] as String,
      licensePlate: json['licensePlate'] as String,
      year: json['year'] as int,
      seats: json['seats'] as int,
      imageUrl: json['imageUrl'] as String?,
      createdAt: _parseDate(json['createdAt']),
      updatedAt: _parseDate(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'ownerId': ownerId,
      'brand': brand,
      'model': model,
      'color': color,
      'licensePlate': licensePlate,
      'year': year,
      'seats': seats,
      'imageUrl': imageUrl,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  Vehicle copyWith({
    String? id,
    String? ownerId,
    String? brand,
    String? model,
    String? color,
    String? licensePlate,
    int? year,
    int? seats,
    String? imageUrl,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Vehicle(
      id: id ?? this.id,
      ownerId: ownerId ?? this.ownerId,
      brand: brand ?? this.brand,
      model: model ?? this.model,
      color: color ?? this.color,
      licensePlate: licensePlate ?? this.licensePlate,
      year: year ?? this.year,
      seats: seats ?? this.seats,
      imageUrl: imageUrl ?? this.imageUrl,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
