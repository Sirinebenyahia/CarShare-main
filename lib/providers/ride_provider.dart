import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/ride.dart';

class RideProvider with ChangeNotifier {
  List<Ride> _allRides = [];
  List<Ride> _myRides = [];
  List<Ride> _searchResults = [];
  bool _isLoading = false;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  List<Ride> get allRides => _allRides;
  List<Ride> get myRides => _myRides;
  List<Ride> get searchResults => _searchResults;
  bool get isLoading => _isLoading;

  RideProvider();

  Ride _rideFromDoc(QueryDocumentSnapshot<Map<String, dynamic>> d) {
    final data = Map<String, dynamic>.from(d.data());
    data['id'] ??= d.id;
    return Ride.fromJson(data);
  }

  Future<void> fetchAllRides() async {
    _isLoading = true;
    notifyListeners();

    try {
      final snap = await _firestore
          .collection('rides')
          .orderBy('departureDate', descending: false)
          .get();

      _allRides = snap.docs.map(_rideFromDoc).toList();
      _searchResults = [];
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
      final snap = await _firestore
          .collection('rides')
          .where('driverId', isEqualTo: userId)
          .orderBy('departureDate', descending: false)
          .get();

      _myRides = snap.docs.map(_rideFromDoc).toList();
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
      Query<Map<String, dynamic>> q = _firestore.collection('rides');
      if (fromCity != null && fromCity.isNotEmpty) {
        q = q.where('fromCity', isEqualTo: fromCity);
      }
      if (toCity != null && toCity.isNotEmpty) {
        q = q.where('toCity', isEqualTo: toCity);
      }

      final snap = await q.orderBy('departureDate', descending: false).get();
      final base = snap.docs.map(_rideFromDoc).toList();

      _searchResults = base.where((ride) {
        bool matches = true;

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
      final ref = _firestore.collection('rides').doc();
      final data = ride.toJson();
      data['id'] = ref.id;
      data['departureDate'] = Timestamp.fromDate(ride.departureDate);
      data['createdAt'] = FieldValue.serverTimestamp();
      data['updatedAt'] = FieldValue.serverTimestamp();
      data['vehicle'] = null;

      await ref.set(data);

      final created = Ride(
        id: ref.id,
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
        vehicle: null,
        intermediateStops: ride.intermediateStops,
        preferences: ride.preferences,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      _myRides.insert(0, created);
      _allRides.insert(0, created);
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateRide(String rideId, Ride updatedRide) async {
    try {
      final data = updatedRide.toJson();
      data['departureDate'] = Timestamp.fromDate(updatedRide.departureDate);
      data['updatedAt'] = FieldValue.serverTimestamp();
      data['vehicle'] = null;

      await _firestore.collection('rides').doc(rideId).set(
            data,
            SetOptions(merge: true),
          );

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
      await _firestore.collection('rides').doc(rideId).delete();

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
