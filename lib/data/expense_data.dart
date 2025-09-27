import 'models/expense_model.dart';
import 'category_expenses_data.dart';

List<Expense> dummyExpenses = [
  Expense(
    id: '1',
    title: 'Nasi Goreng',
    amount: 25000,
    category: initialExpenseCategories.firstWhere((cat) => cat.name == 'Makanan'),
    date: DateTime.now(),
    description: 'Makan malam di warung',
    walletId: 'w2', // ShopeePay
  ),
  Expense(
    id: '2',
    title: 'Tiket Bioskop',
    amount: 50000,
    category: initialExpenseCategories.firstWhere((cat) => cat.name == 'Hiburan'),
    date: DateTime.now().subtract(const Duration(days: 1)),
    description: 'Nonton film baru di XXI',
    walletId: 'w3', // GoPay
  ),
  Expense(
    id: '3',
    title: 'Bensin',
    amount: 100000,
    category: initialExpenseCategories.firstWhere((cat) => cat.name == 'Transportasi'),
    date: DateTime.now().subtract(const Duration(days: 2)),
    description: 'Isi bensin Pertamax',
    walletId: 'w1', // Cash
  ),
  Expense(
    id: '4',
    title: 'Bayar Listrik',
    amount: 200000,
    category: initialExpenseCategories.firstWhere((cat) => cat.name == 'Utilitas'),
    date: DateTime.now().subtract(const Duration(days: 3)),
    description: 'Tagihan listrik bulan ini',
    walletId: 'w1',
  ),
  Expense(
    id: '5',
    title: 'Buku Flutter',
    amount: 150000,
    category: initialExpenseCategories.firstWhere((cat) => cat.name == 'Pendidikan'),
    date: DateTime.now().subtract(const Duration(days: 4)),
    description: 'Beli buku di Gramedia',
    walletId: 'w1',
  ),
  Expense(
    id: '6',
    title: 'Buku Java',
    amount: 250000,
    category: initialExpenseCategories.firstWhere((cat) => cat.name == 'Pendidikan'),
    date: DateTime.now().subtract(const Duration(days: 4)),
    description: 'Beli buku di Gramedia',
    walletId: 'w1',
  ),
];
