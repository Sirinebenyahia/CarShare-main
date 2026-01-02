import 'package:flutter/material.dart';
import '../models/vehicle.dart';

class VehicleProvider with ChangeNotifier {
  List<Vehicle> _myVehicles = [];
  bool _isLoading = false;

  List<Vehicle> get myVehicles => _myVehicles;
  bool get isLoading => _isLoading;

  Future<void> fetchMyVehicles(String ownerId) async {
    _isLoading = true;
    notifyListeners();

    try {
      await Future.delayed(const Duration(seconds: 1));
      
      // Mock vehicles
      _myVehicles = [
        Vehicle(
          id: 'v1',
          ownerId: ownerId,
          brand: 'Peugeot',
          model: '308',
          color: 'Gris',
          licensePlate: '123 TU 4567',
          year: 2020,
          seats: 4,
          createdAt: DateTime.now().subtract(const Duration(days: 90)),
          updatedAt: DateTime.now(),
        ),
      ];
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
      await Future.delayed(const Duration(seconds: 1));

      final newVehicle = Vehicle(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
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
      await Future.delayed(const Duration(seconds: 1));

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
      await Future.delayed(const Duration(milliseconds: 500));

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
