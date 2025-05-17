import 'package:chef_app/features/customer_home/data/firebase_customer_home_repository.dart';
import 'package:chef_app/features/customer_home/domain/customer_home_repository.dart';
import 'package:chef_app/features/vendor_profile/domain/vendor.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Provider for the CustomerHomeRepository implementation
final customerHomeRepositoryProvider = Provider<CustomerHomeRepository>((ref) {
  return FirebaseCustomerHomeRepository();
});

// Provider for the list of vendors
final vendorsProvider = FutureProvider<List<Vendor>>((ref) async {
  final repository = ref.watch(customerHomeRepositoryProvider);
  return repository.getVendors();
});
