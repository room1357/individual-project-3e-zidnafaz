import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../data/models/transfer_model.dart';
import '../../data/models/wallet_model.dart';
import '../../services/transfer_service.dart';
import '../../services/wallet_service.dart';
import '../../core/constants/app_colors.dart';
import '../../data/repositories/transaction_store.dart';
import '../../data/models/expense_model.dart';
import '../../data/models/category_model.dart';
import '../../data/category_expenses_data.dart';
import '../../services/expense_service.dart';
import 'add_expense_page.dart';
import 'add_income_page.dart';

class TransferPage extends StatefulWidget {
  const TransferPage({super.key});

  @override
  State<TransferPage> createState() => _TransferPageState();
}

class _TransferPageState extends State<TransferPage> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _feeController = TextEditingController();
  final _memoController = TextEditingController();

  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();
  Wallet? _fromWallet;
  Wallet? _toWallet;
  bool _hasFee = false;

  @override
  void initState() {
    super.initState();
    // Set default wallets
    final wallets = WalletService.getAllWallets();
    if (wallets.isNotEmpty) {
      _fromWallet = wallets.first;
      if (wallets.length > 1) {
        _toWallet = wallets[1];
      }
    }
    _feeController.text = '0';
  }

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    _feeController.dispose();
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
    );
    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  void _saveTransfer() {
    if (_formKey.currentState!.validate()) {
      if (_fromWallet == null || _toWallet == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select both wallets')),
        );
        return;
      }

      if (_fromWallet!.id == _toWallet!.id) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Source and destination wallets must be different'),
          ),
        );
        return;
      }

      final amount = double.parse(_amountController.text.replaceAll(',', ''));
      final fee = double.parse(_feeController.text.replaceAll(',', ''));
      final totalAmount = amount + fee;

      // Check if from wallet has sufficient balance
      if (!WalletService.hasSufficientBalance(_fromWallet!.id, totalAmount)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Insufficient balance in source wallet!'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      final transfer = Transfer(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        amount: amount,
        fromWalletId: _fromWallet!.id,
        toWalletId: _toWallet!.id,
        date: DateTime(
          _selectedDate.year,
          _selectedDate.month,
          _selectedDate.day,
          _selectedTime.hour,
          _selectedTime.minute,
        ),
        description:
            _descriptionController.text.isNotEmpty
                ? _descriptionController.text
                : 'Transfer from ${_fromWallet!.name} to ${_toWallet!.name}',
        fee: fee,
        memo: _memoController.text,
      );

  // Save transfer to service and realtime store
  TransferService.addTransfer(transfer);
  TransactionStore.instance.addTransfer(transfer);

      // Update wallet balances
      WalletService.subtractFromWallet(_fromWallet!.id, totalAmount);
      WalletService.addToWallet(_toWallet!.id, amount);

      // If fee toggle is on and fee > 0, automatically create an expense from the fromWallet
      if (_hasFee && fee > 0) {
        // Find 'Lainnya' expense category as a default fee category
        final Category feeCategory = initialExpenseCategories.firstWhere(
          (c) => c.name.toLowerCase() == 'lainnya',
          orElse: () => initialExpenseCategories.first,
        );

        final feeExpense = Expense(
          id: 'fee_${DateTime.now().millisecondsSinceEpoch}',
          title: 'Transfer Fee',
          amount: fee,
          category: feeCategory,
          date: DateTime(
            _selectedDate.year,
            _selectedDate.month,
            _selectedDate.day,
            _selectedTime.hour,
            _selectedTime.minute,
          ),
          description: 'Fee for transfer to ${_toWallet!.name}',
          walletId: _fromWallet!.id,
          memo: _memoController.text,
        );

  // Persist in dummy service and push to store for realtime UI
  ExpenseService.addExpense(feeExpense);
  TransactionStore.instance.addExpense(feeExpense);
        // Note: balance already accounted via totalAmount subtraction above.
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Transfer completed successfully!'),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pop(context, transfer);
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
          'Transfer',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
        ),
        actions: [
          TextButton(
            onPressed: _saveTransfer,
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
                              MaterialPageRoute(
                                builder: (context) => const AddIncomePage(),
                              ),
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
                        child: GestureDetector(
                          onTap: () {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const AddExpensePage(),
                              ),
                            );
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              color: Colors.grey[100],
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              'Expense',
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
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text(
                            'Transfer',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
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
                                    Icon(
                                      Icons.calendar_today,
                                      color: AppColors.primary,
                                      size: 20,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      DateFormat(
                                        'dd/MM/yyyy',
                                      ).format(_selectedDate),
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
                                    Icon(
                                      Icons.access_time,
                                      color: AppColors.primary,
                                      size: 20,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      _selectedTime.format(context),
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
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Rp 0',
                          hintStyle: TextStyle(color: Colors.grey[400]),
                          prefixIcon: Icon(
                            Icons.payments,
                            color: AppColors.primary,
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
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter amount';
                          }
                          if (double.tryParse(value.replaceAll(',', '')) ==
                              null) {
                            return 'Please enter valid amount';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 24),

                      // Transfer Between Wallets Section
                      _buildSectionTitle('Transfer Between Wallets'),
                      // Two-row layout: From (full width), Swap (center), To (full width)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // From Wallet (Row 1)
                          Text(
                            'From',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 8),
                          DropdownButtonFormField<Wallet>(
                            initialValue: _fromWallet,
                            isExpanded: true,
                            decoration: InputDecoration(
                              prefixIcon: Icon(
                                Icons.account_balance_wallet,
                                color: AppColors.primary,
                                size: 20,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(
                                  color: Colors.grey[300]!,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(
                                  color: AppColors.primary,
                                ),
                              ),
                              filled: true,
                              fillColor: Colors.grey[50],
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                            ),
                            items: WalletService.getAllWallets()
                                .map((wallet) => DropdownMenuItem(
                                      value: wallet,
                                      child: Text(
                                        '${wallet.name} • ${wallet.formattedBalance}',
                                        style: const TextStyle(fontSize: 14),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ))
                                .toList(),
                            onChanged: (Wallet? value) {
                              setState(() {
                                _fromWallet = value;
                              });
                            },
                          ),

                          const SizedBox(height: 24),

                          // To Wallet (Row 2)
                          Text(
                            'To',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 8),
                          DropdownButtonFormField<Wallet>(
                            initialValue: _toWallet,
                            isExpanded: true,
                            decoration: InputDecoration(
                              prefixIcon: Icon(
                                Icons.account_balance_wallet,
                                color: AppColors.primary,
                                size: 20,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(
                                  color: Colors.grey[300]!,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(
                                  color: AppColors.primary,
                                ),
                              ),
                              filled: true,
                              fillColor: Colors.grey[50],
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                            ),
                            items: WalletService.getAllWallets()
                                .map((wallet) => DropdownMenuItem(
                                      value: wallet,
                                      child: Text(
                                        '${wallet.name} • ${wallet.formattedBalance}',
                                        style: const TextStyle(fontSize: 14),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ))
                                .toList(),
                            onChanged: (Wallet? value) {
                              setState(() {
                                _toWallet = value;
                              });
                            },
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),

                      // Description Section
                      _buildSectionTitle('Description'),
                      TextFormField(
                        controller: _descriptionController,
                        decoration: InputDecoration(
                          hintText: 'Enter description...',
                          hintStyle: TextStyle(color: Colors.grey[400]),
                          prefixIcon: Icon(
                            Icons.description,
                            color: AppColors.primary,
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

                      const SizedBox(height: 24),

                      // Transfer Fee Section
                      Row(
                        children: [
                          Checkbox(
                            value: _hasFee,
                            onChanged: (bool? value) {
                              setState(() {
                                _hasFee = value ?? false;
                                if (!_hasFee) {
                                  _feeController.text = '0';
                                }
                              });
                            },
                            activeColor: AppColors.primary,
                          ),
                          _buildSectionTitle('Transfer Fee'),
                        ],
                      ),
                      if (_hasFee)
                        TextFormField(
                          controller: _feeController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            hintText: 'Rp 0',
                            hintStyle: TextStyle(color: Colors.grey[400]),
                            prefixIcon: Icon(
                              Icons.monetization_on,
                              color: AppColors.primary,
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
                          validator: (value) {
                            if (_hasFee && (value == null || value.isEmpty)) {
                              return 'Please enter fee amount';
                            }
                            if (_hasFee &&
                                double.tryParse(value!.replaceAll(',', '')) ==
                                    null) {
                              return 'Please enter valid fee amount';
                            }
                            return null;
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
