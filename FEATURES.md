# Chef App (Rebuilt) - Detailed Feature Documentation

This document details the features implemented in the rebuilt version of the Chef App.

## Core Architecture & Setup

*   **Foundation:** Built using Flutter SDK (`^3.7.2`).
*   **State Management:** Utilizes `flutter_riverpod` for dependency injection and state management across the application.
*   **Navigation:** Employs `go_router` for declarative routing, handling navigation between screens.
*   **Arabic First & RTL:** Configured with Arabic (`ar`) as the default locale. Uses `flutter_localizations` and `intl` for localization (requires translation updates for new features). Integrates the `Cairo` font via `google_fonts` and ensures proper Right-to-Left (RTL) layout support.
*   **Firebase Integration:** Core integration with Firebase (`firebase_core`), including:
    *   Authentication (`firebase_auth`)
    *   Database (`cloud_firestore`)
    *   File Storage (`firebase_storage`)
    *   Push Notifications (`firebase_messaging`)
*   **Clean Architecture:** Follows principles separating domain, data, and presentation layers.

## User Roles & Authentication

*   **User Roles:** Supports three distinct roles: `Customer`, `Seller` (Home-based cook/family), and `Courier`.
*   **Seller Registration:**
    *   Dedicated registration screen (`SellerRegistrationScreen`).
    *   Requires name and phone number.
    *   Implements phone number verification using Firebase Auth OTP (`PhoneAuthProvider`).
    *   Includes an `OtpVerificationScreen`.
    *   Creates a user record in Firestore with `role: UserRole.seller` and `isVerified: false` (implies manual admin verification needed).
*   **Courier Registration:**
    *   Dedicated registration screen (`CourierRegistrationScreen`).
    *   Requires name and phone number.
    *   Implements phone number verification using Firebase Auth OTP (reuses `PhoneAuthProvider` and `OtpVerificationScreen`).
    *   Creates a user record in Firestore with `role: UserRole.courier` and `isAvailable: true`.
*   **Customer Authentication:** (Assumed, based on original structure - needs specific login/registration flow if different from Seller/Courier)

## Video Content Feature

*   **Video Feed (`VideoFeedScreen`):**
    *   Displays a vertical, swipeable feed of short videos (similar to TikTok) using `video_player`.
    *   Plays videos automatically (basic implementation, visibility detection TODO).
    *   Loops videos.
    *   Includes overlay with seller info, caption, like count, share button (placeholder), and follow button.
*   **Video Upload (`VideoUploadScreen`):**
    *   Allows sellers to select videos using `image_picker`.
    *   Provides fields for caption input.
    *   Handles video upload to Firebase Storage.
    *   Saves video metadata (URL, seller ID, caption, timestamp, likes) to Firestore.
*   **Likes:** Basic structure for tracking video likes (increment/decrement logic TODO).
*   **Backend (`FirebaseVideoContentRepository`):** Handles fetching video feed data, uploading videos, and managing likes in Firestore/Storage.

## Following System

*   **Functionality:** Allows customers to follow/unfollow sellers.
*   **UI Components:**
    *   `FollowButton`: Reusable widget integrated into the video feed overlay.
    *   `FollowingScreen`: Displays a list of sellers the current customer follows, with options to unfollow.
*   **Backend (`FirebaseFollowingRepository`):** Manages follow relationships in Firestore (creating/deleting follow records).
*   **State Management (`following_providers.dart`):** Riverpod providers to manage following state (e.g., `isFollowingProvider`, `followingListProvider`).

## Location & Ordering

*   **Location Services (`LocationService`):**
    *   Uses `geolocator` and `permission_handler`.
    *   Handles requesting location permissions (`locationWhenInUse`).
    *   Fetches the device's current location.
    *   Calculates distance between two geographical points.
