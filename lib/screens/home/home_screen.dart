import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/formatters.dart';
import '../../core/theme.dart';
import '../../models/models.dart';
import '../../providers/app_provider.dart';
import '../../widgets/app_icons.dart';
import '../../widgets/common.dart';
import '../../widgets/status_badge.dart';
import '../about/about_sheet.dart';
import '../booking/book_appointment_sheet.dart';
import '../care/after_care_sheet.dart';
import '../clinic/clinic_info_sheet.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key, required this.onNavigate});

  final void Function(int index) onNavigate;

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppProvider>();
    final patient = app.patient!;
    final next = app.nextAppointment;
    final queue = app.todayQueue;
    final recent = app.data.appointments.take(3).toList();

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      children: [
        Text(
          greeting(patient.firstName),
          style: const TextStyle(fontSize: 14, color: AppColors.muted),
        ),
        const SizedBox(height: 16),
        Card(
          color: AppColors.primary,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Next visit', style: TextStyle(color: Colors.white70, fontSize: 13)),
                const SizedBox(height: 6),
                if (next != null) ...[
                  Text(
                    '${formatDate(next.date)} · ${formatTime(next.time)}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Text(next.serviceType, style: const TextStyle(color: Colors.white70)),
                      const SizedBox(width: 8),
                      StatusBadge(next.status),
                    ],
                  ),
                ] else
                  const Text(
                    'No upcoming visits',
                    style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600),
                  ),
              ],
            ),
          ),
        ),
        if (queue != null) _QueueCard(queue: queue),
        const SectionTitle('Quick actions'),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            _QuickAction(
              icon: AppIcons.calendar,
              label: 'Book visit',
              onTap: () => showBookAppointmentSheet(context),
            ),
            _QuickAction(
              icon: AppIcons.queue,
              label: 'My queue',
              onTap: () => onNavigate(2),
            ),
            _QuickAction(
              icon: AppIcons.bills,
              label: 'View bills',
              onTap: () => onNavigate(3),
            ),
            _QuickAction(
              icon: AppIcons.tooth,
              label: 'Treatments',
              onTap: () => onNavigate(4),
            ),
            _QuickAction(
              icon: AppIcons.clinic,
              label: 'Clinic info',
              onTap: () => showClinicInfoSheet(context),
            ),
            _QuickAction(
              icon: AppIcons.afterCare,
              label: 'After care',
              onTap: () => showAfterCareSheet(context),
            ),
            _QuickAction(
              icon: Icons.info_outline,
              label: 'About us',
              onTap: () => showAboutSheet(context),
            ),
          ],
        ),
        const SectionTitle('After your visit'),
        const AfterCarePreviewCard(),
        const SectionTitle('Recent appointments'),
        Card(
          child: recent.isEmpty
              ? const EmptyState(icon: AppIcons.calendar, message: 'No appointments')
              : Column(
                  children: recent
                      .map((a) => _AppointmentTile(appointment: a, showActions: false))
                      .toList(),
                ),
        ),
      ],
    );
  }
}

class _QueueCard extends StatelessWidget {
  const _QueueCard({required this.queue});

  final QueueEntry queue;

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppColors.primary, width: 4),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Your queue number today', style: TextStyle(color: AppColors.muted, fontSize: 13)),
                  Text(
                    '#${queue.queueNumber}',
                    style: const TextStyle(fontSize: 40, fontWeight: FontWeight.w800, color: AppColors.primary),
                  ),
                  Text(
                    queue.status == 'serving'
                        ? 'Please proceed to the treatment area'
                        : 'Please wait in the waiting room',
                    style: const TextStyle(fontSize: 13),
                  ),
                  if (queue.urgent) ...[
                    const SizedBox(height: 8),
                    const StatusBadge('urgent'),
                  ],
                ],
              ),
            ),
            StatusBadge(queue.status),
          ],
        ),
      ),
    );
  }
}

class _QuickAction extends StatelessWidget {
  const _QuickAction({required this.icon, required this.label, required this.onTap});

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        width: (MediaQuery.sizeOf(context).width - 52) / 2,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.surface(context),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border(context)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppIconBadge(icon: icon, compact: true),
            const SizedBox(height: 10),
            Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }
}

class _AppointmentTile extends StatelessWidget {
  const _AppointmentTile({required this.appointment, required this.showActions});

  final Appointment appointment;
  final bool showActions;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(appointment.serviceType, style: const TextStyle(fontWeight: FontWeight.w700)),
                Text('${formatDate(appointment.date)} · ${formatTime(appointment.time)}'),
                Text(appointment.dentistName ?? 'Dentist', style: const TextStyle(color: AppColors.muted, fontSize: 13)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              StatusBadge(appointment.status),
              if (appointment.urgent) ...[
                const SizedBox(height: 4),
                const StatusBadge('urgent'),
              ],
              if (showActions &&
                  (appointment.status == 'pending' || appointment.status == 'approved'))
                TextButton(
                  onPressed: () => _cancel(context, appointment.id),
                  child: const Text('Cancel', style: TextStyle(color: AppColors.danger)),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _cancel(BuildContext context, String id) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Cancel appointment?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('No')),
          FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Yes')),
        ],
      ),
    );
    if (ok != true || !context.mounted) return;
    try {
      await context.read<AppProvider>().cancelAppointment(id);
      if (context.mounted) showAppToast(context, 'Appointment cancelled.');
    } catch (e) {
      if (context.mounted) showAppToast(context, e.toString());
    }
  }
}

// Export tile for appointments screen
Widget appointmentTile(BuildContext context, Appointment appointment, {required bool showActions}) {
  return _AppointmentTile(appointment: appointment, showActions: showActions);
}
