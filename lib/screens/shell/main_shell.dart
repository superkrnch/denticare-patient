import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../appointments/appointments_screen.dart';
import '../bills/bills_screen.dart';
import '../home/home_screen.dart';
import '../profile/profile_screen.dart';
import '../queue/queue_screen.dart';
import '../treatments/treatments_screen.dart';
import '../../providers/app_provider.dart';
import '../../widgets/app_logo.dart';

class MainShell extends StatelessWidget {
  const MainShell({super.key});

  static const _titles = ['Home', 'Appointments', 'My Queue', 'Bills', 'Treatments', 'Profile'];
  static const _subtitles = [
    '',
    'Book and manage visits',
    "Today's waiting status",
    'Invoices and payments',
    'Your plans and clinic procedures',
    'Your personal information',
  ];

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppProvider>();
    final index = app.navIndex;

    final screens = [
      HomeScreen(onNavigate: app.setNavIndex),
      const AppointmentsScreen(),
      const QueueScreen(),
      const BillsScreen(),
      const TreatmentsScreen(),
      const ProfileScreen(),
    ];

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        leading: Padding(
          padding: const EdgeInsets.all(10),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: const AppLogo(height: 36, width: 36, fit: BoxFit.cover),
          ),
        ),
        leadingWidth: 56,
        centerTitle: true,
        title: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              _titles[index],
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
            ),
            if (_subtitles[index].isNotEmpty)
              Text(
                _subtitles[index],
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.normal),
              ),
          ],
        ),
        toolbarHeight: index == 0 ? 72 : 64,
      ),
      body: IndexedStack(index: index, children: screens),
      bottomNavigationBar: NavigationBar(
        selectedIndex: index,
        onDestinationSelected: app.setNavIndex,
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: 'Home'),
          NavigationDestination(
            icon: Icon(Icons.calendar_today_outlined),
            selectedIcon: Icon(Icons.calendar_today),
            label: 'Visits',
          ),
          NavigationDestination(
            icon: Icon(Icons.format_list_numbered_outlined),
            selectedIcon: Icon(Icons.format_list_numbered),
            label: 'Queue',
          ),
          NavigationDestination(
            icon: Icon(Icons.receipt_long_outlined),
            selectedIcon: Icon(Icons.receipt_long),
            label: 'Bills',
          ),
          NavigationDestination(
            icon: Icon(Icons.medical_services_outlined),
            selectedIcon: Icon(Icons.medical_services),
            label: 'Treatments',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
