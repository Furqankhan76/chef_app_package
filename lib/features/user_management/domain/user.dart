import 'package:cloud_firestore/cloud_firestore.dart';

enum UserRole { customer, seller, courier, unknown }

class AppUser {
  final String uid;
  final String? email; // Optional, as phone is primary
  final String? name;
  final String phoneNumber; // Verified via OTP
  final UserRole role;
  final String? profilePicUrl;
  final GeoPoint? location; // For customers and couriers
  final Timestamp createdAt;
  final String? fcmToken;

  // Seller specific
  final bool? isVerified; // Manual verification status
  final bool? hasSubscription; // Optional subscription status
  final bool? isStoreOpen; // Seller can open/close store

  // Courier specific
  final bool? isAvailable; // Courier availability status
  final GeoPoint? currentLocation; // Real-time location for couriers

  AppUser({
    required this.uid,
    this.email,
    this.name,
    required this.phoneNumber,
    required this.role,
    this.profilePicUrl,
    this.location,
    required this.createdAt,
    this.fcmToken,
    // Seller
    this.isVerified,
    this.hasSubscription,
    this.isStoreOpen,
    // Courier
    this.isAvailable,
    this.currentLocation,
  });

  // Factory constructor for creating a new AppUser instance from a map
  factory AppUser.fromFirestore(DocumentSnapshot<Map<String, dynamic>> snapshot, SnapshotOptions? options) {
    final data = snapshot.data();
    return AppUser(
      uid: snapshot.id,
      email: data?['email'],
      name: data?['name'],
      phoneNumber: data?['phoneNumber'] ?? '',
      role: _parseUserRole(data?['role']),
      profilePicUrl: data?['profilePicUrl'],
      location: data?['location'],
      createdAt: data?['createdAt'] ?? Timestamp.now(),
      fcmToken: data?['fcmToken'],
      isVerified: data?['isVerified'],
      hasSubscription: data?['hasSubscription'],
      isStoreOpen: data?['isStoreOpen'],
      isAvailable: data?['isAvailable'],
      currentLocation: data?['currentLocation'],
    );
  }

  // Method for converting an AppUser instance to a map
  Map<String, dynamic> toFirestore() {
    return {
      if (email != null) 'email': email,
      if (name != null) 'name': name,
      'phoneNumber': phoneNumber,
      'role': role.name,
      if (profilePicUrl != null) 'profilePicUrl': profilePicUrl,
      if (location != null) 'location': location,
      'createdAt': createdAt,
      if (fcmToken != null) 'fcmToken': fcmToken,
      // Seller
      if (isVerified != null) 'isVerified': isVerified,
      if (hasSubscription != null) 'hasSubscription': hasSubscription,
      if (isStoreOpen != null) 'isStoreOpen': isStoreOpen,
      // Courier
      if (isAvailable != null) 'isAvailable': isAvailable,
      if (currentLocation != null) 'currentLocation': currentLocation,
    };
  }

  static UserRole _parseUserRole(String? roleString) {
    switch (roleString) {
      case 'customer':
        return UserRole.customer;
      case 'seller':
        return UserRole.seller;
      case 'courier':
        return UserRole.courier;
      default:
        return UserRole.unknown;
    }
  }
}

