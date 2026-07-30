import 'package:flutter/services.dart';

bool isValidEmail(String value) {
  final email = value.trim();
  if (email.isEmpty) return false;
  return RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(email);
}

final RegExp _personNamePattern = RegExp(
  r"^[\p{L}]+(?:[ '\-][\p{L}]+)*$",
  unicode: true,
);

/// Letters only (Unicode), optional spaces, hyphens, apostrophes. No numbers.
bool isValidPersonName(String value) {
  return personNameError(value) == null;
}

String? personNameError(String value, {String label = 'Name'}) {
  final name = _normalizePersonName(value);
  if (name.isEmpty) return '$label is required.';
  if (RegExp(r'\d').hasMatch(name)) {
    return '$label cannot contain numbers.';
  }
  if (!_personNamePattern.hasMatch(name)) {
    return 'Enter a real $label (letters only).';
  }

  final letters = name.replaceAll(RegExp(r'[^\p{L}]', unicode: true), '');
  if (letters.length < 2) {
    return '$label must be at least 2 letters.';
  }
  return null;
}

String normalizePersonName(String value) => _normalizePersonName(value);

String _normalizePersonName(String value) {
  return value.trim().replaceAll(RegExp(r'\s+'), ' ');
}

/// Blocks numbers and symbols while typing a person's name.
List<TextInputFormatter> personNameInputFormatters() {
  return [
    FilteringTextInputFormatter.deny(RegExp(r'[0-9]')),
    FilteringTextInputFormatter.allow(RegExp(r"[\p{L}\s'-]", unicode: true)),
  ];
}
