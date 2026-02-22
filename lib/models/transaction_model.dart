class TransactionModel {
  final String id;
  final String userId;
  final String type; // 'deposit' | 'withdrawal' | 'bet_debit' | 'win_credit'
  final double amount;
  String status; // 'pending' | 'approved' | 'rejected' | 'completed'
  final DateTime createdAt;
  String notes;

  // --- Deposit fields ---
  /// ID of the admin-configured payment account the user paid to.
  String? paymentAccountId;
  /// Human-readable name of that account (e.g. "Account 1 – Bank Transfer").
  String? paymentAccountName;
  /// File path of the screenshot the user uploaded as payment proof.
  String? depositScreenshotPath;

  // --- Withdrawal fields ---
  /// User's payout details – e.g. "UPI: rahul@upi" or "HDFC, 1234, HDFC001".
  String? withdrawalPaymentDetails;
  /// File path of the screenshot admin uploads after sending the payment.
  String? withdrawalScreenshotPath;

  // --- Admin action ---
  String? rejectionReason;

  TransactionModel({
    required this.id,
    required this.userId,
    required this.type,
    required this.amount,
    this.status = 'pending',
    required this.createdAt,
    this.notes = '',
    this.paymentAccountId,
    this.paymentAccountName,
    this.depositScreenshotPath,
    this.withdrawalPaymentDetails,
    this.withdrawalScreenshotPath,
    this.rejectionReason,
  });
}
