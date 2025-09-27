import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../core/constants/app_colors.dart';
import '../../core/utils/date_utils.dart';
import '../../core/utils/stats_utils.dart';
import '../../data/expense_data.dart';
import '../../data/income_data.dart';
import '../../data/models/expense_model.dart';
import '../../data/models/income_model.dart';
import '../widgets/app_bottom_nav.dart';
import '../widgets/transaction_widgets.dart';
import 'statistics_page.dart';
import '../../trial_screens/expense_list_screen.dart';
import '../../trial_screens/advance_expense_list_screen.dart';
import '../../trial_screens/looping_screen.dart';
import 'wallet_page.dart';
import 'profile_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;

  // Menggunakan data terpusat
  final List<Expense> expenses = dummyExpenses;
  final List<Income> incomes = dummyIncomes;

  double _incomeWeekOverWeekPercent() {
    return weekOverWeekPercent<Income>(incomes, (i) => i.date, (i) => i.amount);
  }

  double _expenseWeekOverWeekPercent() {
    return weekOverWeekPercent<Expense>(
      expenses,
      (e) => e.date,
      (e) => e.amount,
    );
  }

  List<Map<String, dynamic>> get transactions {
    final incomeTx = incomes.map(
      (i) => {
        'title': i.title,
        'date': DateFormat('EEE, dd MMM', 'en_US').format(i.date),
        'time': DateFormat('HH:mm').format(i.date),
        'amount': i.amount, // income positif
        'icon': i.category.icon,
        'color': i.category.color,
      },
    );
    final expenseTx = expenses.map(
      (e) => {
        'title': e.title,
        'date': DateFormat('EEE, dd MMM', 'en_US').format(e.date),
        'time': DateFormat('HH:mm').format(e.date),
        'amount': -e.amount, // expense negatif
        'icon': e.category.icon,
        'color': e.category.color,
      },
    );
    return [...incomeTx, ...expenseTx].toList();
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
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTotalBalanceCard(),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(child: _buildIncomeCard()),
                    const SizedBox(width: 16),
                    Expanded(child: _buildExpenseCard()),
                  ],
                ),
                const SizedBox(height: 30),
                _buildActivitySection(),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
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

  Widget _buildTotalBalanceCard() {
    final totalIncome = incomes.fold(0.0, (sum, item) => sum + item.amount);
    final totalExpense = expenses.fold(0.0, (sum, item) => sum + item.amount);
    final totalBalance = totalIncome - totalExpense;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primary, AppColors.primary.withOpacity(0.8)],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Hey, Jacob!',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Icon(
                Icons.notifications_outlined,
                color: Colors.white.withOpacity(0.8),
              ),
            ],
          ),
          const SizedBox(height: 12),
          FittedBox(
            alignment: Alignment.centerLeft,
            fit: BoxFit.scaleDown,
            child: Text(
              NumberFormat.currency(
                locale: 'id_ID',
                symbol: 'Rp ',
                decimalDigits: 0,
              ).format(totalBalance),
              maxLines: 1,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const Text(
            'Total Balance',
            style: TextStyle(color: Colors.white70, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildIncomeCard() {
    final totalIncome = incomes.fold(0.0, (sum, item) => sum + item.amount);
    final pct = _incomeWeekOverWeekPercent();
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF66D4CC),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Text(
                'Income',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Spacer(),
              Icon(Icons.trending_up, color: Colors.white, size: 20),
            ],
          ),
          const SizedBox(height: 8),
          FittedBox(
            alignment: Alignment.centerLeft,
            fit: BoxFit.scaleDown,
            child: Text(
              NumberFormat.currency(
                locale: 'id_ID',
                symbol: 'Rp ',
                decimalDigits: 0,
              ).format(totalIncome),
              maxLines: 1,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${pct.toStringAsFixed(0)}% then last week',
            style: const TextStyle(
              fontSize: 12,
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExpenseCard() {
    final totalExpense = expenses.fold(0.0, (sum, item) => sum + item.amount);
    final pct = _expenseWeekOverWeekPercent();
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF28080),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Text(
                'Expense',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Spacer(),
              Icon(Icons.trending_down, color: Colors.white, size: 20),
            ],
          ),
          const SizedBox(height: 8),
          FittedBox(
            alignment: Alignment.centerLeft,
            fit: BoxFit.scaleDown,
            child: Text(
              NumberFormat.currency(
                locale: 'id_ID',
                symbol: 'Rp ',
                decimalDigits: 0,
              ).format(totalExpense),
              maxLines: 1,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${pct.toStringAsFixed(0)}% then last week',
            style: const TextStyle(
              fontSize: 12,
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActivitySection() {
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
