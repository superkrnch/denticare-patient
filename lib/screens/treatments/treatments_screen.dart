import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants.dart';
import '../../core/formatters.dart';
import '../../core/theme.dart';
import '../../models/models.dart';
import '../../providers/app_provider.dart';
import '../../widgets/app_icons.dart';
import '../../widgets/common.dart';
import '../../widgets/status_badge.dart';

class TreatmentsScreen extends StatelessWidget {
  const TreatmentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppProvider>();
    final treatments = app.data.treatments;
    final templates = app.procedureTemplates.isNotEmpty
        ? app.procedureTemplates
        : AppConstants.defaultProcedureTemplates
            .map((m) => ProcedureTemplate.fromMap(Map<String, dynamic>.from(m)))
            .toList();

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      children: [
        const SectionTitle('Your treatment plans'),
        if (treatments.isEmpty)
          const Card(
            child: EmptyState(
              icon: AppIcons.tooth,
              message: 'No treatment plans yet.\nYour dentist will add them after a visit.',
            ),
          )
        else
          ...treatments.map((t) => _TreatmentCard(treatment: t)),
        const SizedBox(height: 8),
        const SectionTitle('Clinic procedures & pricing'),
        _ProcedureList(templates: templates),
        const SizedBox(height: 8),
        const Text(
          'Prices are estimates and may vary with your specific case. Ask your dentist for a detailed quote.',
          style: TextStyle(color: AppColors.muted, fontSize: 12, height: 1.4),
        ),
      ],
    );
  }
}

class _TreatmentCard extends StatelessWidget {
  const _TreatmentCard({required this.treatment});

  final Treatment treatment;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    treatment.procedureName,
                    style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
                  ),
                ),
                StatusBadge(treatment.status),
              ],
            ),
            const SizedBox(height: 4),
            Wrap(
              spacing: 12,
              runSpacing: 2,
              children: [
                if (treatment.toothNumber != null)
                  Text('Tooth #${treatment.toothNumber}',
                      style: const TextStyle(color: AppColors.muted, fontSize: 13)),
                if (treatment.date != null)
                  Text(formatDate(treatment.date),
                      style: const TextStyle(color: AppColors.muted, fontSize: 13)),
                if (treatment.cost != null)
                  Text(formatMoney(treatment.cost),
                      style: const TextStyle(
                          color: AppColors.primary,
                          fontSize: 13,
                          fontWeight: FontWeight.w600)),
              ],
            ),
            if (treatment.notes != null && treatment.notes!.isNotEmpty) ...[
              const SizedBox(height: 6),
              Text(treatment.notes!, style: const TextStyle(height: 1.4)),
            ],
          ],
        ),
      ),
    );
  }
}

/// A fixed-height, independently scrollable list of clinic procedures so the
/// long price list stays tidy and easy to browse without scrolling the whole
/// page.
class _ProcedureList extends StatefulWidget {
  const _ProcedureList({required this.templates});

  final List<ProcedureTemplate> templates;

  @override
  State<_ProcedureList> createState() => _ProcedureListState();
}

class _ProcedureListState extends State<_ProcedureList> {
  final _controller = ScrollController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxHeight: 340),
        child: Scrollbar(
          controller: _controller,
          thumbVisibility: true,
          child: ListView.separated(
            controller: _controller,
            primary: false,
            shrinkWrap: true,
            padding: const EdgeInsets.symmetric(vertical: 4),
            itemCount: widget.templates.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, i) => _ProcedureRow(template: widget.templates[i]),
          ),
        ),
      ),
    );
  }
}

class _ProcedureRow extends StatelessWidget {
  const _ProcedureRow({required this.template});

  final ProcedureTemplate template;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(template.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                if (template.defaultNotes.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(template.defaultNotes,
                      style: const TextStyle(color: AppColors.muted, fontSize: 13)),
                ],
              ],
            ),
          ),
          const SizedBox(width: 12),
          Text(
            template.defaultCost > 0 ? formatMoney(template.defaultCost) : '—',
            style: TextStyle(fontWeight: FontWeight.w700, color: AppColors.body(context)),
          ),
        ],
      ),
    );
  }
}
