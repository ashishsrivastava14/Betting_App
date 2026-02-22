import 'package:flutter/material.dart';
import '../models/transaction_model.dart';
import '../models/user_model.dart';
import '../mock_data/mock_transactions.dart';
import '../mock_data/mock_users.dart';

class WalletProvider extends ChangeNotifier {
  final List<TransactionModel> _transactions = List.from(mockTransactions);

  List<TransactionModel> get transactions => _transactions;

  List<TransactionModel> getTransactionsForUser(String userId) =>
      _transactions.where((t) => t.userId == userId).toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

  List<TransactionModel> get pendingTransactions =>
      _transactions.where((t) => t.status == 'pending').toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

  double getTotalWalletBalance() {
    return mockUsers.fold(0.0, (sum, u) => sum + u.walletBalance);
  }

  void addTransaction(TransactionModel txn) {
    _transactions.add(txn);
    notifyListeners();
  }

  void deductBalance(UserModel user, double amount) {
    user.walletBalance -= amount;
    notifyListeners();
  }

  void creditBalance(UserModel user, double amount) {
    user.walletBalance += amount;
    notifyListeners();
  }

  /// Approve a deposit: credit user wallet.
  void approveDeposit(String txnId) {
    final txn = _transactions.firstWhere((t) => t.id == txnId);
    txn.status = 'approved';
    final user = mockUsers.firstWhere((u) => u.id == txn.userId);
    user.walletBalance += txn.amount;
    notifyListeners();
  }

  /// Approve a withdrawal: debit user wallet and store admin-uploaded screenshot.
  void approveWithdrawal(String txnId, {String? screenshotPath}) {
    final txn = _transactions.firstWhere((t) => t.id == txnId);
    txn.status = 'approved';
    if (screenshotPath != null) txn.withdrawalScreenshotPath = screenshotPath;
    final user = mockUsers.firstWhere((u) => u.id == txn.userId);
    user.walletBalance -= txn.amount;
    notifyListeners();
  }

  /// Generic approve (delegates to type-specific logic).
  void approveTransaction(String txnId) {
    final txn = _transactions.firstWhere((t) => t.id == txnId);
    if (txn.type == 'deposit') {
      approveDeposit(txnId);
    } else {
      approveWithdrawal(txnId);
    }
  }

  void rejectTransaction(String txnId, {String? reason}) {
    final txn = _transactions.firstWhere((t) => t.id == txnId);
    txn.status = 'rejected';
    txn.rejectionReason = reason;
    notifyListeners();
  }

  void manualCredit(String userId, double amount, String notes) {
    final user = mockUsers.firstWhere((u) => u.id == userId);
    user.walletBalance += amount;

    _transactions.add(TransactionModel(
      id: 'TXN${DateTime.now().millisecondsSinceEpoch}',
      userId: userId,
      type: 'deposit',
      amount: amount,
      status: 'completed',
      createdAt: DateTime.now(),
      notes: notes,
    ));

    notifyListeners();
  }

  void manualDebit(String userId, double amount, String notes) {
    final user = mockUsers.firstWhere((u) => u.id == userId);
    user.walletBalance -= amount;

    _transactions.add(TransactionModel(
      id: 'TXN${DateTime.now().millisecondsSinceEpoch}',
      userId: userId,
      type: 'withdrawal',
      amount: amount,
      status: 'completed',
      createdAt: DateTime.now(),
      notes: notes,
    ));

    notifyListeners();
  }
}
