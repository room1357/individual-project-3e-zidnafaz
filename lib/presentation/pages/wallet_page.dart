import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../data/models/wallet_model.dart';
import '../../services/wallet_service.dart';
import '../../data/repositories/transaction_store.dart';

import '../widgets/app_bottom_nav.dart';
import '../widgets/wallet/total_balance_card.dart';
import '../widgets/wallet/wallet_grid.dart';
import 'home_page.dart';
import 'statistics_page.dart';
import 'wallet_detail_page.dart';
import 'profile_page.dart';
import 'add_expense_page.dart';

class WalletPage extends StatefulWidget {
  const WalletPage({super.key});

  @override
  State<WalletPage> createState() => _WalletPageState();
}

class _WalletPageState extends State<WalletPage> {
  final store = TransactionStore.instance;
  int _currentIndex = 2;

  @override
  Widget build(BuildContext context) {
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
        child: StreamBuilder<Object>(
          stream: store.expenses$,
          builder: (context, _) {
            return StreamBuilder<Object>(
              stream: store.incomes$,
              builder: (context, __) {
                return StreamBuilder<Object>(
                  stream: store.transfers$,
                  builder: (context, ___) {
                    // Recalculate from services so balances reflect income-expense-transfer net from zero
                    WalletService.recalculateAllFromServices();
                    final wallets = WalletService.getAllWallets();
                    final total = WalletService.getTotalBalance();
                    return SingleChildScrollView(
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
                          WalletGrid(
                            wallets: wallets,
                            balances: {for (var w in wallets) w.id: w.balance},
                            onWalletTap: (wallet) {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => WalletDetailPage(wallet: wallet),
                                ),
                              );
                            },
                            onAddWallet: _onAddWallet,
                          ),
                        ],
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
          } else if (index == 3) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (_) => const ProfilePage()),
            );
          }
        },
      ),
    );
  }  

  void _onAddWallet() {
    // Placeholder: add a dummy wallet quickly
    setState(() {
      final currentWallets = WalletService.getAllWallets();
      final newWallet = Wallet(
        id: 'w${currentWallets.length + 1}',
        name: 'Wallet ${currentWallets.length + 1}',
        balance: 0,
        color: Colors.blueGrey,
        icon: Icons.account_balance_wallet_rounded,
      );
      WalletService.addWallet(newWallet);
    });
  }
}
