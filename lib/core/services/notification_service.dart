import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';
// TODO: Import UserRepository provider if needed to save token

// Handler for background messages (needs to be a top-level function)
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // If you're going to use other Firebase services in the background, like Firestore,
  // make sure you call `initializeApp` before using other Firebase services.
  // await Firebase.initializeApp(); // Consider if needed
  print("Handling a background message: ${message.messageId}");
  // Process the message data here
}

class NotificationService {
  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  final Ref _ref;

  NotificationService(this._ref);

  Future<void> initialize() async {
    // Request permission
    await _requestPermission();

    // Get FCM token
    final token = await _getToken();
    if (token != null) {
      print("FCM Token: $token");
      // TODO: Save the token to the user's profile in Firestore
      // This usually happens after login or registration
      // Example: _saveTokenToDatabase(token);
    }

    // Listen for token refresh
    _fcm.onTokenRefresh.listen((newToken) {
      print("FCM Token Refreshed: $newToken");
      // TODO: Update the token in the user's profile
      // Example: _saveTokenToDatabase(newToken);
    });

    // Handle foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Got a message whilst in the foreground!');
      print('Message data: ${message.data}');

      if (message.notification != null) {
        print('Message also contained a notification: ${message.notification}');
        // TODO: Show a local notification or update UI based on the message
        // Example: Show a snackbar or dialog
      }
    });

    // Handle background message tapping (when app opens from notification)
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('Message clicked!');
      print('Message data: ${message.data}');
      // TODO: Navigate to a specific screen based on message data
      // Example: if (message.data['type'] == 'order_update') { navigateToOrder(message.data['orderId']); }
    });

    // Set the background message handler
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // Check if app was opened from a terminated state notification
    RemoteMessage? initialMessage = await _fcm.getInitialMessage();
    if (initialMessage != null) {
      print('App opened from terminated state notification:');
      print('Message data: ${initialMessage.data}');
      // TODO: Handle navigation based on initial message data
    }
  }

  Future<void> _requestPermission() async {
    // First, try using Firebase Messaging's request permission
    NotificationSettings settings = await _fcm.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false, // Set to true for provisional authorization (iOS 12+)
      sound: true,
    );

    print('User granted FCM permission: ${settings.authorizationStatus}');

    // Additionally, check/request with permission_handler for more control/consistency
    PermissionStatus status = await Permission.notification.status;
    print('Notification permission status via handler: $status');
    if (status.isDenied) {
      status = await Permission.notification.request();
      print('Notification permission requested via handler, new status: $status');
    }

    if (status.isPermanentlyDenied) {
      // The user opted to never see the permission request dialog again.
      // Open app settings to allow the user to grant permission.
      print('Notification permission permanently denied. Opening settings...');
      // openAppSettings(); // Consider prompting user first
    }
  }

  Future<String?> _getToken() async {
    try {
      // For Apple platforms, get APNS token first
      // String? apnsToken = await _fcm.getAPNSToken();
      // if (apnsToken == null && (defaultTargetPlatform == TargetPlatform.iOS || defaultTargetPlatform == TargetPlatform.macOS)) {
      //   print('Failed to get APNS token for Apple platform.');
      //   return null;
      // }
      return await _fcm.getToken();
    } catch (e) {
      print('Error getting FCM token: $e');
      return null;
    }
  }

  // Placeholder for saving token logic
  // Future<void> _saveTokenToDatabase(String token) async {
  //   final userId = _ref.read(authProvider).currentUser?.uid;
  //   if (userId != null) {
  //     try {
  //       await _ref.read(userRepositoryProvider).updateUserToken(userId, token);
  //       print('FCM token saved to database.');
  //     } catch (e) {
  //       print('Error saving FCM token: $e');
  //     }
  //   }
  // }

  // TODO: Add methods to subscribe/unsubscribe from topics if needed
  // Future<void> subscribeToTopic(String topic) async {
  //   await _fcm.subscribeToTopic(topic);
  //   print('Subscribed to topic: $topic');
  // }

  // Future<void> unsubscribeFromTopic(String topic) async {
  //   await _fcm.unsubscribeFromTopic(topic);
  //   print('Unsubscribed from topic: $topic');
  // }
}

// Riverpod provider for the NotificationService
final notificationServiceProvider = Provider<NotificationService>((ref) {
  return NotificationService(ref);
});

