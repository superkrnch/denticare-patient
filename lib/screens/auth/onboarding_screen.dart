import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/friendly_errors.dart';
import '../../core/phone_format.dart';
import '../../core/validators.dart';
import '../../providers/app_provider.dart';
import '../../widgets/auth_shell.dart';
import '../../widgets/common.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _first = TextEditingController();
  final _last = TextEditingController();
  final _phone = TextEditingController();
  final _email = TextEditingController();
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    final user = context.read<AppProvider>().pendingUser;
    final names = (user?.displayName ?? '').split(' ').where((s) => s.isNotEmpty).toList();
    _first.text = names.isNotEmpty ? names.first : '';
    _last.text = names.length > 1 ? names.sublist(1).join(' ') : '';
    _email.text = user?.email ?? '';
    final phone = formatE164ToLocal(user?.phoneNumber);
    if (phone.isNotEmpty) _phone.text = phone;
  }

  @override
  void dispose() {
    _first.dispose();
    _last.dispose();
    _phone.dispose();
    _email.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final firstError = personNameError(_first.text, label: 'First name');
    if (firstError != null) {
      showAppToast(context, firstError);
      return;
    }
    final lastError = personNameError(_last.text, label: 'Last name');
    if (lastError != null) {
      showAppToast(context, lastError);
      return;
    }
    if (_phone.text.trim().isEmpty) {
      showAppToast(context, 'Mobile number is required.');
      return;
    }
    setState(() => _busy = true);
    try {
      await context.read<AppProvider>().completeOnboarding(
            firstName: _first.text.trim(),
            lastName: _last.text.trim(),
            contactNumber: _phone.text.trim(),
          );
      if (mounted) showAppToast(context, 'Welcome to DentiCare!');
    } catch (e) {
      if (mounted) showAppToast(context, friendlyError(e));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AuthShell(
      leading: const AuthBrandHeader(title: 'Almost there', subtitle: 'Complete your patient profile'),
      child: AuthCard(
        child: Column(
          children: [
            TextField(
              controller: _first,
              decoration: const InputDecoration(labelText: 'First name *'),
              textCapitalization: TextCapitalization.words,
              keyboardType: TextInputType.name,
              inputFormatters: personNameInputFormatters(),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _last,
              decoration: const InputDecoration(labelText: 'Last name *'),
              textCapitalization: TextCapitalization.words,
              keyboardType: TextInputType.name,
              inputFormatters: personNameInputFormatters(),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _phone,
              decoration: const InputDecoration(
                labelText: 'Mobile number *',
                hintText: '09XX XXX XXXX',
              ),
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _email,
              readOnly: true,
              decoration: InputDecoration(
                labelText: 'Email',
                hintText: _email.text.isEmpty ? 'Signed in with phone' : null,
              ),
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: _busy ? null : _submit,
              child: Text(_busy ? 'Creating...' : 'Create my account'),
            ),
          ],
        ),
      ),
    );
  }
}
