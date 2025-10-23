import '../data/models/transfer_model.dart';

class TransferService {
  static final List<Transfer> _transfers = [];
  
  // Get all transfers
  static List<Transfer> getAllTransfers() => List.from(_transfers);
  
  // Add new transfer
  static void addTransfer(Transfer transfer) {
    _transfers.add(transfer);
  }
  
  // Update transfer
  static void updateTransfer(String id, Transfer updatedTransfer) {
    final index = _transfers.indexWhere((transfer) => transfer.id == id);
    if (index != -1) {
      _transfers[index] = updatedTransfer;
    }
  }
  
  // Delete transfer
  static void deleteTransfer(String id) {
    _transfers.removeWhere((transfer) => transfer.id == id);
  }
  
  // Get transfer by ID
  static Transfer? getTransferById(String id) {
    try {
      return _transfers.firstWhere((transfer) => transfer.id == id);
    } catch (e) {
      return null;
    }
  }
  
  // Get transfers by from wallet
  static List<Transfer> getTransfersByFromWallet(String walletId) {
    return _transfers.where((transfer) => 
      transfer.fromWalletId == walletId
    ).toList();
  }
  
  // Get transfers by to wallet
  static List<Transfer> getTransfersByToWallet(String walletId) {
    return _transfers.where((transfer) => 
      transfer.toWalletId == walletId
    ).toList();
  }
  
  // Get all transfers involving a specific wallet
  static List<Transfer> getTransfersByWallet(String walletId) {
    return _transfers.where((transfer) => 
      transfer.fromWalletId == walletId || transfer.toWalletId == walletId
    ).toList();
  }
  
  // Get transfers by month
  static List<Transfer> getTransfersByMonth(int month, int year) {
    return _transfers.where((transfer) => 
      transfer.date.month == month && transfer.date.year == year
    ).toList();
  }
  
  // Get total transfer amount (outgoing from a wallet)
  static double getTotalOutgoingFromWallet(String walletId) {
    return _transfers
        .where((transfer) => transfer.fromWalletId == walletId)
        .fold(0.0, (sum, transfer) => sum + transfer.amount + transfer.fee);
  }
  
  // Get total transfer amount (incoming to a wallet)
  static double getTotalIncomingToWallet(String walletId) {
    return _transfers
        .where((transfer) => transfer.toWalletId == walletId)
        .fold(0.0, (sum, transfer) => sum + transfer.amount);
  }
  
  // Get total fees paid
  static double getTotalFees() {
    return _transfers.fold(0.0, (sum, transfer) => sum + transfer.fee);
  }
  
  // Search transfers
  static List<Transfer> searchTransfers(String keyword) {
    String lowerKeyword = keyword.toLowerCase();
    return _transfers.where((transfer) =>
      transfer.description.toLowerCase().contains(lowerKeyword) ||
      transfer.memo.toLowerCase().contains(lowerKeyword)
    ).toList();
  }
  
  // Get transfers with fees
  static List<Transfer> getTransfersWithFees() {
    return _transfers.where((transfer) => transfer.hasFee && transfer.fee > 0).toList();
  }
}