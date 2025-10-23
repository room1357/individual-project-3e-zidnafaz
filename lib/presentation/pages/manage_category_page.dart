import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../data/models/category_model.dart';
import '../../data/category_income_data.dart';
import '../../data/category_expenses_data.dart';
import '../widgets/manage_category/category_list_card.dart';
import '../widgets/manage_category/category_dialog.dart';

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
    CategoryDialog.showAddCategoryDialog(
      context: context,
      isIncome: isIncome,
      onAdd: (newCategory) {
        setState(() {
          if (isIncome) {
            initialIncomeCategories.add(newCategory);
          } else {
            initialExpenseCategories.add(newCategory);
          }
        });
      },
    );
  }

  void _showEditCategoryDialog(Category category, bool isIncome) {
    CategoryDialog.showEditCategoryDialog(
      context: context,
      category: category,
      isIncome: isIncome,
      onUpdate: (updatedCategory) {
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
      },
    );
  }

  void _deleteCategory(Category category, bool isIncome) {
    CategoryDialog.showDeleteCategoryDialog(
      context: context,
      category: category,
      onDelete: () {
        setState(() {
          if (isIncome) {
            initialIncomeCategories.removeWhere((c) => c.name == category.name);
          } else {
            initialExpenseCategories.removeWhere((c) => c.name == category.name);
          }
        });
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
                CategoryListCard(
                  categories: initialIncomeCategories,
                  isIncome: true,
                  onSelectCategory: _selectCategory,
                  onEditCategory: _showEditCategoryDialog,
                  onDeleteCategory: _deleteCategory,
                  onAddCategory: () => _showAddCategoryDialog(true),
                ),
                CategoryListCard(
                  categories: initialExpenseCategories,
                  isIncome: false,
                  onSelectCategory: _selectCategory,
                  onEditCategory: _showEditCategoryDialog,
                  onDeleteCategory: _deleteCategory,
                  onAddCategory: () => _showAddCategoryDialog(false),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
