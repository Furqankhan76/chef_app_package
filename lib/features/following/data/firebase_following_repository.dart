import 'package:chef_app/features/following/domain/following.dart';
import 'package:chef_app/features/following/domain/following_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseFollowingRepository implements FollowingRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference<Following> get _followingRef =>
      _firestore.collection('follows').withConverter<Following>(
            fromFirestore: Following.fromFirestore,
            toFirestore: (Following following, _) => following.toFirestore(),
          );

  // Helper to get the document ID for a specific follow relationship
  String _getFollowDocId(String customerId, String sellerId) {
    return '${customerId}_$sellerId';
  }

  @override
  Future<void> followSeller(String customerId, String sellerId) async {
    final followDocId = _getFollowDocId(customerId, sellerId);
    final followData = Following(
      followingId: followDocId, // Use composite key as ID
      customerId: customerId,
      sellerId: sellerId,
      followedAt: Timestamp.now(),
    );
    // Use set with merge:true or check existence first if needed, but set should overwrite if exists
    await _followingRef.doc(followDocId).set(followData);

    // Optional: Update follower count on the seller's profile (denormalization)
    // This requires access to the UserRepository or a dedicated function
    // await _updateFollowerCount(sellerId, 1);
  }

  @override
  Future<void> unfollowSeller(String customerId, String sellerId) async {
    final followDocId = _getFollowDocId(customerId, sellerId);
    await _followingRef.doc(followDocId).delete();

    // Optional: Update follower count on the seller's profile (denormalization)
    // await _updateFollowerCount(sellerId, -1);
  }

  @override
  Stream<List<Following>> getFollowingList(String customerId) {
    return _followingRef
        .where('customerId', isEqualTo: customerId)
        .orderBy('followedAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => doc.data()).toList());
  }

  @override
  Stream<List<Following>> getFollowersList(String sellerId) {
    return _followingRef
        .where('sellerId', isEqualTo: sellerId)
        .orderBy('followedAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => doc.data()).toList());
  }

  @override
  Stream<bool> isFollowing(String customerId, String sellerId) {
    final followDocId = _getFollowDocId(customerId, sellerId);
    return _followingRef.doc(followDocId).snapshots().map((snapshot) => snapshot.exists);
  }

  // Example helper for denormalization (implement if needed)
  // Future<void> _updateFollowerCount(String sellerId, int change) async {
  //   final sellerRef = _firestore.collection('users').doc(sellerId);
  //   await sellerRef.update({'followerCount': FieldValue.increment(change)});
  // }
}

