import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/vehicle.dart';

class VehicleProvider with ChangeNotifier {
  List<Vehicle> _myVehicles = [];
  bool _isLoading = false;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  List<Vehicle> get myVehicles => _myVehicles;
  bool get isLoading => _isLoading;

  Vehicle _vehicleFromDoc(QueryDocumentSnapshot<Map<String, dynamic>> d) {
    final data = Map<String, dynamic>.from(d.data());
    data['id'] ??= d.id;
    return Vehicle.fromJson(data);
  }

  Future<void> fetchMyVehicles(String ownerId) async {
    _isLoading = true;
    notifyListeners();

    try {
      final snap = await _firestore
          .collection('vehicles')
          .where('ownerId', isEqualTo: ownerId)
          .orderBy('createdAt', descending: false)
          .get();

      _myVehicles = snap.docs.map(_vehicleFromDoc).toList();
    } catch (e) {
      // Handle error
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addVehicle({
    required String ownerId,
    required String brand,
    required String model,
    required String color,
    required String licensePlate,
    required int year,
    required int seats,
    String? imageUrl,
  }) async {
    try {
      final ref = _firestore.collection('vehicles').doc();
      final data = {
        'id': ref.id,
        'ownerId': ownerId,
        'brand': brand,
        'model': model,
        'color': color,
        'licensePlate': licensePlate,
        'year': year,
        'seats': seats,
        'imageUrl': imageUrl,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      };

      await ref.set(data);

      final newVehicle = Vehicle(
        id: ref.id,
        ownerId: ownerId,
        brand: brand,
        model: model,
        color: color,
        licensePlate: licensePlate,
        year: year,
        seats: seats,
        imageUrl: imageUrl,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      _myVehicles.add(newVehicle);
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateVehicle(String vehicleId, Vehicle updatedVehicle) async {
    try {
      final data = {
        'brand': updatedVehicle.brand,
        'model': updatedVehicle.model,
        'color': updatedVehicle.color,
        'licensePlate': updatedVehicle.licensePlate,
        'year': updatedVehicle.year,
        'seats': updatedVehicle.seats,
        'imageUrl': updatedVehicle.imageUrl,
        'updatedAt': FieldValue.serverTimestamp(),
      };

      await _firestore.collection('vehicles').doc(vehicleId).set(
            data,
            SetOptions(merge: true),
          );

      final index = _myVehicles.indexWhere((v) => v.id == vehicleId);
      if (index != -1) {
        _myVehicles[index] = updatedVehicle.copyWith(
          updatedAt: DateTime.now(),
        );
      }

      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteVehicle(String vehicleId) async {
    try {
      await _firestore.collection('vehicles').doc(vehicleId).delete();

      _myVehicles.removeWhere((v) => v.id == vehicleId);
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  Vehicle? getVehicleById(String vehicleId) {
    try {
      return _myVehicles.firstWhere((v) => v.id == vehicleId);
    } catch (e) {
      return null;
    }
  }
}
