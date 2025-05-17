import "package:chef_app/features/auth/presentation/auth_providers.dart";
import "package:chef_app/features/loyalty/presentation/loyalty_providers.dart";
import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";

class LoyaltyScreen extends ConsumerWidget {
  const LoyaltyScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Get current user
    final authState = ref.watch(authStateChangesProvider);

    return authState.when(
      data: (user) {
        if (user == null) {
          // User not logged in, should be handled by router
          return const Scaffold(
            body: Center(child: Text("Not logged in")),
          );
        }

        // Placeholder: Get vendors user has loyalty with
        final vendorsWithLoyaltyAsync = ref.watch(vendorsWithLoyaltyProvider);

        return Scaffold(
          appBar: AppBar(
            title: const Text("Loyalty & Rewards"),
            actions: [
              IconButton(
                icon: const Icon(Icons.logout),
                onPressed: () async {
                  // Sign out
                  await ref.read(authRepositoryProvider).signOut();
                },
              ),
            ],
          ),
          body: vendorsWithLoyaltyAsync.when(
            data: (vendorIds) {
              // Placeholder implementation
              if (vendorIds.isEmpty) {
                return const Center(
                  child: Text("No loyalty points earned yet."),
                );
              }
              // In a real app, you would display loyalty points per vendor
              // and available rewards.
              return ListView.builder(
                itemCount: vendorIds.length,
                itemBuilder: (context, index) {
                  final vendorId = vendorIds[index];
                  // Fetch and display vendor name, points, rewards...
                  return ListTile(
                    title: Text("Vendor ID: $vendorId"),
                    subtitle: const Text("Points: TBD, Rewards: TBD"),
                  );
                },
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, stack) => Center(
              child: Text("Error loading loyalty data: ${error.toString()}"),
            ),
          ),
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: 2, // Loyalty tab
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.home),
                label: "Home",
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.favorite),
                label: "Following",
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.card_giftcard),
                label: "Loyalty",
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person),
                label: "Profile",
              ),
            ],
            onTap: (index) {
              // Handle navigation
              // Will be implemented with go_router later
            },
          ),
        );
      },
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (error, stack) => Scaffold(
        body: Center(
          child: Text("Authentication error: ${error.toString()}"),
        ),
      ),
    );
  }
}

