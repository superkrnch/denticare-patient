import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/constants.dart';
import '../../core/theme.dart';
import '../../widgets/common.dart';

Future<void> showAboutSheet(BuildContext context) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (ctx) => DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.85,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) => _AboutContent(
        scrollController: scrollController,
      ),
    ),
  );
}

class _AboutContent extends StatelessWidget {
  const _AboutContent({required this.scrollController});

  final ScrollController scrollController;

  @override
  Widget build(BuildContext context) {
    return ListView(
      controller: scrollController,
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
      children: [
        Center(
          child: Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.border(context),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ),
        const SizedBox(height: 20),
        Text(
          AppConstants.clinicName,
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 6),
        Text(
          AppConstants.tagline,
          style: const TextStyle(
            fontSize: 15,
            fontStyle: FontStyle.italic,
            color: AppColors.primary,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 20),
        _InfoCard(
          icon: Icons.volunteer_activism_outlined,
          title: 'Free consultation',
          body: AppConstants.freeConsultation,
          highlight: true,
        ),
        const SectionTitle('Our mission'),
        _ParagraphCard(text: AppConstants.mission),
        const SectionTitle('Our vision'),
        _ParagraphCard(text: AppConstants.vision),
        const SectionTitle('Connect with us'),
        Card(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Column(
              children: [
                for (var i = 0; i < AppConstants.socialLinks.length; i++) ...[
                  if (i > 0) const Divider(height: 1),
                  _SocialRow(link: AppConstants.socialLinks[i]),
                ],
              ],
            ),
          ),
        ),
        const SectionTitle('Our branches'),
        ...AppConstants.branches.map((b) => _BranchCard(branch: b)),
      ],
    );
  }
}

class _ParagraphCard extends StatelessWidget {
  const _ParagraphCard({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Text(text, style: const TextStyle(height: 1.5)),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({
    required this.icon,
    required this.title,
    required this.body,
    this.highlight = false,
  });

  final IconData icon;
  final String title;
  final String body;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: highlight
          ? AppColors.primaryLight.withValues(alpha: 0.35)
          : AppColors.surface(context),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: highlight
            ? const BorderSide(color: AppColors.primary, width: 1.5)
            : BorderSide(color: AppColors.border(context)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: AppColors.primary),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
                  const SizedBox(height: 4),
                  Text(body, style: const TextStyle(height: 1.4)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
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
    return ListTile(
      leading: Icon(_icon, color: AppColors.primary),
      title: Text(link.label),
      subtitle: Text(link.handle),
      trailing: const Icon(Icons.copy_outlined, size: 18),
      onTap: () async {
        await Clipboard.setData(ClipboardData(text: link.url));
        if (context.mounted) {
          showAppToast(context, '${link.label} link copied to clipboard.');
        }
      },
    );
  }
}

class _BranchCard extends StatelessWidget {
  const _BranchCard({required this.branch});

  final Branch branch;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(branch.name,
                style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
            const SizedBox(height: 10),
            _line(Icons.location_on_outlined, branch.address),
            _line(Icons.explore_outlined, 'Landmark: ${branch.landmark}'),
            _line(Icons.phone_outlined, branch.phone),
            _line(Icons.schedule_outlined, branch.hours),
          ],
        ),
      ),
    );
  }

  Widget _line(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: AppColors.primary),
          const SizedBox(width: 10),
          Expanded(child: Text(text, style: const TextStyle(height: 1.4))),
        ],
      ),
    );
  }
}
