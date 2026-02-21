import 'package:flutter/material.dart';
import '../models/notification_model.dart';
import '../theme/app_theme.dart';

class NotificationProvider extends ChangeNotifier {
  final List<NotificationModel> _notifications = [
    NotificationModel(
      id: 'NTF001',
      title: 'New Match Added 🏏',
      body: 'IND vs AUS – 3rd ODI is now open for betting. Place your bets before deadline!',
      type: 'event',
      icon: Icons.sports_cricket,
      iconColor: AppColors.accent,
      createdAt: DateTime.now().subtract(const Duration(minutes: 5)),
      isRead: false,
    ),
    NotificationModel(
      id: 'NTF002',
      title: 'LIVE NOW 🔴',
      body: 'RCB vs KKR – IPL Match 42 has gone live. Betting closes in 30 minutes!',
      type: 'event',
      icon: Icons.live_tv_outlined,
      iconColor: AppColors.red,
      createdAt: DateTime.now().subtract(const Duration(minutes: 32)),
      isRead: false,
    ),
    NotificationModel(
      id: 'NTF003',
      title: 'Bet Result 🏆',
      body: 'Congratulations! Your bet on "India" in IND vs SA – 1st T20 won. ₹1,925 credited!',
      type: 'bet',
      icon: Icons.emoji_events_outlined,
      iconColor: AppColors.gold,
      createdAt: DateTime.now().subtract(const Duration(hours: 2)),
      isRead: false,
    ),
    NotificationModel(
      id: 'NTF004',
      title: 'Deposit Approved ✅',
      body: 'Your deposit of ₹5,000 has been approved and added to your wallet.',
      type: 'wallet',
      icon: Icons.account_balance_wallet_outlined,
      iconColor: AppColors.green,
      createdAt: DateTime.now().subtract(const Duration(hours: 5)),
      isRead: true,
    ),
    NotificationModel(
      id: 'NTF005',
      title: 'Bet Settled',
      body: 'Your bet on "CSK" in CSK vs SRH – IPL Match 38 has been settled as lost.',
      type: 'bet',
      icon: Icons.sports_score_outlined,
      iconColor: AppColors.red,
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
      isRead: true,
    ),
    NotificationModel(
      id: 'NTF006',
      title: 'Welcome to BetZone! 🎉',
      body: 'Your account is ready. Explore live matches and place your first bet today!',
      type: 'system',
      icon: Icons.celebration_outlined,
      iconColor: AppColors.purple,
      createdAt: DateTime.now().subtract(const Duration(days: 3)),
      isRead: true,
    ),
  ];

  List<NotificationModel> get notifications => _notifications;

  int get unreadCount => _notifications.where((n) => !n.isRead).length;

  void markAsRead(String id) {
    final idx = _notifications.indexWhere((n) => n.id == id);
    if (idx != -1 && !_notifications[idx].isRead) {
      _notifications[idx].isRead = true;
      notifyListeners();
    }
  }

  void markAllAsRead() {
    bool changed = false;
    for (final n in _notifications) {
      if (!n.isRead) {
        n.isRead = true;
        changed = true;
      }
    }
    if (changed) notifyListeners();
  }

  void addNotification(NotificationModel notification) {
    _notifications.insert(0, notification);
    notifyListeners();
  }
}
