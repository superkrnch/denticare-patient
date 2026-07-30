import 'package:cloud_firestore/cloud_firestore.dart';

import '../core/constants.dart';
import '../models/models.dart';

class PatientRepository {
  PatientRepository({FirebaseFirestore? firestore})
      : _db = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _db;
  Map<String, dynamic>? _cachedDentist;

  Future<PatientData> fetchPatientData(String patientId) async {
    final results = await Future.wait([
      _fetchAppointments(patientId),
      _fetchTreatments(patientId),
      _fetchBillings(patientId),
      _fetchClinicSettings(),
      _fetchTodayQueue(patientId),
    ]);
    return PatientData(
      appointments: results[0] as List<Appointment>,
      treatments: results[1] as List<Treatment>,
      billings: results[2] as List<Billing>,
      clinic: results[3] as Map<String, dynamic>?,
      queue: results[4] as QueueEntry?,
    );
  }

  Stream<QueueEntry?> subscribeTodayQueue(String patientId) {
    final today = _todayStr();
    return _db
        .collection('queues')
        .where('patientId', isEqualTo: patientId)
        .where('date', isEqualTo: today)
        .snapshots()
        .map((snap) {
      final items = snap.docs
          .map((d) => QueueEntry.fromMap(d.id, d.data()))
          .toList();
      final active = items.where((q) => q.status == 'waiting' || q.status == 'serving').firstOrNull;
      if (active != null) return active;
      items.sort((a, b) => b.queueNumber.compareTo(a.queueNumber));
      return items.isNotEmpty ? items.first : null;
    });
  }

  Stream<List<Appointment>> subscribeAppointments(String patientId) {
    return _db
        .collection('appointments')
        .where('patientId', isEqualTo: patientId)
        .orderBy('date', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map((d) => Appointment.fromMap(d.id, d.data())).toList());
  }

  Future<String> createAppointmentRequest(
    Patient patient, {
    required ProcedureTemplate template,
    required String date,
    required String time,
    required String notes,
    required bool urgent,
  }) async {
    final dentist = await _getDefaultDentist();
    final patientName = [patient.firstName, patient.lastName].where((s) => s.isNotEmpty).join(' ');
    final ref = await _db.collection('appointments').add({
      'appointmentId': _generateId('APT'),
      'patientId': patient.id,
      'patientName': patientName,
      'dentistId': dentist['id'],
      'dentistName': dentist['displayName'],
      'serviceType': template.name,
      'procedureId': template.id,
      'estimatedCost': template.defaultCost,
      'date': date,
      'time': time,
      'notes': notes,
      'urgent': urgent,
      'priority': urgent ? 'urgent' : 'normal',
      'status': 'pending',
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
    return ref.id;
  }

  Future<void> cancelAppointmentRequest(String appointmentId) async {
    await _db.collection('appointments').doc(appointmentId).update({
      'status': 'cancelled',
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> updatePatientProfile(
    String patientId,
    Map<String, dynamic> fields,
  ) async {
    await _db.collection('patients').doc(patientId).update({
      ...fields,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> updateProfilePhoto(String patientId, String photoData) async {
    await updatePatientProfile(patientId, {'photoData': photoData});
  }

  Future<void> removeProfilePhoto(String patientId) async {
    await updatePatientProfile(patientId, {'photoData': FieldValue.delete()});
  }

  Future<List<Appointment>> _fetchAppointments(String patientId) async {
    final snap = await _db
        .collection('appointments')
        .where('patientId', isEqualTo: patientId)
        .orderBy('date', descending: true)
        .get();
    return snap.docs.map((d) => Appointment.fromMap(d.id, d.data())).toList();
  }

  Future<List<Treatment>> _fetchTreatments(String patientId) async {
    final snap = await _db
        .collection('treatments')
        .where('patientId', isEqualTo: patientId)
        .orderBy('createdAt', descending: true)
        .get();
    return snap.docs.map((d) => Treatment.fromMap(d.id, d.data())).toList();
  }

  Future<List<Billing>> _fetchBillings(String patientId) async {
    final snap = await _db
        .collection('billings')
        .where('patientId', isEqualTo: patientId)
        .orderBy('createdAt', descending: true)
        .get();
    return snap.docs.map((d) => Billing.fromMap(d.id, d.data())).toList();
  }

  Future<Map<String, dynamic>?> _fetchClinicSettings() async {
    final snap = await _db.collection('settings').doc('clinic').get();
    return snap.data();
  }

  Future<List<ProcedureTemplate>> fetchTreatmentTemplates() async {
    return _parseTreatmentTemplates(await _db.collection('settings').doc('treatment_templates').get());
  }

  Stream<List<ProcedureTemplate>> subscribeTreatmentTemplates() {
    return _db.collection('settings').doc('treatment_templates').snapshots().map(_parseTreatmentTemplates);
  }

  List<ProcedureTemplate> _parseTreatmentTemplates(DocumentSnapshot snap) {
    try {
      final data = snap.data();
      if (data is! Map) {
        throw StateError('missing templates');
      }
      final items = data['items'];
      if (items is List && items.isNotEmpty) {
        return items
            .whereType<Map>()
            .map((item) => ProcedureTemplate.fromMap(Map<String, dynamic>.from(item)))
            .toList();
      }
    } catch (_) {
      // Fall back to bundled defaults if Firestore is unavailable.
    }
    return AppConstants.defaultProcedureTemplates
        .map((item) => ProcedureTemplate.fromMap(item))
        .toList();
  }

  Future<QueueEntry?> _fetchTodayQueue(String patientId) async {
    final today = _todayStr();
    final snap = await _db
        .collection('queues')
        .where('patientId', isEqualTo: patientId)
        .where('date', isEqualTo: today)
        .get();
    final items = snap.docs.map((d) => QueueEntry.fromMap(d.id, d.data())).toList();
    final active = items.where((q) => q.status == 'waiting' || q.status == 'serving').firstOrNull;
    if (active != null) return active;
    items.sort((a, b) => b.queueNumber.compareTo(a.queueNumber));
    return items.isNotEmpty ? items.first : null;
  }

  Future<Map<String, String>> _getDefaultDentist() async {
    if (_cachedDentist != null) {
      return {
        'id': _cachedDentist!['id'] as String? ?? '',
        'displayName': _cachedDentist!['displayName'] as String? ?? 'Dentist',
      };
    }
    final settingsSnap = await _db.collection('settings').doc('clinic').get();
    final settings = settingsSnap.data();
    if (settings?['primaryDentistId'] != null) {
      _cachedDentist = {
        'id': settings!['primaryDentistId'],
        'displayName': settings['primaryDentistName'] ?? 'Dentist',
      };
    } else {
      _cachedDentist = {'id': '', 'displayName': 'Dr. Maria Santos'};
    }
    return {
      'id': _cachedDentist!['id'] as String? ?? '',
      'displayName': _cachedDentist!['displayName'] as String? ?? 'Dentist',
    };
  }

  String _generateId(String prefix) {
    final ts = DateTime.now().millisecondsSinceEpoch.toRadixString(36);
    final rand = (DateTime.now().microsecondsSinceEpoch % 1000000).toRadixString(36);
    return '$prefix-$ts$rand'.toUpperCase();
  }

  String _todayStr() => DateTime.now().toIso8601String().substring(0, 10);
}

extension<T> on Iterable<T> {
  T? get firstOrNull {
    final it = iterator;
    return it.moveNext() ? it.current : null;
  }
}
