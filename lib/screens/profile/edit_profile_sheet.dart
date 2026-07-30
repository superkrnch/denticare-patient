import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/friendly_errors.dart';
import '../../providers/app_provider.dart';
import '../../widgets/common.dart';

Future<void> showEditProfileSheet(BuildContext context) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (ctx) => const _EditProfileSheet(),
  );
}

class _EditProfileSheet extends StatefulWidget {
  const _EditProfileSheet();

  @override
  State<_EditProfileSheet> createState() => _EditProfileSheetState();
}

class _EditProfileSheetState extends State<_EditProfileSheet> {
  late final TextEditingController _phone;
  late final TextEditingController _address;
  late final TextEditingController _emergency;
  late final TextEditingController _allergies;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    final p = context.read<AppProvider>().patient!;
    _phone = TextEditingController(text: p.contactNumber);
    _address = TextEditingController(text: p.address);
    _emergency = TextEditingController(text: p.emergencyContact);
    _allergies = TextEditingController(text: p.allergies);
  }

  @override
  void dispose() {
    _phone.dispose();
    _address.dispose();
    _emergency.dispose();
    _allergies.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    setState(() => _busy = true);
    try {
      await context.read<AppProvider>().updateProfile(
            contactNumber: _phone.text.trim(),
            address: _address.text.trim(),
            emergencyContact: _emergency.text.trim(),
            allergies: _allergies.text.trim(),
          );
      if (mounted) {
        Navigator.pop(context);
        showAppToast(context, 'Profile updated.');
      }
    } catch (e) {
      if (mounted) showAppToast(context, friendlyError(e));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Edit contact info', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
            const SizedBox(height: 16),
            TextField(controller: _phone, decoration: const InputDecoration(labelText: 'Phone')),
            const SizedBox(height: 12),
            TextField(controller: _address, decoration: const InputDecoration(labelText: 'Address')),
            const SizedBox(height: 12),
            TextField(controller: _emergency, decoration: const InputDecoration(labelText: 'Emergency contact')),
            const SizedBox(height: 12),
            TextField(controller: _allergies, decoration: const InputDecoration(labelText: 'Allergies')),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: _busy ? null : _save,
              child: Text(_busy ? 'Saving...' : 'Save changes'),
            ),
          ],
        ),
      ),
    );
  }
}
