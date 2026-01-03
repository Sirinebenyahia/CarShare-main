import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/vehicle.dart';
import '../models/user.dart';

class UserVehicleService {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;
  static final CollectionReference _vehicles = _db.collection('vehicles');

  /// ============================
  /// GET VEHICLE WITH DRIVER INFO
  /// ============================
  Future<Map<String, dynamic>?> getVehicleWithDriverInfo(String vehicleId) async {
    final vehicleDoc = await _vehicles.doc(vehicleId).get();
    if (!vehicleDoc.exists) return null;

    final vehicleData = vehicleDoc.data() as Map<String, dynamic>;
    vehicleData['id'] = vehicleDoc.id;

    // Récupérer les infos du driver (propriétaire)
    final userDoc = await _db.collection('users').doc(vehicleData['ownerId'] as String).get();
    if (userDoc.exists) {
      final userData = userDoc.data() as Map<String, dynamic>;
      vehicleData['driverInfo'] = {
        'name': userData['fullName'] ?? 'Conducteur',
        'email': userData['email'] ?? '',
        'phone': userData['phoneNumber'] ?? '',
        'avatar': userData['avatarUrl'] ?? '',
        'rating': userData['rating'] ?? 0.0,
      };
    }

    return vehicleData;
  }

  /// ============================
  /// GET ALL VEHICLES WITH DRIVER INFO
  /// ============================
  Future<List<Map<String, dynamic>>> getVehiclesWithDriverInfo(String userId) async {
    final vehicles = await _vehicles
        .where('ownerId', isEqualTo: userId)
        .get();

    final List<Map<String, dynamic>> vehiclesWithInfo = [];

    for (final doc in vehicles.docs) {
      final vehicleData = doc.data() as Map<String, dynamic>;
      vehicleData['id'] = doc.id;

      // Récupérer les infos du driver
      final userDoc = await _db.collection('users').doc(vehicleData['ownerId'] as String).get();
      if (userDoc.exists) {
        final userData = userDoc.data() as Map<String, dynamic>;
        vehicleData['driverInfo'] = {
          'name': userData['fullName'] ?? 'Conducteur',
          'email': userData['email'] ?? '',
          'phone': userData['phoneNumber'] ?? '',
          'avatar': userData['avatarUrl'] ?? '',
          'rating': userData['rating'] ?? 0.0,
        };
      }

      vehiclesWithInfo.add(vehicleData);
    }

    return vehiclesWithInfo;
  }
}
