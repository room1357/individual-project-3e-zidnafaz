import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../widgets/transaction_widgets.dart';
import '../../../core/utils/date_utils.dart';

class ActivitySection extends StatelessWidget {
  final List<Map<String, dynamic>> transactions;

  const ActivitySection({
    super.key,
    required this.transactions,
  });

  @override
  Widget build(BuildContext context) {
    final txWithDate =
        transactions.map((t) => {'data': t, 'dt': parseTransactionDateTime(t)}).toList();

    txWithDate.sort((a, b) => (b['dt'] as DateTime).compareTo(a['dt'] as DateTime));

    final Map<DateTime, List<Map<String, dynamic>>> groups = {};
    for (final item in txWithDate) {
      final dt = item['dt'] as DateTime;
      final key = DateTime(dt.year, dt.month, dt.day);
      groups.putIfAbsent(key, () => []);
      groups[key]!.add(item['data'] as Map<String, dynamic>);
    }

    final dates = groups.keys.toList()..sort((a, b) => b.compareTo(a));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Recent Transactions',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(height: 16),
        for (final date in dates) ...[
          TransactionDayCard(
            title: sectionTitleForDate(date),
            items: groups[date]!,
          ),
          const SizedBox(height: 12),
        ],
      ],
    );
  }
}