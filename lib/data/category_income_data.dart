import 'package:flutter/material.dart';
import 'models/category_model.dart';

// Kategori untuk pemasukan (income)
final List<Category> initialIncomeCategories = [
  Category(name: 'Gaji', icon: Icons.work, color: Colors.green),
  Category(name: 'Bonus', icon: Icons.card_giftcard, color: Colors.lightGreen),
  Category(name: 'Investasi', icon: Icons.trending_up, color: Colors.teal),
  Category(name: 'Penjualan', icon: Icons.shopping_cart, color: Colors.blueGrey),
  Category(name: 'Hadiah', icon: Icons.redeem, color: Colors.amber),
  Category(name: 'Lainnya', icon: Icons.more_horiz, color: Colors.blue),
  Category(name: 'Semua', icon: Icons.all_inclusive, color: Colors.grey),
];
