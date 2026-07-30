import 'package:flutter/foundation.dart';

import '../models/models.dart';

/// Payload delivered when the app is opened from a notification tap.
class NotificationTapMessage {
  const NotificationTapMessage(this.data);

  final Map<String, dynamic> data;
}

/// Lightweight notification coordinator.
///
/// NOTE: This is a self-contained, no-op-safe implementation. It exposes the
/// full surface the app relies on (permission, patient token binding, and
/// queue/appointment change hooks) but does not depend on a specific push
/// backend, so it builds and runs on every platform without extra native
/// configuration. Wire it to `firebase_messaging` here if/when push is set up.
class NotificationService {
  NotificationService._();

  static final NotificationService instance = NotificationService._();

  /// Called with a target screen key ("queue", "appointments", …) when the
  /// user opens the app from a notification.
  void Function(String payload)? onNotificationTap;

  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;
    _initialized = true;
  }

  /// Returns the notification that launched the app, if any.
  Future<NotificationTapMessage?> getInitialMessage() async => null;

  Future<void> requestPermission() async {}

  /// Associate the signed-in patient with this device (e.g. store an FCM token).
  Future<void> bindPatient(String patientId) async {}

  /// Remove this device's association for [patientId] on sign-out.
  Future<void> unbindPatient(String patientId) async {}

  /// Hook invoked whenever the patient's live queue entry changes.
  Future<void> handleQueueStatusChange(
    QueueEntry? previous,
    QueueEntry? current,
  ) async {
    if (current == null) return;
    if (previous?.status == current.status) return;
    debugPrint('Queue status changed: ${previous?.status} -> ${current.status}');
  }

  /// Hook invoked whenever one of the patient's appointments changes status.
  Future<void> handleAppointmentStatusChange(
    Appointment previous,
    Appointment current,
  ) async {
    if (previous.status == current.status) return;
    debugPrint(
      'Appointment ${current.id} status changed: '
      '${previous.status} -> ${current.status}',
    );
  }
}
