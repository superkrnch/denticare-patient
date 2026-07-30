import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' show ThemeMode;
import 'package:shared_preferences/shared_preferences.dart';

import '../core/friendly_errors.dart';
import '../models/models.dart';
import '../models/phone_otp_session.dart';
import '../services/auth_service.dart';
import '../services/notification_service.dart';
import '../services/patient_repository.dart';

enum AppAuthState {
  loading,
  unauthenticated,
  needsProfile,
  authenticated,
  sessionError,
}

class AppProvider extends ChangeNotifier {
  AppProvider({
    AuthService? authService,
    PatientRepository? repository,
  })  : _auth = authService ?? AuthService(),
        _repo = repository ?? PatientRepository();

  final AuthService _auth;
  final PatientRepository _repo;

  static const _themePrefKey = 'themeMode';

  AppAuthState authState = AppAuthState.loading;
  ThemeMode themeMode = ThemeMode.system;
  Patient? patient;
  PatientData data = PatientData();
  List<ProcedureTemplate> procedureTemplates = [];
  int navIndex = 0;
  String? authError;
  User? pendingUser;
  StreamSubscription<User?>? _authSub;
  StreamSubscription<QueueEntry?>? _queueSub;
  StreamSubscription<List<Appointment>>? _appointmentsSub;
  StreamSubscription<List<ProcedureTemplate>>? _templatesSub;
  final Map<String, Appointment> _knownAppointments = {};
  bool _handlingAuth = false;
  String? _lastAuthMethod;

  Future<void> init() async {
    await _loadThemeMode();
    NotificationService.instance.onNotificationTap = _onNotificationTap;
    try {
      final redirectUser = await _auth.completeGoogleRedirectIfNeeded();
      if (redirectUser != null) _lastAuthMethod = 'google.com';
    } catch (e) {
      authError = friendlyError(e);
    }
    _authSub = _auth.authStateChanges().listen(_onAuthChanged);
    try {
      final initialMessage = await NotificationService.instance.getInitialMessage();
      if (initialMessage != null) {
        _onNotificationTap(initialMessage.data['screen'] as String? ?? '');
      }
    } catch (e) {
      debugPrint('Initial notification tap skipped: $e');
    }
  }

  void _onNotificationTap(String payload) {
    switch (payload) {
      case 'queue':
        setNavIndex(2);
      case 'appointments':
        setNavIndex(1);
      default:
        break;
    }
  }

  @override
  void dispose() {
    _authSub?.cancel();
    _queueSub?.cancel();
    _appointmentsSub?.cancel();
    _templatesSub?.cancel();
    super.dispose();
  }

  Future<void> _onAuthChanged(User? user) async {
    if (_handlingAuth) return;
    _handlingAuth = true;
    try {
      await _handleAuthChanged(user);
    } finally {
      _handlingAuth = false;
    }
  }

  Future<void> _handleAuthChanged(User? user) async {
    if (user == null) {
      // On web/PWA, Firebase may briefly emit null before restoring a saved session.
      await Future<void>.delayed(const Duration(milliseconds: 400));
      final restored = _auth.currentUser;
      if (restored != null) {
        await _handleAuthChanged(restored);
        return;
      }
    }

    _queueSub?.cancel();
    _queueSub = null;
    _appointmentsSub?.cancel();
    _appointmentsSub = null;
    _templatesSub?.cancel();
    _templatesSub = null;
    _knownAppointments.clear();

    if (user == null) {
      final patientId = patient?.id;
      if (patientId != null) {
        try {
          await NotificationService.instance.unbindPatient(patientId);
        } catch (e) {
          debugPrint('Notification unbind skipped: $e');
        }
      }
      patient = null;
      data = PatientData();
      procedureTemplates = [];
      pendingUser = null;
      authState = AppAuthState.unauthenticated;
      notifyListeners();
      return;
    }

    authState = AppAuthState.loading;
    notifyListeners();

    pendingUser = user;
    try {
      final hasProfile = await _auth.patientAccountExists(user.uid);
      if (!hasProfile) {
        authState = AppAuthState.needsProfile;
        notifyListeners();
        return;
      }
      await _enterApp(user.uid);
    } catch (e) {
      if (e.toString().contains('NEEDS_PROFILE')) {
        authState = AppAuthState.needsProfile;
      } else {
        authError = friendlyError(e);
        authState = AppAuthState.sessionError;
      }
      notifyListeners();
    }
  }

