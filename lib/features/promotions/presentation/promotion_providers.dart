import 'package:chef_app/features/auth/presentation/auth_providers.dart';
import 'package:chef_app/features/promotions/data/firebase_promotion_repository.dart';
import 'package:chef_app/features/promotions/domain/promotion.dart';
import 'package:chef_app/features/promotions/domain/promotion_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Provider for the PromotionRepository implementation
final promotionRepositoryProvider = Provider<PromotionRepository>((ref) {
  return FirebasePromotionRepository();
});

// Provider for promotions from a specific vendor
final vendorPromotionsProvider = FutureProvider.family<List<Promotion>, String>((ref, vendorId) async {
  final repository = ref.watch(promotionRepositoryProvider);
  return repository.getVendorPromotions(vendorId);
});

// Provider for promotions from followed vendors
final followedVendorsPromotionsProvider = FutureProvider<List<Promotion>>((ref) async {
  final userId = ref.watch(authStateChangesProvider).valueOrNull?.uid;
  if (userId == null) return [];
  final repository = ref.watch(promotionRepositoryProvider);
  return repository.getFollowedVendorsPromotions(userId);
});
