import 'package:flutter/material.dart';
import '../models/ride.dart';
import '../services/ride_service.dart';
import '../services/ride_service_fixed.dart';

class RideProvider with ChangeNotifier {
  final RideService _rideService = RideService();
  final RideServiceFixed _rideServiceFixed = RideServiceFixed();

  List<Ride> _allRides = [];
  List<Ride> _myRides = [];
  List<Ride> _searchResults = [];
  bool _isLoading = false;

  List<Ride> get allRides => _allRides;
  List<Ride> get myRides => _myRides;
  List<Ride> get searchResults => _searchResults;
  bool get isLoading => _isLoading;

  /// ============================
  /// CREATE RIDE WITH VEHICLE INFO
  /// ============================
  Future<String> createRideWithVehicle(Ride ride, String vehicleId) async {
    _isLoading = true;
    notifyListeners();

    try {
      print('DEBUG: Creating ride with driverId: ${ride.driverId}');
      final rideId = await _rideServiceFixed.createRideWithVehicle(ride, vehicleId);
      print('DEBUG: Ride created successfully with ID: $rideId');
      return rideId;
    } catch (e) {
      print('DEBUG: Error creating ride: $e');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ============================
  // CREATE RIDE ( FIRESTORE)
  // ============================
  Future<void> createRide(Ride ride) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _rideService.createRide(ride);
    } catch (e) {
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ============================
  // STREAM ALL ACTIVE RIDES
  // ============================
  void listenToAllRides() {
    _rideService.streamAllActiveRides().listen((rides) {
      _allRides = rides;
      notifyListeners();
    });
  }

  // ============================
  // STREAM MY RIDES
  // ============================
  void listenToMyRides(String driverId) {
    print('DEBUG: Listening to rides for driverId: $driverId');
    _rideService.streamMyRides(driverId).listen((rides) {
      print('DEBUG: Received ${rides.length} rides for driver');
      _myRides = rides;
      notifyListeners();
    });
  }

  // ============================
  // LEGACY METHODS (pour compatibilité)
  // ============================
  Future<void> fetchAllRides() async {
    _isLoading = true;
    notifyListeners();

    try {
      listenToAllRides();
      await Future.delayed(const Duration(milliseconds: 500)); // petit délai pour le stream
    } catch (e) {
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchMyRides(String userId) async {
    _isLoading = true;
    notifyListeners();

    try {
      listenToMyRides(userId);
      await Future.delayed(const Duration(milliseconds: 500)); // petit délai pour le stream
    } catch (e) {
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ============================
  // DELETE RIDE
  // ============================
  Future<void> deleteRide(String rideId) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _rideService.deleteRide(rideId);
    } catch (e) {
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ============================
  // UPDATE RIDE
  // ============================
  Future<void> updateRide(String rideId, Map<String, dynamic> data) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _rideService.updateRide(rideId: rideId, data: data);
    } catch (e) {
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ============================
  // SEARCH RIDES
  // ============================
  Future<void> searchRides({
    required String fromCity,
    required String toCity,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      _searchResults = await _rideService.searchRides(
        fromCity: fromCity,
        toCity: toCity,
      );
    } catch (e) {
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearSearchResults() {
    _searchResults = [];
    notifyListeners();
  }
}
