import 'package:flutter/foundation.dart' show kDebugMode;

String friendlyAuthError(String? code) {
  const map = {
    'invalid-credential': 'Invalid email or password.',
    'user-not-found': 'Invalid email or password.',
    'wrong-password': 'Invalid email or password.',
    'email-already-in-use': 'This email is already registered. Try signing in.',
    'weak-password': 'Password must be at least 6 characters.',
    'too-many-requests': 'Too many attempts. Try again later.',
    'popup-closed-by-user': 'Google sign-in was cancelled.',
    'unauthorized-domain':
        'This app domain is not authorized. Add denticare-patient.web.app in Firebase Console → Authentication → Authorized domains.',
    'operation-not-allowed': 'This sign-in method is not enabled in Firebase Console.',
    'missing-email': 'Email is required.',
    'invalid-email': 'Please enter a valid email address.',
    'web-context-cancelled': 'Sign-in was cancelled.',
    'account-exists-with-different-credential':
        'An account already exists with this email using a different sign-in method.',
    'invalid-phone-number': 'Please enter a valid mobile number (e.g. 09XX XXX XXXX).',
    'invalid-verification-code': 'Incorrect OTP. Check the code and try again.',
    'session-expired': 'OTP expired. Request a new code.',
    'code-expired': 'OTP expired. Request a new code.',
    'quota-exceeded': 'Too many SMS requests. Try again later.',
    'missing-verification-code': 'Please enter the 6-digit OTP.',
    'captcha-check-failed': 'Security check failed. Refresh and try again.',
    'invalid-app-credential': 'Phone sign-in is not configured. Enable Phone auth in Firebase Console.',
  };
  return map[code] ?? 'Sign in failed. Please try again.';
}

String friendlyError(Object error) {
  final message = error.toString();
  if (message.contains('permission-denied')) {
    return kDebugMode
        ? 'Permission denied. Run npm run setup:patients in the clinic app, then try again.'
        : 'Permission denied. Please contact the clinic for assistance.';
  }
  if (message.contains('failed-precondition') && message.contains('index')) {
    return 'Database indexes are still building. Wait a few minutes and try again.';
  }
  if (message == 'NEEDS_PROFILE') {
    return 'Please complete your patient profile.';
  }
  if (message.contains('requires-recent-login')) {
    return 'For your security, please sign out and sign in again before deleting your account.';
  }
  if (message.contains('no-current-user')) {
    return 'You are already signed out.';
  }
  if (error is Exception) {
    return error.toString().replaceFirst('Exception: ', '');
  }
  return message;
}
