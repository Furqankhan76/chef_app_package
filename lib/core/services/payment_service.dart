import 'dart:convert';
import 'package:chef_app/features/order_management/data/firebase_order_repository.dart'; // For order repo provider
import 'package:chef_app/features/order_management/domain/order.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:http/http.dart' as http; // For calling backend endpoint

class PaymentService {
  final Ref _ref;

  PaymentService(this._ref);

  // IMPORTANT: In a real app, never hardcode your Stripe secret key.
  // This backend endpoint should be hosted securely.
  // For demonstration, we use a placeholder URL.
  final String _backendUrl = 'https://your-backend.com/create-payment-intent'; // TODO: Replace with your actual backend endpoint

  // Step 1: Create Payment Intent on your backend
  Future<Map<String, dynamic>> _createPaymentIntent(double amount, String currency, String customerId) async {
    try {
      // Convert amount to smallest currency unit (e.g., cents for USD, halalas for SAR)
      final int amountInSmallestUnit = (amount * 100).toInt();

      final response = await http.post(
        Uri.parse(_backendUrl),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'amount': amountInSmallestUnit,
          'currency': currency, // e.g., 'sar'
          'customer': customerId, // Optional: Stripe Customer ID
          // Add other necessary details like order ID, metadata, etc.
        }),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        print('Error creating payment intent: ${response.body}');
        throw Exception('Failed to create payment intent: ${response.reasonPhrase}');
      }
    } catch (e) {
      print('Error calling backend for payment intent: $e');
      throw Exception('Failed to communicate with payment backend.');
    }
  }

  // Step 2: Initialize Payment Sheet
  Future<void> _initializePaymentSheet(String clientSecret, String? customerId, String? ephemeralKeySecret) async {
    try {
      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: clientSecret,
          merchantDisplayName: 'Chef App', // TODO: Replace with your app name
          customerId: customerId, // Optional: Pass Stripe Customer ID
          customerEphemeralKeySecret: ephemeralKeySecret, // Optional: Needed if using Stripe Customer ID
          // applePay: const PaymentSheetApplePay(merchantCountryCode: 'SA'), // TODO: Configure Apple Pay (country code)
          // googlePay: const PaymentSheetGooglePay(merchantCountryCode: 'SA', testEnv: true), // TODO: Configure Google Pay
          style: ThemeMode.system, // Or ThemeMode.light / ThemeMode.dark
        ),
      );
    } catch (e) {
      print('Error initializing payment sheet: $e');
      throw Exception('Failed to initialize payment sheet.');
    }
  }

  // Step 3: Present Payment Sheet
  Future<bool> _presentPaymentSheet() async {
    try {
      await Stripe.instance.presentPaymentSheet();
      print('Payment successful!');
      return true; // Payment completed
    } on StripeException catch (e) {
      // Handle Stripe-specific errors (e.g., payment failed, user cancelled)
      print('Payment failed or cancelled: ${e.error.localizedMessage}');
      return false; // Payment failed or cancelled
    } catch (e) {
      print('Error presenting payment sheet: $e');
      return false; // Other error
    }
  }

  // Main function to handle the payment flow for an order
  Future<bool> handlePayment(Order order) async {
    try {
      // 1. Create Payment Intent on backend
      // TODO: Get Stripe Customer ID if you manage customers in Stripe
      String? stripeCustomerId; 
      final paymentIntentData = await _createPaymentIntent(
        order.totalAmount,
        'sar', // TODO: Use appropriate currency code
        stripeCustomerId ?? '', // Pass customer ID if available
      );

      final clientSecret = paymentIntentData['clientSecret'];
      final ephemeralKeySecret = paymentIntentData['ephemeralKey']; // If using Stripe Customer
      final customer = paymentIntentData['customer']; // If using Stripe Customer

      if (clientSecret == null) {
        throw Exception('Missing clientSecret from backend.');
      }

      // 2. Initialize Payment Sheet
      await _initializePaymentSheet(clientSecret, customer, ephemeralKeySecret);

      // 3. Present Payment Sheet
      final paymentSuccessful = await _presentPaymentSheet();

      if (paymentSuccessful) {
        // 4. Update order status in Firestore
        await _ref.read(orderRepositoryProvider).updateOrderStatus(order.orderId, OrderStatus.paid);
        print('Order ${order.orderId} status updated to paid.');
        return true;
      } else {
        print('Payment process did not complete successfully.');
        return false;
      }
    } catch (e) {
      print('Payment handling error: $e');
      // Optionally show error message to user
      return false;
    }
  }
}

// Riverpod provider for the PaymentService
final paymentServiceProvider = Provider<PaymentService>((ref) {
  return PaymentService(ref);
});

