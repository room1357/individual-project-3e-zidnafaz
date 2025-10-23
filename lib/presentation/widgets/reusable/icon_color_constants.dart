import 'package:flutter/material.dart';

/// Reusable constants for icons and colors used across the app
/// Can be used for categories, wallets, and other features
class IconColorConstants {
  // Available icons for various features (categories, wallets, etc.)
  static final List<IconData> availableIcons = [
    // General
    Icons.category,
    Icons.label,
    Icons.bookmark,
    Icons.star,
    
    // Shopping & Food
    Icons.shopping_cart,
    Icons.shopping_bag,
    Icons.restaurant,
    Icons.local_cafe,
    Icons.fastfood,
    Icons.local_pizza,
    Icons.local_bar,
    
    // Transportation
    Icons.directions_car,
    Icons.local_gas_station,
    Icons.directions_bus,
    Icons.train,
    Icons.flight,
    Icons.two_wheeler,
    
    // Home & Utilities
    Icons.home,
    Icons.phone,
    Icons.wifi,
    Icons.electric_bolt,
    Icons.water_drop,
    Icons.lightbulb,
    
    // Education & Work
    Icons.school,
    Icons.work,
    Icons.business,
    Icons.laptop,
    Icons.book,
    
    // Health & Fitness
    Icons.medical_services,
    Icons.fitness_center,
    Icons.spa,
    Icons.local_hospital,
    
    // Entertainment
    Icons.movie,
    Icons.music_note,
    Icons.sports_esports,
    Icons.sports_soccer,
    Icons.theater_comedy,
    Icons.videocam,
    
    // Gifts & Personal
    Icons.card_giftcard,
    Icons.favorite,
    Icons.pets,
    Icons.child_care,
    Icons.face,
    
    // Finance & Money
    Icons.account_balance_wallet_rounded,
    Icons.attach_money_rounded,
    Icons.credit_card,
    Icons.account_balance,
    Icons.wallet,
    Icons.payment,
    Icons.savings,
    Icons.monetization_on,
    Icons.currency_exchange,
    Icons.payments_outlined,
    Icons.trending_up,
    Icons.trending_down,
    Icons.receipt_long,
  ];

  // Available colors for various features
  static final List<Color> availableColors = [
    // Red tones
    Colors.red,
    const Color(0xFFFF6B6B),
    const Color(0xFFFF6348),
    
    // Pink tones
    Colors.pink,
    const Color(0xFFFF69B4),
    
    // Purple tones
    Colors.purple,
    Colors.deepPurple,
    const Color(0xFF9B59B6),
    
    // Indigo & Blue tones
    Colors.indigo,
    Colors.blue,
    const Color(0xFF3DB2FF),
    Colors.lightBlue,
    Colors.cyan,
    const Color(0xFF4ECDC4),
    
    // Teal & Green tones
    Colors.teal,
    Colors.green,
    const Color(0xFF6BCB77),
    const Color(0xFF00C9A7),
    Colors.lightGreen,
    Colors.lime,
    
    // Yellow & Orange tones
    Colors.yellow,
    Colors.amber,
    const Color(0xFFFFB830),
    Colors.orange,
    Colors.deepOrange,
    
    // Neutral tones
    Colors.brown,
    Colors.grey,
    Colors.blueGrey,
  ];

  // Get icon subset for specific use case
  static List<IconData> getIconsForCategory() {
    // Return icons suitable for categories
    return availableIcons;
  }

  static List<IconData> getIconsForWallet() {
    // Return icons suitable for wallets (finance-related)
    return [
      Icons.account_balance_wallet_rounded,
      Icons.attach_money_rounded,
      Icons.credit_card,
      Icons.account_balance,
      Icons.wallet,
      Icons.payment,
      Icons.savings,
      Icons.monetization_on,
      Icons.currency_exchange,
      Icons.payments_outlined,
      Icons.shopping_bag,
      Icons.business,
      Icons.work,
      Icons.receipt_long,
    ];
  }

  // Get color subset for specific use case (if needed)
  static List<Color> getColorsForCategory() {
    return availableColors;
  }

  static List<Color> getColorsForWallet() {
    // Return colors suitable for wallets
    return [
      const Color(0xFF3DB2FF),
      const Color(0xFFFFB830),
      const Color(0xFF6BCB77),
      const Color(0xFFFF6B6B),
      const Color(0xFF9B59B6),
      const Color(0xFF00C9A7),
      const Color(0xFFFF6348),
      const Color(0xFF4ECDC4),
      Colors.blueGrey,
      Colors.teal,
      Colors.orange,
      Colors.indigo,
      Colors.pink,
      Colors.deepPurple,
      Colors.cyan,
      Colors.amber,
    ];
  }
}
