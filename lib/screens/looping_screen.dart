import 'package:flutter/material.dart';
import '../models/expense_model.dart';

class LoopingScreen extends StatelessWidget {
  const LoopingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Initialize expenses here for demonstration
    LoopingExamples.expenses = [
      Expense(id: '1', title: 'Belanja Bulanan', amount: 150000, category: 'Makanan', date: DateTime(2024, 9, 15), description: 'Belanja kebutuhan bulanan di supermarket'),
      Expense(id: '2', title: 'Bensin Motor', amount: 50000, category: 'Transportasi', date: DateTime(2024, 9, 14), description: 'Isi bensin motor untuk transportasi'),
      Expense(id: '3', title: 'Kopi di Cafe', amount: 25000, category: 'Makanan', date: DateTime(2024, 9, 14), description: 'Ngopi pagi dengan teman'),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Looping Examples'),
        backgroundColor: Colors.deepPurple,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle('1. Calculate Total'),
            _buildResultCard(
              'Traditional For Loop',
              'Rp ${LoopingExamples.calculateTotalTraditional(LoopingExamples.expenses).toStringAsFixed(0)}',
            ),
            _buildResultCard(
              'For-in Loop',
              'Rp ${LoopingExamples.calculateTotalForIn(LoopingExamples.expenses).toStringAsFixed(0)}',
            ),
            _buildResultCard(
              'forEach Method',
              'Rp ${LoopingExamples.calculateTotalForEach(LoopingExamples.expenses).toStringAsFixed(0)}',
            ),
            _buildResultCard(
              'fold Method',
              'Rp ${LoopingExamples.calculateTotalFold(LoopingExamples.expenses).toStringAsFixed(0)}',
            ),
            _buildResultCard(
              'reduce Method',
              'Rp ${LoopingExamples.calculateTotalReduce(LoopingExamples.expenses).toStringAsFixed(0)}',
            ),
            const SizedBox(height: 24),
            _buildSectionTitle('2. Find Expense with ID "2"'),
            _buildResultCard(
              'Traditional Find',
              LoopingExamples.findExpenseTraditional(LoopingExamples.expenses, '2')?.title ?? 'Not Found',
            ),
            _buildResultCard(
              'firstWhere Method',
              LoopingExamples.findExpenseWhere(LoopingExamples.expenses, '2')?.title ?? 'Not Found',
            ),
            const SizedBox(height: 24),
            _buildSectionTitle('3. Filter by Category "Makanan"'),
            _buildResultCard(
              'Manual Filter',
              'Found ${LoopingExamples.filterByCategoryManual(LoopingExamples.expenses, 'Makanan').length} items',
            ),
            _buildResultCard(
              'where Method',
              'Found ${LoopingExamples.filterByCategoryWhere(LoopingExamples.expenses, 'Makanan').length} items',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Text(
        title,
        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.deepPurple),
      ),
    );
  }

  Widget _buildResultCard(String title, String result) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
        trailing: Text(
          result,
          style: const TextStyle(fontSize: 16, color: Colors.black87, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}

class LoopingExamples {
  static List<Expense> expenses = [/* data */];

  // 1. Menghitung total dengan berbagai cara
  
  // Cara 1: For loop tradisional
  static double calculateTotalTraditional(List<Expense> expenses) {
    double total = 0;
    for (int i = 0; i < expenses.length; i++) {
      total += expenses[i].amount;
    }
    return total;
  }

  // Cara 2: For-in loop
  static double calculateTotalForIn(List<Expense> expenses) {
    double total = 0;
    for (Expense expense in expenses) {
      total += expense.amount;
    }
    return total;
  }

  // Cara 3: forEach method
  static double calculateTotalForEach(List<Expense> expenses) {
    double total = 0;
    expenses.forEach((expense) {
      total += expense.amount;
    });
    return total;
  }

  // Cara 4: fold method (paling efisien)
  static double calculateTotalFold(List<Expense> expenses) {
    return expenses.fold(0, (sum, expense) => sum + expense.amount);
  }

  // Cara 5: reduce method
  static double calculateTotalReduce(List<Expense> expenses) {
    if (expenses.isEmpty) return 0;
    return expenses.map((e) => e.amount).reduce((a, b) => a + b);
  }

  // 2. Mencari item dengan berbagai cara
  
  // Cara 1: For loop dengan break
  static Expense? findExpenseTraditional(List<Expense> expenses, String id) {
    for (int i = 0; i < expenses.length; i++) {
      if (expenses[i].id == id) {
        return expenses[i];
      }
    }
    return null;
  }

  // Cara 2: firstWhere method
  static Expense? findExpenseWhere(List<Expense> expenses, String id) {
    try {
      return expenses.firstWhere((expense) => expense.id == id);
    } catch (e) {
      return null;
    }
  }

  // 3. Filtering dengan berbagai cara
  
  // Cara 1: Loop manual dengan List.add()
  static List<Expense> filterByCategoryManual(List<Expense> expenses, String category) {
    List<Expense> result = [];
    for (Expense expense in expenses) {
      if (expense.category.toLowerCase() == category.toLowerCase()) {
        result.add(expense);
      }
    }
    return result;
  }

  // Cara 2: where method (lebih efisien)
  static List<Expense> filterByCategoryWhere(List<Expense> expenses, String category) {
    return expenses.where((expense) => 
      expense.category.toLowerCase() == category.toLowerCase()
    ).toList();
  }
}