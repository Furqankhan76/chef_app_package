// Repository interface for authentication
import 'user.dart';

abstract class AuthRepository {
  // Sign in with email and password
  Future<User> signIn({required String email, required String password});
  
  // Register with email and password
  Future<User> register({
    required String email, 
    required String password, 
    required String name,
    required String role,
  });
  
  // Sign out
  Future<void> signOut();
  
  // Get current user
  Future<User?> getCurrentUser();
  
  // Stream of authentication state changes
  Stream<User?> get authStateChanges;
}
