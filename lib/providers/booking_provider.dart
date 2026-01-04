import 'package:flutter/material.dart';
import '../models/booking.dart';

class BookingProvider with ChangeNotifier {
  List<Booking> _myBookings = [];
  List<Booking> _acceptedRequests = [];
  bool _isLoading = false;

  List<Booking> get myBookings => _myBookings;
  List<Booking> get acceptedRequests => _acceptedRequests;
  bool get isLoading => _isLoading;

  Future<void> fetchMyBookings(String userId) async {
    _isLoading = true;
    notifyListeners();

    try {
      await Future.delayed(const Duration(seconds: 1));
      // Mock bookings
      _myBookings = [];
    } catch (e) {
      // Handle error
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchAcceptedRequests(String driverId) async {
    _isLoading = true;
    notifyListeners();

    try {
      await Future.delayed(const Duration(seconds: 1));
      // Mock accepted requests
      _acceptedRequests = [];
    } catch (e) {
      // Handle error
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> createBooking({
    required String rideId,
    required String passengerId,
    required String passengerName,
    String? passengerImageUrl,
    required String driverId,
    required int seatsBooked,
    required double totalPrice,
  }) async {
    try {
      await Future.delayed(const Duration(seconds: 1));

      final newBooking = Booking(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        rideId: rideId,
        passengerId: passengerId,
        passengerName: passengerName,
        passengerImageUrl: passengerImageUrl,
        driverId: driverId,
        seatsBooked: seatsBooked,
        totalPrice: totalPrice,
        status: BookingStatus.pending,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      _myBookings.add(newBooking);
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> acceptBooking(String bookingId) async {
    try {
      await Future.delayed(const Duration(milliseconds: 500));

      final index = _acceptedRequests.indexWhere((b) => b.id == bookingId);
      if (index != -1) {
        // Update status
      }

      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> rejectBooking(String bookingId) async {
    try {
      await Future.delayed(const Duration(milliseconds: 500));

      _acceptedRequests.removeWhere((b) => b.id == bookingId);
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> cancelBooking(String bookingId) async {
    try {
      await Future.delayed(const Duration(milliseconds: 500));

      _myBookings.removeWhere((b) => b.id == bookingId);
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }
}
