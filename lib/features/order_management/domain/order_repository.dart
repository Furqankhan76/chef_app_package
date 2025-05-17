import 'package:chef_app/features/order_management/domain/order.dart';
import 'package:chef_app/features/order_management/domain/custom_request.dart';
import 'package:cloud_firestore/cloud_firestore.dart' hide Order;

abstract class OrderRepository {
  Future<String> createOrder(Order order);
  Future<void> updateOrderStatus(String orderId, OrderStatus newStatus, {String? reason});
  Stream<Order?> getOrderById(String orderId);
  Stream<List<Order>> getOrdersByCustomer(String customerId);
  Stream<List<Order>> getOrdersBySeller(String sellerId);
  Stream<List<Order>> getOrdersByCourier(String courierId);
  Stream<List<Order>> getAvailableOrdersForCouriers(GeoPoint courierLocation); // For courier discovery
  Future<void> assignCourierToOrder(String orderId, String courierId);

  // Custom Requests
  Future<String> createCustomRequest(CustomRequest request);
  Future<void> updateCustomRequestStatus(String requestId, CustomRequestStatus newStatus, {String? reason, double? price});
  Stream<CustomRequest?> getCustomRequestById(String requestId);
  Stream<List<CustomRequest>> getCustomRequestsByCustomer(String customerId);
  Stream<List<CustomRequest>> getCustomRequestsBySeller(String sellerId);
}

