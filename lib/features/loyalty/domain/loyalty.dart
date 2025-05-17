// Domain layer entity for Loyalty Points/Rewards (Placeholder)
class LoyaltyReward {
  final String id;
  final String vendorId;
  final String description;
  final int pointsRequired;

  LoyaltyReward({
    required this.id,
    required this.vendorId,
    required this.description,
    required this.pointsRequired,
  });
}

class UserLoyalty {
  final String userId;
  final String vendorId;
  final int points;

  UserLoyalty({
    required this.userId,
    required this.vendorId,
    required this.points,
  });
}
