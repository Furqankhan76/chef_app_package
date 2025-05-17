// Repository interface for promotions operations (Placeholder)
import "./promotion.dart";

abstract class PromotionRepository {
  // Get promotions from a specific vendor
  Future<List<Promotion>> getVendorPromotions(String vendorId);
  
  // Get promotions from followed vendors (more complex query)
  Future<List<Promotion>> getFollowedVendorsPromotions(String userId);
  
  // Create a promotion (Vendor only)
  // Future<void> createPromotion(Promotion promotion);
  
  // Update a promotion (Vendor only)
  // Future<void> updatePromotion(Promotion promotion);
  
  // Delete a promotion (Vendor only)
  // Future<void> deletePromotion(String promotionId);
}
