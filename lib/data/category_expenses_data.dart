import 'package:flutter/material.dart';
import 'models/category_model.dart';

final List<Category> initialExpenseCategories = [
  Category(name: 'Makanan', icon: Icons.fastfood, color: Colors.orange),
  Category(name: 'Transportasi', icon: Icons.directions_bus, color: Colors.blue),
  Category(name: 'Belanja', icon: Icons.shopping_bag, color: Colors.green),
  Category(name: 'Hiburan', icon: Icons.movie, color: Colors.purple),
  Category(name: 'Kesehatan', icon: Icons.local_hospital, color: Colors.red),
  Category(name: 'Pendidikan', icon: Icons.school, color: Colors.teal),
  Category(name: 'Utilitas', icon: Icons.power, color: Colors.lightGreen),
  Category(name: 'Adjustment', icon: Icons.tune, color: Colors.deepPurple), // For wallet balance adjustments
  Category(name: 'Lainnya', icon: Icons.more_horiz, color: Colors.deepPurpleAccent),
  Category(name: 'Semua', icon: Icons.all_inclusive, color: Colors.grey),
];
