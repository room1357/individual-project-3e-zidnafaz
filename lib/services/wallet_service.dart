import 'package:flutter/material.dart';
import '../data/models/wallet_model.dart';
import 'income_service.dart';
import 'expense_service.dart';
import 'transfer_service.dart';
import '../data/income_data.dart' as income_dummy;
import '../data/expense_data.dart' as expense_dummy;

class WalletService {
  static final List<Wallet> _wallets = [
    const Wallet(
      id: 'w1',
      name: 'Cash',
      balance: 0, // start from 0; will be adjusted via transactions
      color: Color(0xFF3DB2FF),
      icon: Icons.attach_money_rounded,
      type: WalletType.general,
      isExcluded: false,
      hasAdminFee: false,
      adminFee: 0.0,
      initialBalance: 0.0,
    ),
    const Wallet(
      id: 'w2',
      name: 'ShopeePay',
      balance: 0, // start from 0
      color: Color(0xFFFFB830),
      icon: Icons.account_balance_wallet_rounded,
      type: WalletType.eWallet,
      isExcluded: false,
      hasAdminFee: false,
      adminFee: 0.0,
      initialBalance: 0.0,
    ),
    const Wallet(
      id: 'w3',
      name: 'GoPay',
      balance: 0, // start from 0
      color: Color(0xFF3DB2FF),
      icon: Icons.account_balance_wallet_outlined,
      type: WalletType.eWallet,
      isExcluded: false,
      hasAdminFee: false,
      adminFee: 0.0,
      initialBalance: 0.0,
    ),
  ];

  // Get all wallets
  static List<Wallet> getAllWallets() => List.from(_wallets);

  // Get wallet by ID
  static Wallet? getWalletById(String id) {
    try {
      return _wallets.firstWhere((wallet) => wallet.id == id);
    } catch (e) {
      return null;
    }
  }

  // Update wallet balance
  static void updateWalletBalance(String walletId, double newBalance) {
    final index = _wallets.indexWhere((wallet) => wallet.id == walletId);
    if (index != -1) {
      _wallets[index] = _wallets[index].copyWith(balance: newBalance);
    }
  }

  // Add amount to wallet (for income)
  static void addToWallet(String walletId, double amount) {
    final wallet = getWalletById(walletId);
    if (wallet != null) {
      updateWalletBalance(walletId, wallet.balance + amount);
    }
  }

  // Subtract amount from wallet (for expense)
  static void subtractFromWallet(String walletId, double amount) {
    final wallet = getWalletById(walletId);
    if (wallet != null) {
      updateWalletBalance(walletId, wallet.balance - amount);
    }
  }

  // Transfer between wallets
  static bool transferBetweenWallets(String fromWalletId, String toWalletId, double amount, double fee) {
    final fromWallet = getWalletById(fromWalletId);
    final toWallet = getWalletById(toWalletId);
    
    if (fromWallet == null || toWallet == null) {
      return false; // Wallet not found
    }
    
    if (fromWallet.balance < (amount + fee)) {
      return false; // Insufficient balance
    }
    
    // Subtract from source wallet (amount + fee)
    subtractFromWallet(fromWalletId, amount + fee);
    
    // Add to destination wallet (only the transfer amount, not the fee)
    addToWallet(toWalletId, amount);
    
    return true;
  }

  // Get total balance across all wallets (excluding wallets with isExcluded = true)
  static double getTotalBalance() {
    return _wallets
        .where((wallet) => !wallet.isExcluded)
        .fold(0.0, (sum, wallet) => sum + wallet.balance);
  }

  // Recalculate all wallet balances from current services data (income/expense/transfers)
  // Starts from initialBalance, then applies net of transactions.
  static void recalculateAllFromServices() {
    // Initialize all to their initial balance
    final Map<String, double> totals = {for (final w in _wallets) w.id: w.initialBalance};
    // Pull from services; if empty (initial dummy mode), fall back to dummy data
    final serviceIncomes = IncomeService.getAllIncomes();
    final serviceExpenses = ExpenseService.getAllExpenses();
    final serviceTransfers = TransferService.getAllTransfers();

  final incomesSource = serviceIncomes.isNotEmpty ? serviceIncomes : income_dummy.dummyIncomes;
  final expensesSource = serviceExpenses.isNotEmpty ? serviceExpenses : expense_dummy.dummyExpenses;

    // Apply incomes
    for (final i in incomesSource) {
      final wid = i.walletId;
      if (wid != null && totals.containsKey(wid)) {
        totals[wid] = (totals[wid] ?? 0) + i.amount;
      }
    }

    // Apply expenses
    for (final e in expensesSource) {
      final wid = e.walletId;
      if (wid != null && totals.containsKey(wid)) {
        totals[wid] = (totals[wid] ?? 0) - e.amount;
      }
    }

    // Apply transfers
    for (final t in serviceTransfers) {
      // Outgoing
      final from = t.fromWalletId;
      if (from.isNotEmpty && totals.containsKey(from)) {
        totals[from] = (totals[from] ?? 0) - (t.amount + t.fee);
      }
      // Incoming
      final to = t.toWalletId;
      if (to.isNotEmpty && totals.containsKey(to)) {
        totals[to] = (totals[to] ?? 0) + t.amount;
      }
    }

    // Write back
    for (final w in _wallets) {
      updateWalletBalance(w.id, totals[w.id] ?? 0.0);
    }
  }

  // Check if wallet has sufficient balance
  static bool hasSufficientBalance(String walletId, double amount) {
    final wallet = getWalletById(walletId);
    return wallet != null && wallet.balance >= amount;
  }

  // Reset wallet balance
  static void resetWalletBalance(String walletId) {
    updateWalletBalance(walletId, 0.0);
  }

  // Add new wallet
  static void addWallet(Wallet wallet) {
    _wallets.add(wallet);
  }

  // Remove wallet
  static void removeWallet(String walletId) {
    _wallets.removeWhere((wallet) => wallet.id == walletId);
  }

  // Get wallet transaction history (you can expand this to get from transaction services)
  static Map<String, double> getWalletSummary(String walletId) {
    // This could be expanded to calculate from actual transactions
    final wallet = getWalletById(walletId);
    return {
      'currentBalance': wallet?.balance ?? 0.0,
      'totalIncome': 0.0, // Calculate from IncomeService
      'totalExpenses': 0.0, // Calculate from ExpenseService
      'totalTransfersIn': 0.0, // Calculate from TransferService
      'totalTransfersOut': 0.0, // Calculate from TransferService
    };
  }
}