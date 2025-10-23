import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../core/constants/app_colors.dart';
import '../../core/utils/date_utils.dart';
// import '../../data/expense_data.dart';
// import '../../data/income_data.dart';
import '../../data/models/expense_model.dart';
import '../../data/models/income_model.dart';
import '../../data/models/wallet_model.dart';
import '../../data/models/transfer_model.dart';
import '../../data/repositories/transaction_store.dart';
import '../../services/wallet_service.dart';
import '../widgets/transaction_widgets.dart';
import '../widgets/wallet/total_balance_card.dart';
import '../widgets/reusable/stat_card.dart';
import 'edit_wallet_page.dart';

class WalletDetailPage extends StatefulWidget {
  final Wallet wallet;
  const WalletDetailPage({super.key, required this.wallet});

  @override
  State<WalletDetailPage> createState() => _WalletDetailPageState();
}

class _WalletDetailPageState extends State<WalletDetailPage> {
  late Wallet _currentWallet;

  @override
  void initState() {
    super.initState();
    _currentWallet = widget.wallet;
  }

  void _editWallet() async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => EditWalletPage(wallet: _currentWallet),
      ),
    );

    if (result == true && mounted) {
      // Refresh wallet data
      final updatedWallet = WalletService.getWalletById(_currentWallet.id);
      if (updatedWallet != null) {
        setState(() {
          _currentWallet = updatedWallet;
        });
      }
    }
  }

  List<Income> _walletIncomes(List<Income> incomes) => incomes.where((i) => i.walletId == _currentWallet.id).toList();
  List<Expense> _walletExpenses(List<Expense> expenses) => expenses.where((e) => e.walletId == _currentWallet.id).toList();
  List<Transfer> _walletTransfers(List<Transfer> transfers) => transfers
      .where((t) => t.fromWalletId == _currentWallet.id || t.toWalletId == _currentWallet.id)
      .toList();

  @override
  Widget build(BuildContext context) {
    final store = TransactionStore.instance;
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        titleSpacing: 20,
        title: Text(_currentWallet.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.primary,
        elevation: 0,
        centerTitle: false,
        actions: [
          IconButton(
            onPressed: _editWallet,
            icon: const Icon(Icons.edit),
            tooltip: 'Edit Wallet',
          ),
        ],
      ),
      body: SafeArea(
        child: StreamBuilder<List<Transfer>>(
          stream: store.transfers$,
          initialData: store.currentTransfers,
          builder: (context, transferSnap) {
            final transfers = _walletTransfers(transferSnap.data ?? const <Transfer>[]);
            return StreamBuilder<List<Expense>>(
              stream: store.expenses$,
              initialData: store.currentExpenses,
              builder: (context, expenseSnap) {
                final expenses = _walletExpenses(expenseSnap.data ?? const <Expense>[]);
                return StreamBuilder<List<Income>>(
                  stream: store.incomes$,
                  initialData: store.currentIncomes,
                  builder: (context, incomeSnap) {
                    final incomes = _walletIncomes(incomeSnap.data ?? const <Income>[]);
                    return StreamBuilder<int>(
                      stream: store.walletChanges$,
                      builder: (context, walletSnap) {
                        // Stats for this month
                        final now = DateTime.now();
                        final incomesThisMonth = incomes.where((i) => i.date.year == now.year && i.date.month == now.month).toList();
                        final expensesThisMonth = expenses.where((e) => e.date.year == now.year && e.date.month == now.month).toList();
                        final totalIncome = incomesThisMonth.fold<double>(0, (s, i) => s + i.amount);
                        final totalExpense = expensesThisMonth.fold<double>(0, (s, e) => s + e.amount);

                        // Recalculate to ensure balances reflect net transactions
                        WalletService.recalculateAllFromServices();
                        // Get updated wallet data from service
                        final updatedWallet = WalletService.getWalletById(widget.wallet.id);
                        final effectiveBalance = updatedWallet?.balance ?? _currentWallet.balance;

                    return SingleChildScrollView(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TotalBalanceCard(
                            amount: effectiveBalance,
                            titleLeft: _currentWallet.name,
                            subLabel: 'Current Balance',
                            trailingIcon: _currentWallet.icon,
                            compact: true,
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(child: StatCard(label: 'Income', amount: totalIncome, color: const Color(0xFF66D4CC), icon: Icons.trending_up)),
                              const SizedBox(width: 12),
                              Expanded(child: StatCard(label: 'Expense', amount: totalExpense, color: const Color(0xFFF28080), icon: Icons.trending_down)),
                            ],
                          ),
                          const SizedBox(height: 16),
                          _buildTransactionSection(incomes, expenses, transfers),
                        ],
                      ),
                    );
                      },
                    );
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }

  // Stat card is now a reusable widget (StatCard)

  Widget _buildTransactionSection(List<Income> incomes, List<Expense> expenses, List<Transfer> transfers) {
    final incomeTx = incomes.map(
      (i) => {
        'title': i.title,
        'date': DateFormat('EEE, dd MMM', 'en_US').format(i.date),
        'time': DateFormat('HH:mm').format(i.date),
        'amount': i.amount, // positive
        'icon': i.category.icon,
        'color': i.category.color,
        'walletId': i.walletId,
        'walletName': _currentWallet.name,
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
        'walletId': e.walletId,
        'walletName': _currentWallet.name,
      },
    );

    // Split transfers: for this wallet, show outgoing (-amount) and incoming (+amount)
    final transferTx = transfers.expand((t) {
      final dateStr = DateFormat('EEE, dd MMM', 'en_US').format(t.date);
      final timeStr = DateFormat('HH:mm').format(t.date);
      final List<Map<String, dynamic>> rows = [];
      if (t.fromWalletId == _currentWallet.id) {
        rows.add({
          'title': 'Transfer to',
          'date': dateStr,
          'time': timeStr,
          'amount': -t.amount,
          'icon': Icons.swap_horiz,
          'color': Colors.blueGrey,
          'walletId': t.fromWalletId,
          'walletName': _currentWallet.name,
        });
      }
      if (t.toWalletId == _currentWallet.id) {
        rows.add({
          'title': 'Transfer from',
          'date': dateStr,
          'time': timeStr,
          'amount': t.amount,
          'icon': Icons.swap_horiz,
          'color': Colors.blueGrey,
          'walletId': t.toWalletId,
          'walletName': _currentWallet.name,
        });
      }
      return rows;
    });

    final txWithDate = [...incomeTx, ...expenseTx, ...transferTx]
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
