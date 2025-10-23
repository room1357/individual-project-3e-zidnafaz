import 'category_model.dart';

class Income {
  final String id;
  final String title;
  final double amount;
  final Category category;
  final DateTime date;
  final String description;
  final String? walletId;
  final String memo;

  Income({
    required this.id,
    required this.title,
    required this.amount,
    required this.category,
    required this.date,
    required this.description,
    this.walletId,
    this.memo = '',
  });

  String get formattedAmount => 'Rp ${amount.toStringAsFixed(0)}';

  String get formattedDate => '${date.day}/${date.month}/${date.year}';
}
