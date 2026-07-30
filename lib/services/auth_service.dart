import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:google_sign_in/google_sign_in.dart';

import '../core/phone_format.dart';
import '../core/platform_utils.dart';
import '../core/validators.dart';
import '../models/phone_otp_session.dart';

class AuthService {
  AuthService({FirebaseAuth? auth, GoogleSignIn? googleSignIn})
      : _auth = auth ?? FirebaseAuth.instance,
        _googleSignIn = googleSignIn;

  final FirebaseAuth _auth;
  final GoogleSignIn? _googleSignIn;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  GoogleSignIn get _google => _googleSignIn ?? GoogleSignIn();

  Stream<User?> authStateChanges() => _auth.authStateChanges();

  User? get currentUser => _auth.currentUser;

  /// Call once on startup (web) to complete Google redirect sign-in.
  Future<User?> completeGoogleRedirectIfNeeded() async {
    if (!kIsWeb) return null;
    if (!consumeGoogleRedirectPending()) return null;
    try {
      final result = await _auth.getRedirectResult();
      return result.user;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'auth/no-auth-event') return null;
      rethrow;
    }
  }

  Future<User> loginWithEmail(String email, String password) async {
    final cred = await _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
    return cred.user!;
  }

  Future<User> registerWithEmail(
    String email,
    String password,
    String displayName,
  ) async {
    final cred = await _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
    await cred.user!.updateDisplayName(displayName);
    try {
      await cred.user!.sendEmailVerification();
    } catch (_) {}
    return cred.user!;
  }

  Future<void> sendPasswordResetEmail(String email) async {
    final trimmed = email.trim();
    if (!isValidEmail(trimmed)) {
      throw FirebaseAuthException(code: 'invalid-email');
    }
    await _auth.sendPasswordResetEmail(
      email: trimmed,
      actionCodeSettings: ActionCodeSettings(
        url: 'https://denticare-patient.web.app',
        handleCodeInApp: false,
      ),
    );
  }

  /// Sends an SMS OTP. On web uses [signInWithPhoneNumber]; on mobile [verifyPhoneNumber].
  Future<PhoneOtpSession> sendPhoneOtp(
    String phoneNumber, {
    int? forceResendingToken,
  }) async {
    final e164 = formatPhoneToE164(phoneNumber);
    if (e164 == null) {
      throw FirebaseAuthException(code: 'invalid-phone-number');
    }

    if (kIsWeb) {
      final confirmation = await _auth.signInWithPhoneNumber(e164);
      return PhoneOtpSession(
        phoneE164: e164,
        confirmationResult: confirmation,
      );
    }

    final completer = Completer<PhoneOtpSession>();

    await _auth.verifyPhoneNumber(
      phoneNumber: e164,
      forceResendingToken: forceResendingToken,
      timeout: const Duration(seconds: 60),
      verificationCompleted: (credential) async {
        await _auth.signInWithCredential(credential);
        if (!completer.isCompleted) {
          completer.complete(PhoneOtpSession(phoneE164: e164, autoSignedIn: true));
        }
      },
      verificationFailed: (e) {
        if (!completer.isCompleted) completer.completeError(e);
      },
      codeSent: (verificationId, resendToken) {
        if (!completer.isCompleted) {
          completer.complete(
            PhoneOtpSession(
              phoneE164: e164,
              verificationId: verificationId,
              resendToken: resendToken,
            ),
          );
        }
      },
      codeAutoRetrievalTimeout: (_) {},
    );

    return completer.future;
  }

  Future<User> verifyPhoneOtp(PhoneOtpSession session, String smsCode) async {
    final code = smsCode.trim();
    if (code.length < 6) {
      throw FirebaseAuthException(code: 'missing-verification-code');
    }

    if (session.confirmationResult != null) {
      final result = await session.confirmationResult!.confirm(code);
      return result.user!;
    }

    final verificationId = session.verificationId;
    if (verificationId == null) {
      throw FirebaseAuthException(code: 'session-expired');
    }

    final credential = PhoneAuthProvider.credential(
      verificationId: verificationId,
      smsCode: code,
    );
    final result = await _auth.signInWithCredential(credential);
    return result.user!;
  }

  Future<User> signInWithGoogle() async {
    if (kIsWeb) {
      // Popups fail on mobile browsers / installed PWAs ("requested action is invalid").
      final useRedirect = isMobileWeb || isStandalonePwa;
      if (useRedirect) {
        markGoogleRedirectPending();
        await _auth.signInWithRedirect(GoogleAuthProvider());
        // Browser navigates away; auth completes in completeGoogleRedirectIfNeeded().
        throw FirebaseAuthException(code: 'redirect-started');
      }
      final result = await _auth.signInWithPopup(GoogleAuthProvider());
      return result.user!;
    }

    final googleUser = await _google.signIn();
    if (googleUser == null) {
      throw FirebaseAuthException(code: 'popup-closed-by-user');
    }
    final googleAuth = await googleUser.authentication;
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );
    final result = await _auth.signInWithCredential(credential);
    return result.user!;
  }

  Future<void> logout() async {
    await _auth.signOut();
    if (!kIsWeb) {
      try {
        await _google.signOut();
      } catch (_) {}
    }
  }

  /// Deactivates the patient account and deletes the Firebase Auth user.
  ///
  /// The underlying `patients` record is intentionally kept (soft delete) so the
  /// clinic retains the patient's history, matching the note that patient info
  /// stays on record even after the app account is removed.
  Future<void> deleteAccount() async {
    final user = _auth.currentUser;
    if (user == null) {
      throw FirebaseAuthException(code: 'no-current-user');
    }
    try {
      await _db.collection('patient_accounts').doc(user.uid).set(
        {
          'active': false,
          'deletedAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        },
        SetOptions(merge: true),
      );
    } catch (_) {
      // Deactivation is best-effort; still attempt to remove the auth user.
    }
    await user.delete();
    if (!kIsWeb) {
      try {
        await _google.signOut();
      } catch (_) {}
    }
  }

  Future<bool> patientAccountExists(String uid) async {
    final snap = await _db.collection('patient_accounts').doc(uid).get();
    return snap.exists && snap.data()?['active'] == true;
  }

  Future<String> registerPatient(
    String uid, {
    required String firstName,
    required String lastName,
    required String contactNumber,
    required String email,
    required String authProvider,
  }) async {
    final firstError = personNameError(firstName, label: 'First name');
    if (firstError != null) throw Exception(firstError);
    final lastError = personNameError(lastName, label: 'Last name');
    if (lastError != null) throw Exception(lastError);

    final cleanFirst = normalizePersonName(firstName);
    final cleanLast = normalizePersonName(lastName);

    final patientRef = await _db.collection('patients').add({
      'firstName': cleanFirst,
      'lastName': cleanLast,
      'email': email,
      'contactNumber': contactNumber,
      'birthdate': '',
      'sex': 'other',
      'age': null,
      'address': '',
      'emergencyContact': '',
      'medicalConditions': '',
      'allergies': '',
      'currentMedications': '',
      'archived': false,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });

    await _db.collection('patient_accounts').doc(uid).set({
      'patientId': patientRef.id,
      'email': email,
      'displayName': '$cleanFirst $cleanLast'.trim(),
      'phone': contactNumber,
      'authProvider': authProvider,
      'active': true,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });

    return patientRef.id;
  }

  Future<({String patientId, Map<String, dynamic> patient})> resolvePatientSession(
    String uid,
  ) async {
    final accountSnap = await _db.collection('patient_accounts').doc(uid).get();
    if (!accountSnap.exists || accountSnap.data()?['active'] != true) {
      throw Exception('NEEDS_PROFILE');
    }
    final patientId = accountSnap.data()!['patientId'] as String;
    final patientSnap = await _db.collection('patients').doc(patientId).get();
    if (!patientSnap.exists) {
      throw Exception('Patient record not found. Contact the clinic.');
    }
    return (patientId: patientId, patient: patientSnap.data()!);
  }
}
