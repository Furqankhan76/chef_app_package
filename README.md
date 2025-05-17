# Chef App (Rebuilt) - Source Code & Documentation

This package contains the complete source code for the rebuilt Chef App, a Flutter application designed to connect customers with local home-based cooks (families) through a video-centric platform with an integrated courier system.

## Overview (Rebuilt Version)

The rebuilt Chef App focuses on:
*   **Home-Based Cooks (Sellers):** Providing a platform for families to showcase their food products.
*   **Video Discovery:** A TikTok-style video feed for sellers to post short videos of their products, allowing customers to discover and engage.
*   **Direct Ordering:** Customers can order products directly from sellers.
*   **Courier System:** An independent system for registered couriers to accept and deliver orders based on location.
*   **Arabic First:** Designed with Arabic as the primary language and full Right-to-Left (RTL) support.

## Key Features Implemented

*   **Core Structure:** Reused the basic Flutter project structure with Riverpod for state management and GoRouter for navigation.
*   **Architecture:** Continues to follow Clean Architecture principles.
*   **Arabic First & RTL:** Configured for Arabic default locale, Cairo font integration, and RTL layout.
*   **Firebase Integration:** Setup for Firebase Authentication, Firestore Database, Firebase Storage (for videos/images), and Firebase Cloud Messaging (FCM).
*   **User Roles:** Supports three user roles: Customer, Seller (Family), and Courier.
*   **Authentication:** Phone number authentication with OTP verification (using Firebase Auth) for Seller and Courier registration.
*   **Video Feed:** Vertical scrolling video feed (similar to TikTok) using `video_player` for customers to view seller content.
*   **Video Upload:** Functionality for sellers to upload videos (using `image_picker` and Firebase Storage).
*   **Following System:** Customers can follow their favorite sellers.
*   **Location Services:** Integration of `geolocator` and `permission_handler` for location permissions, fetching current location, and distance calculation.
*   **Courier Order Discovery:** Couriers can view available orders nearby based on their location.
*   **Order Management:** Basic flow for creating orders, assigning couriers, and updating order status (Pending, Accepted, Paid, Ready, OutForDelivery, Delivered, Cancelled, Declined).
*   **Seller Registration:** Dedicated flow for sellers to register using phone OTP.
*   **Courier Registration:** Dedicated flow for couriers to register using phone OTP.
*   **Payment Integration:** Integrated `flutter_stripe` for payment processing (Apple Pay, Google Pay, Cards). Includes a `PaymentService` and UI integration in `OrderDetailsScreen`. **Requires a backend endpoint to create Payment Intents.**
*   **Notification System:** Integrated Firebase Cloud Messaging (FCM) via `firebase_messaging`. Includes permission handling, token management, and basic foreground/background message handling setup.

## Architecture

The application architecture follows Clean Architecture principles. While the original `architecture_design.md` provides context on the initial structure, the specific feature implementations and Firestore schema have been significantly redesigned for this rebuilt version. Refer to the domain models and repository interfaces within the `lib/features/` subdirectories for the current structure.

## Setup Instructions

1.  **Flutter:** Ensure you have the Flutter SDK installed (version compatible with `^3.7.2` as per `pubspec.yaml`). Installation instructions: https://flutter.dev/docs/get-started/install
2.  **Firebase:**
    *   Use the provided `google-services.json` (Android) and `GoogleService-Info.plist` (iOS) files in `android/app/` and `ios/Runner/` respectively.
    *   Ensure your Firebase project has Authentication (Phone Number), Firestore Database, Firebase Storage, and Firebase Cloud Messaging enabled.
    *   **Important:** Additional platform-specific setup is required for FCM (e.g., adding service extensions in iOS, configuring `AndroidManifest.xml`). Refer to the `firebase_messaging` package documentation.
3.  **Location Permissions:**
    *   **iOS:** Add necessary keys to `ios/Runner/Info.plist` (e.g., `NSLocationWhenInUseUsageDescription`).
    *   **Android:** Add necessary permissions to `android/app/src/main/AndroidManifest.xml` (e.g., `ACCESS_FINE_LOCATION`, `ACCESS_COARSE_LOCATION`). Refer to `geolocator` and `permission_handler` documentation.
4.  **Stripe (Payments):**
    *   Replace the placeholder publishable key in `lib/main.dart` with your actual Stripe publishable key (`Stripe.publishableKey = 'pk_test_YOUR_KEY';`).
    *   **Backend Required:** You **must** create a secure backend endpoint to create Stripe Payment Intents. Update the placeholder URL in `lib/core/services/payment_service.dart` (`_backendUrl`). This backend should handle the amount, currency, and potentially customer creation/retrieval.
    *   **Platform Setup:** Follow `flutter_stripe` documentation for platform-specific setup (e.g., URL schemes for iOS, `AndroidManifest.xml` for Android).
5.  **Dependencies:** Navigate to the project root directory (`chef_app_package`) in your terminal and run `flutter pub get`.

## Build Instructions

Navigate to the project root directory (`chef_app_package`) in your terminal.

*   **Android:**
    *   Run `flutter build apk --debug`.
    *   Run `flutter build apk --release` (requires signing key setup).
    *   Output APK: `build/app/outputs/flutter-apk/`.
*   **iOS:**
    *   Run `flutter build ios --debug` (requires macOS + Xcode).
    *   Run `flutter build ios --release` (requires macOS, Xcode, Apple Developer account).
    *   Refer to Flutter iOS build documentation.

## Localization

*   The app is configured for Arabic (`ar`) as the default language.
*   Existing English (`en`) and Spanish (`es`) `.arb` files are in `lib/l10n/`. These need significant updates/translation for the new features.
*   To add/update translations, edit `.arb` files and run `flutter gen-l10n`.

## Notes

*   This is a rebuilt version with significant changes from the original Chef App concept.
*   The payment system relies on a **placeholder backend URL** for creating Payment Intents. You must implement this backend functionality yourself.
*   Seller verification (`isVerified` flag) is currently set to `false` upon registration, implying a manual admin verification process is needed (not implemented in this mobile app).
*   Many UI elements, navigation paths, and specific business logic details are marked with `// TODO:` comments and require further refinement and implementation.
*   Error handling and user feedback can be further improved.
*   Consider optimizing Firestore queries, especially location-based ones (e.g., using Geoflutterfire or backend functions for scalability).

