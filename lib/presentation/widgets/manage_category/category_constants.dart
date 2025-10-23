import 'package:flutter/material.dart';
import '../reusable/icon_color_constants.dart';

class CategoryConstants {
  // Available icons for categories (using reusable constants)
  static final List<IconData> availableIcons = 
      IconColorConstants.getIconsForCategory();

  // Available colors for categories (using reusable constants)
  static final List<Color> availableColors = 
      IconColorConstants.getColorsForCategory();
}
