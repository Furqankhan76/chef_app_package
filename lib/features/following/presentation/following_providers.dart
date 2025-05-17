import 'package:chef_app/features/auth/presentation/auth_providers.dart'; // Assuming this provides currentUser
import 'package:chef_app/features/auth/presentation/gpt_provider.dart';
import 'package:chef_app/features/following/data/firebase_following_repository.dart';
import 'package:chef_app/features/following/domain/following.dart';
import 'package:chef_app/features/following/domain/following_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Provider for the FollowingRepository implementation
final followingRepositoryProvider = Provider<FollowingRepository>((ref) {
  // In a real app, you might inject dependencies like Firestore instance if needed
  return FirebaseFollowingRepository();
});

// Provider to get the list of sellers the current user is following
final followingListProvider = StreamProvider<List<Following>>((ref) {
  final repo = ref.watch(followingRepositoryProvider);
  final currentUser = ref.watch(authProvider).currentUser; // Get current user from auth provider

  if (currentUser == null) {
    // Return an empty stream if no user is logged in
    return Stream.value([]);
  }
  return repo.getFollowingList(currentUser.uid);
});

// Provider to check if the current user is following a specific seller
final isFollowingProvider = StreamProvider.family<bool, String>((ref, sellerId) {
  final repo = ref.watch(followingRepositoryProvider);
  final currentUser = ref.watch(authProvider).currentUser; // Get current user

  if (currentUser == null) {
    // Not following if not logged in
    return Stream.value(false);
  }
  return repo.isFollowing(currentUser.uid, sellerId);
});

// Provider to get the list of followers for a specific seller (might be useful for sellers)
final followersListProvider = StreamProvider.family<List<Following>, String>((ref, sellerId) {
  final repo = ref.watch(followingRepositoryProvider);
  return repo.getFollowersList(sellerId);
});

