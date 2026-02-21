import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../mock_data/mock_users.dart';
import '../../providers/auth_provider.dart';
import '../../providers/bet_provider.dart';
import '../../providers/event_provider.dart';
import '../../providers/wallet_provider.dart';
import '../../theme/app_theme.dart';
import '../../utils/app_utils.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final eventProvider = context.watch<EventProvider>();
    final betProvider = context.watch<BetProvider>();
    final walletProvider = context.watch<WalletProvider>();

    final totalUsers = mockUsers.where((u) => u.role == 'user').length;
    final totalBalance = walletProvider.getTotalWalletBalance();
    final totalBetsToday = betProvider.totalBetsToday;
    final activeEvents =
        eventProvider.liveEvents.length + eventProvider.upcomingEvents.length;
    final todaysRevenue = betProvider.todaysRevenue;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/bg-images.png'),
            fit: BoxFit.cover,
            opacity: 0.15,
          ),
        ),
        child: SafeArea(
          child: RefreshIndicator(
            color: AppColors.accent,
            backgroundColor: AppColors.card,
            onRefresh: () async {
              await Future.delayed(const Duration(seconds: 1));
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Row(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Admin Panel',
                            style: GoogleFonts.poppins(
                              fontSize: 22,
                              fontWeight: FontWeight.w700,
                              color: AppColors.white,
                            ),
                          ),
                          Text(
                            'Hi, ${auth.currentUser?.name ?? "Admin"}',
                            style: GoogleFonts.poppins(
                              fontSize: 13,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                      const Spacer(),
                      GestureDetector(
                        onTap: () {
                          auth.logout();
                          context.go('/login');
                        },
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.red.withValues(alpha: 0.12),
                            border: Border.all(
                              color: AppColors.red.withValues(alpha: 0.3),
                            ),
                          ),
                          child: const Icon(
                            Icons.logout,
                            color: AppColors.red,
                            size: 18,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Stats grid
                  GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    mainAxisSpacing: 10,
                    crossAxisSpacing: 10,
                    childAspectRatio: 1.6,
                    children: [
                      _statCard(
                        Icons.people,
                        'Total Users',
                        '$totalUsers',
                        AppColors.blue,
                      ),
                      _statCard(
                        Icons.account_balance_wallet,
                        'Total Balance',
                        AppUtils.formatCurrency(totalBalance),
                        AppColors.green,
                      ),
                      _statCard(
                        Icons.sports_cricket,
                        'Bets Today',
                        '$totalBetsToday',
                        AppColors.orange,
                      ),
                      _statCard(
                        Icons.event,
                        'Active Events',
                        '$activeEvents',
                        AppColors.purple,
                      ),
                      _statCard(
                        Icons.currency_rupee,
                        "Today's Revenue",
                        AppUtils.formatCurrency(todaysRevenue),
                        AppColors.accent,
                      ),
                      _statCard(
                        Icons.pending_actions,
                        'Pending Txns',
                        '${walletProvider.pendingTransactions.length}',
                        AppColors.red,
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // Quick actions
                  _sectionHeader(Icons.bolt, 'Quick Actions'),
                  const SizedBox(height: 10),

                  Row(
                    children: [
                      _actionButton(
                        Icons.add_box_rounded,
                        'Create\nEvent',
                        () => context.push('/admin/events/create'),
                      ),
                      const SizedBox(width: 10),
                      _actionButton(
                        Icons.gavel_rounded,
                        'Declare\nResult',
                        () => context.push('/admin/events/declare'),
                      ),
                      const SizedBox(width: 10),
                      _actionButton(
                        Icons.people_rounded,
                        'Manage\nUsers',
                        () => context.go('/admin/users'),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // Recent Activity
                  _sectionHeader(Icons.history, 'Recent Activity'),
                  const SizedBox(height: 10),

                  _activityItem(
                    Icons.person_add,
                    'New user registered',
                    'Rahul Sharma',
                    '1h ago',
                    AppColors.blue,
                  ),
                  _activityItem(
                    Icons.sports_cricket,
                    'Bet placed',
                    'Rs500 on RCB vs KKR',
                    '2h ago',
                    AppColors.orange,
                  ),
                  _activityItem(
                    Icons.emoji_events,
                    'Result declared',
                    'IND vs ENG - India won',
                    '1d ago',
                    AppColors.accent,
                  ),
                  _activityItem(
                    Icons.arrow_downward,
                    'Deposit approved',
                    'Rs5,000 for Priya Patel',
                    '2d ago',
                    AppColors.green,
                  ),
                  _activityItem(
                    Icons.arrow_upward,
                    'Withdrawal request',
                    'Rs2,000 from Rahul Sharma',
                    '3h ago',
                    AppColors.red,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _sectionHeader(IconData icon, String title) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.accent),
        const SizedBox(width: 8),
        Text(
          title,
          style: GoogleFonts.poppins(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: AppColors.white,
          ),
        ),
      ],
    );
  }

  Widget _statCard(IconData icon, String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const Spacer(),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: AppColors.white,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 10,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _actionButton(IconData icon, String label, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: AppColors.accent.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.accent.withValues(alpha: 0.25)),
          ),
          child: Column(
            children: [
              Icon(icon, color: AppColors.accent, size: 24),
              const SizedBox(height: 6),
              Text(
                label,
                style: GoogleFonts.poppins(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: AppColors.accent,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _activityItem(
    IconData icon,
    String title,
    String subtitle,
    String time,
    Color color,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 16),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.white,
                  ),
                ),
                Text(
                  subtitle,
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Text(
            time,
            style: GoogleFonts.poppins(
              fontSize: 10,
              color: AppColors.textMuted,
            ),
          ),
        ],
      ),
    );
  }
}
