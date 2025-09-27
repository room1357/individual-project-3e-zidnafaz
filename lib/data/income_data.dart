import 'models/income_model.dart';
import 'category_income_data.dart';

List<Income> dummyIncomes = [
  Income(
    id: 'i1',
    title: 'Gaji Bulanan',
    amount: 4500000.0,
    category: initialIncomeCategories.firstWhere((c) => c.name == 'Gaji'),
    date: DateTime.now().subtract(const Duration(days: 0, hours: 3)),
    description: 'Gaji bulan ini',
    walletId: 'w1', // Cash
  ),
  Income(
    id: 'i2',
    title: 'Bonus Project',
    amount: 750000.0,
    category: initialIncomeCategories.firstWhere((c) => c.name == 'Bonus'),
    date: DateTime.now().subtract(const Duration(days: 2, hours: 1)),
    description: 'Bonus penyelesaian proyek',
    walletId: 'w2', // ShopeePay
  ),
  Income(
    id: 'i3',
    title: 'Dividen Saham',
    amount: 300000.0,
    category: initialIncomeCategories.firstWhere((c) => c.name == 'Investasi'),
    date: DateTime.now().subtract(const Duration(days: 5)),
    description: 'Dividen kuartal 3',
    walletId: 'w3', // GoPay
  ),
  // August incomes
  Income(
    id: 'i-aug-1',
    title: 'Gaji Bulanan',
    amount: 4400000.0,
    category: initialIncomeCategories.firstWhere((c) => c.name == 'Gaji'),
    date: DateTime(DateTime.now().year, 8, 25, 10, 0),
    description: 'Gaji bulan Agustus',
    walletId: 'w1', // Cash
  ),
  Income(
    id: 'i-aug-2',
    title: 'Freelance Design',
    amount: 600000.0,
    category: initialIncomeCategories.firstWhere((c) => c.name == 'Bonus'),
    date: DateTime(DateTime.now().year, 8, 18, 14, 30),
    description: 'Bayaran desain logo',
    walletId: 'w2', // ShopeePay
  ),
  Income(
    id: 'i-aug-3',
    title: 'Dividen Saham',
    amount: 280000.0,
    category: initialIncomeCategories.firstWhere((c) => c.name == 'Investasi'),
    date: DateTime(DateTime.now().year, 8, 8, 9, 15),
    description: 'Dividen Agustus',
    walletId: 'w3', // GoPay
  ),
];
