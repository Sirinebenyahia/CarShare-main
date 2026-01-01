import 'package:flutter/material.dart';
import '../models/ride.dart';
import '../models/vehicle.dart';

class RideProvider with ChangeNotifier {
  List<Ride> _allRides = [];
  List<Ride> _myRides = [];
  List<Ride> _searchResults = [];
  bool _isLoading = false;

  List<Ride> get allRides => _allRides;
  List<Ride> get myRides => _myRides;
  List<Ride> get searchResults => _searchResults;
  bool get isLoading => _isLoading;

  RideProvider() {
    _initializeMockData();
  }

  void _initializeMockData() {
    // Mock rides
    _allRides = [
      Ride(
        id: '1',
        driverId: '2',
        driverName: 'Ahmed Ben Salem',
        driverRating: 4.8,
        fromCity: 'Tunis',
        toCity: 'Sfax',
        departureDate: DateTime.now().add(const Duration(days: 2)),
        departureTime: '08:00',
        availableSeats: 3,
        totalSeats: 4,
        pricePerSeat: 25.0,
        vehicle: Vehicle(
          id: 'v1',
          ownerId: '2',
          brand: 'Peugeot',
          model: '308',
          color: 'Gris',
          licensePlate: '123 TU 4567',
          year: 2020,
          seats: 4,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
        intermediateStops: ['Sousse', 'Monastir'],
        preferences: RidePreferences(
          smokingAllowed: false,
          petsAllowed: false,
          luggageAllowed: true,
          musicAllowed: true,
          chattingAllowed: true,
        ),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      Ride(
        id: '2',
        driverId: '3',
        driverName: 'Salma Mansouri',
        driverRating: 4.9,
        fromCity: 'Sousse',
        toCity: 'Tunis',
        departureDate: DateTime.now().add(const Duration(days: 1)),
        departureTime: '14:00',
        availableSeats: 2,
        totalSeats: 3,
        pricePerSeat: 15.0,
        vehicle: Vehicle(
          id: 'v2',
          ownerId: '3',
          brand: 'Renault',
          model: 'Clio',
          color: 'Blanc',
          licensePlate: '456 TU 7890',
          year: 2021,
          seats: 3,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
        intermediateStops: [],
        preferences: RidePreferences(
          smokingAllowed: false,
          petsAllowed: true,
          luggageAllowed: true,
          musicAllowed: false,
          chattingAllowed: false,
        ),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    ];
  }

  Future<void> fetchAllRides() async {
    _isLoading = true;
    notifyListeners();

    try {
      await Future.delayed(const Duration(seconds: 1));
      // _allRides déjà initialisé
    } catch (e) {
      // Handle error
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchMyRides(String userId) async {
    _isLoading = true;
    notifyListeners();

    try {
      await Future.delayed(const Duration(seconds: 1));
      _myRides = _allRides.where((ride) => ride.driverId == userId).toList();
    } catch (e) {
      // Handle error
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> searchRides({
    String? fromCity,
    String? toCity,
    DateTime? date,
    double? maxPrice,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      await Future.delayed(const Duration(milliseconds: 800));
      
      _searchResults = _allRides.where((ride) {
        bool matches = true;
        
        if (fromCity != null && fromCity.isNotEmpty) {
          matches = matches && ride.fromCity.toLowerCase().contains(fromCity.toLowerCase());
        }
        
        if (toCity != null && toCity.isNotEmpty) {
          matches = matches && ride.toCity.toLowerCase().contains(toCity.toLowerCase());
        }
        
        if (date != null) {
          matches = matches && 
            ride.departureDate.year == date.year &&
            ride.departureDate.month == date.month &&
            ride.departureDate.day == date.day;
        }
        
        if (maxPrice != null) {
          matches = matches && ride.pricePerSeat <= maxPrice;
        }
        
        return matches;
      }).toList();
    } catch (e) {
      // Handle error
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> createRide(Ride ride) async {
    try {
      await Future.delayed(const Duration(seconds: 1));
      
      final newRide = Ride(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        driverId: ride.driverId,
        driverName: ride.driverName,
        driverImageUrl: ride.driverImageUrl,
        driverRating: ride.driverRating,
        fromCity: ride.fromCity,
        toCity: ride.toCity,
        departureDate: ride.departureDate,
        departureTime: ride.departureTime,
        availableSeats: ride.availableSeats,
        totalSeats: ride.totalSeats,
        pricePerSeat: ride.pricePerSeat,
        vehicleId: ride.vehicleId,
        vehicle: ride.vehicle,
        intermediateStops: ride.intermediateStops,
        preferences: ride.preferences,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      
      _myRides.add(newRide);
      _allRides.add(newRide);
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateRide(String rideId, Ride updatedRide) async {
    try {
      await Future.delayed(const Duration(seconds: 1));
      
      final index = _myRides.indexWhere((r) => r.id == rideId);
      if (index != -1) {
        _myRides[index] = updatedRide;
      }
      
      final allIndex = _allRides.indexWhere((r) => r.id == rideId);
      if (allIndex != -1) {
        _allRides[allIndex] = updatedRide;
      }
      
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteRide(String rideId) async {
    try {
      await Future.delayed(const Duration(milliseconds: 500));
      
      _myRides.removeWhere((r) => r.id == rideId);
      _allRides.removeWhere((r) => r.id == rideId);
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  void clearSearchResults() {
    _searchResults = [];
    notifyListeners();
  }
}
