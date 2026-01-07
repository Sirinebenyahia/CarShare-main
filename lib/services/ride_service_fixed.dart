import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/ride.dart';
import '../services/user_vehicle_service.dart';

class RideServiceFixed {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;
  static final CollectionReference _rides = _db.collection('rides');

  /// ============================
  /// CREATE RIDE WITH VEHICLE INFO
  /// ============================
  Future<String> createRideWithVehicle(Ride ride, String vehicleId) async {
    final docRef = _rides.doc();
    final now = DateTime.now();

    // Récupérer les infos du véhicule avec les infos du driver
    final userVehicleService = UserVehicleService();
    final vehicleWithDriver = await userVehicleService.getVehicleWithDriverInfo(vehicleId);
    
    final rideToSave = ride.copyWith(
      id: docRef.id,
      status: RideStatus.active,
      createdAt: now,
      updatedAt: now,
      vehicleInfo: vehicleWithDriver, // Ajouter les infos du véhicule et driver
    );

    await docRef.set(rideToSave.toJson());
    return docRef.id;
  }

  /// ============================
  /// CREATE RIDE (ORIGINAL)
  /// ============================
  Future<String> createRide(Ride ride) async {
    final docRef = _rides.doc();
    final now = DateTime.now();

    final rideToSave = ride.copyWith(
      id: docRef.id,
      status: RideStatus.active,
      createdAt: now,
      updatedAt: now,
    );

    await docRef.set(rideToSave.toJson());
    return docRef.id;
  }

  /// ============================
  /// STREAM ALL ACTIVE RIDES
  /// ============================
  Stream<List<Ride>> streamAllActiveRides() {
    return _rides
        .where('status', isEqualTo: RideStatus.active.name)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map((doc) => Ride.fromJson(doc.data() as Map<String, dynamic>)).toList(),
        );
  }

  /// ============================
  /// STREAM MY RIDES (DRIVER)
  /// ============================
  Stream<List<Ride>> streamMyRides(String driverId) {
    return _rides
        .where('driverId', isEqualTo: driverId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map((doc) => Ride.fromJson(doc.data() as Map<String, dynamic>)).toList(),
        );
  }

  /// ============================
  /// SEARCH RIDES
  /// ============================
  Future<List<Ride>> searchRides({
    required String fromCity,
    required String toCity,
  }) async {
    final query = await _rides
        .where('status', isEqualTo: RideStatus.active.name)
        .where('fromCity', isEqualTo: fromCity)
        .where('toCity', isEqualTo: toCity)
        .get();

    return query.docs.map((doc) => Ride.fromJson(doc.data() as Map<String, dynamic>)).toList();
  }

  /// ============================
  /// GET RIDE BY ID
  /// ============================
  Future<Ride?> getRideById(String rideId) async {
    final doc = await _rides.doc(rideId).get();
    if (!doc.exists || doc.data() == null) return null;
    return Ride.fromJson(doc.data() as Map<String, dynamic>);
  }

  /// ============================
  /// UPDATE RIDE
  /// ============================
  Future<void> updateRide({
    required String rideId,
    required Map<String, dynamic> data,
  }) async {
    data['updatedAt'] = DateTime.now().toIso8601String();
    await _rides.doc(rideId).update(data);
  }

  /// ============================
  /// DELETE RIDE
  /// ============================
  Future<void> deleteRide(String rideId) async {
    await _rides.doc(rideId).delete();
  }
}
