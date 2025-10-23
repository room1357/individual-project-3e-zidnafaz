import 'dart:async';
import 'dart:collection';

import '../../data/expense_data.dart';
import '../../data/income_data.dart';
import '../../data/models/expense_model.dart';
import '../../data/models/income_model.dart';
import '../../data/models/transfer_model.dart';
import 'transaction_repository.dart';

/// In-memory store that mimics a realtime repository using Streams.
/// Initialized from current dummy data and can be swapped to Firebase later.
class TransactionStore implements TransactionRepository {
  TransactionStore._internal() {
    _expenses = List<Expense>.from(dummyExpenses);
    _incomes = List<Income>.from(dummyIncomes);
  }

  static final TransactionStore instance = TransactionStore._internal();

  late List<Expense> _expenses;
  late List<Income> _incomes;
  List<Transfer> _transfers = const <Transfer>[];
  int _walletChangeCounter = 0; // Counter to trigger wallet updates

  final _expenseCtrl = StreamController<List<Expense>>.broadcast();
  final _incomeCtrl = StreamController<List<Income>>.broadcast();
  final _transferCtrl = StreamController<List<Transfer>>.broadcast();
  final _walletChangeCtrl = StreamController<int>.broadcast();

  // Streams
  @override
  Stream<List<Expense>> get expenses$ => _expenseCtrl.stream;
  @override
  Stream<List<Income>> get incomes$ => _incomeCtrl.stream;
  @override
  Stream<List<Transfer>> get transfers$ => _transferCtrl.stream;
  Stream<int> get walletChanges$ => _walletChangeCtrl.stream;

  // Current snapshots (for initialData/defaults)
  @override
  List<Expense> get currentExpenses => UnmodifiableListView(_expenses);
  @override
  List<Income> get currentIncomes => UnmodifiableListView(_incomes);
  @override
  List<Transfer> get currentTransfers => UnmodifiableListView(_transfers);

  // Aggregate helpers
  double get totalIncome => _incomes.fold(0.0, (s, i) => s + i.amount);
  double get totalExpense => _expenses.fold(0.0, (s, e) => s + e.amount);

  // Emits the current state to all listeners.
  @override
  void bootstrap() => _emitAll();

  // Mutations
  @override
  Future<void> addExpense(Expense expense) async {
    _expenses = [..._expenses, expense];
    _emitAll();
  }

  @override
  Future<void> addIncome(Income income) async {
    _incomes = [..._incomes, income];
    _emitAll();
  }

  @override
  Future<void> addTransfer(Transfer transfer) async {
    _transfers = [..._transfers, transfer];
    _emitAll();
  }

  @override
  Future<void> updateExpense(String id, Expense updated) async {
    final idx = _expenses.indexWhere((e) => e.id == id);
    if (idx != -1) {
      _expenses[idx] = updated;
      _emitAll();
    }
  }

  @override
  Future<void> updateIncome(String id, Income updated) async {
    final idx = _incomes.indexWhere((e) => e.id == id);
    if (idx != -1) {
      _incomes[idx] = updated;
      _emitAll();
    }
  }

  @override
  Future<void> updateTransfer(String id, Transfer updated) async {
    final idx = _transfers.indexWhere((t) => t.id == id);
    if (idx != -1) {
      _transfers[idx] = updated;
      _emitAll();
    }
  }

  @override
  Future<void> deleteExpense(String id) async {
    _expenses = _expenses.where((e) => e.id != id).toList(growable: false);
    _emitAll();
  }

  @override
  Future<void> deleteIncome(String id) async {
    _incomes = _incomes.where((e) => e.id != id).toList(growable: false);
    _emitAll();
  }

  @override
  Future<void> deleteTransfer(String id) async {
    _transfers = _transfers.where((t) => t.id != id).toList(growable: false);
    _emitAll();
  }

  void _emitAll() {
    _expenseCtrl.add(UnmodifiableListView(_expenses));
    _incomeCtrl.add(UnmodifiableListView(_incomes));
    _transferCtrl.add(UnmodifiableListView(_transfers));
  }

  // Method to notify wallet changes (when wallet is edited without transactions)
  void notifyWalletChange() {
    _walletChangeCounter++;
    _walletChangeCtrl.add(_walletChangeCounter);
  }

  @override
  void dispose() {
    _expenseCtrl.close();
    _incomeCtrl.close();
    _transferCtrl.close();
    _walletChangeCtrl.close();
  }
}
