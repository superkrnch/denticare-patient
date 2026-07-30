import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/booking_rules.dart';
import '../../core/formatters.dart';
import '../../core/friendly_errors.dart';
import '../../core/theme.dart';
import '../../models/models.dart';
import '../../providers/app_provider.dart';
import '../../widgets/common.dart';

Future<void> showBookAppointmentSheet(BuildContext context) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    isDismissible: true,
    enableDrag: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (ctx) => const _BookAppointmentSheet(),
  );
}

class _BookAppointmentSheet extends StatefulWidget {
  const _BookAppointmentSheet();

  @override
  State<_BookAppointmentSheet> createState() => _BookAppointmentSheetState();
}

class _BookAppointmentSheetState extends State<_BookAppointmentSheet> {
  int _step = 0;
  ProcedureTemplate? _selectedTemplate;
  bool _urgent = false;
  late DateTime _date;
  TimeOfDay _time = const TimeOfDay(hour: 9, minute: 0);
  final _notes = TextEditingController();
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _date = DateTime.now().add(const Duration(days: 1));
  }

  @override
  void dispose() {
    _notes.dispose();
    super.dispose();
  }

  String get _dateIso =>
      '${_date.year}-${_date.month.toString().padLeft(2, '0')}-${_date.day.toString().padLeft(2, '0')}';

  String get _timeStr =>
      '${_time.hour.toString().padLeft(2, '0')}:${_time.minute.toString().padLeft(2, '0')}';

  Future<void> _pickDate() async {
    if (_urgent) return;
    final picked = await showDatePicker(
      context: context,
      firstDate: DateTime.now().add(const Duration(days: 1)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      initialDate: _date,
    );
    if (picked != null) setState(() => _date = picked);
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(context: context, initialTime: _time);
    if (picked != null) setState(() => _time = picked);
  }

  void _continueToDetails() {
    if (_selectedTemplate == null) {
      showAppToast(context, 'Please select the treatment you need first.');
      return;
    }
    setState(() => _step = 1);
  }

  Future<void> _submit() async {
    final template = _selectedTemplate;
    if (template == null) {
      showAppToast(context, 'Please select a treatment first.');
      return;
    }
    final error = validatePatientBooking(
      date: _dateIso,
      urgent: _urgent,
      notes: _notes.text,
    );
    if (error != null) {
      showAppToast(context, error);
      return;
    }
    setState(() => _busy = true);
    try {
      await context.read<AppProvider>().bookAppointment(
            template: template,
            date: _dateIso,
            time: _timeStr,
            notes: _notes.text.trim(),
            urgent: _urgent,
          );
      if (mounted) {
        Navigator.pop(context);
        showAppToast(
          context,
          _urgent
              ? 'Urgent request submitted — clinic will review soon.'
              : 'Appointment request submitted!',
        );
      }
    } catch (e) {
      if (mounted) showAppToast(context, friendlyError(e));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final templates = context.watch<AppProvider>().procedureTemplates;

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                if (_step == 1)
                  IconButton(
                    onPressed: _busy ? null : () => setState(() => _step = 0),
                    icon: const Icon(Icons.arrow_back),
                    tooltip: 'Change treatment',
                  ),
                Expanded(
                  child: Text(
                    _step == 0 ? 'What treatment do you need?' : 'Appointment details',
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              _step == 0
                  ? 'Step 1 of 2 — choose your visit purpose before scheduling.'
                  : 'Step 2 of 2 — pick date and time for ${_selectedTemplate?.name ?? 'your visit'}.',
              style: const TextStyle(color: AppColors.muted, fontSize: 13),
            ),
            const SizedBox(height: 16),
            if (_step == 0) ...[
              if (templates.isEmpty)
                const EmptyState(
                  icon: Icons.medical_services_outlined,
                  message: 'No procedures available yet. Please contact the clinic.',
                )
              else
                ...templates.map((template) {
                  final selected = _selectedTemplate?.id == template.id;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Material(
                      color: selected
                          ? AppColors.primaryLight.withValues(alpha: 0.5)
                          : AppColors.surface(context),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                        side: BorderSide(
                          color: selected ? AppColors.primary : AppColors.border(context),
                          width: selected ? 2 : 1,
                        ),
                      ),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(14),
                        onTap: () => setState(() => _selectedTemplate = template),
                        child: Padding(
                          padding: const EdgeInsets.all(14),
                          child: Row(
                            children: [
                              Icon(
                                selected ? Icons.radio_button_checked : Icons.radio_button_off,
                                color: selected ? AppColors.primary : AppColors.muted,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      template.name,
                                      style: const TextStyle(fontWeight: FontWeight.w700),
                                    ),
                                    if (template.defaultNotes.isNotEmpty) ...[
                                      const SizedBox(height: 4),
                                      Text(
                                        template.defaultNotes,
                                        style: const TextStyle(color: AppColors.muted, fontSize: 13),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                              Text(
                                formatMoney(template.defaultCost),
                                style: const TextStyle(fontWeight: FontWeight.w600),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              const SizedBox(height: 8),
              FilledButton(
                onPressed: _selectedTemplate == null ? null : _continueToDetails,
                child: const Text('Continue'),
              ),
            ] else if (_selectedTemplate != null) ...[
              Card(
                color: AppColors.primaryLight.withValues(alpha: 0.35),
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Row(
                    children: [
                      const Icon(Icons.medical_services_outlined, color: AppColors.primary),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _selectedTemplate!.name,
                              style: const TextStyle(fontWeight: FontWeight.w700),
                            ),
                            Text(
                              'Estimated ${formatMoney(_selectedTemplate!.defaultCost)}',
                              style: const TextStyle(color: AppColors.muted, fontSize: 13),
                            ),
                          ],
                        ),
                      ),
                      TextButton(
                        onPressed: _busy ? null : () => setState(() => _step = 0),
                        child: const Text('Change'),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              CheckboxListTile(
                contentPadding: EdgeInsets.zero,
                value: _urgent,
                onChanged: (v) {
                  setState(() {
                    _urgent = v ?? false;
                    if (_urgent) _date = DateTime.now();
                  });
                },
                title: const Text('Urgent — same day only', style: TextStyle(fontWeight: FontWeight.w600)),
                subtitle: const Text(
                  'Tooth pain, swelling, or emergency. Prioritized in queue after check-in.',
                  style: TextStyle(fontSize: 12),
                ),
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(_urgent ? 'Date (today)' : 'Preferred date *'),
                subtitle: Text(_dateIso),
                trailing: IconButton(
                  icon: const Icon(Icons.calendar_today),
                  onPressed: _urgent ? null : _pickDate,
                ),
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Preferred time *'),
                subtitle: Text(_time.format(context)),
                trailing: IconButton(icon: const Icon(Icons.access_time), onPressed: _pickTime),
              ),
              TextField(
                controller: _notes,
                decoration: InputDecoration(
                  labelText: _urgent ? 'Describe the urgent problem *' : 'Notes (optional)',
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 8),
              Text(
                _urgent
                    ? 'Same-day urgent request — clinic will review quickly.'
                    : 'Regular visits must be booked at least one day ahead.',
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: _busy ? null : _submit,
                child: Text(_busy ? 'Submitting...' : 'Submit request'),
              ),
            ] else
              FilledButton(
                onPressed: () => setState(() => _step = 0),
                child: const Text('Select a treatment'),
              ),
          ],
        ),
      ),
    );
  }
}
