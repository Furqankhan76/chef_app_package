import 'package:cloud_firestore/cloud_firestore.dart';

class Following {
  final String followingId; // Document ID
  final String customerId;
  final String sellerId;
  final Timestamp followedAt;

  Following({
    required this.followingId,
    required this.customerId,
    required this.sellerId,
    required this.followedAt,
  });

  factory Following.fromFirestore(DocumentSnapshot<Map<String, dynamic>> snapshot, SnapshotOptions? options) {
    final data = snapshot.data();
    return Following(
      followingId: snapshot.id,
      customerId: data?['customerId'] ?? '',
      sellerId: data?['sellerId'] ?? '',
      followedAt: data?['followedAt'] ?? Timestamp.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'customerId': customerId,
      'sellerId': sellerId,
      'followedAt': followedAt,
    };
  }
}

