import 'package:intl/intl.dart';

import 'constants.dart';

String todayStr() => DateTime.now().toIso8601String().substring(0, 10);

String formatDate(String? value) {
  if (value == null || value.isEmpty) return '—';
  final d = DateTime.parse('${value}T12:00:00');
  return DateFormat('EEE, MMM d, y').format(d);
}

String formatTime(String? value) {
  if (value == null || value.isEmpty) return '';
  final parts = value.split(':');
  final d = DateTime(2000, 1, 1, int.parse(parts[0]), int.parse(parts[1]));
  return DateFormat.jm().format(d);
}

String formatMoney(num? value) {
  final n = NumberFormat.currency(locale: 'en_PH', symbol: '₱');
  return n.format(value ?? 0);
}

String greeting(String firstName) {
  final h = DateTime.now().hour;
  final word = h < 12
      ? 'Good morning'
      : h < 17
          ? 'Good afternoon'
          : 'Good evening';
  return '$word, $firstName';
}

String formatClinicHours(Map<String, dynamic>? settings) {
  final hours = settings?['hours'];
  if (hours is! Map) return AppConstants.clinicHours;

  const days = [
    'monday',
    'tuesday',
    'wednesday',
    'thursday',
    'friday',
    'saturday',
    'sunday',
  ];
  const labels = {
    'monday': 'Mon',
    'tuesday': 'Tue',
    'wednesday': 'Wed',
    'thursday': 'Thu',
    'friday': 'Fri',
    'saturday': 'Sat',
    'sunday': 'Sun',
  };

  final open = <String>[];
  final closed = <String>[];
  for (final day in days) {
    final dayHours = hours[day];
    if (dayHours is Map && dayHours['closed'] == true) {
      closed.add(labels[day]!);
    } else if (dayHours is Map) {
      open.add('${labels[day]} ${dayHours['open']}–${dayHours['close']}');
    }
  }

  var text = open.join(' · ');
  if (closed.isNotEmpty) text += ' · Closed ${closed.join(', ')}';
  return text;
}
