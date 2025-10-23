import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../data/models/expense_model.dart';
import '../../data/models/category_model.dart';
import '../../data/models/wallet_model.dart';
import '../../services/expense_service.dart';
import '../../services/wallet_service.dart';
import '../../core/constants/app_colors.dart';
import '../../data/repositories/transaction_store.dart';
import 'add_income_page.dart';
import 'transfer_page.dart';
import 'manage_category_page.dart';

class AddExpensePage extends StatefulWidget {
  final Category? preselectedCategory;
  
  const AddExpensePage({
    super.key,
    this.preselectedCategory,
  });

  @override
  State<AddExpensePage> createState() => _AddExpensePageState();
}

class _AddExpensePageState extends State<AddExpensePage> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _memoController = TextEditingController();
  
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();
  Category? _selectedCategory;
  Wallet? _selectedWallet;
  
  @override
  void initState() {
    super.initState();
    // Set preselected category if provided
    if (widget.preselectedCategory != null) {
      _selectedCategory = widget.preselectedCategory;
    }
    // Set default wallet to first available wallet
    final wallets = WalletService.getAllWallets();
    if (wallets.isNotEmpty) {
      _selectedWallet = wallets.first;
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    _memoController.dispose();
    super.dispose();
  }

  void _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _selectTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  void _saveExpense() {
    if (_formKey.currentState!.validate()) {
      if (_selectedCategory == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select a category')),
        );
        return;
      }
      
      if (_selectedWallet == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select a wallet')),
        );
        return;
      }

      final expense = Expense(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: _descriptionController.text.isNotEmpty 
            ? _descriptionController.text 
            : _selectedCategory!.name,
        amount: double.parse(_amountController.text.replaceAll(',', '')),
        category: _selectedCategory!,
        date: DateTime(
          _selectedDate.year,
          _selectedDate.month,
          _selectedDate.day,
          _selectedTime.hour,
          _selectedTime.minute,
        ),
        description: _descriptionController.text,
        walletId: _selectedWallet!.id,
        memo: _memoController.text,
      );

      // Check if wallet has sufficient balance
      if (!WalletService.hasSufficientBalance(_selectedWallet!.id, expense.amount)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Insufficient wallet balance!'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

  // Save expense to service and realtime store
  ExpenseService.addExpense(expense);
  TransactionStore.instance.addExpense(expense);
      
      // Update wallet balance
      WalletService.subtractFromWallet(_selectedWallet!.id, expense.amount);
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Expense added successfully!'),
          backgroundColor: Colors.green,
        ),
      );
      
      Navigator.pop(context, expense);
    }
  }

  Widget _buildCard({required Widget child}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
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
      child: child,
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: TextStyle(
          color: AppColors.primary,
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: AppColors.primary,
        elevation: 0,
        titleSpacing: 20,
        title: const Text(
          'Add Expense',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
        ),
        actions: [
          TextButton(
            onPressed: _saveExpense,
            child: Text(
              'SAVE',
              style: TextStyle(
                color: AppColors.primary,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Transaction Type Tabs
                _buildCard(
                  child: Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(builder: (context) => const AddIncomePage()),
                            );
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              color: Colors.grey[100],
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              'Income',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text(
                            'Expense',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(builder: (context) => const TransferPage()),
                            );
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              color: Colors.grey[100],
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              'Transfer',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Main Form Card
                _buildCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Date & Time Section
                      _buildSectionTitle('Date & Time'),
                      Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: _selectDate,
                              child: Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.grey[50],
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: Colors.grey[300]!),
                                ),
                                child: Row(
                                  children: [
                                    Icon(Icons.calendar_today, 
                                         color: AppColors.primary, size: 20),
                                    const SizedBox(width: 8),
                                    Text(
                                      DateFormat('dd/MM/yyyy').format(_selectedDate),
                                      style: const TextStyle(fontSize: 16),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: GestureDetector(
                              onTap: _selectTime,
                              child: Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.grey[50],
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: Colors.grey[300]!),
                                ),
                                child: Row(
                                  children: [
                                    Icon(Icons.access_time, 
                                         color: AppColors.primary, size: 20),
                                    const SizedBox(width: 8),
                                    Text(
                                      '${_selectedTime.hour.toString().padLeft(2, '0')}:${_selectedTime.minute.toString().padLeft(2, '0')}',
                                      style: const TextStyle(fontSize: 16),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 24),
                      
                      // Amount Section
                      _buildSectionTitle('Amount'),
                      TextFormField(
                        controller: _amountController,
                        keyboardType: TextInputType.number,
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                        decoration: InputDecoration(
                          hintText: 'Rp 0',
                          hintStyle: TextStyle(color: Colors.grey[400]),
                          prefixIcon: Icon(Icons.payments, color: AppColors.primary),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: Colors.grey[300]!),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: AppColors.primary),
                          ),
                          filled: true,
                          fillColor: Colors.grey[50],
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter amount';
                          }
                          if (double.tryParse(value.replaceAll(',', '')) == null) {
                            return 'Please enter valid amount';
                          }
                          return null;
                        },
                      ),
                      
                      const SizedBox(height: 24),
                      
                      // Description Section
                      _buildSectionTitle('Description'),
                      TextFormField(
                        controller: _descriptionController,
                        decoration: InputDecoration(
                          hintText: 'Enter description...',
                          hintStyle: TextStyle(color: Colors.grey[400]),
                          prefixIcon: Icon(Icons.description, color: AppColors.primary),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: Colors.grey[300]!),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: AppColors.primary),
                          ),
                          filled: true,
                          fillColor: Colors.grey[50],
                        ),
                      ),
                      
                      const SizedBox(height: 24),
                      
                      // Category Section
                      _buildSectionTitle('Category'),
                      InkWell(
                        onTap: () async {
                          final result = await Navigator.push<Map<String, dynamic>>(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const ManageCategoryPage(
                                initialTab: 'expense',
                              ),
                            ),
                          );
                          if (result != null) {
                            final category = result['category'] as Category;
                            final isIncome = result['isIncome'] as bool;
                            
                            // If user selected income category while on expense page, switch to income page
                            if (isIncome) {
                              // Navigate to income page with selected category
                              if (mounted) {
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => AddIncomePage(
                                      preselectedCategory: category,
                                    ),
                                  ),
                                );
                              }
                            } else {
                              setState(() {
                                _selectedCategory = category;
                              });
                            }
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                          decoration: BoxDecoration(
                            color: Colors.grey[50],
                            border: Border.all(color: Colors.grey[300]!),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.category, color: AppColors.primary),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _selectedCategory == null
                                    ? Text(
                                        'Select Category',
                                        style: TextStyle(color: Colors.grey[400]),
                                      )
                                    : Row(
                                        children: [
                                          Icon(
                                            _selectedCategory!.icon,
                                            color: _selectedCategory!.color,
                                            size: 20,
                                          ),
                                          const SizedBox(width: 12),
                                          Text(
                                            _selectedCategory!.name,
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ],
                                      ),
                              ),
                              Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey[600]),
                            ],
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 24),
                      
                      // Wallet Section
                      _buildSectionTitle('Wallet'),
                      DropdownButtonFormField<Wallet>(
                        // value: _selectedWallet,
                        decoration: InputDecoration(
                          prefixIcon: Icon(Icons.account_balance_wallet, color: AppColors.primary),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: Colors.grey[300]!),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: AppColors.primary),
                          ),
                          filled: true,
                          fillColor: Colors.grey[50],
                        ),
                        items: WalletService.getAllWallets().map((wallet) => DropdownMenuItem(
                              value: wallet,
                              child: Row(
                                children: [
                                  Icon(wallet.icon, color: wallet.color, size: 20),
                                  const SizedBox(width: 12),
                                  Text('${wallet.name} • ${wallet.formattedBalance}'),
                                ],
                              ),
                            )).toList(),
                        onChanged: (Wallet? value) {
                          setState(() {
                            _selectedWallet = value;
                          });
                        },
                      ),
                      
                      const SizedBox(height: 24),
                      
                      // Memo Section
                      _buildSectionTitle('Memo'),
                      TextFormField(
                        controller: _memoController,
                        maxLines: 3,
                        decoration: InputDecoration(
                          hintText: 'Add a note...',
                          hintStyle: TextStyle(color: Colors.grey[400]),
                          prefixIcon: Padding(
                            padding: const EdgeInsets.only(bottom: 50),
                            child: Icon(Icons.note, color: AppColors.primary),
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: Colors.grey[300]!),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: AppColors.primary),
                          ),
                          filled: true,
                          fillColor: Colors.grey[50],
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}