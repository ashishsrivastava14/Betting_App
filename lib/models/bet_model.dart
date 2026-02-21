class BetModel {
  final String id;
  final String userId;
  final String eventId;
  final String selectedOption;
  final double amount;
  final double multiplier;
  final double potentialWin;
  String status; // 'active' | 'won' | 'lost'
  final DateTime createdAt;

  BetModel({
    required this.id,
    required this.userId,
    required this.eventId,
    required this.selectedOption,
    required this.amount,
    required this.multiplier,
    double? potentialWin,
    this.status = 'active',
    required this.createdAt,
  }) : potentialWin = potentialWin ?? (amount * multiplier);
}
