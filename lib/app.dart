import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/theme.dart';
import 'providers/app_provider.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/onboarding_screen.dart';
import 'screens/auth/session_error_screen.dart';
import 'screens/shell/main_shell.dart';

class DenticareApp extends StatelessWidget {
  const DenticareApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeMode = context.watch<AppProvider>().themeMode;
    return MaterialApp(
      title: 'DentiCare Patient',
      debugShowCheckedModeBanner: false,
      theme: buildAppTheme(),
      darkTheme: buildAppDarkTheme(),
      themeMode: themeMode,
      home: const _AuthGate(),
    );
  }
}

class _AuthGate extends StatelessWidget {
  const _AuthGate();

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppProvider>().authState;

    return switch (state) {
      AppAuthState.loading => const Scaffold(
          body: Center(child: CircularProgressIndicator()),
        ),
      AppAuthState.unauthenticated => const LoginScreen(),
      AppAuthState.needsProfile => const OnboardingScreen(),
      AppAuthState.sessionError => const SessionErrorScreen(),
      AppAuthState.authenticated => const MainShell(),
    };
  }
}
