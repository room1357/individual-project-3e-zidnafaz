import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../data/models/category_model.dart';
import '../../data/category_income_data.dart';
import '../../data/category_expenses_data.dart';

class ManageCategoryPage extends StatefulWidget {
  final String? initialTab; // 'income' or 'expense'
  
  const ManageCategoryPage({
    super.key,
    this.initialTab,
  });

  @override
  State<ManageCategoryPage> createState() => _ManageCategoryPageState();
}

class _ManageCategoryPageState extends State<ManageCategoryPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 2,
      vsync: this,
      initialIndex: widget.initialTab == 'expense' ? 1 : 0,
    );
    // Add listener to rebuild UI when tab changes
    _tabController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _selectCategory(Category category, bool isIncome) {
    // Return both category and type information
    Navigator.pop(context, {
      'category': category,
      'isIncome': isIncome,
    });
  }

  void _showAddCategoryDialog(bool isIncome) {
    final nameController = TextEditingController();
    IconData selectedIcon = Icons.category;
    Color selectedColor = Colors.blue;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text('Add ${isIncome ? 'Income' : 'Expense'} Category'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Category Name',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                const Text('Select Icon:', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _availableIcons.map((icon) {
                    final isSelected = selectedIcon == icon;
                    return InkWell(
                      onTap: () {
                        setDialogState(() {
                          selectedIcon = icon;
                        });
                      },
                      child: Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: isSelected ? AppColors.primary : Colors.grey[200],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          icon,
                          color: isSelected ? Colors.white : Colors.grey[700],
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),
                const Text('Select Color:', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _availableColors.map((color) {
                    final isSelected = selectedColor == color;
                    return InkWell(
                      onTap: () {
                        setDialogState(() {
                          selectedColor = color;
                        });
                      },
                      child: Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: color,
                          borderRadius: BorderRadius.circular(8),
                          border: isSelected
                              ? Border.all(color: Colors.black, width: 3)
                              : null,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (nameController.text.isNotEmpty) {
                  final newCategory = Category(
                    name: nameController.text,
                    icon: selectedIcon,
                    color: selectedColor,
                  );
                  setState(() {
                    if (isIncome) {
                      initialIncomeCategories.add(newCategory);
                    } else {
                      initialExpenseCategories.add(newCategory);
                    }
                  });
                  Navigator.pop(context);
                }
              },
              child: const Text('Add'),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditCategoryDialog(Category category, bool isIncome) {
    final nameController = TextEditingController(text: category.name);
    IconData selectedIcon = category.icon;
    Color selectedColor = category.color;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text('Edit ${isIncome ? 'Income' : 'Expense'} Category'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Category Name',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                const Text('Select Icon:', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _availableIcons.map((icon) {
                    final isSelected = selectedIcon == icon;
                    return InkWell(
                      onTap: () {
                        setDialogState(() {
                          selectedIcon = icon;
                        });
                      },
                      child: Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: isSelected ? AppColors.primary : Colors.grey[200],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          icon,
                          color: isSelected ? Colors.white : Colors.grey[700],
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),
                const Text('Select Color:', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _availableColors.map((color) {
                    final isSelected = selectedColor == color;
                    return InkWell(
                      onTap: () {
                        setDialogState(() {
                          selectedColor = color;
                        });
                      },
                      child: Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: color,
                          borderRadius: BorderRadius.circular(8),
                          border: isSelected
                              ? Border.all(color: Colors.black, width: 3)
                              : null,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (nameController.text.isNotEmpty) {
                  final updatedCategory = Category(
                    name: nameController.text,
                    icon: selectedIcon,
                    color: selectedColor,
                  );
                  setState(() {
                    if (isIncome) {
                      final index = initialIncomeCategories.indexWhere((c) => c.name == category.name);
                      if (index != -1) {
                        initialIncomeCategories[index] = updatedCategory;
                      }
                    } else {
                      final index = initialExpenseCategories.indexWhere((c) => c.name == category.name);
                      if (index != -1) {
                        initialExpenseCategories[index] = updatedCategory;
                      }
                    }
                  });
                  Navigator.pop(context);
                }
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  void _deleteCategory(Category category, bool isIncome) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Category'),
        content: Text('Are you sure you want to delete "${category.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              setState(() {
                if (isIncome) {
                  initialIncomeCategories.removeWhere((c) => c.name == category.name);
                } else {
                  initialExpenseCategories.removeWhere((c) => c.name == category.name);
                }
              });
              Navigator.pop(context);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryList(List<Category> categories, bool isIncome) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: categories.length + 1, // +1 for Add button
      itemBuilder: (context, index) {
        if (index == categories.length) {
          // Add Category Button
          return Card(
            elevation: 0,
            color: AppColors.primary.withOpacity(0.1),
            child: ListTile(
              leading: Icon(Icons.add_circle, color: AppColors.primary),
              title: Text(
                'Add New Category',
                style: TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              onTap: () => _showAddCategoryDialog(isIncome),
            ),
          );
        }

        final category = categories[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: category.color.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(category.icon, color: category.color),
            ),
            title: Text(
              category.name,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit, color: Colors.blue),
                  onPressed: () => _showEditCategoryDialog(category, isIncome),
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => _deleteCategory(category, isIncome),
                ),
              ],
            ),
            onTap: () => _selectCategory(category, isIncome),
          ),
        );
      },
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
        title: const Text(
          'Manage Categories',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: Column(
        children: [
          // Custom Tab Bar wrapped in Card like add_expense_page
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
            child: Container(
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
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        _tabController.animateTo(0);
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: _tabController.index == 0 
                              ? Colors.green 
                              : Colors.grey[100],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'Income',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: _tabController.index == 0 
                                ? Colors.white 
                                : Colors.grey[600],
                            fontWeight: _tabController.index == 0 
                                ? FontWeight.bold 
                                : FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        _tabController.animateTo(1);
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: _tabController.index == 1 
                              ? Colors.red 
                              : Colors.grey[100],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'Expense',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: _tabController.index == 1 
                                ? Colors.white 
                                : Colors.grey[600],
                            fontWeight: _tabController.index == 1 
                                ? FontWeight.bold 
                                : FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Tab Content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildCategoryList(initialIncomeCategories, true),
                _buildCategoryList(initialExpenseCategories, false),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Available icons for categories
  static final List<IconData> _availableIcons = [
    Icons.category,
    Icons.shopping_cart,
    Icons.restaurant,
    Icons.local_cafe,
    Icons.directions_car,
    Icons.local_gas_station,
    Icons.home,
    Icons.phone,
    Icons.wifi,
    Icons.electric_bolt,
    Icons.water_drop,
    Icons.school,
    Icons.medical_services,
    Icons.fitness_center,
    Icons.movie,
    Icons.music_note,
    Icons.sports_esports,
    Icons.card_giftcard,
    Icons.favorite,
    Icons.pets,
    Icons.work,
    Icons.account_balance,
    Icons.savings,
    Icons.attach_money,
    Icons.trending_up,
  ];

  // Available colors for categories
  static final List<Color> _availableColors = [
    Colors.red,
    Colors.pink,
    Colors.purple,
    Colors.deepPurple,
    Colors.indigo,
    Colors.blue,
    Colors.lightBlue,
    Colors.cyan,
    Colors.teal,
    Colors.green,
    Colors.lightGreen,
    Colors.lime,
    Colors.yellow,
    Colors.amber,
    Colors.orange,
    Colors.deepOrange,
    Colors.brown,
    Colors.grey,
  ];
}
