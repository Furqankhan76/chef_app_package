import 'package:chef_app/features/auth/data/firebase_auth_repository.dart';
import 'package:chef_app/features/auth/domain/auth_repository.dart';
import 'package:chef_app/features/auth/domain/user.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Provider for the AuthRepository implementation
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return FirebaseAuthRepository();
});

// Provider for the authentication state stream
// This stream emits the current user (or null if not authenticated)
final authStateChangesProvider = StreamProvider<User?>((ref) {
  final authRepository = ref.watch(authRepositoryProvider);
  return authRepository.authStateChanges;
});

// You might add other providers here later, e.g., for login/register state management

