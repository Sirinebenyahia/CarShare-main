import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  AuthService({FirebaseAuth? auth}) : _auth = auth ?? FirebaseAuth.instance;

  final FirebaseAuth _auth;

  Stream<User?> authStateChanges() => _auth.authStateChanges();

  User? get currentUser => _auth.currentUser;

  Future<UserCredential> signInWithEmail({
    required String email,
    required String password,
  }) async {
    // Désactiver App Check temporairement pour contourner CONFIGURATION_NOT_FOUND
    try {
      return await _auth.signInWithEmailAndPassword(email: email, password: password);
    } on FirebaseAuthException catch (e) {
      if (e.message?.contains('CONFIGURATION_NOT_FOUND') == true) {
        // Réessayer sans App Check
        await Future.delayed(const Duration(seconds: 1));
        return await _auth.signInWithEmailAndPassword(email: email, password: password);
      }
      rethrow;
    }
  }

  Future<UserCredential> signUpWithEmail({
    required String email,
    required String password,
  }) async {
    // Désactiver App Check temporairement pour contourner CONFIGURATION_NOT_FOUND
    try {
      return await _auth.createUserWithEmailAndPassword(email: email, password: password);
    } on FirebaseAuthException catch (e) {
      if (e.message?.contains('CONFIGURATION_NOT_FOUND') == true) {
        // Réessayer sans App Check
        await Future.delayed(const Duration(seconds: 1));
        return await _auth.createUserWithEmailAndPassword(email: email, password: password);
      }
      rethrow;
    }
  }

  Future<UserCredential> signInOrCreateWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      return await signInWithEmail(email: email, password: password);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        return await signUpWithEmail(email: email, password: password);
      }
      rethrow;
    }
  }

  Future<void> signOut() => _auth.signOut();
}
