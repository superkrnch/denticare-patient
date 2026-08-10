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
        // Personal Header with Dental Badge
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
                Row(
                  children: [
                    const Icon(Icons.verified_user_rounded, size: 14, color: AppColors.primary),
                    const SizedBox(width: 4),
                    Text(
                      'Xeradent Dental Patient Portal',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: AppColors.subtle(context)),
                    ),
                  ],
                ),
              ],
            ),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.12),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.shield_outlined, color: AppColors.primary, size: 20),
            ),
          ],
        ),
        const SizedBox(height: 18),

        // Hero Dental Appointment Banner
        Container(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF0F766E), Color(0xFF0D9488), Color(0xFF14B8A6)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(22),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withOpacity(0.35),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(22),
            child: Stack(
              children: [
                Positioned(
                  right: -15,
                  bottom: -20,
                  child: Icon(
                    Icons.clean_hands_rounded,
                    size: 150,
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
                            child: const Row(
                              children: [
                                Icon(Icons.calendar_month, color: Colors.white, size: 12),
                                SizedBox(width: 4),
                                Text(
                                  'UPCOMING DENTAL VISIT',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 0.8,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (next != null) StatusBadge(next.status),
                        ],
                      ),
                      const SizedBox(height: 16),
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
                            const Icon(Icons.health_and_safety_outlined, color: Colors.white70, size: 16),
                            const SizedBox(width: 6),
                              Text(
                                next.serviceType,
                                style: const TextStyle(color: Color.fromRGBO(255, 255, 255, 0.9), fontSize: 14, fontWeight: FontWeight.w500),
                            ),
                          ],
                        ),
                      ] else ...[
                        const Text(
                          'Keep Your Smile Healthy',
                          style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'No visits scheduled. Regular checkups prevent cavities and keep your teeth shining.',
                          style: TextStyle(color: Color.fromRGBO(255, 255, 255, 0.8), fontSize: 12, height: 1.3),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 18),

        // Live Queue Banner (If active today)
        if (queue != null) ...[
          _QueueCard(queue: queue),
          const SizedBox(height: 18),
        ],

        // Emergency Dental Banner
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF2A1515) : const Color(0xFFFEF2F2),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.danger.withOpacity(0.3)),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.danger.withOpacity(0.12),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.medical_services_rounded, color: AppColors.danger, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Dental Emergency or Toothache?',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                        color: isDark ? const Color(0xFFFCA5A5) : AppColors.danger,
                      ),
                    ),
                    Text(
                      'Tap to call clinic hotline or request priority care',
                      style: TextStyle(fontSize: 11, color: AppColors.subtle(context)),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right_rounded, color: AppColors.subtle(context)),
            ],
          ),
        ),
        const SizedBox(height: 20),

        const SectionTitle('Quick Dental Actions'),
        const SizedBox(height: 10),

        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            _QuickAction(
              icon: AppIcons.calendar,
              label: 'Book Visit',
              subtitle: 'Cleanings & Checkups',
              onTap: () => showBookAppointmentSheet(context),
            ),
            _QuickAction(
              icon: AppIcons.queue,
              label: 'My Queue',
              subtitle: 'Live Chair Waiting List',
              onTap: () => onNavigate(2),
            ),
            _QuickAction(
              icon: AppIcons.bills,
              label: 'Dental Bills',
              subtitle: 'Invoices & Payments',
              onTap: () => onNavigate(3),
            ),
            _QuickAction(
              icon: AppIcons.tooth,
              label: 'Tooth Records',
              subtitle: 'Dental Charts & History',
              onTap: () => onNavigate(4),
            ),
            _QuickAction(
              icon: AppIcons.clinic,
              label: 'Clinic Hours',
              subtitle: 'Dentist Schedules & Location',
              onTap: () => showClinicInfoSheet(context),
            ),
            _QuickAction(
              icon: AppIcons.afterCare,
              label: 'Post-Care Tips',
              subtitle: 'Extraction & Braces Care',
              onTap: () => showAfterCareSheet(context),
            ),
            _QuickAction(
              icon: Icons.info_outline,
              label: 'About Clinic',
              subtitle: 'Meet Our Dental Staff',
              onTap: () => showAboutSheet(context),
            ),
          ],
        ),
        const SizedBox(height: 24),

        // Daily Dental Tip Card
        const SectionTitle('Daily Smile Care'),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(16),
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
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(Icons.auto_awesome_rounded, color: AppColors.primary, size: 24),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Brush 2x Daily for 2 Minutes',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: AppColors.body(context),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Use soft-bristled brushes and fluoride toothpaste to protect enamel.',
                      style: TextStyle(fontSize: 12, color: AppColors.subtle(context), height: 1.3),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        const SectionTitle('Recent Dental Visits'),
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
                  child: EmptyState(icon: AppIcons.calendar, message: 'No past dental visits recorded'),
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
                    'DENTAL QUEUE TICKET',
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
                        ? 'Please proceed to Dental Chair'
                        : 'Waiting room · Next in line soon',
                    style: TextStyle(fontSize: 12, color: AppColors.body(context)),
                  ),
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
                    size: 12,
                    color: AppColors.subtle(context).withOpacity(0.5),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Text(
                label,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: AppColors.body(context),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 11,
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
                    fontSize: 14,
                    color: AppColors.body(context),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${formatDate(appointment.date)} · ${formatTime(appointment.time)}',
                  style: TextStyle(fontSize: 12, color: AppColors.subtle(context)),
                ),
                const SizedBox(height: 2),
                Text(
                  appointment.dentistName ?? 'Attending Dentist',
                  style: TextStyle(color: AppColors.subtle(context), fontSize: 11),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              StatusBadge(appointment.status),
              if (showActions && (appointment.status == 'pending' || appointment.status == 'approved'))
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