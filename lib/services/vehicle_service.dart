import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/vehicle.dart';

class VehicleService {
  VehicleService({FirebaseFirestore? db}) : _db = db ?? FirebaseFirestore.instance;

  final FirebaseFirestore _db;

  CollectionReference<Map<String, dynamic>> get _vehicles => _db.collection('vehicles');

  DocumentReference<Map<String, dynamic>> vehicleRef(String vehicleId) => _vehicles.doc(vehicleId);

  // =========================
  // Ajouter un véhicule
  // =========================
  Future<DocumentReference<Map<String, dynamic>>> addVehicle({
    required String ownerId,
    required String brand,
    required String model,
    required String color,
    required String licensePlate,
    required int year,
    required int seats,
    String? imageUrl,
  }) async {
    final vehicleData = {
      'ownerId': ownerId,
      'brand': brand,
      'model': model,
      'color': color,
      'licensePlate': licensePlate,
      'year': year,
      'seats': seats,
      'imageUrl': imageUrl,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };

    return await _vehicles.add(vehicleData);
  }

  // =========================
  // Mettre à jour un véhicule
  // =========================
  Future<void> updateVehicle(String vehicleId, Vehicle vehicle) async {
    await vehicleRef(vehicleId).set(vehicle.toJson(), SetOptions(merge: true));
  }

  // =========================
  // Supprimer un véhicule
  // =========================
  Future<void> deleteVehicle(String vehicleId) async {
    await vehicleRef(vehicleId).delete();
  }

  // =========================
  // Récupérer les véhicules d'un utilisateur
  // =========================
  Future<List<Vehicle>> getMyVehicles(String ownerId) async {
    final query = await _vehicles
        .where('ownerId', isEqualTo: ownerId)
        .get();

    return query.docs.map((doc) {
      final data = doc.data();
      data['id'] = doc.id; // ajouter l'id Firestore au model
      return Vehicle.fromJson(data);
    }).toList();
  }

  // =========================
  // Récupérer un véhicule par son ID
  // =========================
  Future<Vehicle?> getVehicleById(String vehicleId) async {
    final doc = await vehicleRef(vehicleId).get();
    if (doc.exists) {
      final data = doc.data()!;
      data['id'] = doc.id;
      return Vehicle.fromJson(data);
    }
    return null;
  }
}
