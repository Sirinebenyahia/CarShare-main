import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/booking.dart';

class BookingProvider with ChangeNotifier {
  List<Booking> _myBookings = [];
  List<Booking> _acceptedRequests = [];
  bool _isLoading = false;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  List<Booking> get myBookings => _myBookings;
  List<Booking> get acceptedRequests => _acceptedRequests;
  bool get isLoading => _isLoading;

  Future<void> fetchMyBookings(String userId) async {
    _isLoading = true;
    notifyListeners();

    try {
      final snap = await _firestore
          .collection('bookings')
          .where('passengerId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .get();

      _myBookings = snap.docs.map((d) {
        final data = d.data();
        data['id'] ??= d.id;
        return Booking.fromJson(Map<String, dynamic>.from(data));
      }).toList();
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
      final snap = await _firestore
          .collection('bookings')
          .where('driverId', isEqualTo: driverId)
          .where('status', isEqualTo: BookingStatus.accepted.toString().split('.').last)
          .orderBy('createdAt', descending: true)
          .get();

      _acceptedRequests = snap.docs.map((d) {
        final data = d.data();
        data['id'] ??= d.id;
        return Booking.fromJson(Map<String, dynamic>.from(data));
      }).toList();
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
    _isLoading = true;
    notifyListeners();

    try {
      final now = DateTime.now();
      final ref = _firestore.collection('bookings').doc();
      final booking = Booking(
        id: ref.id,
        rideId: rideId,
        passengerId: passengerId,
        passengerName: passengerName,
        passengerImageUrl: passengerImageUrl,
        driverId: driverId,
        seatsBooked: seatsBooked,
        totalPrice: totalPrice,
        status: BookingStatus.pending,
        createdAt: now,
        updatedAt: now,
      );

      final data = booking.toJson();
      data['createdAt'] = FieldValue.serverTimestamp();
      data['updatedAt'] = FieldValue.serverTimestamp();
      await ref.set(data);

      // optimistic local update
      _myBookings.insert(0, booking);
    } catch (e) {
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> acceptBooking(String bookingId) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _firestore.collection('bookings').doc(bookingId).set(
        {
          'status': BookingStatus.accepted.toString().split('.').last,
          'updatedAt': FieldValue.serverTimestamp(),
        },
        SetOptions(merge: true),
      );

      // best-effort: refresh driver list if booking exists locally
      final inMy = _myBookings.indexWhere((b) => b.id == bookingId);
      if (inMy != -1) {
        final b = _myBookings[inMy];
        _myBookings[inMy] = Booking(
          id: b.id,
          rideId: b.rideId,
          passengerId: b.passengerId,
          passengerName: b.passengerName,
          passengerImageUrl: b.passengerImageUrl,
          driverId: b.driverId,
          seatsBooked: b.seatsBooked,
          totalPrice: b.totalPrice,
          status: BookingStatus.accepted,
          createdAt: b.createdAt,
          updatedAt: DateTime.now(),
        );
      }
    } catch (e) {
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> rejectBooking(String bookingId) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _firestore.collection('bookings').doc(bookingId).set(
        {
          'status': BookingStatus.rejected.toString().split('.').last,
          'updatedAt': FieldValue.serverTimestamp(),
        },
        SetOptions(merge: true),
      );
      _acceptedRequests.removeWhere((b) => b.id == bookingId);
    } catch (e) {
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> cancelBooking(String bookingId) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _firestore.collection('bookings').doc(bookingId).set(
        {
          'status': BookingStatus.cancelled.toString().split('.').last,
          'updatedAt': FieldValue.serverTimestamp(),
        },
        SetOptions(merge: true),
      );
      _myBookings.removeWhere((b) => b.id == bookingId);
    } catch (e) {
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
