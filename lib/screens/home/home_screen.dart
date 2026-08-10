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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ListView(
      padding: const EdgeInsets.fromLTRB(18, 12, 18, 32),
      children: [
        // Personal Header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  greeting(patient.firstName),
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: AppColors.body(context),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Welcome to your DentiCare portal',
                  style: TextStyle(fontSize: 13, color: AppColors.subtle(context)),
                ),
              ],
            ),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.12),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.notifications_none_rounded, color: AppColors.primary, size: 22),
            ),
          ],
        ),
        const SizedBox(height: 20),

        // Hero Next Visit Banner (Gradient Card)
        Container(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF0F766E), Color(0xFF0D9488)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withOpacity(0.35),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Stack(
              children: [
                Positioned(
                  right: -20,
                  bottom: -20,
                  child: Icon(
                    Icons.calendar_month_rounded,
                    size: 140,
                    color: Colors.white.withOpacity(0.08),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(22),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Text(
                              'NEXT VISIT',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.8,
                              ),
                            ),
                          ),
                          if (next != null) StatusBadge(next.status),
                        ],
                      ),
                      const SizedBox(height: 14),
                      if (next != null) ...[
                        Text(
                          '${formatDate(next.date)} · ${formatTime(next.time)}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            const Icon(Icons.medical_services_outlined, color: Colors.white70, size: 16),
                            const SizedBox(width: 6),
                            Text(
                              next.serviceType,
                              style: const TextStyle(color: Color.fromRGBO(255, 255, 255, 0.9), fontSize: 14, fontWeight: FontWeight.w500),
                            ),
                          ],
                        ),
                      ] else ...[
                        const Text(
                          'No upcoming visits',
                          style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Book your next checkup anytime below.',
                          style: TextStyle(color: Colors.white70, fontSize: 13),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),

        if (queue != null) ...[
          _QueueCard(queue: queue),
          const SizedBox(height: 16),
        ],

        const SectionTitle('Quick actions'),
        const SizedBox(height: 8),

        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            _QuickAction(
              icon: AppIcons.calendar,
              label: 'Book visit',
              subtitle: 'Schedule appointment',
              onTap: () => showBookAppointmentSheet(context),
            ),
            _QuickAction(
              icon: AppIcons.queue,
              label: 'My queue',
              subtitle: 'Live status',
              onTap: () => onNavigate(2),
            ),
            _QuickAction(
              icon: AppIcons.bills,
              label: 'View bills',
              subtitle: 'Statements & history',
              onTap: () => onNavigate(3),
            ),
            _QuickAction(
              icon: AppIcons.tooth,
              label: 'Treatments',
              subtitle: 'Records & charts',
              onTap: () => onNavigate(4),
            ),
            _QuickAction(
              icon: AppIcons.clinic,
              label: 'Clinic info',
              subtitle: 'Hours & location',
              onTap: () => showClinicInfoSheet(context),
            ),
            _QuickAction(
              icon: AppIcons.afterCare,
              label: 'After care',
              subtitle: 'Recovery tips',
              onTap: () => showAfterCareSheet(context),
            ),
            _QuickAction(
              icon: Icons.info_outline,
              label: 'About us',
              subtitle: 'DentiCare clinic',
              onTap: () => showAboutSheet(context),
            ),
          ],
        ),
        const SizedBox(height: 24),

        const SectionTitle('After your visit'),
        const SizedBox(height: 8),
        const AfterCarePreviewCard(),
        const SizedBox(height: 24),

        const SectionTitle('Recent appointments'),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: AppColors.surface(context),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppColors.border(context)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(isDark ? 0.2 : 0.04),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: recent.isEmpty
              ? const Padding(
                  padding: EdgeInsets.symmetric(vertical: 24),
                  child: EmptyState(icon: AppIcons.calendar, message: 'No appointments'),
                )
              : ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: recent.length,
                  separatorBuilder: (_, __) => Divider(height: 1, color: AppColors.border(context)),
                  itemBuilder: (context, index) => _AppointmentTile(
                    appointment: recent[index],
                    showActions: false,
                  ),
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
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface(context),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.primary, width: 2),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.18),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'YOUR QUEUE NUMBER TODAY',
                    style: TextStyle(
                      color: AppColors.subtle(context),
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.6,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '#${queue.queueNumber}',
                    style: const TextStyle(
                      fontSize: 42,
                      fontWeight: FontWeight.w800,
                      color: AppColors.primary,
                      height: 1.1,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    queue.status == 'serving'
                        ? 'Proceed to treatment area'
                        : 'Please wait in the waiting room',
                    style: TextStyle(fontSize: 13, color: AppColors.body(context)),
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
  const _QuickAction({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        splashColor: AppColors.primary.withOpacity(0.15),
        child: Container(
          width: (MediaQuery.sizeOf(context).width - 48) / 2,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surface(context),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border(context)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(isDark ? 0.25 : 0.04),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(icon, color: AppColors.primary, size: 22),
                  ),
                  Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 13,
                    color: AppColors.subtle(context).withOpacity(0.5),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Text(
                label,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                  color: AppColors.body(context),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.subtle(context),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
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
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  appointment.serviceType,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: AppColors.body(context),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${formatDate(appointment.date)} · ${formatTime(appointment.time)}',
                  style: TextStyle(fontSize: 13, color: AppColors.subtle(context)),
                ),
                const SizedBox(height: 2),
                Text(
                  appointment.dentistName ?? 'Dentist',
                  style: TextStyle(color: AppColors.subtle(context), fontSize: 12),
                ),
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

Widget appointmentTile(BuildContext context, Appointment appointment, {required bool showActions}) {
  return _AppointmentTile(appointment: appointment, showActions: showActions);
}