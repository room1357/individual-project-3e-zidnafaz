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
];
