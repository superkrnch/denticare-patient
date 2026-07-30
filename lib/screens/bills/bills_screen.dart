import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/formatters.dart';
import '../../core/theme.dart';
import '../../providers/app_provider.dart';
import '../../widgets/app_icons.dart';
import '../../widgets/common.dart';
import '../../widgets/status_badge.dart';

class BillsScreen extends StatelessWidget {
  const BillsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final bills = context.watch<AppProvider>().data.billings;

    if (bills.isEmpty) {
      return ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          Card(child: EmptyState(icon: AppIcons.bills, message: 'No invoices yet')),
        ],
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      itemCount: bills.length,
      itemBuilder: (context, index) {
        final b = bills[index];
        final balance = b.balance;
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(b.invoiceNumber, style: const TextStyle(fontWeight: FontWeight.w700)),
                          Text(formatDate(b.date), style: const TextStyle(color: AppColors.muted)),
                        ],
                      ),
                    ),
                    StatusBadge(b.paymentStatus),
                  ],
                ),
                const SizedBox(height: 12),
                _row('Total', formatMoney(b.totalAmount)),
                _row('Paid', formatMoney(b.paidAmount)),
                _row(
                  'Balance',
                  formatMoney(balance),
                  valueColor: balance > 0 ? AppColors.danger : AppColors.success,
                ),
                if (b.treatments.isNotEmpty) ...[
                  const SectionTitle('Items'),
                  ...b.treatments.map((t) => _row(t.procedureName, formatMoney(t.cost))),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _row(String key, String value, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(child: Text(key, style: const TextStyle(color: AppColors.muted))),
          Text(value, style: TextStyle(fontWeight: FontWeight.w600, color: valueColor)),
        ],
      ),
    );
  }
}
