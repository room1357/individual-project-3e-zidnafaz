import 'dart:async';

import '../models/expense_model.dart';
import '../models/income_model.dart';
import '../models/transfer_model.dart';

/// Abstraction of a transaction repository that can be backed by
/// in-memory store, Firestore, SQLite, etc.
///
/// UI should depend on this interface, not on a concrete implementation.
abstract class TransactionRepository {
  // Realtime streams
  Stream<List<Expense>> get expenses$;
  Stream<List<Income>> get incomes$;
  Stream<List<Transfer>> get transfers$;

  // Current snapshots (for initialData)
  List<Expense> get currentExpenses;
  List<Income> get currentIncomes;
  List<Transfer> get currentTransfers;

  // Optional initialization hook
  void bootstrap();

  // Expense CRUD
  Future<void> addExpense(Expense expense);
  Future<void> updateExpense(String id, Expense updated);
  Future<void> deleteExpense(String id);

  // Income CRUD
  Future<void> addIncome(Income income);
  Future<void> updateIncome(String id, Income updated);
  Future<void> deleteIncome(String id);

  // Transfer CRUD
  Future<void> addTransfer(Transfer transfer);
  Future<void> updateTransfer(String id, Transfer updated);
  Future<void> deleteTransfer(String id);

  // Optional: lifecycle
  void dispose();
}
