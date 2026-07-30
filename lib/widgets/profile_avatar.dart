import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../core/theme.dart';
import '../models/models.dart';

/// Circular patient avatar. Shows the stored photo when available, otherwise
/// the patient's initials. Optionally renders a small camera "edit" badge.
class ProfileAvatar extends StatelessWidget {
  const ProfileAvatar({
    super.key,
    required this.patient,
    this.radius = 24,
    this.showEditBadge = false,
  });

  final Patient patient;
  final double radius;
  final bool showEditBadge;

  Uint8List? get _photoBytes {
    final data = patient.photoData;
    if (data == null || data.isEmpty) return null;
    try {
      final base64Part = data.contains(',') ? data.split(',').last : data;
      return base64Decode(base64Part);
    } catch (_) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final bytes = _photoBytes;
    final avatar = CircleAvatar(
      radius: radius,
      backgroundColor: AppColors.primaryLight,
      foregroundImage: bytes != null ? MemoryImage(bytes) : null,
      child: bytes == null
          ? Text(
              patient.initials.toUpperCase(),
              style: TextStyle(
                fontSize: radius * 0.7,
                fontWeight: FontWeight.w700,
                color: AppColors.primaryDark,
              ),
            )
          : null,
    );

    if (!showEditBadge) return avatar;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        avatar,
        Positioned(
          right: 0,
          bottom: 0,
          child: Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2),
            ),
            child: const Icon(Icons.photo_camera, size: 14, color: Colors.white),
          ),
        ),
      ],
    );
  }
}
