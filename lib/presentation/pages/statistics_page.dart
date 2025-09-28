import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../core/constants/app_colors.dart';
import '../../core/utils/date_utils.dart' as du;
import '../../data/category_expenses_data.dart';
import '../../data/category_income_data.dart';
import '../../data/expense_data.dart';
import '../../data/income_data.dart';
import '../../data/models/category_model.dart';
import '../../data/models/expense_model.dart';
import '../../data/models/income_model.dart';
import '../widgets/app_bottom_nav.dart';
import '../widgets/transaction_widgets.dart';
import 'home_page.dart';
import 'wallet_page.dart';
import 'profile_page.dart';

class StatisticsPage extends StatefulWidget {
  const StatisticsPage({super.key});

  @override
  State<StatisticsPage> createState() => _StatisticsPageState();
}

enum StatMode { expense, income }

class _StatisticsPageState extends State<StatisticsPage> {
  final List<Expense> expenses = dummyExpenses;
  final List<Income> incomes = dummyIncomes;
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

  String get _modeLabel => mode == StatMode.expense ? 'Expense' : 'Income';
  IconData get _modeIcon =>
      mode == StatMode.expense ? Icons.trending_down : Icons.trending_up;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: primaryColor,
        elevation: 0,
        titleSpacing: 20,
        title: _buildModeDropdown(),
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
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildMonthSelector(),
                const SizedBox(height: 12),
                _buildDonutAndLegendCard(),
                const SizedBox(height: 16),
                _buildCategoryChips(),
                const SizedBox(height: 16),
                _buildTransactionList(),
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

