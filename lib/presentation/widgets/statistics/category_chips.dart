import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../data/models/category_model.dart';

class CategoryChips extends StatelessWidget {
  final List<Category> categories;
  final Category? selectedCategory;
  final Function(Category) onCategorySelected;

  const CategoryChips({
    super.key,
    required this.categories,
    required this.selectedCategory,
    required this.onCategorySelected,
  });

  @override
  Widget build(BuildContext context) {
    final cats = List<Category>.from(categories);
    final idxAll = cats.indexWhere((c) => c.name.toLowerCase() == 'semua');
    if (idxAll > 0) {
      final allCat = cats.removeAt(idxAll);
      cats.insert(0, allCat);
    }
    
    return SizedBox(
      height: 44,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemBuilder: (context, i) {
          final cat = cats[i];
          final isSel = selectedCategory?.name == cat.name;
          final isAll = cat.name.toLowerCase() == 'semua';
          final Color bgColor =
              isSel ? (isAll ? AppColors.primary : cat.color) : (Colors.grey[100]!);
          final Color borderColor =
              isSel ? (isAll ? AppColors.primary : cat.color) : (Colors.grey[300]!);
          final Color iconColor = isSel ? Colors.white : Colors.black54;
          final Color textColor = isSel ? Colors.white : Colors.black87;
          return GestureDetector(
            onTap: () => onCategorySelected(cat),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: borderColor, width: 1.5),
              ),
              child: Row(
                children: [
                  Icon(cat.icon, size: 18, color: iconColor),
                  const SizedBox(width: 8),
                  Text(
                    cat.name,
                    style: TextStyle(
                      color: textColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemCount: cats.length,
      ),
    );
  }
}