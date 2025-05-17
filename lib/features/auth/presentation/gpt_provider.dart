import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 1) Expose the raw FirebaseAuth instance
final firebaseAuthProvider =
    Provider<FirebaseAuth>((ref) => FirebaseAuth.instance);

/// 2) Wrap it in a simple service that exposes `currentUser`
class AuthService {
  AuthService(this._auth);
  final FirebaseAuth _auth;

  /// Snapshot of the currently-signed-in user (or null)
  User? get currentUser => _auth.currentUser;

  /// If you ever need the auth-state changes stream:
  Stream<User?> get authStateChanges => _auth.authStateChanges();
}

/// 3) Expose your AuthService so widgets can do `ref.watch(authProvider)`
final authProvider = Provider<AuthService>(
  (ref) => AuthService(ref.watch(firebaseAuthProvider)),
);
