import 'package:flutter/material.dart';

enum WalletType {
  general,
  creditCard,
  debitCard,
  eWallet,
}

class Wallet {
  final String id;
  final String name;
  final double balance;
  final Color color;
  final IconData icon;
  final WalletType type;
  final bool isExcluded;
  final bool hasAdminFee;
  final double adminFee;
  final double initialBalance; // ✨ NEW: Store initial balance separately

  const Wallet({
    required this.id,
    required this.name,
    required this.balance,
    required this.color,
    required this.icon,
    this.type = WalletType.general,
    this.isExcluded = false,
    this.hasAdminFee = false,
    this.adminFee = 0.0,
    this.initialBalance = 0.0, // ✨ NEW
  });

  Wallet copyWith({
    String? name,
    double? balance,
    Color? color,
    IconData? icon,
    WalletType? type,
    bool? isExcluded,
    bool? hasAdminFee,
    double? adminFee,
    double? initialBalance, // ✨ NEW
  }) =>
      Wallet(
        id: id,
        name: name ?? this.name,
        balance: balance ?? this.balance,
        color: color ?? this.color,
        icon: icon ?? this.icon,
        type: type ?? this.type,
        isExcluded: isExcluded ?? this.isExcluded,
        hasAdminFee: hasAdminFee ?? this.hasAdminFee,
        adminFee: adminFee ?? this.adminFee,
        initialBalance: initialBalance ?? this.initialBalance, // ✨ NEW
      );

  String get formattedBalance => 'Rp ${balance.toStringAsFixed(0)}';
  
  String get typeLabel {
    switch (type) {
      case WalletType.general:
        return 'General';
      case WalletType.creditCard:
        return 'Credit Card';
      case WalletType.debitCard:
        return 'Debit Card';
      case WalletType.eWallet:
        return 'E-Wallet';
    }
  }
}
