import 'package:chef_app/features/vendor_profile/data/firebase_vendor_profile_repository.dart';
import 'package:chef_app/features/vendor_profile/domain/vendor.dart';
import 'package:chef_app/features/vendor_profile/domain/vendor_profile_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Provider for the VendorProfileRepository implementation
final vendorProfileRepositoryProvider = Provider<VendorProfileRepository>((ref) {
  return FirebaseVendorProfileRepository();
});

// Provider for the current vendor profile
// This is a FutureProvider that will fetch the vendor profile when accessed
final vendorProfileProvider = FutureProvider.family<Vendor, String>((ref, uid) async {
  final repository = ref.watch(vendorProfileRepositoryProvider);
  return repository.getVendorProfile(uid);
});

// Provider for vendor profile editing state
// This would be used in the vendor profile edit screen
final vendorProfileEditingProvider = StateNotifierProvider<VendorProfileEditingNotifier, AsyncValue<Vendor?>>((ref) {
  final repository = ref.watch(vendorProfileRepositoryProvider);
  return VendorProfileEditingNotifier(repository);
});

// Notifier class to handle vendor profile editing state
class VendorProfileEditingNotifier extends StateNotifier<AsyncValue<Vendor?>> {
  final VendorProfileRepository _repository;

  VendorProfileEditingNotifier(this._repository) : super(const AsyncValue.loading());

  // Load vendor profile for editing
  Future<void> loadVendorProfile(String uid) async {
    state = const AsyncValue.loading();
    try {
      final vendor = await _repository.getVendorProfile(uid);
      state = AsyncValue.data(vendor);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  // Update vendor profile
  Future<void> updateVendorProfile(Vendor updatedVendor) async {
    state = const AsyncValue.loading();
    try {
      await _repository.updateVendorProfile(updatedVendor);
      state = AsyncValue.data(updatedVendor);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  // Upload profile photo
  Future<String> uploadProfilePhoto(String uid, String filePath) async {
    try {
      return await _repository.uploadProfilePhoto(uid, filePath);
    } catch (e) {
      throw Exception('Failed to upload profile photo: ${e.toString()}');
    }
  }
}
