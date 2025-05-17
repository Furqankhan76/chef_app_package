import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Provider for FirebaseAuth instance
final firebaseAuthProvider = Provider<FirebaseAuth>((ref) => FirebaseAuth.instance);

// StateNotifier for managing phone auth state
class PhoneAuthNotifier extends StateNotifier<PhoneAuthState> {
  final FirebaseAuth _auth;
  final Ref _ref; // Keep Ref if needed to read other providers

  PhoneAuthNotifier(this._auth, this._ref) : super(PhoneAuthState.initial());

  String? _verificationId;

  // Step 1: Send OTP to the phone number
  Future<void> sendOtp(String phoneNumber) async {
    state = PhoneAuthState.loading('Sending OTP...'); // TODO: Localize
    await _auth.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      verificationCompleted: (PhoneAuthCredential credential) async {
        // Auto-retrieval or instant verification (Android only)
        print('Phone verification completed automatically');
        state = PhoneAuthState.loading('Auto-verifying...'); // TODO: Localize
        await _signInWithCredential(credential);
      },
      verificationFailed: (FirebaseAuthException e) {
        print('Phone verification failed: ${e.code} - ${e.message}');
        state = PhoneAuthState.error('Verification failed: ${e.message}'); // TODO: Localize
      },
      codeSent: (String verificationId, int? resendToken) {
        print('OTP code sent. Verification ID: $verificationId');
        _verificationId = verificationId;
        state = PhoneAuthState.codeSent(verificationId);
      },
      codeAutoRetrievalTimeout: (String verificationId) {
        print('Code auto-retrieval timed out. Verification ID: $verificationId');
        // Can potentially use verificationId for manual entry if needed
        _verificationId = verificationId;
        // Optionally update state if needed, but usually handled by codeSent
      },
      timeout: const Duration(seconds: 60), // Timeout duration
    );
  }

  // Step 2: Verify the OTP code entered by the user
  Future<void> verifyOtp(String smsCode) async {
    if (_verificationId == null) {
      state = PhoneAuthState.error('Verification ID not found. Please request OTP again.'); // TODO: Localize
      return;
    }
    state = PhoneAuthState.loading('Verifying OTP...'); // TODO: Localize
    try {
      final credential = PhoneAuthProvider.credential(
        verificationId: _verificationId!,
        smsCode: smsCode,
      );
      await _signInWithCredential(credential);
    } catch (e) {
      print('Error verifying OTP: $e');
      state = PhoneAuthState.error('Invalid OTP code.'); // TODO: Localize
    }
  }

  // Helper to sign in or link credential
  Future<void> _signInWithCredential(PhoneAuthCredential credential) async {
    try {
      UserCredential userCredential;
      // Check if user is already signed in (e.g., with email/password)
      if (_auth.currentUser != null) {
        // Link the phone credential to the existing account
        userCredential = await _auth.currentUser!.linkWithCredential(credential);
        print('Phone number linked successfully.');
      } else {
        // Sign in with the phone credential (creates a new user if none exists)
        userCredential = await _auth.signInWithCredential(credential);
        print('Signed in with phone number successfully.');
      }
      state = PhoneAuthState.verified(userCredential.user);
    } on FirebaseAuthException catch (e) {
      // Handle specific errors like 'credential-already-in-use'
      print('Error signing in/linking credential: ${e.code} - ${e.message}');
      state = PhoneAuthState.error('Authentication failed: ${e.message}'); // TODO: Localize
    } catch (e) {
      print('Generic error during sign in/linking: $e');
      state = PhoneAuthState.error('An unexpected error occurred.'); // TODO: Localize
    }
  }

  void reset() {
    state = PhoneAuthState.initial();
    _verificationId = null;
  }
}

// State definition for phone authentication
@immutable
abstract class PhoneAuthState {
  const PhoneAuthState();

  factory PhoneAuthState.initial() = PhoneAuthInitial;
  factory PhoneAuthState.loading(String message) = PhoneAuthLoading;
  factory PhoneAuthState.codeSent(String verificationId) = PhoneAuthCodeSent;
  factory PhoneAuthState.verified(User? user) = PhoneAuthVerified;
  factory PhoneAuthState.error(String message) = PhoneAuthError;
}

class PhoneAuthInitial extends PhoneAuthState {
  const PhoneAuthInitial();
}

class PhoneAuthLoading extends PhoneAuthState {
  final String message;
  const PhoneAuthLoading(this.message);
}

class PhoneAuthCodeSent extends PhoneAuthState {
  final String verificationId;
  const PhoneAuthCodeSent(this.verificationId);
}

class PhoneAuthVerified extends PhoneAuthState {
  final User? user;
  const PhoneAuthVerified(this.user);
}

class PhoneAuthError extends PhoneAuthState {
  final String message;
  const PhoneAuthError(this.message);
}

// Provider for the PhoneAuthNotifier
final phoneAuthNotifierProvider = StateNotifierProvider<PhoneAuthNotifier, PhoneAuthState>((ref) {
  final auth = ref.watch(firebaseAuthProvider);
  return PhoneAuthNotifier(auth, ref);
});

