import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/app_provider.dart';
import '../../widgets/auth_shell.dart';

class SessionErrorScreen extends StatelessWidget {
  const SessionErrorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppProvider>();
    final message = app.authError ?? 'Could not load your patient profile.';

    return AuthShell(
      leading: const AuthBrandHeader(
        title: 'Almost signed in',
        subtitle: 'Your account loaded, but we could not open the app.',
      ),
      child: AuthCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              message,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 20),
            FilledButton(
              onPressed: () => app.retrySessionLoad(),
              child: const Text('Try again'),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () => app.logout(),
              child: const Text('Sign out'),
            ),
          ],
        ),
      ),
    );
  }
}
