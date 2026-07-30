import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/friendly_errors.dart';
import '../../core/validators.dart';
import '../../providers/app_provider.dart';
import '../../widgets/auth_shell.dart';
import 'forgot_password_screen.dart';
import 'phone_otp_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _isSignup = false;
  bool _busy = false;
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _first = TextEditingController();
  final _last = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final message = context.read<AppProvider>().authError;
      if (message == null) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
      context.read<AppProvider>().clearAuthError();
    });
  }

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    _first.dispose();
    _last.dispose();
    super.dispose();
  }

  Future<void> _run(Future<void> Function() action) async {
    setState(() => _busy = true);
    try {
      await action();
    } catch (e) {
      if (mounted) {
        final app = context.read<AppProvider>();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(app.authError ?? friendlyError(e))),
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AuthShell(
      leading: const AuthBrandHeader(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const AuthHeroText(
            heading: 'Your dental care,\nin your pocket.',
            subheading: 'Book visits, track your queue, and view bills.',
          ),
          AuthCard(
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: AuthTabButton(
                        label: 'Sign in',
                        active: !_isSignup,
                        onTap: () => setState(() => _isSignup = false),
                      ),
                    ),
                    Expanded(
                      child: AuthTabButton(
                        label: 'Create account',
                        active: _isSignup,
                        onTap: () => setState(() => _isSignup = true),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                GoogleSignInButton(
                  busy: _busy,
                  onPressed: () => _run(context.read<AppProvider>().signInWithGoogle),
                ),
                const SizedBox(height: 10),
                OutlinedButton.icon(
                  onPressed: _busy
                      ? null
                      : () => Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const PhoneOtpScreen()),
                          ),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size.fromHeight(48),
                    backgroundColor: Colors.white,
                    side: const BorderSide(color: Color(0xFFE2E8F0)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  icon: const Icon(Icons.phone_android_outlined, color: Color(0xFF0F172A)),
                  label: const Text('Continue with phone', style: TextStyle(color: Color(0xFF0F172A))),
                ),
                const AuthDivider(),
                if (_isSignup) ...[
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
                ],
                TextField(
                  controller: _email,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    hintText: 'you@email.com',
                  ),
                  keyboardType: TextInputType.emailAddress,
                  autofillHints: const [AutofillHints.email],
                ),
                const SizedBox(height: 12),
                if (!_isSignup) ...[
                  TextField(
                    controller: _password,
                    decoration: const InputDecoration(
                      labelText: 'Password',
                      hintText: 'Your password',
                    ),
                    obscureText: true,
                    autofillHints: const [AutofillHints.password],
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: _busy
                          ? null
                          : () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => ForgotPasswordScreen(
                                    initialEmail: _email.text.trim(),
                                  ),
                                ),
                              ),
                      child: const Text('Forgot password?'),
                    ),
                  ),
                ] else ...[
                  TextField(
                    controller: _password,
                    decoration: const InputDecoration(
                      labelText: 'Password',
                      hintText: 'Min. 6 characters',
                    ),
                    obscureText: true,
                    autofillHints: const [AutofillHints.newPassword],
                  ),
                  const SizedBox(height: 8),
                ],
                FilledButton(
                  onPressed: _busy ? null : _submitEmail,
                  child: Text(_isSignup ? 'Create account' : 'Sign in'),
                ),
              ],
            ),
          ),
          const AuthHintBox(text: 'Sign in with Google, phone OTP, or your email account.'),
        ],
      ),
    );
  }

  Future<void> _submitEmail() async {
    final email = _email.text.trim();
    final password = _password.text;
    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Email and password are required.')),
      );
      return;
    }
    final app = context.read<AppProvider>();
    if (_isSignup) {
      final first = _first.text.trim();
      final last = _last.text.trim();
      final firstError = personNameError(first, label: 'First name');
      if (firstError != null) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(firstError)));
        return;
      }
      final lastError = personNameError(last, label: 'Last name');
      if (lastError != null) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(lastError)));
        return;
      }
      if (password.length < 6) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Password must be at least 6 characters.')),
        );
        return;
      }
      await _run(() => app.registerWithEmail(
            firstName: first,
            lastName: last,
            email: email,
            password: password,
          ));
    } else {
      await _run(() => app.loginWithEmail(email, password));
    }
  }
}
