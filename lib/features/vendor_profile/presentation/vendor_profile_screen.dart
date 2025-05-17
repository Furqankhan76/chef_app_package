import 'package:chef_app/features/auth/presentation/auth_providers.dart';
import 'package:chef_app/features/vendor_profile/domain/vendor.dart';
import 'package:chef_app/features/vendor_profile/presentation/vendor_profile_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class VendorProfileScreen extends ConsumerWidget {
  const VendorProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Get current user
    final authState = ref.watch(authStateChangesProvider);
    
    return authState.when(
      data: (user) {
        if (user == null) {
          // User not logged in, should be handled by router
          return const Scaffold(
            body: Center(child: Text('Not logged in')),
          );
        }
        
        // Get vendor profile for the current user
        final vendorProfileAsync = ref.watch(vendorProfileProvider(user.uid));
        
        return Scaffold(
          appBar: AppBar(
            title: const Text('Vendor Profile'),
            actions: [
              IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () {
                  // Navigate to edit profile screen
                  // Will be implemented with go_router later
                },
              ),
              IconButton(
                icon: const Icon(Icons.logout),
                onPressed: () async {
                  // Sign out
                  await ref.read(authRepositoryProvider).signOut();
                },
              ),
            ],
          ),
          body: vendorProfileAsync.when(
            data: (vendor) {
              return _buildVendorProfileContent(context, vendor);
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, stack) => Center(
              child: Text('Error loading profile: ${error.toString()}'),
            ),
          ),
        );
      },
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (error, stack) => Scaffold(
        body: Center(
          child: Text('Authentication error: ${error.toString()}'),
        ),
      ),
    );
  }
  
  Widget _buildVendorProfileContent(BuildContext context, Vendor vendor) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Profile header with photos
          if (vendor.profilePhotos.isNotEmpty)
            SizedBox(
              height: 200,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: vendor.profilePhotos.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8.0),
                      child: Image.network(
                        vendor.profilePhotos[index],
                        width: 200,
                        height: 200,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            width: 200,
                            height: 200,
                            color: Colors.grey[300],
                            child: const Icon(Icons.error),
                          );
                        },
                      ),
                    ),
                  );
                },
              ),
            )
          else
            Container(
              width: double.infinity,
              height: 200,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: const Center(
                child: Icon(Icons.add_a_photo, size: 50),
              ),
            ),
          
          const SizedBox(height: 16),
          
          // Business name
          Text(
            vendor.businessName,
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          
          const SizedBox(height: 8),
          
          // Description
          Text(
            vendor.description,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          
          const SizedBox(height: 16),
          
          // Followers
          Row(
            children: [
              const Icon(Icons.people),
              const SizedBox(width: 8),
              Text('${vendor.followerCount} followers'),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Sharable link
          Row(
            children: [
              const Icon(Icons.link),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  vendor.sharableLink,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.copy),
                onPressed: () {
                  // Copy link to clipboard
                  // Will be implemented later
                },
              ),
            ],
          ),
          
          const SizedBox(height: 24),
          
          // Products section (placeholder)
          const Text(
            'Products',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          
          const SizedBox(height: 8),
          
          // Placeholder for products
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Center(
              child: Text('Products will be displayed here'),
            ),
          ),
        ],
      ),
    );
  }
}
