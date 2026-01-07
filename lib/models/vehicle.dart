import 'package:cloud_firestore/cloud_firestore.dart';

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

  factory Vehicle.fromJson(Map<String, dynamic> json) {
    return Vehicle(
      id: json['id'] as String,
      ownerId: json['ownerId'] as String,
      brand: json['brand'] as String,
      model: json['model'] as String,
      color: json['color'] as String,
      licensePlate: json['licensePlate'] as String,
      year: json['year'] as int,
      seats: json['seats'] as int,
      imageUrl: json['imageUrl'] as String?,
      createdAt: json['createdAt'] is Timestamp 
          ? (json['createdAt'] as Timestamp).toDate()
          : DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] is Timestamp 
          ? (json['updatedAt'] as Timestamp).toDate()
          : DateTime.parse(json['updatedAt'] as String),
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

  String get displayName => '$brand $model';
  String get fullInfo => '$brand $model ($year) - $color';
}
