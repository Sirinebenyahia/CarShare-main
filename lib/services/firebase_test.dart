import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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
      
      print('🎉 Tous les tests Firebase réussis!');
      
    } catch (e) {
      print('❌ Erreur Firebase: $e');
    }
  }
}
