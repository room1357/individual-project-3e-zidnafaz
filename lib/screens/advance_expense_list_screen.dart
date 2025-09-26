import 'package:flutter/material.dart';
import '../models/category_model.dart';
import '../models/expense_model.dart';
import 'package:intl/intl.dart';

class AdvancedExpenseListScreen extends StatefulWidget {
  @override
  _AdvancedExpenseListScreenState createState() =>
      _AdvancedExpenseListScreenState();
}

class _AdvancedExpenseListScreenState extends State<AdvancedExpenseListScreen> {
  final List<Category> categories = [
    Category(name: 'Semua', icon: Icons.all_inclusive, color: Colors.grey),
    Category(name: 'Makanan', icon: Icons.fastfood, color: Colors.orange),
    Category(name: 'Transportasi', icon: Icons.directions_car, color: Colors.blue),
    Category(name: 'Utilitas', icon: Icons.power, color: Colors.green),
    Category(name: 'Hiburan', icon: Icons.movie, color: Colors.purple),
    Category(name: 'Pendidikan', icon: Icons.school, color: Colors.teal),
  ];

  List<Expense> expenses = [
    Expense(id: '1', title: 'Nasi Goreng', amount: 25000, category: 'Makanan', date: DateTime.now(), description: 'Makan malam'),
    Expense(id: '2', title: 'Tiket Bioskop', amount: 50000, category: 'Hiburan', date: DateTime.now().subtract(Duration(days: 1)), description: 'Nonton film baru'),
    Expense(id: '3', title: 'Bensin', amount: 100000, category: 'Transportasi', date: DateTime.now().subtract(Duration(days: 2)), description: 'Isi bensin motor'),
    Expense(id: '4', title: 'Bayar Listrik', amount: 200000, category: 'Utilitas', date: DateTime.now().subtract(Duration(days: 3)), description: 'Tagihan bulan ini'),
    Expense(id: '5', title: 'Buku Flutter', amount: 150000, category: 'Pendidikan', date: DateTime.now().subtract(Duration(days: 4)), description: 'Beli buku di Gramedia'),
  ];
  
  List<Expense> filteredExpenses = [];
  String selectedCategory = 'Semua';
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    filteredExpenses = expenses;
  }

  Color _getCategoryColor(String categoryName) {
    return categories.firstWhere((cat) => cat.name == categoryName, orElse: () => categories.first).color;
  }

  IconData _getCategoryIcon(String categoryName) {
    return categories.firstWhere((cat) => cat.name == categoryName, orElse: () => categories.first).icon;
  }

  void _showExpenseDetails(BuildContext context, Expense expense) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          padding: EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(expense.title, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              SizedBox(height: 10),
              Text(expense.formattedAmount, style: TextStyle(fontSize: 18, color: Colors.red[600])),
              SizedBox(height: 10),
              Text('${expense.category} • ${expense.formattedDate}'),
              SizedBox(height: 10),
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
            padding: EdgeInsets.all(16),
            child: TextField(
              controller: searchController,
              decoration: InputDecoration(
                hintText: 'Cari pengeluaran...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onChanged: (value) {
                _filterExpenses();
              },
            ),
          ),
          
          // Category filter
          Container(
            height: 50,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(horizontal: 16),
              itemCount: categories.length,
              itemBuilder: (context, index) {
                final category = categories[index];
                return Padding(
                  padding: EdgeInsets.only(right: 8),
                  child: FilterChip(
                    avatar: Icon(category.icon, color: selectedCategory == category.name ? Colors.white : category.color),
                    label: Text(category.name),
                    selected: selectedCategory == category.name,
                    onSelected: (selected) {
                      setState(() {
                        selectedCategory = category.name;
                        _filterExpenses();
                      });
                    },
                    selectedColor: _getCategoryColor(category.name),
                    labelStyle: TextStyle(color: selectedCategory == category.name ? Colors.white : Colors.black),
                    backgroundColor: Colors.grey[200],
                    checkmarkColor: Colors.white,
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
              ? Center(child: Text('Tidak ada pengeluaran ditemukan'))
              : ListView.builder(
                  itemCount: filteredExpenses.length,
                  itemBuilder: (context, index) {
                    final expense = filteredExpenses[index];
                    return Card(
                      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: _getCategoryColor(expense.category),
                          child: Icon(_getCategoryIcon(expense.category), color: Colors.white),
                        ),
                        title: Text(expense.title),
                        subtitle: Text('${expense.category} • ${expense.formattedDate}'),
                        trailing: Text(
                          expense.formattedAmount,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.red[600],
                          ),
                        ),
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
        bool matchesSearch = searchController.text.isEmpty || 
          expense.title.toLowerCase().contains(searchController.text.toLowerCase()) ||
          expense.description.toLowerCase().contains(searchController.text.toLowerCase());
        
        bool matchesCategory = selectedCategory == 'Semua' || 
          expense.category == selectedCategory;
        
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