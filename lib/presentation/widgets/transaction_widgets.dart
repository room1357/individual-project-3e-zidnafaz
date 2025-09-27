import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../core/constants/app_colors.dart';

class TransactionRow extends StatelessWidget {
  final Map<String, dynamic> transaction;

  const TransactionRow({super.key, required this.transaction});

  @override
  Widget build(BuildContext context) {
    final num amount = (transaction['amount'] ?? 0) as num;
    final bool isIncome = amount > 0;
    final String sign = amount > 0 ? '+' : (amount < 0 ? '-' : '');
    final String formattedAmount = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp. ',
      decimalDigits: 0,
    ).format(amount.abs());

    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: (transaction['color'] as Color).withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            transaction['icon'] as IconData,
            color: transaction['color'] as Color,
            size: 20,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                (transaction['title'] ?? '') as String,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                // Allow either 'time' alone or combined 'date • time'
                transaction.containsKey('date')
                    ? '${transaction['date']}  •  ${transaction['time'] ?? ''}'
                    : (transaction['time']?.toString() ?? ''),
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
            ],
          ),
        ),
        Text(
          '$sign$formattedAmount',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: isIncome ? Colors.green : Colors.red,
          ),
        ),
      ],
    );
  }
}

class TransactionDayCard extends StatelessWidget {
  final String title;
  final List<Map<String, dynamic>> items;

  const TransactionDayCard({super.key, required this.title, required this.items});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
              ),
            ),
          ),
          Divider(height: 1, thickness: 1, color: Colors.grey[200]),
          for (int i = 0; i < items.length; i++) ...[
            if (i > 0) Divider(height: 1, thickness: 1, color: Colors.grey[200]),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: TransactionRow(transaction: items[i]),
            ),
          ],
        ],
      ),
    );
  }
}
