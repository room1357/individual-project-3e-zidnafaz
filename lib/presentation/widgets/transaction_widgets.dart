import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../core/constants/app_colors.dart';
import '../../services/wallet_service.dart';

class TransactionRow extends StatelessWidget {
  final Map<String, dynamic> transaction;

  const TransactionRow({super.key, required this.transaction});

  @override
  Widget build(BuildContext context) {
    final String? type = transaction['type'] as String?;
    final num amount = (transaction['amount'] ?? 0) as num;
    final bool isIncome = amount > 0;
    final bool isTransfer = type == 'transfer';
    final String sign = isTransfer ? '' : (amount > 0 ? '+' : (amount < 0 ? '-' : ''));
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
            color: (transaction['color'] as Color).withOpacity(isTransfer ? 0.06 : 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            transaction['icon'] as IconData,
            color: isTransfer ? Colors.blueGrey : transaction['color'] as Color,
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
                _walletLabel(transaction),
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
            ],
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '$sign$formattedAmount',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: isTransfer
                    ? Colors.blueGrey
                    : (isIncome ? Colors.green : Colors.red),
              ),
            ),
            const SizedBox(height: 2),
            if ((transaction['time'] as String?)?.isNotEmpty == true)
              Text(
                transaction['time'] as String,
                style: TextStyle(fontSize: 11, color: Colors.grey[600]),
              ),
          ],
        ),
      ],
    );
  }

  String _walletLabel(Map<String, dynamic> tx) {
    String? walletName;
    // Prefer explicit walletName when provided
    final String? explicit = tx['walletName'] as String?;
    if (explicit != null && explicit.trim().isNotEmpty) {
      walletName = explicit.trim();
    } else {
      // Fallback: use walletId to resolve name from WalletService
      final String? wid = tx['walletId'] as String?;
      if (wid != null) {
        final wallet = WalletService.getWalletById(wid);
        if (wallet != null) walletName = wallet.name;
      }
    }

    return walletName ?? '';
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
