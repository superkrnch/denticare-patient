// Philippine mobile-number helpers.
//
// Accepts common local formats (09XX XXX XXXX, +639XXXXXXXXX, 639XXXXXXXXX,
// 9XXXXXXXXX) and normalizes to E.164 (+639XXXXXXXXX).

String _digits(String value) => value.replaceAll(RegExp(r'[^0-9]'), '');

/// Converts a user-entered PH mobile number to E.164, or `null` if invalid.
String? formatPhoneToE164(String? input) {
  if (input == null) return null;
  final trimmed = input.trim();
  if (trimmed.isEmpty) return null;

  // Already E.164 for PH.
  if (trimmed.startsWith('+63')) {
    final rest = _digits(trimmed.substring(3));
    if (rest.length == 10 && rest.startsWith('9')) return '+63$rest';
    return null;
  }

  final digits = _digits(trimmed);

  // 639XXXXXXXXX
  if (digits.length == 12 && digits.startsWith('63')) {
    final rest = digits.substring(2);
    if (rest.startsWith('9')) return '+63$rest';
    return null;
  }

  // 09XXXXXXXXX
  if (digits.length == 11 && digits.startsWith('09')) {
    return '+63${digits.substring(1)}';
  }

  // 9XXXXXXXXX
  if (digits.length == 10 && digits.startsWith('9')) {
    return '+63$digits';
  }

  return null;
}

/// Converts an E.164 PH number back to the local `09XXXXXXXXX` format for
/// display / prefilling. Returns an empty string when it cannot be parsed.
String formatE164ToLocal(String? e164) {
  if (e164 == null) return '';
  final trimmed = e164.trim();
  if (trimmed.isEmpty) return '';

  if (trimmed.startsWith('+63')) {
    final rest = _digits(trimmed.substring(3));
    if (rest.length == 10) return '0$rest';
  }

  final digits = _digits(trimmed);
  if (digits.length == 12 && digits.startsWith('63')) {
    return '0${digits.substring(2)}';
  }
  if (digits.length == 11 && digits.startsWith('09')) {
    return digits;
  }
  if (digits.length == 10 && digits.startsWith('9')) {
    return '0$digits';
  }
  return trimmed;
}
