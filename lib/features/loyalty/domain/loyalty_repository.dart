// Repository interface for loyalty operations (Placeholder)
import "./loyalty.dart";

abstract class LoyaltyRepository {
  // Get loyalty points for a user with a specific vendor
  Future<UserLoyalty?> getUserLoyalty(String userId, String vendorId);
  
  // Get available rewards from a vendor
  Future<List<LoyaltyReward>> getVendorRewards(String vendorId);
  
  // Add loyalty points (e.g., after a purchase - likely triggered server-side or by vendor)
  // Future<void> addLoyaltyPoints(String userId, String vendorId, int points);
  
  // Redeem a reward (likely involves checking points and updating)
  // Future<void> redeemReward(String userId, String vendorId, String rewardId);
}
