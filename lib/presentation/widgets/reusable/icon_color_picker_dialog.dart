import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import 'icon_color_constants.dart';

class IconColorPickerDialog {
  /// Show dialog to select icon
  static Future<IconData?> showIconPicker({
    required BuildContext context,
    required IconData currentIcon,
    List<IconData>? customIcons,
  }) async {
    IconData selectedIcon = currentIcon;
    final icons = customIcons ?? IconColorConstants.availableIcons;

    return await showDialog<IconData>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Select Icon'),
          content: SizedBox(
            width: double.maxFinite,
            height: 400,
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
              ),
              itemCount: icons.length,
              itemBuilder: (context, index) {
                final icon = icons[index];
                final isSelected = selectedIcon == icon;
                return InkWell(
                  onTap: () {
                    setDialogState(() {
                      selectedIcon = icon;
                    });
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.primary : Colors.grey[200],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      icon,
                      color: isSelected ? Colors.white : Colors.grey[700],
                      size: 28,
                    ),
                  ),
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
              onPressed: () => Navigator.pop(context, selectedIcon),
              child: const Text('Select'),
            ),
          ],
        ),
      ),
    );
  }

  /// Show dialog to select color
  static Future<Color?> showColorPicker({
    required BuildContext context,
    required Color currentColor,
    List<Color>? customColors,
  }) async {
    Color selectedColor = currentColor;
    final colors = customColors ?? IconColorConstants.availableColors;

    return await showDialog<Color>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Select Color'),
          content: SizedBox(
            width: double.maxFinite,
            height: 400,
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemCount: colors.length,
              itemBuilder: (context, index) {
                final color = colors[index];
                final isSelected = selectedColor == color;
                return InkWell(
                  onTap: () {
                    setDialogState(() {
                      selectedColor = color;
                    });
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                      border: isSelected
                          ? Border.all(color: Colors.black, width: 3)
                          : Border.all(color: Colors.grey[300]!, width: 1),
                      boxShadow: [
                        BoxShadow(
                          color: color.withOpacity(0.4),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: isSelected
                        ? const Icon(Icons.check, color: Colors.white, size: 24)
                        : null,
                  ),
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
              onPressed: () => Navigator.pop(context, selectedColor),
              child: const Text('Select'),
            ),
          ],
        ),
      ),
    );
  }
}
