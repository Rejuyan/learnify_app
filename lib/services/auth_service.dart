import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'firestore_service.dart';

class AuthService {
  // Singleton pattern
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  final firebase_auth.FirebaseAuth _auth = firebase_auth.FirebaseAuth.instance;

  // Stream of auth changes
  Stream<firebase_auth.User?> get authStateChanges => _auth.authStateChanges();

  // Current user getter
  firebase_auth.User? get currentUser => _auth.currentUser;

  // Register
  Future<firebase_auth.UserCredential?> registerWithEmailAndPassword(String email, String password) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(email: email, password: password);
      // Immediately send verification email
      if (credential.user != null && !credential.user!.emailVerified) {
        await credential.user!.sendEmailVerification();
      }
      return credential;
    } on firebase_auth.FirebaseAuthException catch (e) {
      // Re-throw to handle in UI
      throw Exception(e.message ?? 'An error occurred during registration.');
    }
  }

  // Login
  Future<firebase_auth.UserCredential?> signInWithEmailAndPassword(String email, String password) async {
    try {
      return await _auth.signInWithEmailAndPassword(email: email, password: password);
    } on firebase_auth.FirebaseAuthException catch (e) {
      throw Exception(e.message ?? 'An error occurred during login.');
    }
  }

  // Send Email Verification (if user needs to re-send it)
  Future<void> sendEmailVerification() async {
    if (currentUser != null && !currentUser!.emailVerified) {
      await currentUser!.sendEmailVerification();
    }
  }

  // Reload user (to check if they clicked the verification link)
  Future<void> reloadUser() async {
    await currentUser?.reload();
  }

  // Update Display Name
  Future<void> updateDisplayName(String name) async {
    final user = _auth.currentUser;
    if (user != null) {
      await user.updateDisplayName(name);
      await user.reload();
      
      // Also update Firestore for consistency
      await FirestoreService().updateUserProfile(name: name);
    }
  }

  // Sign out
  Future<void> signOut() async {
    await _auth.signOut();
  }
}
