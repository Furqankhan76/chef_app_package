import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// TODO: Import following providers (repository, isFollowingProvider)
// TODO: Import auth provider (to get current user ID)

// Example provider definitions (replace with actual providers)
// final followingRepositoryProvider = Provider<FollowingRepository>((ref) => ...);
// final currentUserProvider = Provider<AppUser?>((ref) => ...);
// final isFollowingProvider = StreamProvider.family<bool, String>((ref, sellerId) {
//   final repo = ref.watch(followingRepositoryProvider);
//   final currentUser = ref.watch(currentUserProvider);
//   if (currentUser == null) return Stream.value(false);
//   return repo.isFollowing(currentUser.uid, sellerId);
// });

class FollowButton extends ConsumerWidget {
  final String sellerId;

  const FollowButton({super.key, required this.sellerId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // TODO: Replace placeholder providers with actual ones
    // final isFollowingAsync = ref.watch(isFollowingProvider(sellerId));
    // final currentUser = ref.watch(currentUserProvider);

    // Placeholder data for demonstration
    final isFollowingAsync = AsyncData(false); // Assume not following initially
    final currentUser = null; // Assume no user logged in for placeholder

    return isFollowingAsync.when(
      data: (isFollowing) {
        return ElevatedButton(
          onPressed: currentUser == null
              ? null // Disable if no user logged in
              : () {
                  // TODO: Implement follow/unfollow logic
                  // final repo = ref.read(followingRepositoryProvider);
                  // if (isFollowing) {
                  //   repo.unfollowSeller(currentUser.uid, sellerId);
                  // } else {
                  //   repo.followSeller(currentUser.uid, sellerId);
                  // }
                },
          style: ElevatedButton.styleFrom(
            backgroundColor: isFollowing ? Colors.grey : Theme.of(context).primaryColor,
            foregroundColor: Colors.white,
          ),
          child: Text(isFollowing ? 'Unfollow' : 'Follow'), // TODO: Localize
        );
      },
      loading: () => const ElevatedButton(
        onPressed: null,
        child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)),
      ),
      error: (err, stack) => ElevatedButton(
        onPressed: null,
        child: const Icon(Icons.error_outline, color: Colors.red),
      ),
    );
  }
}

