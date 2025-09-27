import '../../data/models/wallet_model.dart';
import '../../data/models/expense_model.dart';
import '../../data/models/income_model.dart';

/// Compute per-wallet balances using initial wallet balances + incomes - expenses filtered by walletId.
Map<String, double> computeWalletBalances({
  required List<Wallet> wallets,
  required List<Income> incomes,
  required List<Expense> expenses,
}) {
  final Map<String, double> map = {
    for (final w in wallets) w.id: w.balance,
  };
  for (final i in incomes) {
    if (i.walletId != null && map.containsKey(i.walletId)) {
      map[i.walletId!] = (map[i.walletId!] ?? 0) + i.amount;
    }
  }
  for (final e in expenses) {
    if (e.walletId != null && map.containsKey(e.walletId)) {
      map[e.walletId!] = (map[e.walletId!] ?? 0) - e.amount;
    }
  }
  return map;
}
