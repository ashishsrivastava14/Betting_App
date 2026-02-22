import '../models/payment_account_model.dart';

final List<PaymentAccountModel> mockPaymentAccounts = [
  PaymentAccountModel(
    id: 'ACC001',
    name: 'Account 1',
    type: PaymentMethodType.bank,
    isActive: true,
    bankName: 'HDFC Bank',
    accountNumber: '50100123456789',
    ifscCode: 'HDFC0001234',
    accountHolderName: 'BetZone Admin',
    createdAt: DateTime.now().subtract(const Duration(days: 30)),
  ),
  PaymentAccountModel(
    id: 'ACC002',
    name: 'Account 2',
    type: PaymentMethodType.upi,
    isActive: true,
    upiId: 'betzone@upi',
    createdAt: DateTime.now().subtract(const Duration(days: 20)),
  ),
  PaymentAccountModel(
    id: 'ACC003',
    name: 'PhonePe Account',
    type: PaymentMethodType.phonePe,
    isActive: true,
    upiId: '9999999999@ybl',
    createdAt: DateTime.now().subtract(const Duration(days: 10)),
  ),
  PaymentAccountModel(
    id: 'ACC004',
    name: 'Google Pay',
    type: PaymentMethodType.googlePay,
    isActive: false,
    upiId: 'betzone@okaxis',
    createdAt: DateTime.now().subtract(const Duration(days: 5)),
  ),
];
