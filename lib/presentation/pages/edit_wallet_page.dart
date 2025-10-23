import 'package:flutter/material.dart';
import '../../data/models/wallet_model.dart';
import '../../data/models/income_model.dart';
import '../../data/models/expense_model.dart';
import '../../services/wallet_service.dart';
import '../../services/income_service.dart';
import '../../services/expense_service.dart';
import '../../data/repositories/transaction_store.dart';
import '../../data/category_income_data.dart';
import '../../data/category_expenses_data.dart';
import '../../core/constants/app_colors.dart';

class EditWalletPage extends StatefulWidget {
  final Wallet wallet;
  
  const EditWalletPage({super.key, required this.wallet});

  @override
  State<EditWalletPage> createState() => _EditWalletPageState();
}

class _EditWalletPageState extends State<EditWalletPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _balanceController;
  late final TextEditingController _adminFeeController;

  late WalletType _selectedType;
  late Color _selectedColor;
  late IconData _selectedIcon;
  late bool _isExcluded;
  late bool _hasAdminFee;
  bool _adjustByTransaction = true; // Default: create adjustment transaction
  
  double _originalBalance = 0.0;

  final List<Color> _availableColors = [
    const Color(0xFF3DB2FF),
    const Color(0xFFFFB830),
    const Color(0xFF6BCB77),
    const Color(0xFFFF6B6B),
    const Color(0xFF9B59B6),
    const Color(0xFF00C9A7),
    const Color(0xFFFF6348),
    const Color(0xFF4ECDC4),
    Colors.blueGrey,
    Colors.teal,
    Colors.orange,
    Colors.indigo,
  ];

  final List<IconData> _availableIcons = [
    Icons.account_balance_wallet_rounded,
    Icons.attach_money_rounded,
    Icons.credit_card,
    Icons.account_balance,
    Icons.wallet,
    Icons.payment,
    Icons.savings,
    Icons.monetization_on,
    Icons.currency_exchange,
    Icons.payments_outlined,
  ];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.wallet.name);
    _balanceController = TextEditingController(text: widget.wallet.balance.toStringAsFixed(0));
    _adminFeeController = TextEditingController(text: widget.wallet.adminFee.toStringAsFixed(0));
    
    _selectedType = widget.wallet.type;
    _selectedColor = widget.wallet.color;
    _selectedIcon = widget.wallet.icon;
    _isExcluded = widget.wallet.isExcluded;
    _hasAdminFee = widget.wallet.hasAdminFee;
    _originalBalance = widget.wallet.balance;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _balanceController.dispose();
    _adminFeeController.dispose();
    super.dispose();
  }

  void _saveWallet() {
    if (_formKey.currentState!.validate()) {
      final newBalance = double.tryParse(_balanceController.text.replaceAll(',', '')) ?? 0;
      final balanceDifference = newBalance - _originalBalance;
      
      // Update wallet properties (name, type, color, icon, exclude, admin fee)
      final updatedWallet = widget.wallet.copyWith(
        name: _nameController.text,
        type: _selectedType,
        color: _selectedColor,
        icon: _selectedIcon,
        isExcluded: _isExcluded,
        hasAdminFee: _hasAdminFee,
        adminFee: _hasAdminFee
            ? (double.tryParse(_adminFeeController.text.replaceAll(',', '')) ?? 0)
            : 0,
      );

      // Update wallet data in service (without changing initialBalance yet)
      WalletService.updateWalletData(widget.wallet.id, updatedWallet);

      // Handle balance changes based on user's choice
      bool adjustmentCreated = false;
      Income? adjustmentIncome;
      Expense? adjustmentExpense;
      
      if (balanceDifference != 0) {
        if (_adjustByTransaction) {
          // Create adjustment transaction (initialBalance stays the same)
          // Store the transaction but don't emit to stream yet
          final adjustmentCategory = balanceDifference > 0
              ? initialIncomeCategories.firstWhere(
                  (cat) => cat.name == 'Adjustment',
                  orElse: () => initialIncomeCategories.last,
                )
              : initialExpenseCategories.firstWhere(
                  (cat) => cat.name == 'Adjustment',
                  orElse: () => initialExpenseCategories.last,
                );

          if (balanceDifference > 0) {
            adjustmentIncome = Income(
              id: 'adj_${DateTime.now().millisecondsSinceEpoch}',
              title: 'Balance Adjustment',
              amount: balanceDifference,
              category: adjustmentCategory,
              date: DateTime.now(),
              description: 'Wallet balance adjustment',
              walletId: widget.wallet.id,
              memo: 'Auto-generated from wallet edit',
            );
            IncomeService.addIncome(adjustmentIncome);
            adjustmentCreated = true;
          } else {
            adjustmentExpense = Expense(
              id: 'adj_${DateTime.now().millisecondsSinceEpoch}',
              title: 'Balance Adjustment',
              amount: balanceDifference.abs(),
              category: adjustmentCategory,
              date: DateTime.now(),
              description: 'Wallet balance adjustment',
              walletId: widget.wallet.id,
              memo: 'Auto-generated from wallet edit',
            );
            ExpenseService.addExpense(adjustmentExpense);
            adjustmentCreated = true;
          }
        } else {
          // Change initial balance directly (no transaction)
          final newInitialBalance = widget.wallet.initialBalance + balanceDifference;
          final walletWithNewInitialBalance = updatedWallet.copyWith(
            initialBalance: newInitialBalance,
          );
          WalletService.updateWalletData(widget.wallet.id, walletWithNewInitialBalance);
        }
      }

      // Recalculate balances (will use the updated wallet data and new transactions if any)
      WalletService.recalculateAllFromServices();

      // NOW emit to stream after everything is done to trigger UI refresh
      if (adjustmentCreated) {
        if (adjustmentIncome != null) {
          TransactionStore.instance.addIncome(adjustmentIncome);
        } else if (adjustmentExpense != null) {
          TransactionStore.instance.addExpense(adjustmentExpense);
        }
      } else if (balanceDifference != 0 && !_adjustByTransaction) {
        // Notify wallet change for "Change Initial Balance" option
        TransactionStore.instance.notifyWalletChange();
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${updatedWallet.name} updated successfully!'),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pop(context, true); // Return true to indicate changes were made
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
          'Edit Wallet',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
        ),
        actions: [
          TextButton(
            onPressed: _saveWallet,
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
                // Info box
                Container(
                  padding: const EdgeInsets.all(12),
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.blue[200]!),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline, color: Colors.blue[700], size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'You can choose to create adjustment transaction or directly change initial balance',
                          style: TextStyle(
                            color: Colors.blue[900],
                            fontSize: 12,
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
                      // Name Section
                      _buildSectionTitle('Name'),
                      TextFormField(
                        controller: _nameController,
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.w600),
                        decoration: InputDecoration(
                          hintText: "Wallet's name",
                          hintStyle: TextStyle(color: Colors.grey[400]),
                          prefixIcon:
                              Icon(Icons.edit, color: AppColors.primary),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey[300]!),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: AppColors.primary),
                          ),
                          filled: true,
                          fillColor: Colors.grey[50],
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter wallet name';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 24),

                      // Type Section
                      _buildSectionTitle('Type'),
                      DropdownButtonFormField<WalletType>(
                        value: _selectedType,
                        decoration: InputDecoration(
                          hintText: 'Select Type',
                          hintStyle: TextStyle(color: Colors.grey[400]),
                          prefixIcon:
                              Icon(Icons.category, color: AppColors.primary),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey[300]!),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: AppColors.primary),
                          ),
                          filled: true,
                          fillColor: Colors.grey[50],
                        ),
                        items: WalletType.values
                            .map((type) => DropdownMenuItem(
                                  value: type,
                                  child: Text(_getTypeLabel(type)),
                                ))
                            .toList(),
                        onChanged: (WalletType? value) {
                          if (value != null) {
                            setState(() => _selectedType = value);
                          }
                        },
                      ),

                      const SizedBox(height: 24),

                      // Current Balance Section
                      _buildSectionTitle('Current Balance'),
                      TextFormField(
                        controller: _balanceController,
                        keyboardType: TextInputType.number,
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.w600),
                        decoration: InputDecoration(
                          hintText: 'Rp 0',
                          hintStyle: TextStyle(color: Colors.grey[400]),
                          prefixIcon:
                              Icon(Icons.payments, color: AppColors.primary),
                          helperText: 'Original: Rp ${_originalBalance.toStringAsFixed(0)}',
                          helperStyle: TextStyle(color: Colors.grey[600], fontSize: 11),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey[300]!),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: AppColors.primary),
                          ),
                          filled: true,
                          fillColor: Colors.grey[50],
                        ),
                        validator: (value) {
                          if (value != null && value.isNotEmpty) {
                            if (double.tryParse(value.replaceAll(',', '')) ==
                                null) {
                              return 'Please enter valid amount';
                            }
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 24),

                      // Balance Adjustment Method Section
                      _buildSectionTitle('Balance Adjustment Method'),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.grey[50],
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey[300]!),
                        ),
                        child: Column(
                          children: [
                            SwitchListTile(
                              value: _adjustByTransaction,
                              onChanged: (value) {
                                setState(() => _adjustByTransaction = value);
                              },
                              activeColor: AppColors.primary,
                              title: Text(
                                _adjustByTransaction
                                    ? 'Adjust by Transaction'
                                    : 'Change Initial Balance',
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              subtitle: Text(
                                _adjustByTransaction
                                    ? 'Balance changes will create adjustment transaction'
                                    : 'Balance changes will update initial balance directly',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.grey[600],
                                ),
                              ),
                              contentPadding: EdgeInsets.zero,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // Color & Icon Section
                _buildCard(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Color Section
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildSectionTitle('Color'),
                            Container(
                              height: 120,
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.grey[50],
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.grey[300]!),
                              ),
                              child: GridView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                gridDelegate:
                                    const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 4,
                                  crossAxisSpacing: 8,
                                  mainAxisSpacing: 8,
                                ),
                                itemCount: _availableColors.length,
                                itemBuilder: (context, index) {
                                  final color = _availableColors[index];
                                  final isSelected = color == _selectedColor;
                                  return GestureDetector(
                                    onTap: () =>
                                        setState(() => _selectedColor = color),
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: color,
                                        shape: BoxShape.circle,
                                        border: isSelected
                                            ? Border.all(
                                                color: Colors.black, width: 3)
                                            : null,
                                        boxShadow: [
                                          BoxShadow(
                                            color: color.withOpacity(0.4),
                                            blurRadius: 4,
                                            offset: const Offset(0, 2),
                                          ),
                                        ],
                                      ),
                                      child: isSelected
                                          ? const Icon(Icons.check,
                                              color: Colors.white, size: 16)
                                          : null,
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(width: 16),

                      // Icon Section
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildSectionTitle('Icon'),
                            Container(
                              height: 120,
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.grey[50],
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.grey[300]!),
                              ),
                              child: GridView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                gridDelegate:
                                    const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 3,
                                  crossAxisSpacing: 8,
                                  mainAxisSpacing: 8,
                                ),
                                itemCount: _availableIcons.length,
                                itemBuilder: (context, index) {
                                  final icon = _availableIcons[index];
                                  final isSelected = icon == _selectedIcon;
                                  return GestureDetector(
                                    onTap: () =>
                                        setState(() => _selectedIcon = icon),
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: isSelected
                                            ? AppColors.primary
                                            : Colors.grey[200],
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Icon(
                                        icon,
                                        color: isSelected
                                            ? Colors.white
                                            : Colors.grey[600],
                                        size: 24,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // Exclude Toggle Section
                _buildCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Exclude',
                                  style: TextStyle(
                                    color: AppColors.primary,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Ignore the balance of this wallet on the total balance',
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Switch(
                            value: _isExcluded,
                            onChanged: (value) {
                              setState(() => _isExcluded = value);
                            },
                            activeColor: AppColors.primary,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Admin Fee Toggle Section
                _buildCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Admin Fee',
                                  style: TextStyle(
                                    color: AppColors.primary,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Monthly fee will be automatically deducted on the 20th of each month',
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Switch(
                            value: _hasAdminFee,
                            onChanged: (value) {
                              setState(() => _hasAdminFee = value);
                            },
                            activeColor: AppColors.primary,
                          ),
                        ],
                      ),
                      if (_hasAdminFee) ...[
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _adminFeeController,
                          keyboardType: TextInputType.number,
                          style: const TextStyle(
                              fontSize: 18, fontWeight: FontWeight.w600),
                          decoration: InputDecoration(
                            hintText: 'Rp 0',
                            hintStyle: TextStyle(color: Colors.grey[400]),
                            prefixIcon: Icon(Icons.monetization_on,
                                color: AppColors.primary),
                            labelText: 'Monthly Admin Fee Amount',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: Colors.grey[300]!),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: AppColors.primary),
                            ),
                            filled: true,
                            fillColor: Colors.grey[50],
                          ),
                          validator: (value) {
                            if (_hasAdminFee) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter admin fee amount';
                              }
                              if (double.tryParse(
                                      value.replaceAll(',', '')) ==
                                  null) {
                                return 'Please enter valid amount';
                              }
                            }
                            return null;
                          },
                        ),
                      ],
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

  String _getTypeLabel(WalletType type) {
    switch (type) {
      case WalletType.general:
        return 'General';
      case WalletType.creditCard:
        return 'Credit Card';
      case WalletType.debitCard:
        return 'Debit Card';
      case WalletType.eWallet:
        return 'E-Wallet';
    }
  }
}
