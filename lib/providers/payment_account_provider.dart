import 'package:flutter/material.dart';
import '../models/payment_account_model.dart';
import '../mock_data/mock_payment_accounts.dart';

class PaymentAccountProvider extends ChangeNotifier {
  final List<PaymentAccountModel> _accounts = List.from(mockPaymentAccounts);

  List<PaymentAccountModel> get accounts => List.unmodifiable(_accounts);

  List<PaymentAccountModel> get activeAccounts =>
      _accounts.where((a) => a.isActive).toList();

  void addAccount(PaymentAccountModel account) {
    _accounts.add(account);
    notifyListeners();
  }

  void updateAccount(PaymentAccountModel updated) {
    final i = _accounts.indexWhere((a) => a.id == updated.id);
    if (i >= 0) {
      _accounts[i] = updated;
      notifyListeners();
    }
  }

  void removeAccount(String id) {
    _accounts.removeWhere((a) => a.id == id);
    notifyListeners();
  }

  void toggleActive(String id) {
    final a = _accounts.firstWhere((acc) => acc.id == id);
    a.isActive = !a.isActive;
    notifyListeners();
  }

  String _nextId() =>
      'ACC${DateTime.now().millisecondsSinceEpoch}';

  PaymentAccountModel buildNew({
    required String name,
    required PaymentMethodType type,
    String? bankName,
    String? accountNumber,
    String? ifscCode,
    String? accountHolderName,
    String? upiId,
    String? qrCodePath,
  }) {
    return PaymentAccountModel(
      id: _nextId(),
      name: name,
      type: type,
      isActive: true,
      bankName: bankName,
      accountNumber: accountNumber,
      ifscCode: ifscCode,
      accountHolderName: accountHolderName,
      upiId: upiId,
      qrCodePath: qrCodePath,
      createdAt: DateTime.now(),
    );
  }
}
