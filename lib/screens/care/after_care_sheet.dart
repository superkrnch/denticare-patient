import 'package:flutter/material.dart';

import '../../core/theme.dart';
import '../../widgets/app_icons.dart';

class _CareTip {
  const _CareTip(this.icon, this.title, this.body);
  final IconData icon;
  final String title;
  final String body;
}

const List<_CareTip> _afterCareTips = [
  _CareTip(
    Icons.bloodtype_outlined,
    'Control bleeding',
    'Bite gently on clean gauze for 30–45 minutes after an extraction. Replace if it soaks through.',
  ),
  _CareTip(
    Icons.ac_unit_outlined,
    'Reduce swelling',
    'Apply a cold compress to the cheek for 10–15 minutes at a time during the first 24 hours.',
  ),
  _CareTip(
    Icons.restaurant_outlined,
    'Eat soft foods',
    'Stick to soft, lukewarm foods for a day. Avoid chewing on the treated side.',
  ),
  _CareTip(
    Icons.no_drinks_outlined,
    'Avoid straws & smoking',
    'Suction can dislodge the clot and delay healing. Skip straws, smoking, and vigorous rinsing for 24 hours.',
  ),
  _CareTip(
    Icons.medication_outlined,
    'Take medication as directed',
    'Use prescribed pain relief and finish any antibiotics your dentist gives you.',
  ),
  _CareTip(
    Icons.clean_hands_outlined,
    'Keep it clean',
    'After 24 hours, rinse gently with warm salt water and brush carefully around the area.',
  ),
];

Future<void> showAfterCareSheet(BuildContext context) {
  return showModalBottomSheet(
    context: context,
    useSafeArea: true,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (ctx) {
      return DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.7,
        minChildSize: 0.4,
        maxChildSize: 0.92,
        builder: (context, controller) => ListView(
          controller: controller,
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: const Color(0xFFCBD5E1),
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
            ),
            Row(
              children: [
                AppIconBadge(icon: AppIcons.afterCare),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'After-care tips',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            const Text(
              'Follow these to heal comfortably after your visit. Call the clinic if pain or bleeding is severe or lasts more than a few days.',
              style: TextStyle(color: AppColors.muted, height: 1.4),
            ),
            const SizedBox(height: 16),
            ..._afterCareTips.map((tip) => _CareTipRow(tip: tip)),
          ],
        ),
      );
    },
  );
}

class _CareTipRow extends StatelessWidget {
  const _CareTipRow({required this.tip});

  final _CareTip tip;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(tip.icon, color: AppColors.primary, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(tip.title, style: const TextStyle(fontWeight: FontWeight.w700)),
                const SizedBox(height: 2),
                Text(tip.body, style: const TextStyle(color: AppColors.muted, height: 1.4)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Compact teaser shown on the home screen that opens the full after-care sheet.
class AfterCarePreviewCard extends StatelessWidget {
  const AfterCarePreviewCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => showAfterCareSheet(context),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              AppIconBadge(icon: AppIcons.afterCare),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Recovering from a procedure?',
                        style: TextStyle(fontWeight: FontWeight.w700)),
                    SizedBox(height: 2),
                    Text('Tap for after-care instructions.',
                        style: TextStyle(color: AppColors.muted, fontSize: 13)),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: AppColors.muted),
            ],
          ),
        ),
      ),
    );
  }
}
