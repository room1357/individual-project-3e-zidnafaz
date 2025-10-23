# Add Wallet Feature - Implementation Guide

## 📋 Overview
Fitur Add Wallet telah diimplementasikan dengan lengkap menggunakan design pattern yang konsisten dengan halaman Add Income/Expense yang sudah ada.

## 🎨 Design & Layout
- **Style**: Mengikuti design dari `add_income_page.dart` dan `add_expense_page.dart`
- **Colors**: Menggunakan `AppColors.primary` dari `app_colors.dart`
- **Layout**: Dark theme dengan cards putih dan rounded corners
- **Components**: Form fields dengan prefix icons, dropdowns, dan toggle switches

## 📝 Fields yang Diimplementasikan

### 1. **Wallet Name** *(Required)*
- Type: TextFormField
- Validation: Tidak boleh kosong
- Placeholder: "Wallet's name"
- Icon: Edit icon

### 2. **Type** *(Required)*
- Type: Dropdown
- Options:
  - General
  - Credit Card
  - Debit Card
  - E-Wallet
- Default: General
- Icon: Category icon

### 3. **Initial Amount** *(Optional)*
- Type: TextFormField (Number)
- Validation: Harus berupa angka valid
- Default: Rp 0
- Format: Currency (IDR)
- Icon: Payment icon

