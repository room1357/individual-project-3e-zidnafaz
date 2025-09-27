import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../core/constants/app_colors.dart';
import '../../core/utils/date_utils.dart';
import '../../data/expense_data.dart';
import '../../data/income_data.dart';
import '../../data/models/expense_model.dart';
import '../../data/models/income_model.dart';
import '../../data/models/wallet_model.dart';
import '../widgets/transaction_widgets.dart';
import '../widgets/total_balance_card.dart';

class WalletDetailPage extends StatelessWidget {
  final Wallet wallet;
  const WalletDetailPage({super.key, required this.wallet});

  List<Income> _walletIncomes() => dummyIncomes.where((i) => i.walletId == wallet.id).toList();
  List<Expense> _walletExpenses() => dummyExpenses.where((e) => e.walletId == wallet.id).toList();

  @override
  Widget build(BuildContext context) {
    final incomes = _walletIncomes();
    final expenses = _walletExpenses();
    // Filter for current month to match 'This month' label
    final now = DateTime.now();
    final incomesThisMonth = incomes.where((i) => i.date.year == now.year && i.date.month == now.month).toList();
    final expensesThisMonth = expenses.where((e) => e.date.year == now.year && e.date.month == now.month).toList();
    final totalIncome = incomesThisMonth.fold<double>(0, (s, i) => s + i.amount);
    final totalExpense = expensesThisMonth.fold<double>(0, (s, e) => s + e.amount);

    // wallet.balance is already the effective balance on the card if passed from WalletPage.
    final effectiveBalance = wallet.balance;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        titleSpacing: 20,
        title: Text(wallet.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.primary,
        elevation: 0,
        centerTitle: false,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TotalBalanceCard(
                amount: effectiveBalance,
                titleLeft: wallet.name,
                subLabel: 'Current Balance',
                trailingIcon: wallet.icon,
                compact: true,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(child: _buildStatCard('Income', totalIncome, const Color(0xFF66D4CC), Icons.trending_up)),
                  const SizedBox(width: 12),
                  Expanded(child: _buildStatCard('Expense', totalExpense, const Color(0xFFF28080), Icons.trending_down)),
                ],
              ),
              const SizedBox(height: 16),
              _buildTransactionSection(incomes, expenses),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(String label, double amount, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                label,
                style: const TextStyle(fontSize: 14, color: Colors.white, fontWeight: FontWeight.w600),
              ),
              const Spacer(),
              Icon(icon, color: Colors.white, size: 20),
            ],
          ),
          const SizedBox(height: 8),
          FittedBox(
            alignment: Alignment.centerLeft,
            fit: BoxFit.scaleDown,
            child: Text(
              NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0).format(amount),
              maxLines: 1,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
            ),
          ),
          const SizedBox(height: 2),
          const Text('This month', style: TextStyle(fontSize: 12, color: Colors.white)),
        ],
      ),
    );
  }

  Widget _buildTransactionSection(List<Income> incomes, List<Expense> expenses) {
    final incomeTx = incomes.map(
      (i) => {
        'title': i.title,
        'date': DateFormat('EEE, dd MMM', 'en_US').format(i.date),
        'time': DateFormat('HH:mm').format(i.date),
        'amount': i.amount, // positive
        'icon': i.category.icon,
        'color': i.category.color,
      },
    );
    final expenseTx = expenses.map(
      (e) => {
        'title': e.title,
        'date': DateFormat('EEE, dd MMM', 'en_US').format(e.date),
        'time': DateFormat('HH:mm').format(e.date),
        'amount': -e.amount, // negative
        'icon': e.category.icon,
        'color': e.category.color,
      },
    );

    final txWithDate = [...incomeTx, ...expenseTx]
        .map((t) => {'data': t, 'dt': parseTransactionDateTime(t)})
        .toList();

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
          'Transactions',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.primary),
        ),
        const SizedBox(height: 12),
        if (dates.isEmpty)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 2)),
              ],
            ),
            child: const Center(
              child: Text('No transactions for this wallet', style: TextStyle(color: Colors.black54)),
            ),
          )
        else
          ...[
            for (final date in dates) ...[
              TransactionDayCard(title: sectionTitleForDate(date), items: groups[date]!),
              const SizedBox(height: 12),
            ]
          ],
      ],
    );
  }
}
