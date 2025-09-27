import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../data/models/wallet_model.dart';
import '../../data/wallet_data.dart';
import '../../data/expense_data.dart';
import '../../data/income_data.dart';
import '../../data/models/expense_model.dart';
import '../../data/models/income_model.dart';
import '../../core/utils/wallet_utils.dart';
import '../widgets/app_bottom_nav.dart';
import '../widgets/wallet_card.dart';
import '../widgets/total_balance_card.dart';
import 'home_page.dart';
import 'statistics_page.dart';

class WalletPage extends StatefulWidget {
  const WalletPage({super.key});

  @override
  State<WalletPage> createState() => _WalletPageState();
}

class _WalletPageState extends State<WalletPage> {
  // Start with dummy; later this can be state-managed
  final List<Wallet> wallets = List.of(dummyWallets);
  final List<Expense> expenses = dummyExpenses;
  final List<Income> incomes = dummyIncomes;
  int _currentIndex = 2;

  @override
  Widget build(BuildContext context) {
  // Effective balances = initial balances +/- transactions tagged with walletId
  final balances = computeWalletBalances(wallets: wallets, incomes: incomes, expenses: expenses);
  final total = balances.values.fold<double>(0, (s, v) => s + v);
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        titleSpacing: 20,
        title: const Text(
          'Wallet',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
        ),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.primary,
        elevation: 0,
        centerTitle: false,
        actions: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.search)),
          IconButton(onPressed: () {}, icon: const Icon(Icons.more_vert)),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TotalBalanceCard(
                amount: total,
                titleLeft: 'Wallets',
                subLabel: 'Total Balance',
                trailingIcon: Icons.account_balance_wallet_rounded,
              ),
              const SizedBox(height: 16),
              _buildGrid(balances),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _onAddWallet,
        backgroundColor: AppColors.primary,
        elevation: 4,
        shape: const CircleBorder(),
        child: const Icon(Icons.add, color: Colors.white, size: 32),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: AppBottomNav(
        currentIndex: _currentIndex,
        onTap: (index) {
          if (index == 0) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (_) => const HomePage()),
            );
          } else if (index == 1) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (_) => const StatisticsPage()),
            );
          } else if (index == 2) {
            setState(() => _currentIndex = 2);
          }
        },
      ),
    );
  }  

  Widget _buildGrid(Map<String, double> balances) {
    final tiles = <Widget>[
      for (final w in wallets)
        WalletCard(
          wallet: w.copyWith(balance: balances[w.id] ?? w.balance),
          onTap: () {},
        ),
      _buildAddTile(),
    ];
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.6,
      ),
      itemCount: tiles.length,
      itemBuilder: (_, i) => tiles[i],
    );
  }

  Widget _buildAddTile() {
    return InkWell(
      onTap: _onAddWallet,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey[300],
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Center(
          child: Icon(Icons.add, size: 36, color: Colors.white),
        ),
      ),
    );
  }

  void _onAddWallet() {
    // Placeholder: add a dummy wallet quickly
    setState(() {
      wallets.add(Wallet(
        id: 'w${wallets.length + 1}',
        name: 'Wallet ${wallets.length + 1}',
        balance: 0,
        color: Colors.blueGrey,
        icon: Icons.account_balance_wallet_rounded,
      ));
    });
  }
}
