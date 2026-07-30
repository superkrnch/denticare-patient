import 'package:flutter/material.dart';

import '../core/theme.dart';

class StatusBadge extends StatelessWidget {
  const StatusBadge(this.status, {super.key});

  final String status;

  Color get _color {
    switch (status) {
      case 'approved':
      case 'paid':
      case 'completed':
      case 'serving':
        return AppColors.success;
      case 'pending':
      case 'waiting':
      case 'unpaid':
        return AppColors.warning;
      case 'cancelled':
      case 'rejected':
        return AppColors.danger;
      case 'urgent':
        return AppColors.danger;
      default:
        return AppColors.muted;
    }
  }

  @override
  Widget build(BuildContext context) {
    final label = status.replaceAll('_', ' ');
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: _color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: _color,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
