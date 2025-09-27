import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../data/category_expenses_data.dart';
import '../data/expense_data.dart';
import '../data/models/category_model.dart';
import '../data/models/expense_model.dart';

class AdvancedExpenseListScreen extends StatefulWidget {
  const AdvancedExpenseListScreen({super.key});

  @override
  _AdvancedExpenseListScreenState createState() =>
      _AdvancedExpenseListScreenState();
}

class _AdvancedExpenseListScreenState extends State<AdvancedExpenseListScreen> {
  // Menggunakan data dari file terpusat
  final List<Category> categories = initialExpenseCategories;
  final List<Expense> expenses = dummyExpenses;

  List<Expense> filteredExpenses = [];
  Category? selectedCategory;
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Atur filter awal ke "Semua"
    selectedCategory = categories.firstWhere((cat) => cat.name == 'Semua');
    filteredExpenses = expenses;
    searchController.addListener(_filterExpenses);
  }

  @override
  void dispose() {
    searchController.removeListener(_filterExpenses);
    searchController.dispose();
    super.dispose();
  }

  void _showExpenseDetails(BuildContext context, Expense expense) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(expense.title,
                  style: const TextStyle(
                      fontSize: 22, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              Text(expense.formattedAmount,
                  style: TextStyle(fontSize: 18, color: Colors.red[600])),
              const SizedBox(height: 10),
              Row(
                children: [
                  Icon(expense.category.icon, color: expense.category.color, size: 16),
                  const SizedBox(width: 8),
                  Text('${expense.category.name} • ${expense.formattedDate}'),
                ],
              ),
              const SizedBox(height: 10),
              Text(expense.description),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Pengeluaran Advanced'),
        backgroundColor: Colors.blue,
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: searchController,
              decoration: InputDecoration(
                hintText: 'Cari pengeluaran...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),

          // Category filter
          Container(
            height: 50,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: categories.length,
              itemBuilder: (context, index) {
                final category = categories[index];
                final isSelected = selectedCategory?.name == category.name;
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedCategory = category;
                      _filterExpenses();
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    margin: const EdgeInsets.only(right: 8),
                    decoration: BoxDecoration(
                      color: isSelected ? category.color : Colors.grey[200],
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isSelected ? category.color : Colors.grey[300]!,
                        width: 1.5,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          category.icon,
                          size: 18,
                          color: isSelected ? Colors.white : Colors.black54,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          category.name,
                          style: TextStyle(
                            color: isSelected ? Colors.white : Colors.black87,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          // Statistics summary
          Container(
            padding: EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatCard('Total', _calculateTotal(filteredExpenses)),
                _buildStatCard('Jumlah', '${filteredExpenses.length} item'),
                _buildStatCard('Rata-rata', _calculateAverage(filteredExpenses)),
              ],
            ),
          ),
          
          // Expense list
          Expanded(
            child: filteredExpenses.isEmpty
                ? const Center(child: Text('Tidak ada pengeluaran ditemukan'))
                : ListView.builder(
                    padding: const EdgeInsets.all(8),
                    itemCount: filteredExpenses.length,
                    itemBuilder: (context, index) {
                      final expense = filteredExpenses[index];
                      return Card(
                        elevation: 2,
                        margin: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: expense.category.color,
                            child: Icon(expense.category.icon,
                                color: Colors.white),
                          ),
                          title: Text(expense.title,
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text(expense.formattedDate),
                          trailing: Text(expense.formattedAmount,
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.red)),
                          onTap: () => _showExpenseDetails(context, expense),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  void _filterExpenses() {
    setState(() {
      filteredExpenses = expenses.where((expense) {
        final searchLower = searchController.text.toLowerCase();
        bool matchesSearch = searchLower.isEmpty ||
            expense.title.toLowerCase().contains(searchLower) ||
            expense.description.toLowerCase().contains(searchLower);

        bool matchesCategory = selectedCategory?.name == 'Semua' ||
            expense.category.name == selectedCategory?.name;

        return matchesSearch && matchesCategory;
      }).toList();
    });
  }

  Widget _buildStatCard(String label, String value) {
    return Column(
      children: [
        Text(label, style: TextStyle(fontSize: 12, color: Colors.grey)),
        Text(value, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
      ],
    );
  }

  String _calculateTotal(List<Expense> expenses) {
    double total = expenses.fold(0.0, (sum, expense) => sum + expense.amount);
    return NumberFormat.compactCurrency(locale: 'id_ID', symbol: 'Rp ').format(total);
  }

  String _calculateAverage(List<Expense> expenses) {
    if (expenses.isEmpty) return 'Rp 0';
    double average = expenses.fold(0.0, (sum, expense) => sum + expense.amount) / expenses.length;
    return NumberFormat.compactCurrency(locale: 'id_ID', symbol: 'Rp ').format(average);
  }
}