import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../core/constants/app_colors.dart';
import '../../data/category_expenses_data.dart';
import '../../data/category_income_data.dart';
// import '../../data/expense_data.dart';
// import '../../data/income_data.dart';
import '../../data/models/category_model.dart';
import '../../data/models/expense_model.dart';
import '../../data/models/income_model.dart';
import '../../data/models/transfer_model.dart';
import '../../data/repositories/transaction_store.dart';
import '../widgets/app_bottom_nav.dart';
import '../widgets/statistics/month_selector.dart';
import '../widgets/statistics/mode_dropdown.dart';
import '../widgets/statistics/donut_legend_card.dart';
import '../widgets/statistics/category_chips.dart';
import '../widgets/statistics/transaction_list.dart';
import '../widgets/statistics/chart_segment.dart';
import 'home_page.dart';
import 'wallet_page.dart';
import 'profile_page.dart';
import 'add_expense_page.dart';

class StatisticsPage extends StatefulWidget {
  const StatisticsPage({super.key});

  @override
  State<StatisticsPage> createState() => _StatisticsPageState();
}

class _StatisticsPageState extends State<StatisticsPage> {
  // Realtime store
  final store = TransactionStore.instance;
  final Color primaryColor = AppColors.primary;

  StatMode mode = StatMode.expense;
  Category? selectedCategory;
  final TextEditingController searchCtrl = TextEditingController();
  final GlobalKey _modeBtnKey = GlobalKey();
  DateTime _selectedMonth = DateTime(DateTime.now().year, DateTime.now().month);

  @override
  void initState() {
    super.initState();
    selectedCategory = _allCategories.firstWhere((c) => c.name == 'Semua');
    searchCtrl.addListener(() => setState(() {}));
    WidgetsBinding.instance.addPostFrameCallback((_) => store.bootstrap());
  }

  @override
  void dispose() {
    searchCtrl.dispose();
    super.dispose();
  }

