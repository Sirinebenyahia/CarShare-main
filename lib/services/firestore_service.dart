import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;
  static final CollectionReference users = _db.collection('users');
  static final CollectionReference rides = _db.collection('rides');
  static final CollectionReference bookings = _db.collection('bookings');
  static final CollectionReference groups = _db.collection('groups');
  static final CollectionReference chatMessages = _db.collection('chatMessages');

  // Generic methods for CRUD operations
  
  // Create
  static Future<DocumentReference> addDocument(String collection, Map<String, dynamic> data) {
    return _db.collection(collection).add(data);
  }

  // Read
  static Future<DocumentSnapshot> getDocument(String collection, String docId) {
    return _db.collection(collection).doc(docId).get();
  }

  static Future<QuerySnapshot> getCollection(String collection) {
    return _db.collection(collection).get();
  }

  static Stream<QuerySnapshot> getCollectionStream(String collection) {
    return _db.collection(collection).snapshots();
  }

  // Update
  static Future<void> updateDocument(String collection, String docId, Map<String, dynamic> data) {
    return _db.collection(collection).doc(docId).update(data);
  }

  // Delete
  static Future<void> deleteDocument(String collection, String docId) {
    return _db.collection(collection).doc(docId).delete();
  }

  // Query with filters
  static Future<QuerySnapshot> queryCollection(
    String collection, 
    String field, 
    String operator, 
    dynamic value
  ) {
    return _db.collection(collection).where(field, isEqualTo: value).get();
  }

  static Stream<QuerySnapshot> queryCollectionStream(
    String collection, 
    String field, 
    String operator, 
    dynamic value
  ) {
    return _db.collection(collection).where(field, isEqualTo: value).snapshots();
  }
}
