import 'package:flutter/material.dart';
import '../data/expense_data.dart';
import '../models/expense_model.dart';

class ExpenseListScreen extends StatelessWidget {
  const ExpenseListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Data sample sekarang diambil dari file terpusat
    final List<Expense> expenses = dummyExpenses;

    return Scaffold(
      appBar: AppBar(
        title: Text('Daftar Pengeluaran'),
        backgroundColor: Colors.blue,
      ),
      body: Column(
        children: [
          // Header dengan total pengeluaran
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              border: Border(
                bottom: BorderSide(color: Colors.blue.shade200),
              ),
            ),
            child: Column(
              children: [
                Text(
                  'Total Pengeluaran',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                ),
                Text(
                  _calculateTotal(expenses),
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
              ],
            ),
          ),
          // ListView untuk menampilkan daftar pengeluaran
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(8),
              itemCount: expenses.length,
              itemBuilder: (context, index) {
                final expense = expenses[index];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  elevation: 2,
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: expense.category.color,
                      child: Icon(expense.category.icon, color: Colors.white),
                    ),
                    title: Text(
                      expense.title,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(expense.formattedDate),
                    trailing: Text(
                      expense.formattedAmount,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.red,
                      ),
                    ),
                    onTap: () {
                      _showExpenseDetails(context, expense);
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Fitur tambah pengeluaran segera hadir!')),
          );
        },
        backgroundColor: Colors.blue,
        child: const Icon(Icons.add),
      ),
    );
  }

  // Method untuk menghitung total menggunakan fold()
  String _calculateTotal(List<Expense> expenses) {
    double total = expenses.fold(0, (sum, expense) => sum + expense.amount);
    return 'Rp ${total.toStringAsFixed(0)}';
  }

  // Method untuk menampilkan detail pengeluaran dalam dialog
  void _showExpenseDetails(BuildContext context, Expense expense) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(expense.title),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Jumlah: ${expense.formattedAmount}'),
            const SizedBox(height: 8),
            Text('Kategori: ${expense.category.name}'),
            const SizedBox(height: 8),
            Text('Tanggal: ${expense.formattedDate}'),
            const SizedBox(height: 8),
            Text('Deskripsi: ${expense.description}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tutup'),
          ),
        ],
      ),
    );
  }
}