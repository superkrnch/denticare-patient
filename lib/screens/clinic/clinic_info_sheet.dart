import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../core/constants.dart';
import '../../core/formatters.dart';
import '../../core/theme.dart';
import '../../providers/app_provider.dart';
import '../../widgets/app_icons.dart';
import '../../widgets/common.dart';
import '../about/about_sheet.dart';

Future<void> showClinicInfoSheet(BuildContext context) {
  return showModalBottomSheet(
    context: context,
    useSafeArea: true,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (ctx) {
      final clinic = ctx.watch<AppProvider>().data.clinic;
      final name = clinic?['clinicName'] as String? ?? AppConstants.clinicName;
      final address = clinic?['address'] as String? ?? AppConstants.clinicAddress;
      final phone = clinic?['phone'] as String? ?? AppConstants.clinicPhone;
      final email = clinic?['email'] as String? ?? AppConstants.clinicEmail;
      final hours = formatClinicHours(clinic);

      return DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.7,
        minChildSize: 0.4,
        maxChildSize: 0.95,
        builder: (context, scrollController) => ListView(
          controller: scrollController,
          padding: const EdgeInsets.all(24),
          children: [
            const Text('Clinic information',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
            const SizedBox(height: 16),
            Text(name, style: const TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 12),
            ClinicInfoRow(icon: AppIcons.location, text: address),
            ClinicInfoRow(icon: AppIcons.phone, text: phone),
            ClinicInfoRow(icon: AppIcons.email, text: email),
            ClinicInfoRow(icon: AppIcons.hours, text: hours),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.primaryLight.withValues(alpha: 0.35),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.primary),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.volunteer_activism_outlined,
                      size: 18, color: AppColors.primary),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      AppConstants.freeConsultation,
                      style: const TextStyle(height: 1.4, fontSize: 13),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            const SectionTitle('Follow us'),
            for (final link in AppConstants.socialLinks)
              _SocialRow(link: link),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: () {
                Navigator.pop(context);
                showAboutSheet(context);
              },
              icon: const Icon(Icons.info_outline),
              label: const Text('About DentiCare & branches'),
            ),
            const SizedBox(height: 8),
          ],
        ),
      );
    },
  );
}

class _SocialRow extends StatelessWidget {
  const _SocialRow({required this.link});

  final SocialLink link;

  IconData get _icon => switch (link.label) {
        'Facebook' => Icons.facebook,
        'Instagram' => Icons.camera_alt_outlined,
        'TikTok' => Icons.music_note_outlined,
        'Email' => Icons.mail_outlined,
        _ => Icons.link,
      };

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(_icon, size: 18, color: AppColors.primary),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(link.label,
                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                Text(link.handle,
                    style: TextStyle(color: AppColors.subtle(context), fontSize: 12)),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.copy_outlined, size: 18),
            tooltip: 'Copy link',
            onPressed: () async {
              await Clipboard.setData(ClipboardData(text: link.url));
              if (context.mounted) {
                showAppToast(context, '${link.label} link copied to clipboard.');
              }
            },
          ),
        ],
      ),
    );
  }
}
