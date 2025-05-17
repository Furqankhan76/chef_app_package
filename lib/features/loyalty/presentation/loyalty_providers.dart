import 'package:chef_app/features/auth/presentation/auth_providers.dart';
import 'package:chef_app/features/loyalty/data/firebase_loyalty_repository.dart';
import 'package:chef_app/features/loyalty/domain/loyalty.dart';
import 'package:chef_app/features/loyalty/domain/loyalty_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Provider for the LoyaltyRepository implementation
final loyaltyRepositoryProvider = Provider<LoyaltyRepository>((ref) {
  return FirebaseLoyaltyRepository();
});

// Provider to get user's loyalty points for a specific vendor
final userLoyaltyProvider = FutureProvider.family<UserLoyalty?, String>((ref, vendorId) async {
  final userId = ref.watch(authStateChangesProvider).valueOrNull?.uid;
  if (userId == null) return null;
  final repository = ref.watch(loyaltyRepositoryProvider);
  return repository.getUserLoyalty(userId, vendorId);
});

// Provider to get available rewards from a specific vendor
final vendorRewardsProvider = FutureProvider.family<List<LoyaltyReward>, String>((ref, vendorId) async {
  final repository = ref.watch(loyaltyRepositoryProvider);
  return repository.getVendorRewards(vendorId);
});

// Provider for the list of vendors the user has loyalty points with
// This might involve a more complex query or data structure in a real app
// For now, let's assume we fetch all vendors and then filter by loyalty
// (This is inefficient and just a placeholder)
final vendorsWithLoyaltyProvider = FutureProvider<List<String>>((ref) async {
  final userId = ref.watch(authStateChangesProvider).valueOrNull?.uid;
  if (userId == null) return [];
  // Placeholder: In a real app, query the user's loyalty subcollection
  // For now, returning an empty list as we don't have a screen to display this yet.
  return [];
});