  List<Category> get _expenseCategories => initialExpenseCategories;
  List<Category> get _incomeCategories => initialIncomeCategories;
  List<Category> get _allCategories =>
      mode == StatMode.expense ? _expenseCategories : _incomeCategories;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: primaryColor,
        elevation: 0,
        titleSpacing: 20,
        title: ModeDropdown(
          mode: mode,
          onModeChanged: (newMode) {
            setState(() {
              mode = newMode;
              selectedCategory = _allCategories.firstWhere(
                (c) => c.name == 'Semua',
              );
            });
          },
          modeBtnKey: _modeBtnKey,
        ),
        actions: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.search)),
          PopupMenuButton<String>(
            itemBuilder:
                (context) => const [
                  PopupMenuItem(value: 'filter', child: Text('Filter')),
                  PopupMenuItem(value: 'export', child: Text('Export')),
                ],
            icon: const Icon(Icons.more_vert),
          ),
        ],
      ),
      body: SafeArea(
        child: StreamBuilder<List<Expense>>(
          stream: store.expenses$,
          initialData: store.currentExpenses,
          builder: (context, expenseSnap) {
            final expenses = expenseSnap.data ?? const <Expense>[];
            return StreamBuilder<List<Income>>(
              stream: store.incomes$,
              initialData: store.currentIncomes,
              builder: (context, incomeSnap) {
                final incomes = incomeSnap.data ?? const <Income>[];
                return StreamBuilder<List<Transfer>>(
                  stream: store.transfers$,
                  initialData: store.currentTransfers,
                  builder: (context, transferSnap) {
                    final transfers = transferSnap.data ?? const <Transfer>[];

                    return SingleChildScrollView(
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            MonthSelector(
                              selectedMonth: _selectedMonth,
                              onChangeMonth: _changeMonth,
                            ),
                            const SizedBox(height: 12),
                            DonutLegendCard(
                              segments: _categorySegments(expenses, incomes),
                              mode: mode,
                            ),
                            const SizedBox(height: 16),
                            CategoryChips(
                              categories: _allCategories,
                              selectedCategory: selectedCategory,
                              onCategorySelected: (cat) => setState(() => selectedCategory = cat),
                            ),
                            const SizedBox(height: 16),
                            TransactionList(
                              transactions: _filteredTransactions(expenses, incomes, transfers),
                            ),
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
        currentIndex: 1,
        onTap: (index) {
          if (index == 0) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (_) => const HomePage()),
            );
          } else if (index == 2) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (_) => const WalletPage()),
            );
          } else if (index == 3) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (_) => const ProfilePage()),
            );
          }
        },
      ),
    );
  }

  void _changeMonth(int delta) {
    final y = _selectedMonth.year;
    final m = _selectedMonth.month + delta;
    final newDate = DateTime(y, m);
    setState(() => _selectedMonth = DateTime(newDate.year, newDate.month));
  }

  List<ChartSegment> _categorySegments(List<Expense> allExpenses, List<Income> allIncomes) {
    if (mode == StatMode.expense) {
      final filtered = _filteredExpenses(allExpenses);
      final Map<String, double> byCat = {};
      for (final e in filtered) {
        byCat[e.category.name] = (byCat[e.category.name] ?? 0) + e.amount;
      }
      return _expenseCategories
          .where((c) => c.name != 'Semua')
          .map(
            (c) => ChartSegment(
              label: c.name,
              value: byCat[c.name] ?? 0,
              color: c.color,
              icon: c.icon,
            ),
          )
          .where((s) => s.value > 0)
          .toList();
    } else {
      final filtered = _filteredIncomes(allIncomes);
      final Map<String, double> byCat = {};
      for (final i in filtered) {
        byCat[i.category.name] = (byCat[i.category.name] ?? 0) + i.amount;
      }
      return _incomeCategories
          .where((c) => c.name != 'Semua')
          .map(
            (c) => ChartSegment(
              label: c.name,
              value: byCat[c.name] ?? 0,
              color: c.color,
              icon: c.icon,
            ),
          )
          .where((s) => s.value > 0)
          .toList();
    }
  }

  List<Expense> _filteredExpenses(List<Expense> expenses, {bool ignoreWeekWindow = false}) {
    final sc = selectedCategory;
    return expenses.where((e) {
      final searchLower = searchCtrl.text.toLowerCase();
      final matchesSearch =
          searchLower.isEmpty ||
          e.title.toLowerCase().contains(searchLower) ||
          e.description.toLowerCase().contains(searchLower);
      final matchesCat =
          sc == null || sc.name == 'Semua' || e.category.name == sc.name;
      final matchesMonth =
          e.date.year == _selectedMonth.year &&
          e.date.month == _selectedMonth.month;
      return matchesSearch && matchesCat && matchesMonth;
    }).toList();
  }

  List<Income> _filteredIncomes(List<Income> incomes, {bool ignoreWeekWindow = false}) {
    final sc = selectedCategory;
    return incomes.where((i) {
      final searchLower = searchCtrl.text.toLowerCase();
      final matchesSearch =
          searchLower.isEmpty ||
          i.title.toLowerCase().contains(searchLower) ||
          i.description.toLowerCase().contains(searchLower);
      final matchesCat =
          sc == null || sc.name == 'Semua' || i.category.name == sc.name;
      final matchesMonth =
          i.date.year == _selectedMonth.year &&
          i.date.month == _selectedMonth.month;
      return matchesSearch && matchesCat && matchesMonth;
    }).toList();
  }

  List<Map<String, dynamic>> _filteredTransactions(
    List<Expense> expenses,
    List<Income> incomes,
    List<Transfer> transfers,
  ) {
    final List<Map<String, dynamic>> rows = [];
    final sc = selectedCategory;
    final searchLower = searchCtrl.text.toLowerCase();
    final bool includeTransfers = sc == null || sc.name == 'Semua';

    if (mode == StatMode.expense) {
      // Expenses
      rows.addAll(
        _filteredExpenses(expenses, ignoreWeekWindow: true).map(
          (e) => {
            'title': e.title,
            'date': DateFormat('EEE, dd MMM', 'en_US').format(e.date),
            'time': DateFormat('HH:mm').format(e.date),
            'amount': -e.amount,
            'icon': e.category.icon,
            'color': e.category.color,
            'walletId': e.walletId,
          },
        ),
      );

      // Outgoing transfers as expense-like
      if (includeTransfers) {
        final month = _selectedMonth.month;
        final year = _selectedMonth.year;
        rows.addAll(
          transfers.where((t) {
            final matchesMonth = t.date.year == year && t.date.month == month;
            final matchesSearch = searchLower.isEmpty ||
                t.description.toLowerCase().contains(searchLower) ||
                t.memo.toLowerCase().contains(searchLower);
            return matchesMonth && matchesSearch;
          }).map((t) => {
                'title': 'Transfer to',
                'date': DateFormat('EEE, dd MMM', 'en_US').format(t.date),
                'time': DateFormat('HH:mm').format(t.date),
                'amount': -t.amount,
                'icon': Icons.swap_horiz,
                'color': Colors.blueGrey,
                'walletId': t.fromWalletId,
              }),
        );
      }
    } else {
      // Incomes
      rows.addAll(
        _filteredIncomes(incomes, ignoreWeekWindow: true).map(
          (i) => {
            'title': i.title,
            'date': DateFormat('EEE, dd MMM', 'en_US').format(i.date),
            'time': DateFormat('HH:mm').format(i.date),
            'amount': i.amount,
            'icon': i.category.icon,
            'color': i.category.color,
            'walletId': i.walletId,
          },
        ),
      );

      // Incoming transfers as income-like
      if (includeTransfers) {
        final month = _selectedMonth.month;
        final year = _selectedMonth.year;
        rows.addAll(
          transfers.where((t) {
            final matchesMonth = t.date.year == year && t.date.month == month;
            final matchesSearch = searchLower.isEmpty ||
                t.description.toLowerCase().contains(searchLower) ||
                t.memo.toLowerCase().contains(searchLower);
            return matchesMonth && matchesSearch;
          }).map((t) => {
                'title': 'Transfer from',
                'date': DateFormat('EEE, dd MMM', 'en_US').format(t.date),
                'time': DateFormat('HH:mm').format(t.date),
                'amount': t.amount,
                'icon': Icons.swap_horiz,
                'color': Colors.blueGrey,
                'walletId': t.toWalletId,
              }),
        );
      }
    }

    return rows;
  }
}