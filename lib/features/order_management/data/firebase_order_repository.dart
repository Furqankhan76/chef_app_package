import 'package:chef_app/core/services/location_service.dart'; // Import LocationService
import 'package:chef_app/features/order_management/domain/custom_request.dart';
import 'package:chef_app/features/order_management/domain/order.dart';
import 'package:chef_app/features/order_management/domain/order_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart' hide Order;
import 'package:flutter_riverpod/flutter_riverpod.dart'; // Import Ref for LocationService

class FirebaseOrderRepository implements OrderRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final Ref _ref; // Add Ref to access other providers like LocationService

  FirebaseOrderRepository(this._ref); // Constructor to accept Ref

  CollectionReference<Order> get _ordersRef =>
      _firestore.collection('orders').withConverter<Order>(
            fromFirestore: Order.fromFirestore,
            toFirestore: (Order order, _) => order.toFirestore(),
          );

  CollectionReference<CustomRequest> get _customRequestsRef =>
      _firestore.collection('custom_requests').withConverter<CustomRequest>(
            fromFirestore: CustomRequest.fromFirestore,
            toFirestore: (CustomRequest request, _) => request.toFirestore(),
          );

  @override
  Future<String> createOrder(Order order) async {
    final docRef = await _ordersRef.add(order);
    return docRef.id;
  }

  @override
  Future<void> updateOrderStatus(String orderId, OrderStatus newStatus, {String? reason}) async {
    final updateData = {
      'status': newStatus.name,
      'updatedAt': Timestamp.now(),
    };
    if (newStatus == OrderStatus.cancelled && reason != null) {
      updateData['cancellationReason'] = reason;
    }
    if (newStatus == OrderStatus.declined && reason != null) {
      updateData['declineReason'] = reason;
    }
    // Add timestamps for specific statuses
    switch (newStatus) {
      case OrderStatus.accepted:
        updateData['acceptedAt'] = Timestamp.now();
        break;
      case OrderStatus.paid:
        updateData['paidAt'] = Timestamp.now();
        break;
      case OrderStatus.ready:
        updateData['readyAt'] = Timestamp.now();
        break;
      case OrderStatus.outForDelivery:
        updateData['pickedUpAt'] = Timestamp.now();
        break;
      case OrderStatus.delivered:
        updateData['deliveredAt'] = Timestamp.now();
        break;
      default:
        break;
    }
    await _ordersRef.doc(orderId).update(updateData);
  }

  @override
  Stream<Order?> getOrderById(String orderId) {
    return _ordersRef.doc(orderId).snapshots().map((snapshot) => snapshot.data());
  }

  @override
  Stream<List<Order>> getOrdersByCustomer(String customerId) {
    return _ordersRef
        .where('customerId', isEqualTo: customerId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => doc.data()).toList());
  }

  @override
  Stream<List<Order>> getOrdersBySeller(String sellerId) {
    return _ordersRef
        .where('sellerId', isEqualTo: sellerId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => doc.data()).toList());
  }

  @override
  Stream<List<Order>> getOrdersByCourier(String courierId) {
    return _ordersRef
        .where('assignedCourierId', isEqualTo: courierId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => doc.data()).toList());
  }

  @override
  Stream<List<Order>> getAvailableOrdersForCouriers(GeoPoint courierLocation) {
    // Basic implementation: Fetch orders ready for pickup
    // TODO: Implement more sophisticated geo-querying if needed (e.g., using Geoflutterfire or backend functions)
    return _ordersRef
        .where('status', isEqualTo: OrderStatus.ready.name)
        .orderBy('createdAt', descending: false) // Oldest ready orders first?
        .snapshots()
        .map((snapshot) {
          final orders = snapshot.docs.map((doc) => doc.data()).toList();
          // Optional: Client-side filtering by distance (can be inefficient for large datasets)
          final locationService = _ref.read(locationServiceProvider);
          orders.removeWhere((order) {
            if (order.deliveryLocation == null) return true; // Remove if no delivery location
            // Example: Filter orders within 10km (adjust radius as needed)
            final distance = locationService.calculateDistance(
              courierLocation.latitude,
              courierLocation.longitude,
              order.deliveryLocation!.latitude, // Assuming courier picks up from seller, filter by seller location?
              order.deliveryLocation!.longitude, // Or filter by customer location? Needs clarification.
            );
            return distance > 10000; // 10km radius
          });
          return orders;
        });
  }

  @override
  Future<void> assignCourierToOrder(String orderId, String courierId) async {
    await _ordersRef.doc(orderId).update({
      'assignedCourierId': courierId,
      'status': OrderStatus.outForDelivery.name, // Update status when courier accepts
      'pickedUpAt': Timestamp.now(),
      'updatedAt': Timestamp.now(),
    });
  }

  // --- Custom Requests --- 

  @override
  Future<String> createCustomRequest(CustomRequest request) async {
    final docRef = await _customRequestsRef.add(request);
    return docRef.id;
  }

  @override
  Future<void> updateCustomRequestStatus(String requestId, CustomRequestStatus newStatus, {String? reason, double? price}) async {
     final updateData = {
      'status': newStatus.name,
      'updatedAt': Timestamp.now(),
    };
    if (newStatus == CustomRequestStatus.declined && reason != null) {
      updateData['sellerDeclineReason'] = reason;
    }
    if (newStatus == CustomRequestStatus.approved && price != null) {
      updateData['proposedPrice'] = price;
      updateData['approvedAt'] = Timestamp.now();
    }
     if (newStatus == CustomRequestStatus.confirmed) {
      updateData['confirmedAt'] = Timestamp.now();
    }
     if (newStatus == CustomRequestStatus.paid) {
      updateData['paidAt'] = Timestamp.now();
    }
    await _customRequestsRef.doc(requestId).update(updateData);
  }

  @override
  Stream<CustomRequest?> getCustomRequestById(String requestId) {
     return _customRequestsRef.doc(requestId).snapshots().map((snapshot) => snapshot.data());
  }

  @override
  Stream<List<CustomRequest>> getCustomRequestsByCustomer(String customerId) {
     return _customRequestsRef
        .where('customerId', isEqualTo: customerId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => doc.data()).toList());
  }

  @override
  Stream<List<CustomRequest>> getCustomRequestsBySeller(String sellerId) {
     return _customRequestsRef
        .where('sellerId', isEqualTo: sellerId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => doc.data()).toList());
  }
}

// Provider for the OrderRepository implementation
final orderRepositoryProvider = Provider<OrderRepository>((ref) {
  return FirebaseOrderRepository(ref); // Pass ref to the repository
});

