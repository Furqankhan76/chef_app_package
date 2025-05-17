import 'package:cloud_firestore/cloud_firestore.dart';

class Product {
  final String productId;
  final String sellerId;
  final String name; // Cannot be edited after creation
  final String description;
  final double price;
  final String category;
  final List<String> photos; // URLs
  final bool isActive;
  final bool allowsCustomRequest;
  final Timestamp createdAt;
  final Timestamp updatedAt;

  Product({
    required this.productId,
    required this.sellerId,
    required this.name,
    required this.description,
    required this.price,
    required this.category,
    required this.photos,
    required this.isActive,
    required this.allowsCustomRequest,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Product.fromFirestore(DocumentSnapshot<Map<String, dynamic>> snapshot, SnapshotOptions? options) {
    final data = snapshot.data();
    return Product(
      productId: snapshot.id,
      sellerId: data?['sellerId'] ?? '',
      name: data?['name'] ?? '',
      description: data?['description'] ?? '',
      price: (data?['price'] as num?)?.toDouble() ?? 0.0,
      category: data?['category'] ?? '',
      photos: List<String>.from(data?['photos'] ?? []),
      isActive: data?['isActive'] ?? true,
      allowsCustomRequest: data?['allowsCustomRequest'] ?? false,
      createdAt: data?['createdAt'] ?? Timestamp.now(),
      updatedAt: data?['updatedAt'] ?? Timestamp.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'sellerId': sellerId,
      'name': name,
      'description': description,
      'price': price,
      'category': category,
      'photos': photos,
      'isActive': isActive,
      'allowsCustomRequest': allowsCustomRequest,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }
}

