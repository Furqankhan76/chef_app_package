import 'package:chef_app/features/auth/presentation/auth_providers.dart';
import 'package:chef_app/features/promotions/presentation/promotion_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

class PromotionsScreen extends ConsumerWidget {
  const PromotionsScreen({super.key});

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
        
        // Get promotions from followed vendors
        final promotionsAsync = ref.watch(followedVendorsPromotionsProvider);
        
        return Scaffold(
          appBar: AppBar(
            title: const Text('Promotions'),
            actions: [
              IconButton(
                icon: const Icon(Icons.logout),
                onPressed: () async {
                  // Sign out
                  await ref.read(authRepositoryProvider).signOut();
                },
              ),
            ],
          ),
          body: promotionsAsync.when(
            data: (promotions) {
              if (promotions.isEmpty) {
                return const Center(
                  child: Text('No promotions available from your followed chefs.'),
                );
              }
              return _buildPromotionsList(context, promotions);
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, stack) => Center(
              child: Text('Error loading promotions: ${error.toString()}'),
            ),
          ),
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: 3, // Promotions tab (not actually in the bottom nav)
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.home),
                label: 'Home',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.favorite),
                label: 'Following',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.card_giftcard),
                label: 'Loyalty',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person),
                label: 'Profile',
              ),
            ],
            onTap: (index) {
              // Handle navigation
              // Will be implemented with go_router later
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
  
  Widget _buildPromotionsList(BuildContext context, List<dynamic> promotions) {
    final dateFormat = DateFormat('MMM d, yyyy');
    
    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: promotions.length,
      itemBuilder: (context, index) {
        final promotion = promotions[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Promotion image
              if (promotion.imageUrl != null)
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(4.0)),
                  child: Image.network(
                    promotion.imageUrl!,
                    width: double.infinity,
                    height: 150,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: double.infinity,
                        height: 150,
                        color: Colors.grey[300],
                        child: const Icon(Icons.error),
                      );
                    },
                  ),
                )
              else
                Container(
                  width: double.infinity,
                  height: 150,
                  color: Colors.grey[300],
                  child: const Center(
                    child: Icon(Icons.local_offer, size: 50),
                  ),
                ),
              
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title
                    Text(
                      promotion.title,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    
                    const SizedBox(height: 8),
                    
                    // Description
                    Text(
                      promotion.description,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Dates
                    Row(
                      children: [
                        const Icon(Icons.calendar_today, size: 16),
                        const SizedBox(width: 4),
                        Text(
                          'Valid: ${dateFormat.format(promotion.startDate)} - ${dateFormat.format(promotion.endDate)}',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Action button
                    Align(
                      alignment: Alignment.centerRight,
                      child: ElevatedButton(
                        child: const Text('View Chef'),
                        onPressed: () {
                          // Navigate to vendor profile
                          // Will be implemented with go_router later
                        },
                      ),
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
