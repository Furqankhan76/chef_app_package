// Repository interface for customer home operations
import "package:chef_app/features/vendor_profile/domain/vendor.dart";

abstract class CustomerHomeRepository {
  // Get a list of vendors (potentially with pagination/filtering)
  Future<List<Vendor>> getVendors();
  
  // Search vendors (optional, based on requirements)
  // Future<List<Vendor>> searchVendors(String query);
}
