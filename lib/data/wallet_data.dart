import 'package:flutter/material.dart';

import 'models/wallet_model.dart';

const List<Wallet> dummyWallets = [
  Wallet(
    id: 'w1',
    name: 'Cash',
    balance: 0,
    color: Color(0xFF3DB2FF),
    icon: Icons.attach_money_rounded,
  ),
  Wallet(
    id: 'w2',
    name: 'ShopeePay',
    balance: 0,
    color: Color(0xFFFFB830),
    icon: Icons.account_balance_wallet_rounded,
  ),
  Wallet(
    id: 'w3',
    name: 'GoPay',
    balance: 0,
    color: Color(0xFF3DB2FF),
    icon: Icons.account_balance_wallet_outlined,
  ),
];
