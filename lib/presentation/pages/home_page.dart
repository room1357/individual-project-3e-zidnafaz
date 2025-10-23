import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../core/constants/app_colors.dart';
// import '../../data/expense_data.dart';
// import '../../data/income_data.dart';
import '../../data/models/expense_model.dart';
import '../../data/models/income_model.dart';
import '../../data/models/transfer_model.dart';
import '../../data/repositories/transaction_store.dart';
import '../../services/wallet_service.dart';
import '../widgets/app_bottom_nav.dart';
import '../widgets/home/total_balance_home_card.dart';
import '../widgets/reusable/stat_card.dart';
import '../widgets/home/activity_section.dart';
import 'statistics_page.dart';
import '../../trial_screens/expense_list_screen.dart';
import '../../trial_screens/advance_expense_list_screen.dart';
import '../../trial_screens/looping_screen.dart';
import 'wallet_page.dart';
import 'profile_page.dart';
import 'add_expense_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;

  // Realtime store
  final store = TransactionStore.instance;

  List<Map<String, dynamic>> _buildTransactions({
    required List<Income> incomes,
    required List<Expense> expenses,
    required List<Transfer> transfers,
  }) {
    final incomeTx = incomes.map(
      (i) => {
        'title': i.title,
        'date': DateFormat('EEE, dd MMM', 'en_US').format(i.date),
        'time': DateFormat('HH:mm').format(i.date),
        'amount': i.amount,
        'icon': i.category.icon,
        'color': i.category.color,
        'walletId': i.walletId,
      },
    );
    final expenseTx = expenses.map(
      (e) => {
        'title': e.title,
        'date': DateFormat('EEE, dd MMM', 'en_US').format(e.date),
        'time': DateFormat('HH:mm').format(e.date),
        'amount': -e.amount,
        'icon': e.category.icon,
        'color': e.category.color,
        'walletId': e.walletId,
      },
    );

    // Transfer as a single entry: walletName formatted as "[from] -> [to]"
    final transferTx = transfers.map((t) {
      final dateStr = DateFormat('EEE, dd MMM', 'en_US').format(t.date);
      final timeStr = DateFormat('HH:mm').format(t.date);
      final from = WalletService.getWalletById(t.fromWalletId)?.name ?? t.fromWalletId;
      final to = WalletService.getWalletById(t.toWalletId)?.name ?? t.toWalletId;
      return {
        'type': 'transfer',
        'title': t.description,
        'date': dateStr,
        'time': timeStr,
        'amount': t.amount,
        'icon': Icons.swap_horiz,
        'color': Colors.blueGrey,
        'walletName': '$from -> $to',
        'fromWalletId': t.fromWalletId,
        'toWalletId': t.toWalletId,
      };
    });

    return [...incomeTx, ...expenseTx, ...transferTx].toList();
  }

  @override
  void initState() {
    super.initState();
    // Ensure initial emission after first frame so StreamBuilders get data
    WidgetsBinding.instance.addPostFrameCallback((_) => store.bootstrap());
  }

  @override
  Widget build(BuildContext context) {
  return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        titleSpacing: 20,
        title: const Text(
          'Moneta',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
        ),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.primary,
        elevation: 0,
        centerTitle: false,
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.search),
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              switch (value) {
                case 'expense_list':
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ExpenseListScreen(),
                    ),
                  );
                  break;
                case 'advanced_expense_list':
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AdvancedExpenseListScreen(),
                    ),
                  );
                  break;
                case 'looping_examples':
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const LoopingScreen(),
                    ),
                  );
                  break;
              }
            },
            itemBuilder: (BuildContext context) => const <PopupMenuEntry<String>>[
              PopupMenuItem<String>(
                value: 'expense_list',
                child: Text('Expense List'),
              ),
              PopupMenuItem<String>(
                value: 'advanced_expense_list',
                child: Text('Advanced Expense List'),
              ),
              PopupMenuItem<String>(
                value: 'looping_examples',
                child: Text('Looping Examples'),
              ),
            ],
            icon: const Icon(Icons.more_vert),
          ),
        ],
      ),
      body: SafeArea(
        child: StreamBuilder<List<Transfer>>(
          stream: store.transfers$,
          initialData: store.currentTransfers,
          builder: (context, transferSnap) {
            final transfers = transferSnap.data ?? const <Transfer>[];
            return StreamBuilder<List<Expense>>(
              stream: store.expenses$,
              initialData: store.currentExpenses,
              builder: (context, expenseSnap) {
                final expenses = expenseSnap.data ?? const <Expense>[];
                return StreamBuilder<List<Income>>(
                  stream: store.incomes$,
                  initialData: store.currentIncomes,
                  builder: (context, incomeSnap) {
                    final incomes = incomeSnap.data ?? const <Income>[];
                    // This month totals (like wallet_detail_page but for all wallets)
                    final now = DateTime.now();
                    final incomesThisMonth = incomes.where((i) => i.date.year == now.year && i.date.month == now.month);
                    final expensesThisMonth = expenses.where((e) => e.date.year == now.year && e.date.month == now.month);
                    final totalIncome = incomesThisMonth.fold<double>(0, (s, i) => s + i.amount);
                    final totalExpense = expensesThisMonth.fold<double>(0, (s, e) => s + e.amount);
                    WalletService.recalculateAllFromServices();
                    final totalBalance = WalletService.getTotalBalance();
                    final transactions = _buildTransactions(
                      incomes: incomes,
                      expenses: expenses,
                      transfers: transfers,
                    );

                    return SingleChildScrollView(
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            TotalBalanceHomeCard(totalBalance: totalBalance),
                            const SizedBox(height: 20),
                            Row(
                              children: [
                                Expanded(child: StatCard(label: 'Income', amount: totalIncome, color: const Color(0xFF66D4CC), icon: Icons.trending_up)),
                                const SizedBox(width: 16),
                                Expanded(child: StatCard(label: 'Expense', amount: totalExpense, color: const Color(0xFFF28080), icon: Icons.trending_down)),
                              ],
                            ),
                            const SizedBox(height: 30),
                            ActivitySection(transactions: transactions),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AddExpensePage(),
            ),
          );
        },
        backgroundColor: AppColors.primary,
        elevation: 4,
        shape: const CircleBorder(),
        child: const Icon(Icons.add, color: Colors.white, size: 32),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: AppBottomNav(
        currentIndex: _currentIndex,
        onTap: (index) {
          if (index == 1) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (_) => const StatisticsPage()),
            );
          } else if (index == 2) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (_) => const WalletPage()),
            );
          } else if (index == 3) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (_) => const ProfilePage()),
            );
          } else {
            setState(() => _currentIndex = index);
          }
        },
      ),
    );
  }
}