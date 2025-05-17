import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:cloud_firestore/cloud_firestore.dart';
import '../domain/auth_repository.dart';
import '../domain/user.dart' as app;

class FirebaseAuthRepository implements AuthRepository {
  final firebase_auth.FirebaseAuth _firebaseAuth;
  final FirebaseFirestore _firestore;

  FirebaseAuthRepository({
    firebase_auth.FirebaseAuth? firebaseAuth,
    FirebaseFirestore? firestore,
  })  : _firebaseAuth = firebaseAuth ?? firebase_auth.FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Future<app.User> signIn({required String email, required String password}) async {
    try {
      final userCredential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      if (userCredential.user == null) {
        throw Exception('Sign in failed: No user returned');
      }
      
      // Get additional user data from Firestore
      final userData = await _getUserData(userCredential.user!.uid);
      return userData;
    } catch (e) {
      throw Exception('Sign in failed: ${e.toString()}');
    }
  }

  @override
  Future<app.User> register({
    required String email,
    required String password,
    required String name,
    required String role,
  }) async {
    try {
      final userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      if (userCredential.user == null) {
        throw Exception('Registration failed: No user returned');
      }
      
      // Create user document in Firestore
      final user = app.User(
        uid: userCredential.user!.uid,
        email: email,
        name: name,
        role: role,
        languagePreference: 'en',
      );
      
      await _firestore.collection('users').doc(user.uid).set({
        'email': user.email,
        'name': user.name,
        'role': user.role,
        'languagePreference': user.languagePreference,
        'createdAt': FieldValue.serverTimestamp(),
      });
      
      return user;
    } catch (e) {
      throw Exception('Registration failed: ${e.toString()}');
    }
  }

  @override
  Future<void> signOut() async {
    await _firebaseAuth.signOut();
  }

  @override
  Future<app.User?> getCurrentUser() async {
    final firebaseUser = _firebaseAuth.currentUser;
    if (firebaseUser == null) {
      return null;
    }
    
    return _getUserData(firebaseUser.uid);
  }

  @override
  Stream<app.User?> get authStateChanges {
    return _firebaseAuth.authStateChanges().asyncMap((firebaseUser) async {
      if (firebaseUser == null) {
        return null;
      }
      
      try {
        return await _getUserData(firebaseUser.uid);
      } catch (e) {
        print('Error getting user data: ${e.toString()}');
        return null;
      }
    });
  }

  // Helper method to get user data from Firestore
  Future<app.User> _getUserData(String uid) async {
    final doc = await _firestore.collection('users').doc(uid).get();
    
    if (!doc.exists) {
      throw Exception('User data not found');
    }
    
    final data = doc.data()!;
    
    return app.User(
      uid: uid,
      email: data['email'] as String?,
      name: data['name'] as String?,
      role: data['role'] as String,
      profilePicUrl: data['profilePicUrl'] as String?,
      languagePreference: data['languagePreference'] as String? ?? 'en',
    );
  }
}