  Future<void> retrySessionLoad() async {
    final user = pendingUser ?? _auth.currentUser;
    if (user == null) {
      authState = AppAuthState.unauthenticated;
      notifyListeners();
      return;
    }

    authState = AppAuthState.loading;
    authError = null;
    notifyListeners();

    try {
      final hasProfile = await _auth.patientAccountExists(user.uid);
      if (!hasProfile) {
        pendingUser = user;
        authState = AppAuthState.needsProfile;
        notifyListeners();
        return;
      }
      await _enterApp(user.uid);
    } catch (e) {
      pendingUser = user;
      if (e.toString().contains('NEEDS_PROFILE')) {
        authState = AppAuthState.needsProfile;
      } else {
        authError = friendlyError(e);
        authState = AppAuthState.sessionError;
      }
      notifyListeners();
    }
  }

  Future<void> _enterApp(String uid) async {
    final session = await _auth.resolvePatientSession(uid);
    patient = Patient.fromMap(session.patientId, session.patient);
    final loaded = await Future.wait([
      _repo.fetchPatientData(session.patientId),
      _repo.fetchTreatmentTemplates(),
    ]);
    data = loaded[0] as PatientData;
    procedureTemplates = loaded[1] as List<ProcedureTemplate>;
    pendingUser = null;
    authState = AppAuthState.authenticated;

    _knownAppointments.clear();
    for (final appointment in data.appointments) {
      _knownAppointments[appointment.id] = appointment;
    }

    _queueSub = _repo.subscribeTodayQueue(session.patientId).listen(
      (queue) async {
        final previous = data.queue;
        await NotificationService.instance.handleQueueStatusChange(previous, queue);
        data = data.copyWith(queue: queue);
        notifyListeners();
      },
      onError: (Object e) => debugPrint('Queue stream error: $e'),
    );

    _appointmentsSub =
        _repo.subscribeAppointments(session.patientId).listen(
      (appointments) async {
        for (final appointment in appointments) {
          final previous = _knownAppointments[appointment.id];
          if (previous != null) {
            await NotificationService.instance
                .handleAppointmentStatusChange(previous, appointment);
          }
          _knownAppointments[appointment.id] = appointment;
        }
        data = PatientData(
          appointments: appointments,
          treatments: data.treatments,
          billings: data.billings,
          clinic: data.clinic,
          queue: data.queue,
        );
        notifyListeners();
      },
      onError: (Object e) => debugPrint('Appointments stream error: $e'),
    );

    _templatesSub = _repo.subscribeTreatmentTemplates().listen(
      (templates) {
        procedureTemplates = templates;
        notifyListeners();
      },
      onError: (Object e) => debugPrint('Procedure template stream error: $e'),
    );

    notifyListeners();

    // Notifications must not block sign-in if permission or Firestore write fails.
    try {
      await NotificationService.instance.requestPermission();
      await NotificationService.instance.bindPatient(session.patientId);
    } catch (e) {
      debugPrint('Notification setup skipped: $e');
    }
  }

  Future<void> loginWithEmail(String email, String password) async {
    authError = null;
    _lastAuthMethod = 'password';
    try {
      await _auth.loginWithEmail(email, password);
    } on FirebaseAuthException catch (e) {
      authError = friendlyAuthError(e.code.replaceFirst('auth/', ''));
      notifyListeners();
      rethrow;
    }
  }

  Future<void> registerWithEmail({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
  }) async {
    authError = null;
    _lastAuthMethod = 'password';
    try {
      await _auth.registerWithEmail(email, password, '$firstName $lastName');
    } on FirebaseAuthException catch (e) {
      authError = friendlyAuthError(e.code.replaceFirst('auth/', ''));
      notifyListeners();
      rethrow;
    }
  }

  Future<void> signInWithGoogle() async {
    authError = null;
    _lastAuthMethod = 'google.com';
    try {
      await _auth.signInWithGoogle();
    } on FirebaseAuthException catch (e) {
      if (e.code == 'redirect-started') return;
      authError = friendlyAuthError(e.code.replaceFirst('auth/', ''));
      notifyListeners();
      rethrow;
    }
  }

  Future<PhoneOtpSession> sendPhoneOtp(String phoneNumber, {int? resendToken}) async {
    authError = null;
    _lastAuthMethod = 'phone';
    try {
      return await _auth.sendPhoneOtp(phoneNumber, forceResendingToken: resendToken);
    } on FirebaseAuthException catch (e) {
      authError = friendlyAuthError(e.code.replaceFirst('auth/', ''));
      notifyListeners();
      rethrow;
    }
  }

  Future<void> verifyPhoneOtp(PhoneOtpSession session, String smsCode) async {
    authError = null;
    try {
      await _auth.verifyPhoneOtp(session, smsCode);
    } on FirebaseAuthException catch (e) {
      authError = friendlyAuthError(e.code.replaceFirst('auth/', ''));
      notifyListeners();
      rethrow;
    }
  }

