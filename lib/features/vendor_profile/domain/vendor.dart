// Domain layer entity for Vendor Profile

class Vendor {
  final String uid; // Corresponds to the User UID
  final String businessName;
  final String description;
  final List<String> profilePhotos; // URLs
  final String sharableLink; // Unique link
  final int followerCount;
  final DateTime createdAt;
  final DateTime updatedAt;

  // Potentially add products as a sub-collection or separate entity list

  Vendor({
    required this.uid,
    required this.businessName,
    required this.description,
    this.profilePhotos = const [],
    required this.sharableLink,
    this.followerCount = 0,
    required this.createdAt,
    required this.updatedAt,
  });

  // Add copyWith, toJson, fromJson methods as needed for Firestore
  // Example fromJson (adjust based on actual Firestore structure):
  // factory Vendor.fromFirestore(DocumentSnapshot doc) {
  //   Map data = doc.data() as Map<String, dynamic>;
  //   return Vendor(
  //     uid: doc.id,
  //     businessName: data["businessName"] ?? ",
  //     description: data["description"] ?? ",
  //     profilePhotos: List<String>.from(data["profilePhotos"] ?? []),
  //     sharableLink: data["sharableLink"] ?? ",
  //     followerCount: data["followerCount"] ?? 0,
  //     createdAt: (data["createdAt"] as Timestamp?)?.toDate() ?? DateTime.now(),
  //     updatedAt: (data["updatedAt"] as Timestamp?)?.toDate() ?? DateTime.now(),
  //   );
  // }
}
