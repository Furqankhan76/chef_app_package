import 'package:cloud_firestore/cloud_firestore.dart';

enum CustomRequestStatus {
  pending, // Customer submitted, waiting for seller review
  approved, // Seller approved, set price, waiting for customer confirmation
  declined, // Seller declined the request
  confirmed, // Customer confirmed the price, waiting for payment
  paid, // Customer paid, request becomes an order or similar
  cancelled // Request cancelled (e.g., customer didn't confirm/pay)
}

class CustomRequest {
  final String requestId;
  final String customerId;
  final String sellerId;
  final String? productId; // Optional: if based on an existing product
  final String requestName;
  final String requestDescription;
  final CustomRequestStatus status;
  final String? sellerDeclineReason;
  final double? proposedPrice; // Set by seller upon approval
  final Timestamp createdAt;
  final Timestamp updatedAt;
  final Timestamp? approvedAt;
  final Timestamp? confirmedAt;
  final Timestamp? paidAt;

  CustomRequest({
    required this.requestId,
    required this.customerId,
    required this.sellerId,
    this.productId,
    required this.requestName,
    required this.requestDescription,
    required this.status,
    this.sellerDeclineReason,
    this.proposedPrice,
    required this.createdAt,
    required this.updatedAt,
    this.approvedAt,
    this.confirmedAt,
    this.paidAt,
  });

  factory CustomRequest.fromFirestore(DocumentSnapshot<Map<String, dynamic>> snapshot, SnapshotOptions? options) {
    final data = snapshot.data();
    return CustomRequest(
      requestId: snapshot.id,
      customerId: data?['customerId'] ?? '',
      sellerId: data?['sellerId'] ?? '',
      productId: data?['productId'],
      requestName: data?['requestName'] ?? '',
      requestDescription: data?['requestDescription'] ?? '',
      status: _parseCustomRequestStatus(data?['status']),
      sellerDeclineReason: data?['sellerDeclineReason'],
      proposedPrice: (data?['proposedPrice'] as num?)?.toDouble(),
      createdAt: data?['createdAt'] ?? Timestamp.now(),
      updatedAt: data?['updatedAt'] ?? Timestamp.now(),
      approvedAt: data?['approvedAt'],
      confirmedAt: data?['confirmedAt'],
      paidAt: data?['paidAt'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'customerId': customerId,
      'sellerId': sellerId,
      if (productId != null) 'productId': productId,
      'requestName': requestName,
      'requestDescription': requestDescription,
      'status': status.name,
      if (sellerDeclineReason != null) 'sellerDeclineReason': sellerDeclineReason,
      if (proposedPrice != null) 'proposedPrice': proposedPrice,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      if (approvedAt != null) 'approvedAt': approvedAt,
      if (confirmedAt != null) 'confirmedAt': confirmedAt,
      if (paidAt != null) 'paidAt': paidAt,
    };
  }

  static CustomRequestStatus _parseCustomRequestStatus(String? statusString) {
    return CustomRequestStatus.values.firstWhere(
      (e) => e.name == statusString,
      orElse: () => CustomRequestStatus.pending, // Default status
    );
  }
}

