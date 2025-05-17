import 'package:chef_app/features/auth/presentation/otp_verification_screen.dart';
import 'package:chef_app/features/auth/presentation/phone_auth_provider.dart';
import 'package:chef_app/features/user_management/domain/user.dart'; // Import AppUser
import 'package:chef_app/features/user_management/presentation/seller_registration_screen.dart'; // Import user repo provider placeholder
import 'package:cloud_firestore/cloud_firestore.dart'; // For Timestamp
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CourierRegistrationScreen extends ConsumerStatefulWidget {
  const CourierRegistrationScreen({super.key});

  @override
  ConsumerState<CourierRegistrationScreen> createState() => _CourierRegistrationScreenState();
}

class _CourierRegistrationScreenState extends ConsumerState<CourierRegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  // TODO: Add controllers for courier-specific fields if needed (e.g., vehicle type)

  bool _isLoading = false;
  String? _currentPhoneNumber;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _initiatePhoneVerification() async {
    if (!_formKey.currentState!.validate()) {
      return; // Don't proceed if form is invalid
    }

    setState(() {
      _isLoading = true;
      _currentPhoneNumber = _phoneController.text.trim(); // Store phone number
    });

    // Reset previous auth state before starting new verification
    ref.read(phoneAuthNotifierProvider.notifier).reset();

    // Call sendOtp from the provider
    await ref.read(phoneAuthNotifierProvider.notifier).sendOtp(_currentPhoneNumber!);

    // No need to set isLoading to false here, handled by listener
  }

  Future<void> _completeRegistration(String firebaseUid) async {
    // This function is called after OTP verification is successful
    final name = _nameController.text;
    final phone = _currentPhoneNumber!; // Use the stored phone number

    try {
      // Create AppUser object for Courier
      final newCourier = AppUser(
        uid: firebaseUid,
        name: name,
        phoneNumber: phone,
        role: UserRole.courier,
        isAvailable: true, // Default to available
        createdAt: Timestamp.now(),
        // location: null, // Current location updated separately
        // currentLocation: null, // Real-time location updated separately
      );

      // Save user to Firestore using UserRepository
      // Assuming userRepositoryProvider is correctly set up elsewhere
      await ref.read(userRepositoryProvider).createUser(newCourier);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Courier registration successful!')), // TODO: Localize
      );
      // Navigate to courier dashboard or home screen
      Navigator.of(context).popUntil((route) => route.isFirst); // Go back to the initial screen
      // Or pushReplacement to a new screen: context.go('/courier/dashboard');

    } catch (e) {
      print('Error creating courier profile in Firestore: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save profile: $e')), // TODO: Localize
      );
      // Keep user on registration screen or handle error appropriately
      setState(() {
        _isLoading = false; // Allow retry if Firestore save fails
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Listen to phone auth state changes
    ref.listen<PhoneAuthState>(phoneAuthNotifierProvider, (previous, next) {
      setState(() {
        // Update loading state based on provider state
        _isLoading = next is PhoneAuthLoading;
      });

      if (next is PhoneAuthCodeSent) {
        // Navigate to OTP screen when code is sent
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => OtpVerificationScreen(
              verificationId: next.verificationId,
              phoneNumber: _currentPhoneNumber!, // Pass phone number
            ),
          ),
        ).then((otpVerifiedSuccessfully) {
          // This block executes when OtpVerificationScreen pops
          if (otpVerifiedSuccessfully == true) {
            // OTP was verified, get the Firebase User and complete registration
            final verifiedState = ref.read(phoneAuthNotifierProvider);
            if (verifiedState is PhoneAuthVerified && verifiedState.user != null) {
              _completeRegistration(verifiedState.user!.uid);
            } else {
              // Should not happen if otpVerifiedSuccessfully is true, but handle defensively
              setState(() { _isLoading = false; });
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Verification state error. Please try again.')), // TODO: Localize
              );
            }
          } else {
            // OTP verification failed or was cancelled, allow user to retry
            setState(() { _isLoading = false; });
             ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Phone verification cancelled or failed.')), // TODO: Localize
              );
          }
        });
      } else if (next is PhoneAuthError) {
        // Show error message if OTP sending fails
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${next.message}')), // TODO: Localize
        );
        setState(() { _isLoading = false; }); // Allow retry
      } else if (next is PhoneAuthVerified) {
        // Handle auto-verification case (if it happens before navigating)
        if (next.user != null) {
           _completeRegistration(next.user!.uid);
        } else {
           setState(() { _isLoading = false; });
           ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Auto-verification error. Please try again.')), // TODO: Localize
              );
        }
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Become a Courier'), // TODO: Localize
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Your Name'), // TODO: Localize
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your name'; // TODO: Localize
                  }
                  return null;
                },
                enabled: !_isLoading, // Disable form fields when loading
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(
                  labelText: 'Phone Number (e.g., +966xxxxxxxxx)', // TODO: Localize
                  hintText: '+CountryCodePhoneNumber',
                ),
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your phone number'; // TODO: Localize
                  }
                  if (!value.trim().startsWith('+')) {
                    return 'Please include the country code (e.g., +966)'; // TODO: Localize
                  }
                  if (!RegExp(r'^\+[0-9]+$').hasMatch(value.trim())) {
                     return 'Please enter a valid phone number'; // TODO: Localize
                  }
                  return null;
                },
                 enabled: !_isLoading,
              ),
              const SizedBox(height: 16),
              // TODO: Add fields for vehicle type, etc. if needed
              const SizedBox(height: 24),
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                      onPressed: _initiatePhoneVerification,
                      child: const Text('Register & Verify Phone'), // TODO: Localize
                    ),
            ],
          ),
        ),
      ),
    );
  }
}

