import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user.dart' as app;
import 'firestore_refs.dart';

class UserService {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;
  static final CollectionReference _users = _db.collection('users');

  /// Create or overwrite user document
  Future<void> createUser(app.User user) async {
    await _users.doc(user.id).set(user.toJson(), SetOptions(merge: true));
  }

  Future<app.User?> getUserById(String uid) async {
    final doc = await _users.doc(uid).get();
    if (!doc.exists) return null;
    return app.User.fromJson(doc.data() as Map<String, dynamic>);
  }

  Stream<app.User?> streamUser(String uid) {
    return _users.doc(uid).snapshots().map((doc) {
      if (!doc.exists) return null;
      return app.User.fromJson(doc.data() as Map<String, dynamic>);
    });
  }

  Future<void> updateUser(String uid, Map<String, dynamic> data) async {
    data['updatedAt'] = DateTime.now().toIso8601String();
    await _users.doc(uid).update(data);
  }
}
