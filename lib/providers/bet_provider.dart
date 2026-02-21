import 'package:flutter/material.dart';
import '../models/bet_model.dart';
import '../models/event_model.dart';
import '../mock_data/mock_bets.dart';

class BetProvider extends ChangeNotifier {
  final List<BetModel> _bets = List.from(mockBets);

  List<BetModel> get bets => _bets;

  List<BetModel> getBetsForUser(String userId) =>
      _bets.where((b) => b.userId == userId).toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

  List<BetModel> getActiveBetsForUser(String userId) =>
      _bets.where((b) => b.userId == userId && b.status == 'active').toList();

  List<BetModel> getBetsForEvent(String eventId) =>
      _bets.where((b) => b.eventId == eventId).toList();

  int get totalBetsToday {
    final today = DateTime.now();
    return _bets.where((b) =>
        b.createdAt.day == today.day &&
        b.createdAt.month == today.month &&
        b.createdAt.year == today.year).length;
  }

  double getTotalWonForUser(String userId) {
    return _bets
        .where((b) => b.userId == userId && b.status == 'won')
        .fold(0.0, (sum, b) => sum + b.potentialWin);
  }

  double getTotalLostForUser(String userId) {
    return _bets
        .where((b) => b.userId == userId && b.status == 'lost')
        .fold(0.0, (sum, b) => sum + b.amount);
  }

  void placeBet(BetModel bet) {
    _bets.add(bet);
    notifyListeners();
  }

  void settleBetsForEvent(EventModel event) {
    if (event.winningOption == null) return;

    for (var bet in _bets) {
      if (bet.eventId == event.id && bet.status == 'active') {
        bet.status =
            bet.selectedOption == event.winningOption ? 'won' : 'lost';
      }
    }
    notifyListeners();
  }

  // Admin stats
  double get todaysRevenue {
    final today = DateTime.now();
    return _bets
        .where((b) =>
            b.createdAt.day == today.day &&
            b.createdAt.month == today.month &&
            b.createdAt.year == today.year &&
            b.status == 'lost')
        .fold(0.0, (sum, b) => sum + b.amount);
  }
}
