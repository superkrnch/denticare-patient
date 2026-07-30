import 'package:firebase_auth/firebase_auth.dart';

/// Holds the state needed to verify a phone OTP across web and mobile.
///
/// - On web, [confirmationResult] is returned by `signInWithPhoneNumber` and is
///   used directly to confirm the SMS code.
/// - On mobile, [verificationId] (from `codeSent`) is combined with the SMS
///   code to build a [PhoneAuthCredential]. [autoSignedIn] is set when Android
///   auto-retrieves the code and completes sign-in without user input.
class PhoneOtpSession {
  PhoneOtpSession({
    required this.phoneE164,
    this.verificationId,
    this.resendToken,
    this.confirmationResult,
    this.autoSignedIn = false,
  });

  final String phoneE164;
  final String? verificationId;
  final int? resendToken;
  final ConfirmationResult? confirmationResult;
  final bool autoSignedIn;
}
