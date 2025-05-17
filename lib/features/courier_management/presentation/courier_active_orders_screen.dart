import 'package:chef_app/features/auth/presentation/auth_providers.dart';
import 'package:chef_app/features/auth/presentation/gpt_provider.dart';
import 'package:chef_app/features/following/presentation/following_screen.dart';
import 'package:chef_app/features/order_management/data/firebase_order_repository.dart';
import 'package:chef_app/features/order_management/domain/order.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Provider to get orders assigned to the current courier
final courierActiveOrdersProvider = StreamProvider<List<Order>>((ref) {
  final orderRepository = ref.watch(orderRepositoryProvider);
  final currentUser = ref.watch(authProvider).currentUser;

  if (currentUser == null) {
    return Stream.value([]); // No orders if not logged in
  }
  // Fetch orders where assignedCourierId matches and status is suitable (e.g., outForDelivery)
  // The existing getOrdersByCourier might need refinement based on status
  return orderRepository.getOrdersByCourier(currentUser.uid).map((orders) {
    // Filter for orders that are currently active for delivery
    return orders.where((order) => 
      order.status == OrderStatus.outForDelivery || 
      order.status == OrderStatus.ready // Or maybe 'accepted' if that's a state before pickup
    ).toList();
  });
});

class CourierActiveOrdersScreen extends ConsumerWidget {
  const CourierActiveOrdersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeOrdersAsync = ref.watch(courierActiveOrdersProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Active Deliveries'), // TODO: Localize
      ),
      body: activeOrdersAsync.when(
        data: (orders) {
          if (orders.isEmpty) {
            return const Center(child: Text('You have no active deliveries right now.')); // TODO: Localize
          }
          return RefreshIndicator(
            onRefresh: () => ref.refresh(courierActiveOrdersProvider.future),
            child: ListView.builder(
              itemCount: orders.length,
              itemBuilder: (context, index) {
                final order = orders[index];
                final sellerAsync = ref.watch(userDetailsProvider(order.sellerId));
                final customerAsync = ref.watch(userDetailsProvider(order.customerId));

                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  child: ListTile(
                    title: Text('Order ID: ${order.orderId}'),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Status: ${order.status.name}'), // TODO: Localize status
                        sellerAsync.when(
                          data: (seller) => Text('From: ${seller?.name ?? order.sellerId}'),
                          loading: () => const Text('From: Loading...'),
                          error: (e, s) => const Text('From: Error'),
                        ),
                        customerAsync.when(
                          data: (customer) => Text('To: ${customer?.name ?? order.customerId}'),
                          loading: () => const Text('To: Loading...'),
                          error: (e, s) => const Text('To: Error'),
                        ),
                        // TODO: Add address details if available
                      ],
                    ),
                    isThreeLine: true, // Adjust based on content
                    trailing: _buildActionButton(context, ref, order),
                    onTap: () {
                      // TODO: Navigate to detailed order view with map/directions?
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
                Text('Error loading active orders: $err'), // TODO: Localize
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () => ref.refresh(courierActiveOrdersProvider),
                  child: const Text('Retry'), // TODO: Localize
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Helper to build the appropriate action button based on order status
  Widget _buildActionButton(BuildContext context, WidgetRef ref, Order order) {
    VoidCallback? onPressed;
    String buttonText = '';

    switch (order.status) {
      case OrderStatus.ready: // Assuming 'ready' means ready for pickup
        buttonText = 'Mark Picked Up'; // TODO: Localize
        onPressed = () async {
          try {
            await ref.read(orderRepositoryProvider).updateOrderStatus(order.orderId, OrderStatus.outForDelivery);
             ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Order ${order.orderId} marked as picked up!')), // TODO: Localize
              );
          } catch (e) {
             ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Failed to update status: $e')), // TODO: Localize
              );
          }
        };
        break;
      case OrderStatus.outForDelivery:
        buttonText = 'Mark Delivered'; // TODO: Localize
        onPressed = () async {
           try {
            await ref.read(orderRepositoryProvider).updateOrderStatus(order.orderId, OrderStatus.delivered);
             ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Order ${order.orderId} marked as delivered!')), // TODO: Localize
              );
          } catch (e) {
             ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Failed to update status: $e')), // TODO: Localize
              );
          }
        };
        break;
      default:
        // No action for other statuses like pending, delivered, cancelled etc.
        buttonText = order.status.name; // Display current status
        onPressed = null;
    }

    return ElevatedButton(
      onPressed: onPressed,
      child: Text(buttonText),
    );
  }
}

