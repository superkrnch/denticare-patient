import 'package:flutter/material.dart';

import '../../core/theme.dart';
import '../../widgets/common.dart';

Future<void> showFeedbackSheet(BuildContext context) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (ctx) => const _FeedbackForm(),
  );
}

class _FeedbackForm extends StatefulWidget {
  const _FeedbackForm();

  @override
  State<_FeedbackForm> createState() => _FeedbackFormState();
}

class _FeedbackFormState extends State<_FeedbackForm> {
  int _rating = 0;
  final _commentController = TextEditingController();

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  static const _labels = [
    'Tap a star to rate',
    'Very dissatisfied',
    'Dissatisfied',
    'Okay',
    'Satisfied',
    'Very satisfied',
  ];

  void _submit() {
    Navigator.pop(context);
    showAppToast(context, 'Thank you! Your feedback helps us serve you better.');
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;
    return Padding(
      padding: EdgeInsets.fromLTRB(24, 20, 24, 24 + bottomInset),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Satisfaction survey',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 6),
          Text(
            'How happy are you with your DentiCare experience?',
            style: TextStyle(color: AppColors.subtle(context), fontSize: 13),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(5, (i) {
              final value = i + 1;
              final filled = value <= _rating;
              return IconButton(
                iconSize: 40,
                onPressed: () => setState(() => _rating = value),
                icon: Icon(
                  filled ? Icons.star_rounded : Icons.star_outline_rounded,
                  color: filled ? AppColors.warning : AppColors.subtle(context),
                ),
              );
            }),
          ),
          Center(
            child: Text(
              _labels[_rating],
              style: TextStyle(
                color: AppColors.subtle(context),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _commentController,
            maxLines: 4,
            textInputAction: TextInputAction.newline,
            decoration: const InputDecoration(
              hintText: 'Tell us what went well or what we can improve (optional)',
            ),
          ),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: _rating == 0 ? null : _submit,
            child: const Text('Submit feedback'),
          ),
        ],
      ),
    );
  }
}
