// Repository interface for vendor profile operations
import "./vendor.dart";

abstract class VendorProfileRepository {
  // Get vendor profile data
  Future<Vendor> getVendorProfile(String uid);
  
  // Create or update vendor profile data
  Future<void> updateVendorProfile(Vendor vendor);
  
  // Stream of vendor profile changes (optional, if needed for real-time updates)
  // Stream<Vendor> getVendorProfileStream(String uid);
  
  // Upload profile photo and return URL
  Future<String> uploadProfilePhoto(String uid, String filePath);
}
