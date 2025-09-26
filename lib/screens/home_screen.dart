import 'package:flutter/material.dart';
import '../models/expense_model.dart';
import '../data/expense_data.dart';
import '../models/income_model.dart';
import '../data/income_data.dart';
import '../trial_screens/expense_list_screen.dart';
import '../trial_screens/advance_expense_list_screen.dart';
import '../trial_screens/looping_screen.dart';
import 'package:intl/intl.dart';
import '../utils/date_utils.dart';
import '../utils/stats_utils.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  // Main app color
  final Color primaryColor = const Color(0xFF003E68);

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

  // Map data income + expenses -> struktur transaksi yang diharapkan UI activity lama
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
        foregroundColor: primaryColor,
        elevation: 0,
        centerTitle: false,
        actions: [
          IconButton(
            onPressed: () {
              // Handle search
            },
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
            itemBuilder:
                (BuildContext context) => <PopupMenuEntry<String>>[
                  const PopupMenuItem<String>(
                    value: 'expense_list',
                    child: Text('Expense List'),
                  ),
                  const PopupMenuItem<String>(
                    value: 'advanced_expense_list',
                    child: Text('Advanced Expense List'),
                  ),
                  const PopupMenuItem<String>(
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
                // Total Balance Section
                _buildTotalBalanceCard(),
                const SizedBox(height: 20),

                // Income and Expense Cards
                Row(
                  children: [
                    Expanded(child: _buildIncomeCard()),
                    const SizedBox(width: 16),
                    Expanded(child: _buildExpenseCard()),
                  ],
                ),
                const SizedBox(height: 30),

                // Activity Section
                _buildActivitySection(),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: primaryColor,
        elevation: 4,
        shape: const CircleBorder(),
        child: const Icon(Icons.add, color: Colors.white, size: 32),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: SizedBox(
        height: 60, // Enforce tinggi 40 dari parent
        child: BottomAppBar(
          elevation: 8,
          color: Colors.white, // Warna background navbar
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(Icons.home_rounded, 0),
              _buildNavItem(Icons.bar_chart_rounded, 1),
              const SizedBox(width: 64), // space for FAB
              _buildNavItem(Icons.account_balance_wallet_rounded, 2),
              _buildNavItem(Icons.person_rounded, 3),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTotalBalanceCard() {
    // Menghitung total pemasukan/pengeluaran dari data dummy
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
          colors: [primaryColor, primaryColor.withOpacity(0.8)],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: primaryColor.withOpacity(0.3),
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
            children: [
              const Text(
                'Income',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const Spacer(),
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
            children: [
              const Text(
                'Expense',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const Spacer(),
              const Icon(Icons.trending_down, color: Colors.white, size: 20),
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
    // Create a list of pairs (transaction, DateTime)
    final txWithDate =
        transactions
            .map((t) => {'data': t, 'dt': parseTransactionDateTime(t)})
            .toList();

    // Sort descending by time
    txWithDate.sort(
      (a, b) => (b['dt'] as DateTime).compareTo(a['dt'] as DateTime),
    );

    // Group by calendar day
    final Map<DateTime, List<Map<String, dynamic>>> groups = {};
    for (final item in txWithDate) {
      final dt = item['dt'] as DateTime;
      final key = DateTime(dt.year, dt.month, dt.day);
      groups.putIfAbsent(key, () => []);
      groups[key]!.add(item['data'] as Map<String, dynamic>);
    }

    // Sort group keys descending (latest date first)
    final dates = groups.keys.toList()..sort((a, b) => b.compareTo(a));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Recent Transactions',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: primaryColor,
          ),
        ),
        const SizedBox(height: 16),
        for (final date in dates) ...[
          _buildTransactionDayCard(date, groups[date]!),
          const SizedBox(height: 12),
        ],
      ],
    );
  }

  Widget _buildTransactionDayCard(
    DateTime date,
    List<Map<String, dynamic>> items,
  ) {
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
          // Header tanggal
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              sectionTitleForDate(date),
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: primaryColor,
              ),
            ),
          ),
          // Pemisah setelah header tanggal
          Divider(height: 1, thickness: 1, color: Colors.grey[200]),
          // Daftar transaksi dengan garis pemisah
          for (int i = 0; i < items.length; i++) ...[
            if (i > 0)
              Divider(height: 1, thickness: 1, color: Colors.grey[200]),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: _buildTransactionRow(items[i]),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTransactionRow(Map<String, dynamic> transaction) {
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
                transaction['title'] as String,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: primaryColor,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                transaction['time']?.toString() ?? '',
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

  Widget _buildNavItem(IconData icon, int index) {
    final isSelected = _currentIndex == index;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _currentIndex = index;
          });
        },
        child: Container(
          height: 40,
          alignment: Alignment.center, // Center icon di tengah
          child: Icon(
            icon,
            color: isSelected ? primaryColor : Colors.grey,
            size: 28, // Kecilkan icon sedikit
          ),
        ),
      ),
    );
  }
}
