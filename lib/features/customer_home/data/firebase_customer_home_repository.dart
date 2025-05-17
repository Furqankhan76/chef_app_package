import "package:chef_app/features/vendor_profile/domain/vendor.dart";
import "package:cloud_firestore/cloud_firestore.dart";
import "../domain/customer_home_repository.dart";

class FirebaseCustomerHomeRepository implements CustomerHomeRepository {
  final FirebaseFirestore _firestore;

  FirebaseCustomerHomeRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Future<List<Vendor>> getVendors() async {
    try {
      final snapshot = await _firestore.collection("vendors").get();
      return snapshot.docs.map((doc) => _vendorFromFirestore(doc)).toList();
    } catch (e) {
      throw Exception("Failed to get vendors: ${e.toString()}");
    }
  }

  // Helper to convert Firestore doc to Vendor object (copied from VendorProfile repo)
  Vendor _vendorFromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Vendor(
      uid: doc.id,
      businessName: data["businessName"] ?? "",
      description: data["description"] ?? "",
      profilePhotos: List<String>.from(data["profilePhotos"] ?? []),
      sharableLink: data["sharableLink"] ?? "",
      followerCount: data["followerCount"] ?? 0,
      createdAt: (data["createdAt"] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data["updatedAt"] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
}

