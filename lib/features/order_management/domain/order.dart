import 'package:cloud_firestore/cloud_firestore.dart';

enum OrderStatus {
  pending, // Customer placed, waiting for seller acceptance
  accepted, // Seller accepted, waiting for payment
  paid, // Payment successful, waiting for preparation
  preparing, // Seller is preparing the order
  ready, // Ready for pickup by courier
  outForDelivery, // Courier picked up, en route to customer
  delivered, // Customer received the order
  cancelled, // Order cancelled (e.g., seller declined, payment failed)
  declined // Seller explicitly declined the order
}

class OrderItem {
  final String productId;
  final String name;
  final int quantity;
  final double price; // Price at the time of order

  OrderItem({
    required this.productId,
    required this.name,
    required this.quantity,
    required this.price,
  });

  factory OrderItem.fromMap(Map<String, dynamic> map) {
    return OrderItem(
      productId: map['productId'] ?? '',
      name: map['name'] ?? '',
      quantity: map['quantity'] ?? 0,
      price: (map['price'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'productId': productId,
      'name': name,
      'quantity': quantity,
      'price': price,
    };
  }
}

class Order {
  final String orderId;
  final String customerId;
  final String sellerId;
  final List<OrderItem> items;
  final double subtotal;
  final double deliveryFee; // To be determined/added later
  final double totalAmount;
  final OrderStatus status;
  final Timestamp createdAt;
  final Timestamp updatedAt;
  final String? paymentMethod; // e.g., 'card', 'apple_pay', 'google_pay', 'cod'
  final String? paymentIntentId; // For tracking payment status
  final GeoPoint? deliveryLocation; // Customer's location
  final String? assignedCourierId; // UID of the courier who accepted
  final Timestamp? acceptedAt;
  final Timestamp? paidAt;
  final Timestamp? readyAt;
  final Timestamp? pickedUpAt;
  final Timestamp? deliveredAt;
  final String? cancellationReason; // If cancelled
  final String? declineReason; // If seller declined

  Order({
    required this.orderId,
    required this.customerId,
    required this.sellerId,
    required this.items,
    required this.subtotal,
    required this.deliveryFee,
    required this.totalAmount,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    this.paymentMethod,
    this.paymentIntentId,
    this.deliveryLocation,
    this.assignedCourierId,
    this.acceptedAt,
    this.paidAt,
    this.readyAt,
    this.pickedUpAt,
    this.deliveredAt,
    this.cancellationReason,
    this.declineReason,
  });

  factory Order.fromFirestore(DocumentSnapshot<Map<String, dynamic>> snapshot, SnapshotOptions? options) {
    final data = snapshot.data();
    return Order(
      orderId: snapshot.id,
      customerId: data?['customerId'] ?? '',
      sellerId: data?['sellerId'] ?? '',
      items: (data?['items'] as List<dynamic>? ?? [])
          .map((item) => OrderItem.fromMap(item as Map<String, dynamic>))
          .toList(),
      subtotal: (data?['subtotal'] as num?)?.toDouble() ?? 0.0,
      deliveryFee: (data?['deliveryFee'] as num?)?.toDouble() ?? 0.0,
      totalAmount: (data?['totalAmount'] as num?)?.toDouble() ?? 0.0,
      status: _parseOrderStatus(data?['status']),
      createdAt: data?['createdAt'] ?? Timestamp.now(),
      updatedAt: data?['updatedAt'] ?? Timestamp.now(),
      paymentMethod: data?['paymentMethod'],
      paymentIntentId: data?['paymentIntentId'],
      deliveryLocation: data?['deliveryLocation'],
      assignedCourierId: data?['assignedCourierId'],
      acceptedAt: data?['acceptedAt'],
      paidAt: data?['paidAt'],
      readyAt: data?['readyAt'],
      pickedUpAt: data?['pickedUpAt'],
      deliveredAt: data?['deliveredAt'],
      cancellationReason: data?['cancellationReason'],
      declineReason: data?['declineReason'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'customerId': customerId,
      'sellerId': sellerId,
      'items': items.map((item) => item.toMap()).toList(),
      'subtotal': subtotal,
      'deliveryFee': deliveryFee,
      'totalAmount': totalAmount,
      'status': status.name,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      if (paymentMethod != null) 'paymentMethod': paymentMethod,
      if (paymentIntentId != null) 'paymentIntentId': paymentIntentId,
      if (deliveryLocation != null) 'deliveryLocation': deliveryLocation,
      if (assignedCourierId != null) 'assignedCourierId': assignedCourierId,
      if (acceptedAt != null) 'acceptedAt': acceptedAt,
      if (paidAt != null) 'paidAt': paidAt,
      if (readyAt != null) 'readyAt': readyAt,
      if (pickedUpAt != null) 'pickedUpAt': pickedUpAt,
      if (deliveredAt != null) 'deliveredAt': deliveredAt,
      if (cancellationReason != null) 'cancellationReason': cancellationReason,
      if (declineReason != null) 'declineReason': declineReason,
    };
  }

  static OrderStatus _parseOrderStatus(String? statusString) {
    return OrderStatus.values.firstWhere(
      (e) => e.name == statusString,
      orElse: () => OrderStatus.pending, // Default status
    );
  }
}

