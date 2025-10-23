import 'package:flutter/material.dart';
import '../../data/models/wallet_model.dart';
import '../../services/wallet_service.dart';
import '../../core/constants/app_colors.dart';
import '../widgets/reusable/icon_color_constants.dart';
import '../widgets/reusable/icon_color_picker_dialog.dart';

class AddWalletPage extends StatefulWidget {
  const AddWalletPage({super.key});

  @override
  State<AddWalletPage> createState() => _AddWalletPageState();
}

class _AddWalletPageState extends State<AddWalletPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _initialAmountController = TextEditingController(text: '0');
  final _adminFeeController = TextEditingController(text: '0');

  WalletType _selectedType = WalletType.general;
  Color _selectedColor = const Color(0xFF3DB2FF);
  IconData _selectedIcon = Icons.account_balance_wallet_rounded;
  bool _isExcluded = false;
  bool _hasAdminFee = false;

  // Use reusable constants
  final List<Color> _availableColors = IconColorConstants.getColorsForWallet();
  final List<IconData> _availableIcons = IconColorConstants.getIconsForWallet();

  @override
  void dispose() {
    _nameController.dispose();
    _initialAmountController.dispose();
    _adminFeeController.dispose();
    super.dispose();
  }

  void _saveWallet() {
    if (_formKey.currentState!.validate()) {
      final initialAmount = double.tryParse(_initialAmountController.text.replaceAll(',', '')) ?? 0;
      
      final newWallet = Wallet(
        id: 'w${DateTime.now().millisecondsSinceEpoch}',
        name: _nameController.text,
        balance: initialAmount, // Set balance sama dengan initial amount
        color: _selectedColor,
        icon: _selectedIcon,
        type: _selectedType,
        isExcluded: _isExcluded,
        hasAdminFee: _hasAdminFee,
        adminFee: _hasAdminFee
            ? (double.tryParse(_adminFeeController.text.replaceAll(',', '')) ?? 0)
            : 0,
        initialBalance: initialAmount, // Simpan initial balance
      );

      WalletService.addWallet(newWallet);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${newWallet.name} added successfully!'),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pop(context, newWallet);
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
          'Add Wallet',
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
                // Single Main Form Card with all fields
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

                      // Initial Amount Section
                      _buildSectionTitle('Initial Amount'),
                      TextFormField(
                        controller: _initialAmountController,
                        keyboardType: TextInputType.number,
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.w600),
                        decoration: InputDecoration(
                          hintText: 'Rp 0',
                          hintStyle: TextStyle(color: Colors.grey[400]),
                          prefixIcon:
                              Icon(Icons.payments, color: AppColors.primary),
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

                      // Color & Icon Section with Dialog
                      Row(
                        children: [
                          // Color Picker Button
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildSectionTitle('Color'),
                                InkWell(
                                  onTap: () async {
                                    final color = await IconColorPickerDialog.showColorPicker(
                                      context: context,
                                      currentColor: _selectedColor,
                                      customColors: _availableColors,
                                    );
                                    if (color != null) {
                                      setState(() => _selectedColor = color);
                                    }
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: Colors.grey[50],
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(color: Colors.grey[300]!),
                                    ),
                                    child: Row(
                                      children: [
                                        Container(
                                          width: 40,
                                          height: 40,
                                          decoration: BoxDecoration(
                                            color: _selectedColor,
                                            shape: BoxShape.circle,
                                            boxShadow: [
                                              BoxShadow(
                                                color: _selectedColor.withOpacity(0.4),
                                                blurRadius: 4,
                                                offset: const Offset(0, 2),
                                              ),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Text(
                                            'Select Color',
                                            style: TextStyle(
                                              color: Colors.grey[600],
                                              fontSize: 14,
                                            ),
                                          ),
                                        ),
                                        Icon(Icons.arrow_forward_ios, 
                                            size: 16, color: Colors.grey[600]),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(width: 16),

                          // Icon Picker Button
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildSectionTitle('Icon'),
                                InkWell(
                                  onTap: () async {
                                    final icon = await IconColorPickerDialog.showIconPicker(
                                      context: context,
                                      currentIcon: _selectedIcon,
                                      customIcons: _availableIcons,
                                    );
                                    if (icon != null) {
                                      setState(() => _selectedIcon = icon);
                                    }
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: Colors.grey[50],
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(color: Colors.grey[300]!),
                                    ),
                                    child: Row(
                                      children: [
                                        Container(
                                          width: 40,
                                          height: 40,
                                          decoration: BoxDecoration(
                                            color: AppColors.primary,
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: Icon(
                                            _selectedIcon,
                                            color: Colors.white,
                                            size: 24,
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Text(
                                            'Select Icon',
                                            style: TextStyle(
                                              color: Colors.grey[600],
                                              fontSize: 14,
                                            ),
                                          ),
                                        ),
                                        Icon(Icons.arrow_forward_ios, 
                                            size: 16, color: Colors.grey[600]),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),

                      // Exclude Toggle Section (now in same card)
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

                      const SizedBox(height: 24),

                      // Admin Fee Toggle Section (now in same card)
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
