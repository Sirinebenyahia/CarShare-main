import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class RideService {
  RideService({FirebaseFirestore? db}) : _db = db ?? FirebaseFirestore.instance;

  final FirebaseFirestore _db;

  CollectionReference<Map<String, dynamic>> get _rides => _db.collection('rides');
  CollectionReference<Map<String, dynamic>> get _bookings => _db.collection('bookings');
  CollectionReference<Map<String, dynamic>> get _users => _db.collection('users');

  DocumentReference<Map<String, dynamic>> rideRef(String rideId) => _rides.doc(rideId);

  DocumentReference<Map<String, dynamic>> bookingRef(String bookingId) => _bookings.doc(bookingId);

  Stream<DocumentSnapshot<Map<String, dynamic>>> rideStream(String rideId) {
    return rideRef(rideId).snapshots();
  }

  Stream<DocumentSnapshot<Map<String, dynamic>>> bookingStream(String bookingId) {
    return bookingRef(bookingId).snapshots();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> ridesStream() {
    return _rides.orderBy('departureTime', descending: false).snapshots();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> searchRidesStream({
    required String from,
    required String to,
  }) {
    Query<Map<String, dynamic>> q = _rides.orderBy('departureTime', descending: false);
    if (from.isNotEmpty) {
      q = q.where('from', isEqualTo: from);
    }
    if (to.isNotEmpty) {
      q = q.where('to', isEqualTo: to);
    }
    return q.snapshots();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> myBookingsStream({required String uid}) {
    return _bookings.where('userId', isEqualTo: uid).orderBy('createdAt', descending: true).snapshots();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> myBookingsByStatusStream({
    required String uid,
    required String status,
  }) {
    return _bookings
        .where('userId', isEqualTo: uid)
        .where('status', isEqualTo: status)
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  Future<void> ensureUserDoc({required User user}) async {
    final ref = _users.doc(user.uid);
    final snap = await ref.get();
    if (!snap.exists) {
      await ref.set({
        'uid': user.uid,
        'email': user.email,
        'createdAt': FieldValue.serverTimestamp(),
      });
    }
  }

  Future<void> updateUserCin({
    required String uid,
    required String cinNumber,
    required String cinFileUrl,
  }) {
    return _users.doc(uid).set({
      'cinNumber': cinNumber,
      'cinFileUrl': cinFileUrl,
      'cinUpdatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<DocumentReference<Map<String, dynamic>>> createBooking({
    required String rideId,
    required String userId,
    required String paymentMethod,
  }) {
    return _bookings.add({
      'rideId': rideId,
      'userId': userId,
      'paymentMethod': paymentMethod,
      'status': 'confirmed',
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<DocumentReference<Map<String, dynamic>>> createRide({
    required String driverId,
    required String driverName,
    required String from,
    required String to,
    required double priceTnd,
    required int seatsAvailable,
    required bool womenOnly,
    required DateTime departureTime,
  }) {
    return _rides.add({
      'from': from,
      'to': to,
      'priceTnd': priceTnd,
      'womenOnly': womenOnly,
      'seatsAvailable': seatsAvailable,
      'driverName': driverName,
      'rating': 5.0,
      'departureTime': Timestamp.fromDate(departureTime),
      'createdAt': FieldValue.serverTimestamp(),
      'driverId': driverId,
    });
  }

  Future<void> seedSampleRideIfEmpty({required User user}) async {
    final snap = await _rides.limit(1).get();
    if (snap.docs.isNotEmpty) return;

    await _rides.add({
      'from': 'Tunis',
      'to': 'Sousse',
      'priceTnd': 15.0,
      'womenOnly': false,
      'seatsAvailable': 2,
      'driverName': 'Foulen Ben Foulen',
      'rating': 4.8,
      'departureTime': Timestamp.fromDate(DateTime.now().add(const Duration(hours: 3))),
      'createdAt': FieldValue.serverTimestamp(),
      'driverId': user.uid,
    });
  }
}
