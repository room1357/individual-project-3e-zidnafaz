import 'package:flutter/material.dart';
import 'package:pemrograman_mobile/utils/date_utils.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  // Main app color
  final Color primaryColor = const Color(0xFF003E68);

  // Sample transaction data
  final List<Map<String, dynamic>> transactions = [
    {
      'title': 'Grab to RSUD',
      'date': 'Sun, 03 Aug',
      'time': '06:24',
      'amount': -15.50,
      'icon': Icons.local_taxi,
      'color': Colors.purple,
    },
    {
      'title': 'Promag',
      'date': 'Sat, 02 Aug',
      'time': '18:30',
      'amount': -2.50,
      'icon': Icons.medical_services,
      'color': Colors.blue,
    },
    {
      'title': 'Okky Jelly Drink',
      'date': 'Sat, 02 Aug',
      'time': '12:42',
      'amount': -2.00,
      'icon': Icons.local_drink,
      'color': Colors.orange,
    },
    {
      'title': 'Energen',
      'date': 'Sat, 02 Aug',
      'time': '07:19',
      'amount': -1.50,
      'icon': Icons.local_drink,
      'color': Colors.orange,
    },
    {
      'title': 'Coffee Shop',
      'date': 'Fri, 01 Aug',
      'time': '17:05',
      'amount': -68.50,
      'icon': Icons.local_cafe,
      'color': Colors.orange,
    },
    {
      'title': 'Weekly Salary Pt. 2',
      'date': 'Fri, 01 Aug',
      'time': '16:00',
      'amount': 715.00,
      'icon': Icons.account_balance,
      'color': Colors.green,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        titleSpacing: 20,
        title: const Text(
          'Moneta',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        backgroundColor: Colors.white,
        foregroundColor: primaryColor,
        elevation: 0,
        centerTitle: false,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 20),
            child: IconButton(
              onPressed: () {
                // Handle search
              },
              icon: const Icon(Icons.search),
            ),
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
          const Text(
            '\$4,586.00',
            style: TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.bold,
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
          const Text(
            '\$2,450.00',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            '4% then last week',
            style: TextStyle(
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
              Icon(Icons.trending_down, color: Colors.white, size: 20),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            '-\$710.00',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            '7% then last week',
            style: TextStyle(
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
  final txWithDate = transactions
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

  Widget _buildTransactionRow(Map<String, dynamic> transaction) {
    final isIncome = (transaction['amount'] ?? 0) > 0;
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
          '${isIncome ? '+' : ''}${(transaction['amount'] as num).toStringAsFixed(2)}',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: isIncome ? Colors.green : Colors.red,
          ),
        ),
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