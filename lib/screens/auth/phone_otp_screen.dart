import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../core/friendly_errors.dart';
import '../../models/phone_otp_session.dart';
import '../../providers/app_provider.dart';
import '../../widgets/auth_shell.dart';
import '../../widgets/common.dart';

class PhoneOtpScreen extends StatefulWidget {
  const PhoneOtpScreen({super.key});

  @override
  State<PhoneOtpScreen> createState() => _PhoneOtpScreenState();
}

class _PhoneOtpScreenState extends State<PhoneOtpScreen> {
  final _phone = TextEditingController();
  final _code = TextEditingController();
  PhoneOtpSession? _session;
  bool _busy = false;

  @override
  void dispose() {
    _phone.dispose();
    _code.dispose();
    super.dispose();
  }

  bool get _codeSent => _session != null;

  Future<void> _sendCode({bool resend = false}) async {
    if (_phone.text.trim().isEmpty) {
      showAppToast(context, 'Enter your mobile number.');
      return;
    }
    setState(() => _busy = true);
    try {
      final session = await context.read<AppProvider>().sendPhoneOtp(
            _phone.text.trim(),
            resendToken: resend ? _session?.resendToken : null,
          );
      if (!mounted) return;
      if (session.autoSignedIn) {
        Navigator.pop(context);
        return;
      }
      setState(() => _session = session);
      showAppToast(context, resend ? 'Code re-sent.' : 'We sent you a 6-digit code.');
    } catch (e) {
      if (mounted) showAppToast(context, friendlyError(e));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _verify() async {
    final session = _session;
    if (session == null) return;
    if (_code.text.trim().length < 6) {
      showAppToast(context, 'Enter the 6-digit code.');
      return;
    }
    setState(() => _busy = true);
    try {
      await context.read<AppProvider>().verifyPhoneOtp(session, _code.text.trim());
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) showAppToast(context, friendlyError(e));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AuthShell(
      leading: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.maybePop(context),
            icon: const Icon(Icons.arrow_back, color: Colors.white),
          ),
        ],
      ),
      child: AuthCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              _codeSent ? 'Enter the code' : 'Sign in with phone',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 6),
            Text(
              _codeSent
                  ? 'We sent a 6-digit code to ${_phone.text.trim()}.'
                  : "We'll text you a one-time code to verify your number.",
              style: const TextStyle(color: Color(0xFF64748B), height: 1.4),
            ),
            const SizedBox(height: 16),
            if (!_codeSent) ...[
              TextField(
                controller: _phone,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: 'Mobile number',
                  hintText: '09XX XXX XXXX',
                ),
              ),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: _busy ? null : () => _sendCode(),
                child: Text(_busy ? 'Sending...' : 'Send code'),
              ),
            ] else ...[
              TextField(
                controller: _code,
                keyboardType: TextInputType.number,
                maxLength: 6,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: const InputDecoration(
                  labelText: 'Verification code',
                  hintText: '123456',
                  counterText: '',
                ),
              ),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: _busy ? null : _verify,
                child: Text(_busy ? 'Verifying...' : 'Verify & continue'),
              ),
              const SizedBox(height: 4),
              TextButton(
                onPressed: _busy ? null : () => _sendCode(resend: true),
                child: const Text('Resend code'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
