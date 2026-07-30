import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/formatters.dart';
import '../../core/theme.dart';
import '../../providers/app_provider.dart';
import '../../widgets/app_icons.dart';
import '../../widgets/common.dart';
import '../../widgets/status_badge.dart';
import '../care/after_care_sheet.dart';

class QueueScreen extends StatelessWidget {
  const QueueScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppProvider>();
    final queue = app.todayQueue;
    final today = todayStr();
    final todayAppt = app.data.appointments
        .where((a) => a.date == today && a.status == 'approved')
        .firstOrNull;

    if (queue != null) {
      return ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  const Text('Your number', style: TextStyle(color: AppColors.muted)),
                  Text(
                    '#${queue.queueNumber}',
                    style: const TextStyle(
                      fontSize: 56,
                      fontWeight: FontWeight.w800,
                      color: AppColors.primary,
                    ),
                  ),
                  StatusBadge(queue.status),
                  const SizedBox(height: 12),
                  Text(
                    queue.status == 'serving'
                        ? 'The dentist is ready for you. Please proceed.'
                        : queue.status == 'completed'
                            ? 'Your visit is complete. Thank you!'
                            : 'Relax in the waiting area. We will call your number soon.',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: AppColors.muted),
                  ),
                ],
              ),
            ),
          ),
          if (queue.status == 'completed') ...[
            const SectionTitle('After your visit'),
            const AfterCarePreviewCard(),
          ],
          const Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'Live updates: This page refreshes automatically when reception calls your number.',
              ),
            ),
          ),
        ],
      );
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      children: [
        const Card(
          child: EmptyState(
            icon: AppIcons.queue,
            message: 'Not in queue today.\nCheck in at reception when you arrive.',
          ),
        ),
        if (todayAppt != null)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Today's appointment", style: TextStyle(color: AppColors.muted, fontSize: 13)),
                  const SizedBox(height: 6),
                  Text(
                    '${todayAppt.serviceType} · ${formatTime(todayAppt.time)}',
                    style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Approved — visit the clinic and check in at the front desk',
                    style: TextStyle(color: AppColors.muted, fontSize: 13),
                  ),
                ],
              ),
            ),
          )
        else
          const Padding(
            padding: EdgeInsets.only(top: 8),
            child: Text(
              'No approved appointment today.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.muted),
            ),
          ),
      ],
    );
  }
}

extension<T> on Iterable<T> {
  T? get firstOrNull {
    final it = iterator;
    return it.moveNext() ? it.current : null;
  }
}
