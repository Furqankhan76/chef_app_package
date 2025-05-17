import "package:chef_app/features/promotions/domain/promotion.dart";
import "package:chef_app/features/promotions/domain/promotion_repository.dart";
import "package:cloud_firestore/cloud_firestore.dart";

class FirebasePromotionRepository implements PromotionRepository {
  final FirebaseFirestore _firestore;

  FirebasePromotionRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Future<List<Promotion>> getVendorPromotions(String vendorId) async {
    try {
      final now = DateTime.now();
      final snapshot = await _firestore
          .collection("vendors")
          .doc(vendorId)
          .collection("promotions")
          .where("endDate", isGreaterThanOrEqualTo: now) // Only active promotions
          .orderBy("endDate")
          .get();

      return snapshot.docs.map((doc) => _promotionFromFirestore(doc)).toList();
    } catch (e) {
      throw Exception("Failed to get vendor promotions: ${e.toString()}");
    }
  }

  @override
  Future<List<Promotion>> getFollowedVendorsPromotions(String userId) async {
    try {
      // Get list of followed vendors
      final followingSnapshot = await _firestore
          .collection("users")
          .doc(userId)
          .collection("following")
          .get();

      if (followingSnapshot.docs.isEmpty) {
        return [];
      }

      final vendorIds = followingSnapshot.docs.map((doc) => doc.id).toList();
      final now = DateTime.now();
      final promotions = <Promotion>[];

      // For each vendor, get their promotions
      // Note: This is inefficient for large numbers of vendors
      // A better approach would be to use a cloud function or a different data structure
      for (final vendorId in vendorIds) {
        final vendorPromotions = await getVendorPromotions(vendorId);
        promotions.addAll(vendorPromotions);
      }

      // Sort by end date (soonest first)
      promotions.sort((a, b) => a.endDate.compareTo(b.endDate));
      return promotions;
    } catch (e) {
      throw Exception("Failed to get followed vendors promotions: ${e.toString()}");
    }
  }

  // Helper to convert Firestore doc to Promotion object
  Promotion _promotionFromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Promotion(
      id: doc.id,
      vendorId: data["vendorId"] ?? "",
      title: data["title"] ?? "",
      description: data["description"] ?? "",
      startDate: (data["startDate"] as Timestamp?)?.toDate() ?? DateTime.now(),
      endDate: (data["endDate"] as Timestamp?)?.toDate() ?? DateTime.now().add(const Duration(days: 7)),
      imageUrl: data["imageUrl"],
    );
  }
}
