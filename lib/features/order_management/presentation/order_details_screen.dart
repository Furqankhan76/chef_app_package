import 'package:chef_app/core/services/payment_service.dart';
import 'package:chef_app/features/order_management/data/firebase_order_repository.dart';
import 'package:chef_app/features/order_management/domain/order.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Provider to fetch a specific order by ID
final orderDetailsProvider = StreamProvider.family<Order?, String>((ref, orderId) {
  final orderRepository = ref.watch(orderRepositoryProvider);
  return orderRepository.getOrderById(orderId);
});

class OrderDetailsScreen extends ConsumerStatefulWidget {
  final String orderId;

  const OrderDetailsScreen({super.key, required this.orderId});

  @override
  ConsumerState<OrderDetailsScreen> createState() => _OrderDetailsScreenState();
}

class _OrderDetailsScreenState extends ConsumerState<OrderDetailsScreen> {
  bool _isPaying = false;

  Future<void> _processPayment(Order order) async {
    setState(() {
      _isPaying = true;
    });

    try {
      final paymentService = ref.read(paymentServiceProvider);
      final success = await paymentService.handlePayment(order);

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Payment Successful! Order status updated.')), // TODO: Localize
        );
        // Optionally navigate away or update UI further
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Payment failed or was cancelled.')), // TODO: Localize
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Payment Error: $e')), // TODO: Localize
      );
    } finally {
      if (mounted) {
        setState(() {
          _isPaying = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final orderAsync = ref.watch(orderDetailsProvider(widget.orderId));

    return Scaffold(
      appBar: AppBar(
        title: Text('Order Details: ${widget.orderId}'), // TODO: Localize
      ),
      body: orderAsync.when(
        data: (order) {
          if (order == null) {
            return const Center(child: Text('Order not found.')); // TODO: Localize
          }

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: ListView(
              children: [
                Text('Order ID: ${order.orderId}', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 8),
                Text('Status: ${order.status.name}'), // TODO: Localize status
                const SizedBox(height: 8),
                Text('Seller ID: ${order.sellerId}'),
                const SizedBox(height: 8),
                Text('Total Amount: ${order.totalAmount.toStringAsFixed(2)} SAR'), // TODO: Localize currency
                const SizedBox(height: 16),
                const Text('Items:', style: TextStyle(fontWeight: FontWeight.bold)),
                ...order.items.map((item) => ListTile(
                      title: Text(item.name),
                      subtitle: Text('Quantity: ${item.quantity}'),
                      trailing: Text('${item.price.toStringAsFixed(2)} SAR'),
                    )),
                const Divider(),
                // Add more details as needed (delivery address, timestamps, etc.)

                const SizedBox(height: 24),

                // Payment Button (only show if order needs payment)
                if (order.status == OrderStatus.pending || order.status == OrderStatus.accepted) // Example statuses requiring payment
                  _isPaying
                      ? const Center(child: CircularProgressIndicator())
                      : ElevatedButton.icon(
                          icon: const Icon(Icons.payment),
                          label: const Text('Pay Now'), // TODO: Localize
                          onPressed: () => _processPayment(order),
                          style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 12)),
                        ),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text('Error loading order details: $err'), // TODO: Localize
          ),
        ),
      ),
    );
  }
}

