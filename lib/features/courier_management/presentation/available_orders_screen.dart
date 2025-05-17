import 'package:chef_app/core/services/location_service.dart';
import 'package:chef_app/features/auth/presentation/auth_providers.dart'; // For current user ID
import 'package:chef_app/features/auth/presentation/gpt_provider.dart';
import 'package:chef_app/features/following/presentation/following_screen.dart';
import 'package:chef_app/features/order_management/data/firebase_order_repository.dart'; // Import provider
import 'package:chef_app/features/order_management/domain/order.dart';
import 'package:chef_app/features/user_management/domain/user.dart'; // For Seller details
import 'package:cloud_firestore/cloud_firestore.dart' hide Order; // For GeoPoint
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart'; // For Position

// Provider to fetch available orders based on current location
final availableOrdersProvider = StreamProvider<List<Order>>((ref) async* {
  final locationService = ref.watch(locationServiceProvider);
  final orderRepository = ref.watch(orderRepositoryProvider);

  try {
    // Get current location first
    final Position position = await locationService.getCurrentLocation();
    final currentLocation = GeoPoint(position.latitude, position.longitude);

    // Yield the stream of available orders based on location
    // Note: The repository currently does client-side filtering, which might need optimization
    yield* orderRepository.getAvailableOrdersForCouriers(currentLocation);

  } catch (e) {
    print('Error getting location for available orders: $e');
    // Yield an error state
    throw Exception('Could not fetch available orders due to location error: $e');
  }
});

class AvailableOrdersScreen extends ConsumerWidget {
  const AvailableOrdersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final availableOrdersAsync = ref.watch(availableOrdersProvider);
    final currentUser = ref.watch(authProvider).currentUser;
    final locationService = ref.watch(locationServiceProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Available Orders Nearby'), // TODO: Localize
      ),
      body: availableOrdersAsync.when(
        data: (orders) {
          if (orders.isEmpty) {
            return const Center(child: Text('No available orders nearby at the moment.')); // TODO: Localize
          }
          return RefreshIndicator(
            onRefresh: () => ref.refresh(availableOrdersProvider.future),
            child: ListView.builder(
              itemCount: orders.length,
              itemBuilder: (context, index) {
                final order = orders[index];
                // Fetch seller details for display
                final sellerAsync = ref.watch(userDetailsProvider(order.sellerId));

                // Calculate distance (requires current courier location, refetch or use cached)
                // For simplicity, let's assume we have the courier's location from the initial fetch
                // In a real app, might need a separate provider for current courier position
                String distanceText = 'Calculating...';
                // This part is tricky without a consistent courier location provider
                // final currentCourierPos = ref.watch(currentCourierPositionProvider); // Hypothetical provider
                // if (currentCourierPos != null && order.deliveryLocation != null) {
                //   final distance = locationService.calculateDistance(
                //     currentCourierPos.latitude, currentCourierPos.longitude,
                //     order.deliveryLocation!.latitude, order.deliveryLocation!.longitude,
                //   );
                //   distanceText = '${(distance / 1000).toStringAsFixed(1)} km away'; // TODO: Localize
                // }

                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  child: ListTile(
                    title: Text('Order from: ${sellerAsync.when(
                      data: (seller) => seller?.name ?? order.sellerId,
                      loading: () => 'Loading...', 
                      error: (e,s) => 'Error',
                    )}'),
                    subtitle: Text(
                      'Total: ${order.totalAmount.toStringAsFixed(2)} SAR\n' // TODO: Localize currency
                      // 'Distance: $distanceText\n' // Add distance display
                      'Items: ${order.items.map((i) => i.name).join(', ')}'
                    ),
                    isThreeLine: true,
                    trailing: ElevatedButton(
                      onPressed: currentUser == null
                          ? null
                          : () async {
                              try {
                                // Show confirmation dialog
                                final confirmed = await showDialog<bool>(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    title: const Text('Accept Order?'), // TODO: Localize
                                    content: Text('Accept order ${order.orderId}?'), // TODO: Localize
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.of(context).pop(false),
                                        child: const Text('Cancel'), // TODO: Localize
                                      ),
                                      TextButton(
                                        onPressed: () => Navigator.of(context).pop(true),
                                        child: const Text('Accept'), // TODO: Localize
                                      ),
                                    ],
                                  ),
                                );

                                if (confirmed == true) {
                                  await ref.read(orderRepositoryProvider).assignCourierToOrder(order.orderId, currentUser.uid);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('Order ${order.orderId} accepted!')), // TODO: Localize
                                  );
                                  // Optionally navigate to courier's active orders screen
                                }
                              } catch (e) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Failed to accept order: $e')), // TODO: Localize
                                );
                              }
                            },
                      child: const Text('Accept'), // TODO: Localize
                    ),
                    onTap: () {
                      // TODO: Navigate to order details screen
                      // context.push('/order/${order.orderId}');
                    },
                  ),
                );
              },
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Error loading available orders: $err'), // TODO: Localize
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () => ref.refresh(availableOrdersProvider),
                  child: const Text('Retry'), // TODO: Localize
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Placeholder for userDetailsProvider - replace with actual implementation if not already done
// final userDetailsProvider = StreamProvider.family<AppUser?, String>((ref, userId) {
//   final repo = ref.watch(userRepositoryProvider);
//   return repo.getUser(userId);
// });