  Future<void> sendPasswordResetEmail(String email) async {
    authError = null;
    try {
      await _auth.sendPasswordResetEmail(email);
    } on FirebaseAuthException catch (e) {
      authError = friendlyAuthError(e.code.replaceFirst('auth/', ''));
      notifyListeners();
      rethrow;
    }
  }

  Future<void> completeOnboarding({
    required String firstName,
    required String lastName,
    required String contactNumber,
  }) async {
    final user = pendingUser;
    if (user == null) throw Exception('Session expired. Please sign in again.');

    final provider = _lastAuthMethod ??
        (user.providerData.isNotEmpty
            ? user.providerData.first.providerId
            : 'password');

    await _auth.registerPatient(
      user.uid,
      firstName: firstName,
      lastName: lastName,
      contactNumber: contactNumber,
      email: user.email ?? '',
      authProvider: provider,
    );
    await _enterApp(user.uid);
    _lastAuthMethod = null;
  }

  Future<void> logout() async {
    await _auth.logout();
  }

  Future<void> deleteAccount() async {
    await _auth.deleteAccount();
  }

  Future<void> _loadThemeMode() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final saved = prefs.getString(_themePrefKey);
      themeMode = _themeModeFromString(saved);
    } catch (e) {
      debugPrint('Theme preference load skipped: $e');
    }
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    if (themeMode == mode) return;
    themeMode = mode;
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_themePrefKey, mode.name);
    } catch (e) {
      debugPrint('Theme preference save skipped: $e');
    }
  }

  ThemeMode _themeModeFromString(String? value) {
    return switch (value) {
      'light' => ThemeMode.light,
      'dark' => ThemeMode.dark,
      _ => ThemeMode.system,
    };
  }

  Future<void> refreshData() async {
    if (patient == null) return;
    final loaded = await Future.wait([
      _repo.fetchPatientData(patient!.id),
      _repo.fetchTreatmentTemplates(),
    ]);
    data = loaded[0] as PatientData;
    procedureTemplates = loaded[1] as List<ProcedureTemplate>;
    notifyListeners();
  }

  Future<void> bookAppointment({
    required ProcedureTemplate template,
    required String date,
    required String time,
    required String notes,
    required bool urgent,
  }) async {
    if (patient == null) return;
    await _repo.createAppointmentRequest(
      patient!,
      template: template,
      date: date,
      time: time,
      notes: notes,
      urgent: urgent,
    );
    await refreshData();
  }

  Future<void> cancelAppointment(String id) async {
    await _repo.cancelAppointmentRequest(id);
    await refreshData();
  }

  Future<void> updateProfile({
    required String contactNumber,
    required String address,
    required String emergencyContact,
    required String allergies,
  }) async {
    if (patient == null) return;
    await _repo.updatePatientProfile(patient!.id, {
      'contactNumber': contactNumber,
      'address': address,
      'emergencyContact': emergencyContact,
      'allergies': allergies,
    });
    patient = patient!.copyWith(
      contactNumber: contactNumber,
      address: address,
      emergencyContact: emergencyContact,
      allergies: allergies,
    );
    notifyListeners();
  }

  Future<void> uploadProfilePhoto(String photoData) async {
    if (patient == null) return;
    await _repo.updateProfilePhoto(patient!.id, photoData);
    patient = patient!.copyWith(photoData: photoData);
    notifyListeners();
  }

  Future<void> removeProfilePhoto() async {
    if (patient == null) return;
    await _repo.removeProfilePhoto(patient!.id);
    patient = patient!.copyWith(clearPhoto: true);
    notifyListeners();
  }

  void setNavIndex(int index) {
    navIndex = index;
    notifyListeners();
  }

  void clearAuthError() {
    authError = null;
    notifyListeners();
  }

  Appointment? get nextAppointment {
    final today = DateTime.now().toIso8601String().substring(0, 10);
    final upcoming = data.appointments
        .where((a) =>
            (a.status == 'pending' || a.status == 'approved') &&
            a.date.compareTo(today) >= 0)
        .toList()
      ..sort((a, b) => a.date.compareTo(b.date) == 0
          ? a.time.compareTo(b.time)
          : a.date.compareTo(b.date));
    return upcoming.isEmpty ? null : upcoming.first;
  }

  QueueEntry? get todayQueue {
    final q = data.queue;
    final today = DateTime.now().toIso8601String().substring(0, 10);
    if (q == null || q.date != today) return null;
    return q;
  }
}
