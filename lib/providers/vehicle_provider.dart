import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/vehicle.dart';
import '../services/vehicle_service.dart';
import '../providers/auth_provider.dart';

class VehicleProvider with ChangeNotifier {
  final VehicleService _service = VehicleService();
  
  List<Vehicle> _myVehicles = [];
  bool _isLoading = false;

  List<Vehicle> get myVehicles => _myVehicles;
  bool get isLoading => _isLoading;
  
  Future<void> fetchMyVehicles(String ownerId) async {
    _isLoading = true;
    notifyListeners();
    try {
      _myVehicles = await _service.getMyVehicles(ownerId);
    } catch (e) {
      debugPrint('Error fetching vehicles: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadVehicles() async {
    // This method should be called from a widget with context
    // The actual loading will be done from the widget using fetchMyVehicles
  }

  Future<void> addVehicle(Vehicle vehicle) async {
    try {
      await _service.addVehicle(
        ownerId: vehicle.ownerId,
        brand: vehicle.brand,
        model: vehicle.model,
        color: vehicle.color,
        licensePlate: vehicle.licensePlate,
        year: vehicle.year,
        seats: vehicle.seats,
        imageUrl: vehicle.imageUrl,
      );
      
      // Rafraîchir la liste
      await fetchMyVehicles(vehicle.ownerId);
    } catch (e) {
      debugPrint('Error adding vehicle: $e');
      rethrow;
    }
  }

  Future<void> updateVehicle(String vehicleId, Vehicle updatedVehicle) async {
    try {
      await _service.updateVehicle(vehicleId, updatedVehicle);
      
      // Rafraîchir la liste
      final index = _myVehicles.indexWhere((v) => v.id == vehicleId);
      if (index != -1) {
        _myVehicles[index] = updatedVehicle.copyWith(updatedAt: DateTime.now());
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error updating vehicle: $e');
      rethrow;
    }
  }

  Future<void> deleteVehicle(String vehicleId) async {
    try {
      await _service.deleteVehicle(vehicleId);
      
      // Retirer de la liste locale
      _myVehicles.removeWhere((v) => v.id == vehicleId);
      notifyListeners();
    } catch (e) {
      debugPrint('Error deleting vehicle: $e');
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
