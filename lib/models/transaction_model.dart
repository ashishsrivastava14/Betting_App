class TransactionModel {
  final String id;
  final String userId;
  final String type; // 'deposit' | 'withdrawal' | 'bet_debit' | 'win_credit'
  final double amount;
  String status; // 'pending' | 'approved' | 'completed'
  final DateTime createdAt;
  final String notes;

  TransactionModel({
    required this.id,
    required this.userId,
    required this.type,
    required this.amount,
    this.status = 'pending',
    required this.createdAt,
    this.notes = '',
  });
}
