import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../widgets/transaction_widgets.dart';
import '../../../core/utils/date_utils.dart' as du;

class TransactionList extends StatelessWidget {
  final List<Map<String, dynamic>> transactions;

  const TransactionList({
    super.key,
    required this.transactions,
  });

  @override
  Widget build(BuildContext context) {
    if (transactions.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Center(
          child: Text(
            'Tidak ada transaksi',
            style: TextStyle(color: Colors.grey[600]),
          ),
        ),
      );
    }

    // Sort by datetime DESC and group by day like HomePage
    final txWithDate =
        transactions
            .map((t) => {'data': t, 'dt': du.parseTransactionDateTime(t)})
            .toList();
    txWithDate.sort(
      (a, b) => (b['dt'] as DateTime).compareTo(a['dt'] as DateTime),
    );

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
          'Transactions',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(height: 12),
        for (final date in dates) ...[
          TransactionDayCard(
            title: du.sectionTitleForDate(date),
            items: groups[date]!,
          ),
          const SizedBox(height: 12),
        ],
      ],
    );
  }
}