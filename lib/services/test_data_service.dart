import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/ride.dart';
import 'package:flutter/material.dart';

class TestDataService {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;
  static final CollectionReference _rides = _db.collection('rides');

  /// Créer un trajet de test pour vérifier l'affichage
  static Future<void> createTestRide() async {
    try {
      print('🔧 Création d\'un trajet de test...');
      
      final testRide = {
        'id': 'test-ride-123',
        'driverId': 'test-driver-456',
        'driverName': 'Ahmed Test',
        'driverImageUrl': '',
        'driverRating': 4.5,
        'fromCity': 'Tunis',
        'toCity': 'Sfax',
        'departureDate': DateTime.now().toIso8601String(),
        'departureTime': {
          'hour': 8,
          'minute': 30,
        },
        'pricePerSeat': 15.0,
        'availableSeats': 3,
        'totalSeats': 4,
        'description': 'Trajet de test pour vérifier l\'affichage',
        'status': 'active',
        'createdAt': DateTime.now().toIso8601String(),
        'updatedAt': DateTime.now().toIso8601String(),
        'vehicleId': null,
        'vehicleInfo': {
          'brand': 'Renault',
          'model': 'Clio',
          'color': 'Blanc',
          'plateNumber': 'TU12345',
        },
      };

      await _rides.doc('test-ride-123').set(testRide);
      print('✅ Trajet de test créé avec succès!');
      
      // Vérifier immédiatement
      final doc = await _rides.doc('test-ride-123').get();
      if (doc.exists) {
        print('✅ Trajet vérifié dans la base: ${doc.data()}');
      }
      
    } catch (e) {
      print('❌ Erreur lors de la création du trajet de test: $e');
    }
  }

  /// Créer plusieurs trajets de test
  static Future<void> createMultipleTestRides() async {
    try {
      print('🔧 Création de plusieurs trajets de test...');
      
      final testRides = [
        {
          'id': 'test-ride-1',
          'driverId': 'driver-1',
          'driverName': 'Mohamed Conductor',
          'driverImageUrl': '',
          'driverRating': 4.8,
          'fromCity': 'Tunis',
          'toCity': 'Sousse',
          'departureDate': DateTime.now().toIso8601String(),
          'departureTime': {'hour': 9, 'minute': 0},
          'pricePerSeat': 12.0,
          'availableSeats': 2,
          'totalSeats': 4,
          'description': 'Trajet confortable avec climatisation',
          'status': 'active',
          'createdAt': DateTime.now().toIso8601String(),
          'updatedAt': DateTime.now().toIso8601String(),
        },
        {
          'id': 'test-ride-2',
          'driverId': 'driver-2',
          'driverName': 'Sami Driver',
          'driverImageUrl': '',
          'driverRating': 4.2,
          'fromCity': 'Tunis',
          'toCity': 'Sfax',
          'departureDate': DateTime.now().toIso8601String(),
          'departureTime': {'hour': 14, 'minute': 30},
          'pricePerSeat': 18.0,
          'availableSeats': 1,
          'totalSeats': 3,
          'description': 'Trajet direct sans arrêt',
          'status': 'active',
          'createdAt': DateTime.now().toIso8601String(),
          'updatedAt': DateTime.now().toIso8601String(),
        },
        {
          'id': 'test-ride-3',
          'driverId': 'driver-3',
          'driverName': 'Leila Pilot',
          'driverImageUrl': '',
          'driverRating': 4.9,
          'fromCity': 'Sousse',
          'toCity': 'Sfax',
          'departureDate': DateTime.now().toIso8601String(),
          'departureTime': {'hour': 11, 'minute': 15},
          'pricePerSeat': 10.0,
          'availableSeats': 3,
          'totalSeats': 4,
          'description': 'Trajet économique et agréable',
          'status': 'active',
          'createdAt': DateTime.now().toIso8601String(),
          'updatedAt': DateTime.now().toIso8601String(),
        },
      ];

      for (final ride in testRides) {
        await _rides.doc(ride['id'] as String).set(ride);
        print('✅ Trajet créé: ${ride['id']} - ${ride['fromCity']} -> ${ride['toCity']}');
      }
      
      print('🎉 Tous les trajets de test créés!');
      
    } catch (e) {
      print('❌ Erreur lors de la création des trajets de test: $e');
    }
  }

  /// Supprimer tous les trajets de test
  static Future<void> cleanupTestRides() async {
    try {
      print('🧹 Nettoyage des trajets de test...');
      
      final testIds = ['test-ride-1', 'test-ride-2', 'test-ride-3', 'test-ride-123'];
      
      for (final id in testIds) {
        await _rides.doc(id).delete();
        print('🗑️ Trajet supprimé: $id');
      }
      
      print('✅ Nettoyage terminé!');
      
    } catch (e) {
      print('❌ Erreur lors du nettoyage: $e');
    }
  }
}