  Widget _buildMonthSelector() {
    final now = DateTime.now();
    final bool isCurrentMonth =
        _selectedMonth.year == now.year && _selectedMonth.month == now.month;
    String label = DateFormat('MMM yyyy', 'en_US').format(_selectedMonth);
    // Capitalize properly (already), keep style consistent
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
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
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left_rounded),
            color: primaryColor,
            onPressed: () => _changeMonth(-1),
            tooltip: 'Previous month',
          ),
          Text(
            label,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.primary,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right_rounded),
            color: isCurrentMonth ? Colors.grey : primaryColor,
            onPressed: isCurrentMonth ? null : () => _changeMonth(1),
            tooltip: 'Next month',
          ),
        ],
      ),
    );
  }

  void _changeMonth(int delta) {
    final y = _selectedMonth.year;
    final m = _selectedMonth.month + delta;
    final newDate = DateTime(y, m);
    setState(() => _selectedMonth = DateTime(newDate.year, newDate.month));
  }

  Widget _buildModeDropdown() {
    return GestureDetector(
      key: _modeBtnKey,
      onTap: () async {
        final button =
            _modeBtnKey.currentContext!.findRenderObject() as RenderBox;
        final overlay =
            Overlay.of(context).context.findRenderObject() as RenderBox;
        final offset = button.localToGlobal(Offset.zero, ancestor: overlay);
        final size = button.size;
        final position = RelativeRect.fromLTRB(
          offset.dx,
          offset.dy + size.height,
          overlay.size.width - (offset.dx + size.width),
          overlay.size.height - (offset.dy + size.height),
        );

        final opposite =
            mode == StatMode.expense ? StatMode.income : StatMode.expense;
        final newMode = await showMenu<StatMode>(
          context: context,
          position: position,
          elevation: 12,
          color: Colors.white,
          shadowColor: Colors.black.withOpacity(0.15),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          constraints: BoxConstraints(
            minWidth: size.width,
            maxWidth: size.width,
          ),
          items: [
            if (opposite == StatMode.expense)
              PopupMenuItem(
                value: StatMode.expense,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Row(
                    children: [
                      const Icon(Icons.trending_down, color: Colors.red),
                      const SizedBox(width: 10),
                      Text(
                        'Expense',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: primaryColor,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
              PopupMenuItem(
                value: StatMode.income,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Row(
                    children: [
                      const Icon(Icons.trending_up, color: Colors.green),
                      const SizedBox(width: 10),
                      Text(
                        'Income',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: primaryColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        );
        if (newMode != null && newMode != mode) {
          setState(() {
            mode = newMode;
            selectedCategory = _allCategories.firstWhere(
              (c) => c.name == 'Semua',
            );
          });
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: primaryColor,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              _modeIcon,
              color:
                  mode == StatMode.expense
                      ? Colors.red[200]
                      : Colors.green[200],
              size: 18,
            ),
            const SizedBox(width: 8),
            Text(
              _modeLabel,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 16,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 4),
            const Icon(Icons.keyboard_arrow_down_rounded, color: Colors.white),
          ],
        ),
      ),
    );
  }

  Widget _buildDonutAndLegendCard() {
    final segments = _categorySegments();
    final total = segments.fold<double>(0, (s, e) => s + e.value);
    final top = [...segments]..sort((a, b) => b.value.compareTo(a.value));
    final top3 = top.take(3).toList();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: AspectRatio(
              aspectRatio: 1,
              child: CustomPaint(
                painter: _DonutPainter(segments: segments),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        NumberFormat.compactCurrency(
                          locale: 'id_ID',
                          symbol: 'Rp ',
                        ).format(total),
                        style: TextStyle(
                          color: primaryColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        _modeLabel,
                        style: TextStyle(color: Colors.grey[600], fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (final s in top3)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: s.color.withOpacity(0.10),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: s.color.withOpacity(0.7),
                              width: 1,
                            ),
                          ),
                          child: Text(
                            '${total == 0 ? 0 : (s.value / total * 100).round()}%',
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 12,
                              color: s.color,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            s.label,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: primaryColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryChips() {
    final cats = List<Category>.from(_allCategories);
    final idxAll = cats.indexWhere((c) => c.name.toLowerCase() == 'semua');
    if (idxAll > 0) {
      final allCat = cats.removeAt(idxAll);
      cats.insert(0, allCat);
    }
    return SizedBox(
      height: 44,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemBuilder: (context, i) {
          final cat = cats[i];
          final isSel = selectedCategory?.name == cat.name;
          final isAll = cat.name.toLowerCase() == 'semua';
          final Color bgColor =
              isSel ? (isAll ? primaryColor : cat.color) : (Colors.grey[100]!);
          final Color borderColor =
              isSel ? (isAll ? primaryColor : cat.color) : (Colors.grey[300]!);
          final Color iconColor = isSel ? Colors.white : Colors.black54;
          final Color textColor = isSel ? Colors.white : Colors.black87;
          return GestureDetector(
            onTap: () => setState(() => selectedCategory = cat),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: borderColor, width: 1.5),
              ),
              child: Row(
                children: [
                  Icon(cat.icon, size: 18, color: iconColor),
                  const SizedBox(width: 8),
                  Text(
                    cat.name,
                    style: TextStyle(
                      color: textColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemCount: cats.length,
      ),
    );
  }

  // Bar chart card removed as requested.

  Widget _buildTransactionList() {
    final tx = _filteredTransactions();
    if (tx.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
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
        child: Center(
          child: Text(
            'Tidak ada transaksi',
            style: TextStyle(color: Colors.grey[600]),
          ),
        ),
      );
    }

    // Sort by datetime DESC and group by day like HomePage
    final txWithDate =
        tx
            .map((t) => {'data': t, 'dt': du.parseTransactionDateTime(t)})
            .toList();
    txWithDate.sort(
      (a, b) => (b['dt'] as DateTime).compareTo(a['dt'] as DateTime),
    );

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
        Text(
          'Transactions',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: primaryColor,
          ),
        ),
        const SizedBox(height: 12),
        for (final date in dates) ...[
          TransactionDayCard(
            title: du.sectionTitleForDate(date),
            items: groups[date]!,
          ),
          const SizedBox(height: 12),
        ],
      ],
    );
  }

  List<_ChartSegment> _categorySegments() {
    if (mode == StatMode.expense) {
      final filtered = _filteredExpenses();
      final Map<String, double> byCat = {};
      for (final e in filtered) {
        byCat[e.category.name] = (byCat[e.category.name] ?? 0) + e.amount;
      }
      return _expenseCategories
          .where((c) => c.name != 'Semua')
          .map(
            (c) => _ChartSegment(
              label: c.name,
              value: byCat[c.name] ?? 0,
              color: c.color,
              icon: c.icon,
            ),
          )
          .where((s) => s.value > 0)
          .toList();
    } else {
      final filtered = _filteredIncomes();
      final Map<String, double> byCat = {};
      for (final i in filtered) {
        byCat[i.category.name] = (byCat[i.category.name] ?? 0) + i.amount;
      }
      return _incomeCategories
          .where((c) => c.name != 'Semua')
          .map(
            (c) => _ChartSegment(
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

  // Weekly bucket helpers removed.

  // Week-over-week percentage removed.

  List<Expense> _filteredExpenses({bool ignoreWeekWindow = false}) {
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

  List<Income> _filteredIncomes({bool ignoreWeekWindow = false}) {
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

  List<Map<String, dynamic>> _filteredTransactions() {
    if (mode == StatMode.expense) {
      return _filteredExpenses(ignoreWeekWindow: true)
          .map(
            (e) => {
              'title': e.title,
              'date': DateFormat('EEE, dd MMM', 'en_US').format(e.date),
              'time': DateFormat('HH:mm').format(e.date),
              'amount': -e.amount,
              'icon': e.category.icon,
              'color': e.category.color,
              'walletId': e.walletId,
            },
          )
          .toList();
    } else {
      return _filteredIncomes(ignoreWeekWindow: true)
          .map(
            (i) => {
              'title': i.title,
              'date': DateFormat('EEE, dd MMM', 'en_US').format(i.date),
              'time': DateFormat('HH:mm').format(i.date),
              'amount': i.amount,
              'icon': i.category.icon,
              'color': i.category.color,
              'walletId': i.walletId,
            },
          )
          .toList();
    }
  }

  // Week range label removed.
}

class _ChartSegment {
  final String label;
  final double value;
  final Color color;
  final IconData icon;
  _ChartSegment({
    required this.label,
    required this.value,
    required this.color,
    required this.icon,
  });
}

// Weekly bucket model removed.

class _DonutPainter extends CustomPainter {
  final List<_ChartSegment> segments;
  _DonutPainter({required this.segments});

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final center = rect.center;
    final radius = size.shortestSide / 2;

    final total = segments.fold<double>(0, (s, e) => s + e.value);
    double start = -90 * 3.1415926535 / 180; // start from top
    final stroke = radius * 0.32;
    final paint =
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = stroke
          ..strokeCap = StrokeCap.butt;

    if (total == 0) {
      paint.color = Colors.grey[200]!;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius * 0.8),
        0,
        6.283,
        false,
        paint,
      );
    } else {
      for (final s in segments) {
        final sweep = (s.value / total) * 6.28318530718;
        paint.color = s.color.withOpacity(0.9);
        canvas.drawArc(
          Rect.fromCircle(center: center, radius: radius * 0.8),
          start,
          sweep,
          false,
          paint,
        );
        start += sweep;
      }
    }

    final innerPaint = Paint()..color = Colors.white;
    canvas.drawCircle(center, radius * 0.55, innerPaint);
  }

  @override
  bool shouldRepaint(covariant _DonutPainter oldDelegate) {
    return oldDelegate.segments != segments;
  }
}
