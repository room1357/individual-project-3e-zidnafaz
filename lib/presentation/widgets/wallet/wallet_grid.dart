import 'package:flutter/material.dart';

import '../../../data/models/wallet_model.dart';
import 'wallet_card.dart';

class WalletGrid extends StatelessWidget {
  final List<Wallet> wallets;
  final Map<String, double> balances;
  final Function(Wallet) onWalletTap;
  final VoidCallback onAddWallet;

  const WalletGrid({
    super.key,
    required this.wallets,
    required this.balances,
    required this.onWalletTap,
    required this.onAddWallet,
  });

  @override
  Widget build(BuildContext context) {
    final tiles = <Widget>[
      for (final w in wallets)
        WalletCard(
          wallet: w.copyWith(balance: balances[w.id] ?? w.balance),
          onTap: () {
            final effective = w.copyWith(balance: balances[w.id] ?? w.balance);
            onWalletTap(effective);
          },
        ),
      _buildAddTile(),
    ];
    
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.6,
      ),
      itemCount: tiles.length,
      itemBuilder: (_, i) => tiles[i],
    );
  }

  Widget _buildAddTile() {
    return InkWell(
      onTap: onAddWallet,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey[300],
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Center(
          child: Icon(Icons.add, size: 36, color: Colors.white),
        ),
      ),
    );
  }
}