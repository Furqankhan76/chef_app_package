import 'package:chef_app/app/widgets/language_switcher.dart';
import 'package:chef_app/features/auth/presentation/auth_providers.dart';
import 'package:chef_app/features/customer_home/presentation/customer_home_providers.dart';
import 'package:chef_app/features/vendor_profile/domain/vendor.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class CustomerHomeScreen extends ConsumerWidget {
  const CustomerHomeScreen({super.key});

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
        
        // Get vendors list
        final vendorsAsync = ref.watch(vendorsProvider);
        
        return Scaffold(
          appBar: AppBar(
            title: Text(AppLocalizations.of(context)?.discoverChefs ?? 'Discover Chefs'),
            actions: [
              IconButton(
                icon: const Icon(Icons.search),
                onPressed: () {
                  // Implement search functionality
                },
                tooltip: AppLocalizations.of(context)?.search,
              ),
              const LanguageSwitcher(), // Add language switcher
              IconButton(
                icon: const Icon(Icons.logout),
                onPressed: () async {
                  // Sign out
                  await ref.read(authRepositoryProvider).signOut();
                },
                tooltip: AppLocalizations.of(context)?.logout,
              ),
            ],
          ),
          body: vendorsAsync.when(
            data: (vendors) {
              if (vendors.isEmpty) {
                return Center(
                  child: Text(AppLocalizations.of(context)?.noChefsFound ?? 
                      'No chefs found. Check back later!'),
                );
              }
              return _buildVendorsList(context, vendors, ref);
            },
            loading: () => Center(child: Text(AppLocalizations.of(context)?.loading ?? 
                'Loading...')),
            error: (error, stack) => Center(
              child: Text(AppLocalizations.of(context)?.errorLoadingChefs(error.toString()) ?? 
                  'Error loading chefs: ${error.toString()}'),
            ),
          ),
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: 0, // Assuming Home is the first tab
            type: BottomNavigationBarType.fixed, // Ensure labels are always visible
            items: [
              BottomNavigationBarItem(
                icon: const Icon(Icons.home),
                label: AppLocalizations.of(context)?.home ?? 
                    'Home',
              ),
              BottomNavigationBarItem(
                icon: const Icon(Icons.favorite),
                label: AppLocalizations.of(context)?.following ?? 
                    'Following',
              ),
              BottomNavigationBarItem(
                icon: const Icon(Icons.card_giftcard),
                label: AppLocalizations.of(context)?.loyalty ?? 
                    'Loyalty',
              ),
              BottomNavigationBarItem(
                icon: const Icon(Icons.person),
                label: AppLocalizations.of(context)?.profile ?? 
                    'Profile',
              ),
            ],
            onTap: (index) {
              // Handle navigation based on index
              // TODO: Implement navigation using go_router
              switch (index) {
                case 0: // Home
                  // Already here or navigate to home
                  break;
                case 1: // Following
                  // Navigate to Following screen
                  // GoRouter.of(context).go('/following');
                  break;
                case 2: // Loyalty
                  // Navigate to Loyalty screen
                  // GoRouter.of(context).go('/loyalty');
                  break;
                case 3: // Profile
                  // Navigate to Profile screen (Vendor or Customer)
                  // GoRouter.of(context).go('/profile');
                  break;
              }
            },
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
  
  Widget _buildVendorsList(BuildContext context, List<Vendor> vendors, WidgetRef ref) {
    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: vendors.length,
      itemBuilder: (context, index) {
        final vendor = vendors[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Vendor image
              if (vendor.profilePhotos.isNotEmpty)
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(4.0)),
                  child: Image.network(
                    vendor.profilePhotos.first,
                    width: double.infinity,
                    height: 200,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: double.infinity,
                        height: 200,
                        color: Colors.grey[300],
                        child: const Icon(Icons.error),
                      );
                    },
                  ),
                )
              else
                Container(
                  width: double.infinity,
                  height: 200,
                  color: Colors.grey[300],
                  child: const Center(
                    child: Icon(Icons.restaurant, size: 50),
                  ),
                ),
              
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Business name
                    Text(
                      vendor.businessName,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    
                    const SizedBox(height: 8),
                    
                    // Description (truncated)
                    Text(
                      vendor.description.length > 100
                          ? '${vendor.description.substring(0, 100)}...'
                          : vendor.description,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Followers count
                    Row(
                      children: [
                        const Icon(Icons.people, size: 16),
                        const SizedBox(width: 4),
                        Text(AppLocalizations.of(context)?.followers(vendor.followerCount) ?? '${vendor.followerCount} followers'),
                      ],
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Action buttons
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        OutlinedButton.icon(
                          icon: const Icon(Icons.add),
                          label: Text(AppLocalizations.of(context)?.follow ?? 'Follow'),
                          onPressed: () {
                            // TODO: Implement follow functionality
                          },
                        ),
                        ElevatedButton(
                          child: Text(AppLocalizations.of(context)?.viewProfile ?? 'View Profile'),
                          onPressed: () {
                            // TODO: Navigate to vendor profile using go_router
                            // GoRouter.of(context).push('/vendor/${vendor.id}');
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

