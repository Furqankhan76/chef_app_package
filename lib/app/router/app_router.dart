import 'package:chef_app/features/auth/presentation/auth_providers.dart';
import 'package:chef_app/features/auth/presentation/login_screen.dart';
import 'package:chef_app/features/auth/presentation/register_screen.dart';
import 'package:chef_app/features/customer_home/presentation/customer_home_screen.dart';
import 'package:chef_app/features/following/presentation/following_screen.dart';
import 'package:chef_app/features/loyalty/presentation/loyalty_screen.dart';
import 'package:chef_app/features/promotions/presentation/promotions_screen.dart';
import 'package:chef_app/features/vendor_profile/presentation/vendor_profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Router configuration provider
final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateChangesProvider);
  
  return GoRouter(
    initialLocation: '/login',
    redirect: (context, state) {
      // Check if the user is logged in
      final isLoggedIn = authState.valueOrNull != null;
      final isLoginRoute = state.matchedLocation == '/login' || state.matchedLocation == '/register';
      
      // If not logged in and not on a login route, redirect to login
      if (!isLoggedIn && !isLoginRoute) {
        return '/login';
      }
      
      // If logged in and on a login route, redirect to home
      if (isLoggedIn && isLoginRoute) {
        final userRole = authState.valueOrNull?.role;
        if (userRole == 'vendor') {
          return '/vendor-dashboard';
        } else {
          return '/customer-home';
        }
      }
      
      // No redirect needed
      return null;
    },
    routes: [
      // Auth routes
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
      ),
      
      // Customer routes
      GoRoute(
        path: '/customer-home',
        builder: (context, state) => const CustomerHomeScreen(),
      ),
      
      // Vendor routes
      GoRoute(
        path: '/vendor-dashboard',
        builder: (context, state) => const VendorProfileScreen(), // Using VendorProfileScreen as dashboard for now
      ),
      
      // Following routes
      GoRoute(
        path: '/following',
        builder: (context, state) => const FollowingScreen(),
      ),
      
      // Loyalty routes (placeholder)
      GoRoute(
        path: '/loyalty',
        builder: (context, state) => const LoyaltyScreen(),
      ),
      
      // Promotions routes (placeholder)
      GoRoute(
        path: '/promotions',
        builder: (context, state) => const PromotionsScreen(),
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Text('Error: ${state.error}'),
      ),
    ),
  );
});
