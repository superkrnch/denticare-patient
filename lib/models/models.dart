import 'package:cloud_firestore/cloud_firestore.dart';

class Patient {
  Patient({
    required this.id,
    required this.firstName,
    required this.lastName,
    this.email,
    this.contactNumber = '',
    this.address = '',
    this.emergencyContact = '',
    this.allergies = '',
    this.medicalConditions = '',
    this.currentMedications = '',
    this.birthdate,
    this.sex,
    this.photoData,
  });

  final String id;
  final String firstName;
  final String lastName;
  final String? email;
  final String contactNumber;
  final String address;
  final String emergencyContact;
  final String allergies;
  final String medicalConditions;
  final String currentMedications;
  final String? birthdate;
  final String? sex;
  final String? photoData;

  String get initials =>
      '${firstName.isNotEmpty ? firstName[0] : ''}${lastName.isNotEmpty ? lastName[0] : ''}';

  Patient copyWith({
    String? contactNumber,
    String? address,
    String? emergencyContact,
    String? allergies,
    String? photoData,
    bool clearPhoto = false,
  }) {
    return Patient(
      id: id,
      firstName: firstName,
      lastName: lastName,
      email: email,
      contactNumber: contactNumber ?? this.contactNumber,
      address: address ?? this.address,
      emergencyContact: emergencyContact ?? this.emergencyContact,
      allergies: allergies ?? this.allergies,
      medicalConditions: medicalConditions,
      currentMedications: currentMedications,
      birthdate: birthdate,
      sex: sex,
      photoData: clearPhoto ? null : (photoData ?? this.photoData),
    );
  }

  factory Patient.fromMap(String id, Map<String, dynamic> data) {
    return Patient(
      id: id,
      firstName: data['firstName'] as String? ?? '',
      lastName: data['lastName'] as String? ?? '',
      email: data['email'] as String?,
      contactNumber: data['contactNumber'] as String? ?? '',
      address: data['address'] as String? ?? '',
      emergencyContact: data['emergencyContact'] as String? ?? '',
      allergies: data['allergies'] as String? ?? '',
      medicalConditions: data['medicalConditions'] as String? ?? '',
      currentMedications: data['currentMedications'] as String? ?? '',
      birthdate: data['birthdate'] as String?,
      sex: data['sex'] as String?,
      photoData: data['photoData'] as String?,
    );
  }
}

class Appointment {
  Appointment({
    required this.id,
    required this.serviceType,
    required this.date,
    required this.time,
    required this.status,
    this.dentistName,
    this.notes,
    this.urgent = false,
  });

  final String id;
  final String serviceType;
  final String date;
  final String time;
  final String status;
  final String? dentistName;
  final String? notes;
  final bool urgent;

  factory Appointment.fromMap(String id, Map<String, dynamic> data) {
    return Appointment(
      id: id,
      serviceType: data['serviceType'] as String? ?? 'Visit',
      date: data['date'] as String? ?? '',
      time: data['time'] as String? ?? '',
      status: data['status'] as String? ?? 'pending',
      dentistName: data['dentistName'] as String?,
      notes: data['notes'] as String?,
      urgent: data['urgent'] == true,
    );
  }
}

class Treatment {
  Treatment({
    required this.id,
    required this.procedureName,
    required this.status,
    this.toothNumber,
    this.date,
    this.cost,
    this.notes,
  });

  final String id;
  final String procedureName;
  final String status;
  final String? toothNumber;
  final String? date;
  final num? cost;
  final String? notes;

  factory Treatment.fromMap(String id, Map<String, dynamic> data) {
    final createdAt = data['createdAt'];
    String? date;
    if (createdAt is Timestamp) {
      date = createdAt.toDate().toIso8601String().substring(0, 10);
    }
    final tooth = data['toothNumber'];
    return Treatment(
      id: id,
      procedureName: data['procedureName'] as String? ?? 'Treatment',
      status: data['status'] as String? ?? 'planned',
      toothNumber: tooth?.toString(),
      date: date,
      cost: data['cost'] as num?,
      notes: data['notes'] as String?,
    );
  }
}

class ProcedureTemplate {
  ProcedureTemplate({
    required this.id,
    required this.name,
    required this.defaultCost,
    this.defaultNotes = '',
  });

  final String id;
  final String name;
  final num defaultCost;
  final String defaultNotes;

  factory ProcedureTemplate.fromMap(Map<String, dynamic> data) {
    return ProcedureTemplate(
      id: data['id'] as String? ??
          data['name']?.toString().toLowerCase().replaceAll(' ', '_') ??
          'procedure',
      name: data['name'] as String? ?? 'Procedure',
      defaultCost: _readNum(data['defaultCost']),
      defaultNotes: data['defaultNotes'] as String? ?? '',
    );
  }

  static num _readNum(dynamic value) {
    if (value is num) return value;
    if (value is String) return num.tryParse(value) ?? 0;
    return 0;
  }
}

class Billing {
  Billing({
    required this.id,
    required this.invoiceNumber,
    required this.paymentStatus,
    required this.totalAmount,
    required this.paidAmount,
    this.date,
    this.treatments = const [],
  });

  final String id;
  final String invoiceNumber;
  final String paymentStatus;
  final num totalAmount;
  final num paidAmount;
  final String? date;
  final List<BillingItem> treatments;

  num get balance => totalAmount - paidAmount;

  factory Billing.fromMap(String id, Map<String, dynamic> data) {
    final createdAt = data['createdAt'];
    String? date;
    if (createdAt is Timestamp) {
      date = createdAt.toDate().toIso8601String().substring(0, 10);
    }
    final items = (data['treatments'] as List<dynamic>? ?? [])
        .map((e) => BillingItem.fromMap(e as Map<String, dynamic>))
        .toList();
    return Billing(
      id: id,
      invoiceNumber: data['invoiceNumber'] as String? ?? id,
      paymentStatus: data['paymentStatus'] as String? ?? 'unpaid',
      totalAmount: data['totalAmount'] as num? ?? 0,
      paidAmount: data['paidAmount'] as num? ?? 0,
      date: date,
      treatments: items,
    );
  }
}

class BillingItem {
  BillingItem({required this.procedureName, required this.cost});

  final String procedureName;
  final num cost;

  factory BillingItem.fromMap(Map<String, dynamic> data) {
    return BillingItem(
      procedureName: data['procedureName'] as String? ?? 'Item',
      cost: data['cost'] as num? ?? 0,
    );
  }
}

class QueueEntry {
  QueueEntry({
    required this.id,
    required this.queueNumber,
    required this.status,
    required this.date,
    this.urgent = false,
  });

  final String id;
  final int queueNumber;
  final String status;
  final String date;
  final bool urgent;

  factory QueueEntry.fromMap(String id, Map<String, dynamic> data) {
    return QueueEntry(
      id: id,
      queueNumber: (data['queueNumber'] as num?)?.toInt() ?? 0,
      status: data['status'] as String? ?? 'waiting',
      date: data['date'] as String? ?? '',
      urgent: data['urgent'] == true,
    );
  }
}

class PatientData {
  PatientData({
    this.appointments = const [],
    this.treatments = const [],
    this.billings = const [],
    this.clinic,
    this.queue,
  });

  final List<Appointment> appointments;
  final List<Treatment> treatments;
  final List<Billing> billings;
  final Map<String, dynamic>? clinic;
  final QueueEntry? queue;

  PatientData copyWith({QueueEntry? queue}) {
    return PatientData(
      appointments: appointments,
      treatments: treatments,
      billings: billings,
      clinic: clinic,
      queue: queue,
    );
  }
}
