import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'test_data_service.dart';

class FirebaseTest {
  static Future<void> testConnection() async {
    try {
      // Test Firebase initialization
      print('✅ Firebase initialisé: ${Firebase.app().name}');
      
      // Test Firestore connection
      CollectionReference testRef = FirebaseFirestore.instance.collection('test');
      
      // Test write
      DocumentReference doc = await testRef.add({
        'timestamp': Timestamp.now(),
        'message': 'Test de connexion Firebase',
        'status': 'success'
      });
      
      print('✅ Document créé: ${doc.id}');
      
      // Test read
      DocumentSnapshot snapshot = await doc.get();
      if (snapshot.exists) {
        print('✅ Document lu: ${snapshot.data()}');
      }
      
      // Clean up
      await doc.delete();
      print('✅ Document supprimé');
      
      // Test rides collection
      await _testRidesCollection();
      
      // Créer des données de test si la base est vide
      await _createTestDataIfNeeded();
      
      print('🎉 Tous les tests Firebase réussis!');
      
    } catch (e) {
      print('❌ Erreur Firebase: $e');
    }
  }

  static Future<void> _testRidesCollection() async {
    try {
      print('\n🔍 Test de la collection rides...');
      
      CollectionReference ridesRef = FirebaseFirestore.instance.collection('rides');
      
      // Compter tous les documents
      QuerySnapshot allRides = await ridesRef.get();
      print('📊 Nombre total de trajets dans la base: ${allRides.docs.length}');
      
      // Afficher les détails de chaque trajet
      for (var doc in allRides.docs) {
        final data = doc.data() as Map<String, dynamic>;
        print('\n🚗 Trajet ID: ${doc.id}');
        print('  - De: ${data['fromCity'] ?? 'N/A'}');
        print('  - À: ${data['toCity'] ?? 'N/A'}');
        print('  - Status: ${data['status'] ?? 'N/A'}');
        print('  - Places: ${data['availableSeats'] ?? 'N/A'}/${data['totalSeats'] ?? 'N/A'}');
        print('  - Conducteur: ${data['driverName'] ?? 'N/A'}');
        print('  - Date: ${data['departureDate'] ?? 'N/A'}');
        print('  - Prix: ${data['pricePerSeat'] ?? 'N/A'} TND');
      }
      
      // Test des trajets actifs
      QuerySnapshot activeRides = await ridesRef.where('status', isEqualTo: 'active').get();
      print('\n✅ Nombre de trajets actifs: ${activeRides.docs.length}');
      
    } catch (e) {
      print('❌ Erreur lors du test de la collection rides: $e');
    }
  }

  static Future<void> _createTestDataIfNeeded() async {
    try {
      print('\n🔧 Vérification si des données de test sont nécessaires...');
      
      CollectionReference ridesRef = FirebaseFirestore.instance.collection('rides');
      QuerySnapshot existingRides = await ridesRef.get();
      
      if (existingRides.docs.isEmpty) {
        print('📝 Base de données vide, création de trajets de test...');
        await TestDataService.createMultipleTestRides();
        
        // Vérifier après création
        QuerySnapshot newRides = await ridesRef.get();
        print('✅ Création terminée. Nombre de trajets: ${newRides.docs.length}');
      } else {
        print('✅ Des trajets existent déjà dans la base');
      }
      
    } catch (e) {
      print('❌ Erreur lors de la création des données de test: $e');
    }
  }
}
