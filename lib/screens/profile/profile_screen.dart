import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../core/friendly_errors.dart';
import '../../core/profile_image.dart';
import '../../core/theme.dart';
import '../../providers/app_provider.dart';
import '../../widgets/common.dart';
import '../../widgets/profile_avatar.dart';
import '../about/about_sheet.dart';
import '../clinic/clinic_info_sheet.dart';
import '../feedback/feedback_sheet.dart';
import 'edit_profile_sheet.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _photoBusy = false;

  Future<void> _showPhotoOptions() async {
    final patient = context.read<AppProvider>().patient!;
    final action = await showModalBottomSheet<String>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Profile photo', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
              const SizedBox(height: 8),
              const Text(
                'Photos are resized and compressed before saving.',
                style: TextStyle(color: AppColors.muted, fontSize: 13),
              ),
              const SizedBox(height: 12),
              ListTile(
                leading: const Icon(Icons.photo_library_outlined),
                title: const Text('Choose from gallery'),
                onTap: () => Navigator.pop(ctx, 'gallery'),
              ),
              ListTile(
                leading: const Icon(Icons.photo_camera_outlined),
                title: const Text('Take a photo'),
                onTap: () => Navigator.pop(ctx, 'camera'),
              ),
              if (patient.photoData != null)
                ListTile(
                  leading: const Icon(Icons.delete_outline, color: AppColors.danger),
                  title: const Text('Remove photo', style: TextStyle(color: AppColors.danger)),
                  onTap: () => Navigator.pop(ctx, 'remove'),
                ),
            ],
          ),
        ),
      ),
    );

    if (!mounted || action == null) return;

    if (action == 'remove') {
      await _removePhoto();
      return;
    }

    final source = action == 'camera' ? ImageSource.camera : ImageSource.gallery;
    await _pickAndUpload(source);
  }

  Future<void> _pickAndUpload(ImageSource source) async {
    final picked = await ImagePicker().pickImage(
      source: source,
      maxWidth: 1600,
      maxHeight: 1600,
      imageQuality: 90,
    );
    if (picked == null || !mounted) return;

    setState(() => _photoBusy = true);
    try {
      final bytes = await picked.readAsBytes();
      if (!mounted) return;
      final photoData = compressProfilePhoto(bytes);
      await context.read<AppProvider>().uploadProfilePhoto(photoData);
      if (mounted) showAppToast(context, 'Profile photo updated.');
    } catch (e) {
      if (mounted) showAppToast(context, friendlyError(e));
    } finally {
      if (mounted) setState(() => _photoBusy = false);
    }
  }

  Future<void> _removePhoto() async {
    setState(() => _photoBusy = true);
    try {
      await context.read<AppProvider>().removeProfilePhoto();
      if (mounted) showAppToast(context, 'Profile photo removed.');
    } catch (e) {
      if (mounted) showAppToast(context, friendlyError(e));
    } finally {
      if (mounted) setState(() => _photoBusy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppProvider>();
    final p = app.patient!;

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                GestureDetector(
                  onTap: _photoBusy ? null : _showPhotoOptions,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      ProfileAvatar(patient: p, radius: 44, showEditBadge: !_photoBusy),
                      if (_photoBusy)
                        Container(
                          width: 88,
                          height: 88,
                          decoration: BoxDecoration(
                            color: Colors.black26,
                            shape: BoxShape.circle,
                          ),
                          child: const Padding(
                            padding: EdgeInsets.all(28),
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  _photoBusy ? 'Uploading...' : 'Tap photo to change',
                  style: const TextStyle(color: AppColors.muted, fontSize: 13),
                ),
                const SizedBox(height: 12),
                Text('${p.firstName} ${p.lastName}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                Text(p.email ?? '', style: const TextStyle(color: AppColors.muted)),
              ],
            ),
          ),
        ),
        const SectionTitle('Contact'),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _row('Phone', p.contactNumber.isEmpty ? '—' : p.contactNumber),
                _row('Address', p.address.isEmpty ? '—' : p.address),
                _row('Emergency', p.emergencyContact.isEmpty ? '—' : p.emergencyContact),
                const SizedBox(height: 8),
                OutlinedButton(
                  onPressed: () => showEditProfileSheet(context),
                  child: const Text('Edit contact info'),
                ),
              ],
            ),
          ),
        ),
        const SectionTitle('Health info'),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _row('Allergies', p.allergies.isEmpty ? 'None' : p.allergies),
                _row('Conditions', p.medicalConditions.isEmpty ? 'None' : p.medicalConditions),
                _row('Medications', p.currentMedications.isEmpty ? 'None' : p.currentMedications),
              ],
            ),
          ),
        ),
        const SectionTitle('Appearance'),
        Card(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Theme',
                  style: TextStyle(color: AppColors.subtle(context), fontSize: 13),
                ),
                const SizedBox(height: 10),
                _ThemeSelector(
                  value: app.themeMode,
                  onChanged: app.setThemeMode,
                ),
              ],
            ),
          ),
        ),
        const SectionTitle('About & support'),
        Card(
          child: Column(
            children: [
              ListTile(
                leading: const Icon(Icons.info_outline, color: AppColors.primary),
                title: const Text('About DentiCare'),
                subtitle: const Text('Mission, vision, branches & socials'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => showAboutSheet(context),
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.business_outlined, color: AppColors.primary),
                title: const Text('Clinic information'),
                subtitle: const Text('Contact details and hours'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => showClinicInfoSheet(context),
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.rate_review_outlined, color: AppColors.primary),
                title: const Text('Satisfaction survey'),
                subtitle: const Text('Rate your experience & send feedback'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => showFeedbackSheet(context),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        OutlinedButton.icon(
          onPressed: () => _confirmSignOut(context),
          style: OutlinedButton.styleFrom(foregroundColor: AppColors.danger),
          icon: const Icon(Icons.logout),
          label: const Text('Sign out'),
        ),
        const SizedBox(height: 12),
        TextButton(
          onPressed: () => _confirmDeleteAccount(context),
          style: TextButton.styleFrom(foregroundColor: AppColors.danger),
          child: const Text('Delete account'),
        ),
        const SizedBox(height: 8),
        Text(
          'Deleting your account removes your app access. Your dental records are '
          'kept securely by the clinic for medical and legal requirements.',
          textAlign: TextAlign.center,
          style: TextStyle(color: AppColors.subtle(context), fontSize: 12, height: 1.4),
        ),
      ],
    );
  }

  Future<void> _confirmSignOut(BuildContext context) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Sign out?'),
        content: const Text('Are you sure you want to log out?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.danger),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Sign out'),
          ),
        ],
      ),
    );
    if (ok != true || !context.mounted) return;
    await context.read<AppProvider>().logout();
  }

  Future<void> _confirmDeleteAccount(BuildContext context) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete account?'),
        content: const Text(
          'This permanently removes your DentiCare app account and sign-in. '
          'Your dental records stay on file with the clinic. This cannot be undone.',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.danger),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (ok != true || !context.mounted) return;
    try {
      await context.read<AppProvider>().deleteAccount();
    } catch (e) {
      if (context.mounted) showAppToast(context, friendlyError(e));
    }
  }

  Widget _row(String key, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 110, child: Text(key, style: const TextStyle(color: AppColors.muted))),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}

class _ThemeSelector extends StatelessWidget {
  const _ThemeSelector({required this.value, required this.onChanged});

  final ThemeMode value;
  final ValueChanged<ThemeMode> onChanged;

  @override
  Widget build(BuildContext context) {
    return SegmentedButton<ThemeMode>(
      showSelectedIcon: false,
      segments: const [
        ButtonSegment(
          value: ThemeMode.system,
          label: Text('System'),
          icon: Icon(Icons.brightness_auto_outlined),
        ),
        ButtonSegment(
          value: ThemeMode.light,
          label: Text('Light'),
          icon: Icon(Icons.light_mode_outlined),
        ),
        ButtonSegment(
          value: ThemeMode.dark,
          label: Text('Dark'),
          icon: Icon(Icons.dark_mode_outlined),
        ),
      ],
      selected: {value},
      onSelectionChanged: (selection) => onChanged(selection.first),
    );
  }
}