*   **Order Domain (`Order`, `CustomRequest`):** Defines data models for standard orders and custom requests, including items, amounts, addresses (GeoPoint), statuses, and timestamps.
*   **Order Repository (`FirebaseOrderRepository`):**
    *   Manages order and custom request data in Firestore.
    *   Provides methods to create orders, update statuses, and fetch orders by customer, seller, or courier.
    *   Implements `getAvailableOrdersForCouriers` which fetches orders ready for pickup and performs basic client-side distance filtering (optimization TODO).
    *   Handles assigning a courier to an order.
*   **Courier Order Discovery (`AvailableOrdersScreen`):**
    *   Uses `availableOrdersProvider` to fetch nearby orders based on the courier's current location.
    *   Displays a list of available orders with seller info and order details.
    *   Allows couriers to accept an order via a confirmation dialog.
*   **Courier Active Deliveries (`CourierActiveOrdersScreen`):**
    *   Displays orders currently assigned to the logged-in courier.
    *   Allows couriers to update order status (e.g., 

mark as `pickedUp` or `delivered`).

## Payment Integration

*   **Stripe Integration:** Uses the `flutter_stripe` package.
*   **SDK Initialization:** Stripe SDK is initialized in `main.dart` with a placeholder publishable key.
*   **Payment Service (`PaymentService`):**
    *   Handles the core payment logic using Stripe's Payment Sheet.
    *   Includes a method `_createPaymentIntent` which requires a **backend endpoint** (placeholder URL provided) to securely create Payment Intents on a server.
    *   Initializes (`_initializePaymentSheet`) and presents (`_presentPaymentSheet`) the Stripe Payment Sheet.
    *   Handles payment success/failure/cancellation.
    *   Updates the order status to `paid` in Firestore upon successful payment.
*   **UI Integration (`OrderDetailsScreen`):**
    *   Displays order details.
    *   Includes a "Pay Now" button for orders in appropriate statuses (e.g., `pending`, `confirmed`).
    *   Uses the `PaymentService` to process payments when the button is pressed.
    *   Shows loading indicators and success/error messages.

## Notification System

*   **Firebase Cloud Messaging (FCM):** Uses the `firebase_messaging` package.
*   **Notification Service (`NotificationService`):**
    *   Handles FCM initialization.
    *   Requests notification permissions from the user (using both `firebase_messaging` and `permission_handler`).
    *   Retrieves and manages the FCM device token (includes TODOs for saving/updating the token in the user's Firestore profile).
    *   Listens for token refreshes.
    *   Handles incoming messages when the app is in the foreground (`onMessage`).
    *   Handles notification taps when the app is opened from the background (`onMessageOpenedApp`).
    *   Sets up a background message handler (`_firebaseMessagingBackgroundHandler`).
    *   Checks for initial messages if the app was opened from a terminated state.
*   **Initialization:** The `NotificationService` is initialized in `main.dart` before the app runs.

## Future Enhancements & TODOs

*   **Customer Login/Registration:** Implement a specific flow if needed.
*   **UI/UX Refinement:** Improve overall UI/UX, add animations, and refine layouts, especially for RTL.
*   **Localization:** Translate all user-facing strings in `.arb` files for Arabic, English, and Spanish.
*   **Error Handling:** Implement more robust error handling and user feedback mechanisms.
*   **Backend Implementation:** **Crucially, implement the backend endpoint required by `PaymentService` to create Stripe Payment Intents.**
*   **Seller Verification:** Implement the admin-side process for verifying sellers.
*   **Firestore Query Optimization:** Optimize queries, especially location-based ones, potentially using backend functions or Geoflutterfire.
*   **Video Player Enhancements:** Add features like visibility detection for auto-play/pause, better controls, etc.
*   **Detailed Order Views:** Implement screens showing full order details, potentially with maps for delivery tracking.
*   **Search & Filtering:** Implement product/seller search and filtering capabilities.
*   **Custom Request Flow:** Fully implement the UI and logic for submitting and managing custom food requests.
*   **Testing:** Add unit, widget, and integration tests.

