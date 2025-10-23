import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../core/constants/app_colors.dart';

class MonthSelector extends StatelessWidget {
  final DateTime selectedMonth;
  final Function(int) onChangeMonth;

  const MonthSelector({
    super.key,
    required this.selectedMonth,
    required this.onChangeMonth,
  });

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final bool isCurrentMonth =
        selectedMonth.year == now.year && selectedMonth.month == now.month;
    String label = DateFormat('MMM yyyy', 'en_US').format(selectedMonth);
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
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
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left_rounded),
            color: AppColors.primary,
            onPressed: () => onChangeMonth(-1),
            tooltip: 'Previous month',
          ),
          Text(
            label,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.primary,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right_rounded),
            color: isCurrentMonth ? Colors.grey : AppColors.primary,
            onPressed: isCurrentMonth ? null : () => onChangeMonth(1),
            tooltip: 'Next month',
          ),
        ],
      ),
    );
  }
}