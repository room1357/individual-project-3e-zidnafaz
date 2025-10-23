class Transfer {
  final String id;
  final double amount;
  final DateTime date;
  final String description;
  final String fromWalletId;
  final String toWalletId;
  final double fee;
  final bool hasFee;
  final String memo;

  Transfer({
    required this.id,
    required this.amount,
    required this.date,
    required this.description,
    required this.fromWalletId,
    required this.toWalletId,
    this.fee = 0.0,
    this.hasFee = false,
    this.memo = '',
  });

  String get formattedAmount => 'Rp ${amount.toStringAsFixed(0)}';
  String get formattedFee => 'Rp ${fee.toStringAsFixed(0)}';

  String get formattedDate {
    return '${date.day}/${date.month}/${date.year}';
  }

  Transfer copyWith({
    String? id,
    double? amount,
    DateTime? date,
    String? description,
    String? fromWalletId,
    String? toWalletId,
    double? fee,
    bool? hasFee,
    String? memo,
  }) {
    return Transfer(
      id: id ?? this.id,
      amount: amount ?? this.amount,
      date: date ?? this.date,
      description: description ?? this.description,
      fromWalletId: fromWalletId ?? this.fromWalletId,
      toWalletId: toWalletId ?? this.toWalletId,
      fee: fee ?? this.fee,
      hasFee: hasFee ?? this.hasFee,
      memo: memo ?? this.memo,
    );
  }
}