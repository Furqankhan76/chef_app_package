# Chef App - Architecture & Design

This document outlines the proposed architecture and design decisions for the Chef App mobile application.

## 1. Technology Stack

*   **Framework:** Flutter (latest stable version)
*   **Platform:** iOS & Android
*   **State Management:** Riverpod
*   **Navigation:** go_router (for declarative routing and deep linking)
*   **Backend:** Firebase
    *   Authentication: Firebase Authentication (Email/Password initially)
    *   Database: Cloud Firestore
    *   Storage: Firebase Cloud Storage (for images)
    *   Push Notifications: Firebase Cloud Messaging (FCM)
    *   Deep Linking: Firebase Dynamic Links (or go_router integration)
*   **Localization:** `flutter_localizations` with `intl` package (`.arb` files)
*   **IDE:** VS Code / Android Studio (developer choice)

## 2. Project Structure

A feature-first approach combined with layering (Presentation, Domain, Data) will be used within each feature module.

```
chef_app/
├── lib/
│   ├── main.dart             # App entry point, Firebase init, Riverpod Scope
│   ├── app/                  # Core app setup
│   │   ├── app.dart          # MaterialApp setup
│   │   ├── router/           # GoRouter configuration
│   │   │   └── app_router.dart
│   │   ├── theme/            # App theme data
│   │   │   └── app_theme.dart
│   │   └── l10n/             # Localization files (intl_en.arb, intl_ar.arb)
│   ├── core/                 # Shared utilities, constants, base classes, core services
│   │   ├── constants/        # App-wide constants (e.g., Firestore collection names)
│   │   ├── utils/            # Utility functions (e.g., validators, formatters)
│   │   ├── services/         # Abstract services (e.g., NotificationService)
│   │   ├── models/           # Common data models (if any, distinct from domain entities)
│   │   └── widgets/          # Common reusable widgets (e.g., CustomButton, LoadingIndicator)
│   ├── features/             # Feature modules
│   │   ├── auth/             # Authentication (Login, Register)
│   │   │   ├── data/         # Data sources (Firebase Auth implementation), Repositories Impl
│   │   │   ├── domain/       # Entities (User), Repositories (Abstract), Use Cases
│   │   │   └── presentation/ # UI (Screens/Pages, Widgets), State Management (Riverpod Providers/Notifiers)
│   │   ├── vendor_profile/   # Vendor profile creation, editing, viewing, sharing
│   │   │   ├── data/
│   │   │   ├── domain/
│   │   │   └── presentation/
│   │   ├── customer_home/    # Customer discovery screen (viewing vendors)
│   │   │   ├── data/
│   │   │   ├── domain/
│   │   │   └── presentation/
│   │   ├── following/        # Follow/unfollow vendors, view followed list
│   │   │   ├── data/
│   │   │   ├── domain/
│   │   │   └── presentation/
│   │   ├── loyalty/          # Loyalty points system (wallet, earning, redeeming)
│   │   │   ├── data/
│   │   │   ├── domain/
│   │   │   └── presentation/
│   │   ├── promotions/       # Vendor sending promotions
│   │   │   ├── data/
│   │   │   ├── domain/
│   │   │   └── presentation/
│   │   └── vendor_dashboard/ # Vendor home screen (manage profile, view followers)
│   │       ├── data/
│   │       ├── domain/
│   │       └── presentation/
│   └── data/                 # Firebase configuration, potentially abstract data source interfaces
├── android/              # Android specific files
├── ios/                  # iOS specific files
├── test/                 # Unit, widget, integration tests (mirrors lib structure)
├── pubspec.yaml          # Project dependencies and metadata
└── README.md             # Project description
```

## 3. State Management (Riverpod)

*   Providers will be used for dependency injection (repositories, services).
*   StateNotifierProvider or FutureProvider/StreamProvider will be used for managing UI state based on asynchronous operations.
*   State will be kept as immutable as possible.
*   Providers will be scoped appropriately (globally or feature-specific).

