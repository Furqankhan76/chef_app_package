import 'package:chef_app/features/auth/presentation/phone_auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class OtpVerificationScreen extends ConsumerStatefulWidget {
  final String verificationId; // Passed from the previous screen
  final String phoneNumber; // For display purposes

  const OtpVerificationScreen({
    super.key,
    required this.verificationId,
    required this.phoneNumber,
  });

  @override
  ConsumerState<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends ConsumerState<OtpVerificationScreen> {
  final _otpController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _otpController.dispose();
    super.dispose();
  }

  void _verifyOtp() {
    if (_formKey.currentState!.validate()) {
      final otpCode = _otpController.text;
      // Call the verifyOtp method from the provider
      ref.read(phoneAuthNotifierProvider.notifier).verifyOtp(otpCode);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Listen to the phone auth state for loading/error/success feedback
    ref.listen<PhoneAuthState>(phoneAuthNotifierProvider, (previous, next) {
      if (next is PhoneAuthVerified) {
        // OTP verification successful
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Phone number verified successfully!')), // TODO: Localize
        );
        // TODO: Navigate to the next step (e.g., create user profile in Firestore)
        // This might involve popping this screen and continuing the registration
        // process in the SellerRegistrationScreen or navigating to a new screen.
        // For now, just pop back.
        Navigator.of(context).pop(true); // Indicate success
      } else if (next is PhoneAuthError) {
        // Show error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${next.message}')), // TODO: Localize
        );
      }
    });

    final phoneAuthState = ref.watch(phoneAuthNotifierProvider);
    final isLoading = phoneAuthState is PhoneAuthLoading;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Verify Phone Number'), // TODO: Localize
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Enter the 6-digit code sent to ${widget.phoneNumber}', // TODO: Localize
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: _otpController,
                decoration: const InputDecoration(
                  labelText: 'OTP Code', // TODO: Localize
                  counterText: '', // Hide the counter
                ),
                keyboardType: TextInputType.number,
                maxLength: 6,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 24, letterSpacing: 8),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the OTP code'; // TODO: Localize
                  }
                  if (value.length != 6) {
                    return 'OTP must be 6 digits'; // TODO: Localize
                  }
                  return null;
                },
              ),
              const SizedBox(height: 32),
              isLoading
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: _verifyOtp,
                      child: const Text('Verify OTP'), // TODO: Localize
                    ),
              // TODO: Add a resend OTP button if needed
              // TextButton(
              //   onPressed: isLoading ? null : () {
              //     // Call sendOtp again (might need phone number)
              //     ref.read(phoneAuthNotifierProvider.notifier).sendOtp(widget.phoneNumber);
              //   },
              //   child: Text('Resend Code'), // TODO: Localize
              // ),
            ],
          ),
        ),
      ),
    );
  }
}

