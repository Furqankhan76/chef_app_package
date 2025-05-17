import 'package:chef_app/features/following/domain/following.dart';

abstract class FollowingRepository {
  Future<void> followSeller(String customerId, String sellerId);
  Future<void> unfollowSeller(String customerId, String sellerId);
  Stream<List<Following>> getFollowingList(String customerId);
  Stream<List<Following>> getFollowersList(String sellerId);
  Stream<bool> isFollowing(String customerId, String sellerId);
}

