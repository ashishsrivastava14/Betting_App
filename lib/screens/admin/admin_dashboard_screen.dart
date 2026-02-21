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
    final activeEvents = eventProvider.liveEvents.length +
        eventProvider.upcomingEvents.length;
    final todaysRevenue = betProvider.todaysRevenue;

    return Scaffold(
      body: SafeArea(
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
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                            color: AppColors.white,
                          ),
                        ),
                        Text(
                          'Hi, ${auth.currentUser?.name ?? "Admin"} 👋',
                          style: GoogleFonts.poppins(
                            fontSize: 13, color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.logout, color: AppColors.red),
                      onPressed: () {
                        auth.logout();
                        context.go('/login');
                      },
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // Stats grid
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 1.6,
                  children: [
                    _statCard(
                      icon: Icons.people,
                      label: 'Total Users',
                      value: '$totalUsers',
                      color: AppColors.accent,
                    ),
                    _statCard(
                      icon: Icons.account_balance_wallet,
                      label: 'Total Balance',
                      value: AppUtils.formatCurrency(totalBalance),
                      color: AppColors.green,
                    ),
                    _statCard(
                      icon: Icons.sports_cricket,
                      label: 'Bets Today',
                      value: '$totalBetsToday',
                      color: AppColors.orange,
                    ),
                    _statCard(
                      icon: Icons.event,
                      label: 'Active Events',
                      value: '$activeEvents',
                      color: Colors.lightBlueAccent,
                    ),
                    _statCard(
                      icon: Icons.currency_rupee,
                      label: "Today's Revenue",
                      value: AppUtils.formatCurrency(todaysRevenue),
                      color: AppColors.gold,
                    ),
                    _statCard(
                      icon: Icons.pending_actions,
                      label: 'Pending Txns',
                      value:
                          '${walletProvider.pendingTransactions.length}',
                      color: AppColors.red,
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // Quick actions
                Text(
                  'Quick Actions',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.white,
                  ),
                ),
                const SizedBox(height: 12),

                Row(
                  children: [
                    _actionButton(
                      icon: Icons.add_box,
                      label: 'Create Event',
                      onTap: () => context.push('/admin/events/create'),
                    ),
                    const SizedBox(width: 10),
                    _actionButton(
                      icon: Icons.gavel,
                      label: 'Declare Result',
                      onTap: () => context.push('/admin/events/declare'),
                    ),
                    const SizedBox(width: 10),
                    _actionButton(
                      icon: Icons.people,
                      label: 'Manage Users',
                      onTap: () => context.go('/admin/users'),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // Recent Activity
                Text(
                  'Recent Activity',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.white,
                  ),
                ),
                const SizedBox(height: 12),

                _activityItem(Icons.person_add, 'New user registered',
                    'Rahul Sharma', '1h ago', AppColors.accent),
                _activityItem(Icons.sports_cricket, 'Bet placed',
                    '₹500 on RCB vs KKR', '2h ago', AppColors.orange),
                _activityItem(Icons.emoji_events, 'Result declared',
                    'IND vs ENG - India won', '1d ago', AppColors.gold),
                _activityItem(Icons.arrow_downward, 'Deposit approved',
                    '₹5,000 for Priya Patel', '2d ago', AppColors.green),
                _activityItem(Icons.arrow_upward, 'Withdrawal request',
                    '₹2,000 from Rahul Sharma', '3h ago', AppColors.red),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _statCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(icon, color: color, size: 24),
          const Spacer(),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.white,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 11,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _actionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: AppColors.accent.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
                color: AppColors.accent.withValues(alpha: 0.3)),
          ),
          child: Column(
            children: [
              Icon(icon, color: AppColors.accent, size: 24),
              const SizedBox(height: 6),
              Text(
                label,
                style: GoogleFonts.poppins(
                  fontSize: 11,
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
      IconData icon, String title, String subtitle, String time, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 13,
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
              color: AppColors.grey,
            ),
          ),
        ],
      ),
    );
  }
}