### 4. **Color** *(Required)*
- Type: Grid Color Picker
- Options: 12 warna pilihan
- Visual: Circular color swatches dengan checkmark saat dipilih
- Default: Blue (#3DB2FF)

### 5. **Icon** *(Required)*
- Type: Grid Icon Picker
- Options: 10 icon pilihan
- Visual: Icon dalam container dengan highlight saat dipilih
- Default: account_balance_wallet_rounded

### 6. **Currency** *(Required)*
- Type: Dropdown
- Options: IDR, USD, EUR, SGD, MYR
- Default: IDR
- Icon: Monetization icon

### 7. **Exclude** *(Toggle)*
- Type: Switch
- Description: "Ignore the balance of this wallet on the total balance"
- Default: false (OFF)
- Purpose: Wallet dengan toggle ini ON tidak akan dihitung dalam total balance

### 8. **Admin Fee** *(Toggle + Field)*
- Type: Switch + Conditional TextFormField
- Description: "Monthly fee will be automatically deducted on the 20th of each month"
- Default: false (OFF)
- Field muncul ketika toggle ON
- Validation: Required jika toggle ON
- **Note**: Warning box telah dihapus karena sudah ada keterangan di description

## 🔧 Technical Implementation

### Model Updates (`wallet_model.dart`)

```dart
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
  final WalletType type;           // ✨ NEW
  final String currency;            // ✨ NEW
  final bool isExcluded;           // ✨ NEW
  final bool hasAdminFee;          // ✨ NEW
  final double adminFee;           // ✨ NEW
  final double initialBalance;     // ✨ NEW - Stores initial balance separately
  
  // ... constructor and methods
}
```

**Important**: `initialBalance` field stores the starting balance of the wallet. This is separate from `balance` which gets recalculated based on transactions. This ensures that when `recalculateAllFromServices()` is called, the initial amount is preserved and used as the starting point for calculations.

### Service Updates (`wallet_service.dart`)

1. **Default wallets** updated dengan field baru (including `initialBalance`)
2. **getTotalBalance()** sekarang mengecualikan wallet dengan `isExcluded = true`
3. **addWallet()** method sudah support Wallet model yang baru
4. **recalculateAllFromServices()** sekarang mulai dari `initialBalance` instead of 0, lalu apply semua transaksi

### Balance Calculation Logic

```dart
// Old (INCORRECT - initial amount hilang):
totals[walletId] = 0 + income - expense + transfer

// New (CORRECT - initial amount preserved):
totals[walletId] = initialBalance + income - expense + transfer
```

### New Page (`add_wallet_page.dart`)

File: `lib/presentation/pages/add_wallet_page.dart`

**Key Features:**
- Form validation
- Color picker grid (4 columns)
- Icon picker grid (3 columns)
- Conditional rendering untuk admin fee field
- Info box dengan warning untuk admin fee
- SAVE button di AppBar
- Consistent styling dengan pages lain

## 🚀 How to Use

### From User Perspective:
1. Buka halaman **Wallet**
2. Klik tombol **"+ Add Wallet"** di WalletGrid
3. Isi form:
   - Masukkan nama wallet
   - Pilih tipe wallet
   - Tentukan initial amount (optional)
   - Pilih warna favorit
   - Pilih icon yang sesuai
   - Pilih currency
   - Toggle "Exclude" jika tidak ingin dihitung di total balance
   - Toggle "Admin Fee" jika ada biaya bulanan + isi jumlahnya
4. Klik **SAVE**
5. Wallet baru akan muncul di grid

### From Developer Perspective:

```dart
// Navigate to Add Wallet Page
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => const AddWalletPage(),
  ),
);

// Service akan otomatis handle:
// - Add wallet ke list
// - Update total balance (kecuali jika excluded)
// - Recalculate berdasarkan transactions
```

## 💡 Features Explanation

### Exclude Toggle
Berguna untuk wallet yang ingin di-track tapi tidak dihitung dalam total balance, misalnya:
- Credit card (karena ini adalah hutang)
- Investment account
- Savings yang di-freeze

### Admin Fee System
- **Automatic Deduction**: Secara otomatis akan mengurangi balance wallet setiap tanggal 20
- **Use Case**: 
  - Biaya administrasi bank
  - Monthly fee kartu kredit
  - Subscription fee
- **Warning**: User diberi peringatan jelas bahwa fee akan auto-deducted

## 🎯 Future Enhancements

1. **Admin Fee Automation**:
   - Implementasi background service/scheduler untuk auto-deduct di tanggal 20
   - History log untuk admin fee deductions

2. **Edit Wallet**:
   - Tambah page untuk edit wallet yang sudah ada
   - Support untuk delete wallet (dengan confirmation)

3. **Wallet Templates**:
   - Preset wallet templates (BCA, Mandiri, GoPay, etc.)
   - Quick add dengan pre-filled data

4. **Export/Import**:
   - Export wallet configuration
   - Import dari aplikasi lain

## 📱 Screenshots Reference

Layout mengikuti design yang Anda kirimkan dengan:
- Dark background (#121212)
- White cards dengan shadow
- SAVE button di top right (AppBar)
- Sections yang terorganisir dengan titles
- Form fields dengan consistent styling
- Toggle switches aligned ke kanan
- Color grid: 4x3
- Icon grid: 3x4

## ✅ Checklist

- [x] Update Wallet model dengan field baru
- [x] Add `initialBalance` field untuk preserve initial amount
- [x] Update default wallets di WalletService
- [x] Create AddWalletPage dengan complete form
- [x] Implement color picker (12 colors)
- [x] Implement icon picker (10 icons)
- [x] Add validation for all required fields
- [x] Implement exclude toggle
- [x] Implement admin fee toggle + conditional field
- [x] Remove redundant warning box (info already in description)
- [x] Update getTotalBalance untuk respect isExcluded flag
- [x] Update recalculateAllFromServices untuk preserve initialBalance
- [x] Fix initial amount not persisting issue
- [x] Integrate dengan WalletPage
- [x] Consistent styling dengan add_income/expense pages
- [x] Form validation & error messages
- [x] Success notification setelah save

## 🎨 Color Palette Used

```dart
Primary Colors:
- #3DB2FF (Blue)
- #FFB830 (Orange)
- #6BCB77 (Green)
- #FF6B6B (Red)
- #9B59B6 (Purple)
- #00C9A7 (Teal)
- #FF6348 (Coral)
- #4ECDC4 (Turquoise)
- BlueGrey
- Teal
- Orange
- Indigo
```

## 🔗 Related Files

- `lib/data/models/wallet_model.dart` - Model definition
- `lib/services/wallet_service.dart` - Business logic
- `lib/presentation/pages/add_wallet_page.dart` - UI implementation
- `lib/presentation/pages/wallet_page.dart` - Integration point
- `lib/core/constants/app_colors.dart` - Color constants

---

**Status**: ✅ Fully Implemented & Ready to Use
**Version**: 1.0.0
**Last Updated**: October 23, 2025
