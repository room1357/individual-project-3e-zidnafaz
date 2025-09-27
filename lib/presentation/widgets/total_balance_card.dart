import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../core/constants/app_colors.dart';

class TotalBalanceCard extends StatelessWidget {
  final double amount;
  final String titleLeft;
  final String subLabel;
  final IconData? trailingIcon;
  final bool compact;

  const TotalBalanceCard({
    super.key,
    required this.amount,
    this.titleLeft = 'Hey, Jacob!',
    this.subLabel = 'Total Balance',
    this.trailingIcon,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final EdgeInsets padding = compact ? const EdgeInsets.all(16) : const EdgeInsets.all(24);
    final double titleFontSize = compact ? 16 : 18;
    final double amountFontSize = compact ? 24 : 32;
    final double subLabelFontSize = compact ? 12 : 14;
    final BorderRadius radius = BorderRadius.circular(compact ? 16 : 20);
    final BoxShadow shadow = BoxShadow(
      color: AppColors.primary.withOpacity(0.3),
      blurRadius: compact ? 12 : 15,
      offset: Offset(0, compact ? 6 : 8),
    );

    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primary, AppColors.primary.withOpacity(0.8)],
        ),
        borderRadius: radius,
        boxShadow: [shadow],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                titleLeft,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: titleFontSize,
                  fontWeight: FontWeight.w500,
                ),
              ),
              if (trailingIcon != null)
                Icon(trailingIcon, color: Colors.white.withOpacity(0.8)),
            ],
          ),
          SizedBox(height: compact ? 8 : 12),
          FittedBox(
            alignment: Alignment.centerLeft,
            fit: BoxFit.scaleDown,
            child: Text(
              NumberFormat.currency(
                locale: 'id_ID',
                symbol: 'Rp ',
                decimalDigits: 0,
              ).format(amount),
              maxLines: 1,
              style: TextStyle(
                color: Colors.white,
                fontSize: amountFontSize,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Text(
            subLabel,
            style: TextStyle(color: Colors.white70, fontSize: subLabelFontSize),
          ),
        ],
      ),
    );
  }
}