## 4. Navigation (go_router)

*   A central router configuration (`app_router.dart`) will define all app routes.
*   Routes will be named for easy navigation.
*   Path parameters will be used for passing data like vendor IDs.
*   Deep linking configuration will be integrated with `go_router` to handle vendor profile links.
*   Authentication state changes will trigger navigation redirects (e.g., redirect to login if not authenticated).

## 5. Database Schema (Cloud Firestore)

*   **`users`** (Collection)
    *   Document ID: Firebase Auth UID
    *   Fields:
        *   `email`: String
        *   `name`: String
        *   `role`: String ('customer' | 'vendor')
        *   `profilePicUrl`: String (Optional)
        *   `languagePreference`: String ('en' | 'ar')
        *   `createdAt`: Timestamp
        *   `fcmToken`: String (Optional, for push notifications)
*   **`vendors`** (Collection)
    *   Document ID: User UID (links to `users` collection)
    *   Fields:
        *   `businessName`: String
        *   `description`: String
        *   `profilePhotos`: List<String> (URLs to images in Firebase Storage)
        *   `sharableLink`: String (Unique link, potentially generated)
        *   `followerCount`: Integer (Denormalized for quick display)
        *   `createdAt`: Timestamp
        *   `updatedAt`: Timestamp
    *   **`products`** (Subcollection)
        *   Document ID: Auto-generated
        *   Fields:
            *   `name`: String
            *   `description`: String
            *   `price`: Number
            *   `photos`: List<String> (URLs)
            *   `isActive`: Boolean
            *   `createdAt`: Timestamp
*   **`follows`** (Collection)
    *   Document ID: Auto-generated or composite key like `{customerId}_{vendorId}`
    *   Fields:
        *   `customerId`: String (User UID)
        *   `vendorId`: String (User UID)
        *   `followedAt`: Timestamp
*   **`loyaltyWallets`** (Collection)
    *   Document ID: Customer User UID
    *   Fields:
        *   `balance`: Integer
        *   `updatedAt`: Timestamp
    *   **`transactions`** (Subcollection)
        *   Document ID: Auto-generated
        *   Fields:
            *   `type`: String ('earn' | 'redeem')
            *   `points`: Integer
            *   `description`: String (e.g., "Followed Vendor X", "Ordered Item Y", "Redeemed Reward Z")
            *   `relatedVendorId`: String (Optional)
            *   `relatedOrderId`: String (Optional, for future use)
            *   `timestamp`: Timestamp
*   **`promotions`** (Collection)
    *   Document ID: Auto-generated
    *   Fields:
        *   `vendorId`: String (User UID)
        *   `message`: String
        *   `sentAt`: Timestamp
        *   `status`: String ('sent')

## 6. API Design (Firebase Services)

*   Direct interaction with Firebase services (Auth, Firestore, Storage, FCM) will be encapsulated within the `data` layer of each feature.
*   Repositories in the `domain` layer will define abstract interfaces for data operations.
*   Repositories implementation in the `data` layer will use Firebase services.
*   Use Cases in the `domain` layer will orchestrate calls to repositories.
*   Riverpod providers will provide instances of Use Cases or Repositories to the Presentation layer.

## 7. Multi-language Support

*   Use `flutter_localizations` and `intl` package.
*   Define strings in `lib/app/l10n/intl_en.arb` and `lib/app/l10n/intl_ar.arb`.
*   Use code generation (`flutter gen-l10n`) to create localization delegates.
*   Access localized strings in widgets via `AppLocalizations.of(context)!`.
*   Implement a language switching mechanism (e.g., in user settings) that updates the app's locale and potentially stores the preference in the user's profile (`users` collection).

## 8. UI/UX

*   Follow Material Design guidelines.
*   Aim for a clean, modern, and simple UI.
*   Ensure responsiveness across different screen sizes.
*   Consider Right-to-Left (RTL) layout support for Arabic.
*   Wireframes/Mockups will be developed separately or iteratively during feature implementation.

