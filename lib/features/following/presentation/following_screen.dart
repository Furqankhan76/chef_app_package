import 'package:chef_app/features/auth/presentation/auth_providers.dart'; // Assuming this provides currentUser
import 'package:chef_app/features/auth/presentation/gpt_provider.dart';
import 'package:chef_app/features/following/presentation/following_providers.dart';
import 'package:chef_app/features/user_management/domain/user.dart'; // Import AppUser
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';



class FollowingScreen extends ConsumerWidget {
  const FollowingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final followingListAsync = ref.watch(followingListProvider);
    final currentUser = ref.watch(authProvider).currentUser; // Get current user

    return Scaffold(
      appBar: AppBar(
        title: const Text('Following'), // TODO: Localize
      ),
      body: currentUser == null
          ? const Center(child: Text('Please log in to see your followed sellers.')) // TODO: Localize
          : followingListAsync.when(
              data: (followingList) {
                if (followingList.isEmpty) {
                  return const Center(child: Text('You are not following any sellers yet.')); // TODO: Localize
                }
                return ListView.builder(
                  itemCount: followingList.length,
                  itemBuilder: (context, index) {
                    final follow = followingList[index];
                    // Fetch seller details based on follow.sellerId
                    final sellerAsync = ref.watch(userDetailsProvider(follow.sellerId));

                    return sellerAsync.when(
                      data: (seller) {
                        if (seller == null) {
                          return ListTile(title: Text('Seller not found: ${follow.sellerId}'));
                        }
                        return ListTile(
                          leading: CircleAvatar(
                            backgroundImage: seller.profilePicUrl != null
                                ? NetworkImage(seller.profilePicUrl!)
                                : null, // Placeholder image
                            child: seller.profilePicUrl == null
                                ? const Icon(Icons.storefront)
                                : null,
                          ),
                          title: Text(seller.name ?? 'Unnamed Seller'), // Use seller name
                          // subtitle: Text(seller.someOtherDetail ?? ''), // Add other relevant details
                          trailing: ElevatedButton(
                            onPressed: () {
                              // Implement unfollow logic
                              ref.read(followingRepositoryProvider).unfollowSeller(currentUser.uid, follow.sellerId);
                            },
                            style: ElevatedButton.styleFrom(backgroundColor: Colors.grey),
                            child: const Text('Unfollow'), // TODO: Localize
                          ),
                          onTap: () {
                            // TODO: Navigate to seller profile screen
                            // context.push('/seller/${follow.sellerId}');
                          },
                        );
                      },
                      loading: () => ListTile(
                        title: Text('Loading seller... ${follow.sellerId}'),
                        trailing: const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)),
                      ),
                      error: (err, stack) => ListTile(
                        title: Text('Error loading seller: ${follow.sellerId}'),
                        subtitle: Text('$err'),
                      ),
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => Center(child: Text('Error loading following list: $err')), // TODO: Localize
            ),
    );
  }
}

// Placeholder for userDetailsProvider - replace with actual implementation
final userDetailsProvider = StreamProvider.family<AppUser?, String>((ref, userId) {
  // Replace with actual user repository call
  // final repo = ref.watch(userRepositoryProvider);
  // return repo.getUser(userId);
  return Stream.value(null); // Placeholder
});

