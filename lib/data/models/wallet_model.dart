import 'package:flutter/material.dart';

class Wallet {
  final String id;
  final String name;
  final double balance;
  final Color color;
  final IconData icon;

  const Wallet({
    required this.id,
    required this.name,
    required this.balance,
    required this.color,
    required this.icon,
  });

  Wallet copyWith({String? name, double? balance, Color? color, IconData? icon}) => Wallet(
        id: id,
        name: name ?? this.name,
        balance: balance ?? this.balance,
        color: color ?? this.color,
        icon: icon ?? this.icon,
      );

  String get formattedBalance => 'Rp ${balance.toStringAsFixed(0)}';
}
