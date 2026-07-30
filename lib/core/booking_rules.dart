String todayIso() => DateTime.now().toIso8601String().substring(0, 10);

String tomorrowIso() {
  final d = DateTime.now().add(const Duration(days: 1));
  return d.toIso8601String().substring(0, 10);
}

String? validatePatientBooking({
  required String date,
  required bool urgent,
  required String notes,
}) {
  final today = todayIso();
  if (date.isEmpty) return 'Please choose a date.';

  if (urgent) {
    if (date != today) {
      return 'Urgent visits are for today only. Turn off urgent to pick a future date.';
    }
    if (notes.trim().length < 10) {
      return 'Please describe your urgent concern (at least 10 characters).';
    }
    return null;
  }

  if (date.compareTo(today) <= 0) {
    return 'Book at least one day ahead, or turn on urgent for same-day emergencies.';
  }
  return null;
}
