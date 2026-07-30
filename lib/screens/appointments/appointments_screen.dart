import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/app_provider.dart';
import '../../widgets/app_icons.dart';
import '../../widgets/common.dart';
import '../booking/book_appointment_sheet.dart';
import '../home/home_screen.dart';

class AppointmentsScreen extends StatelessWidget {
  const AppointmentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appointments = [...context.watch<AppProvider>().data.appointments]
      ..sort((a, b) {
        final d = b.date.compareTo(a.date);
        return d != 0 ? d : b.time.compareTo(a.time);
      });

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      children: [
        FilledButton.icon(
          onPressed: () => showBookAppointmentSheet(context),
          icon: const Icon(Icons.add),
          label: const Text('Request appointment'),
        ),
        const SizedBox(height: 12),
        Card(
          child: appointments.isEmpty
              ? const EmptyState(icon: AppIcons.calendar, message: 'No appointments yet')
              : Column(
                  children: appointments
                      .map((a) => appointmentTile(context, a, showActions: true))
                      .toList(),
                ),
        ),
      ],
    );
  }
}
