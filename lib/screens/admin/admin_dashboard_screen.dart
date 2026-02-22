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
    final pendingTxns = walletProvider.pendingTransactions.length;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/bg-images.png'),
            fit: BoxFit.cover,
            opacity: 0.07,
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Hero Header ──────────────────────────────────────────
                  _HeroHeader(auth: auth),

                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // ── Stats Grid ──────────────────────────────────────
                        _sectionHeader(
                          context,
                          Icons.bar_chart_rounded,
                          'Overview',
                          null,
                        ),
                        const SizedBox(height: 12),

                        GridView.count(
                          crossAxisCount: 2,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          mainAxisSpacing: 12,
                          crossAxisSpacing: 12,
                          childAspectRatio: 1.55,
                          children: [
                            _StatCard(
                              icon: Icons.people_alt_rounded,
                              label: 'Total Users',
                              value: '$totalUsers',
                              color: AppColors.blue,
                              trend: '+3 this week',
                              trendUp: true,
                            ),
                            _StatCard(
                              icon: Icons.account_balance_wallet_rounded,
                              label: 'Total Balance',
                              value: AppUtils.formatCurrency(totalBalance),
                              color: AppColors.green,
                              trend: 'across all users',
                              trendUp: null,
                            ),
                            _StatCard(
                              icon: Icons.sports_cricket_rounded,
                              label: 'Bets Today',
                              value: '$totalBetsToday',
                              color: AppColors.orange,
                              trend: 'placed today',
                              trendUp: null,
                            ),
                            _StatCard(
                              icon: Icons.event_available_rounded,
                              label: 'Active Events',
                              value: '$activeEvents',
                              color: AppColors.purple,
                              trend: 'live & upcoming',
                              trendUp: null,
                            ),
                            _StatCard(
                              icon: Icons.trending_up_rounded,
                              label: "Today's Revenue",
                              value: AppUtils.formatCurrency(todaysRevenue),
                              color: AppColors.accent,
                              trend: 'earned today',
                              trendUp: true,
                            ),
                            _StatCard(
                              icon: Icons.pending_actions_rounded,
                              label: 'Pending Txns',
                              value: '$pendingTxns',
                              color: pendingTxns > 0
                                  ? AppColors.red
                                  : AppColors.green,
                              trend: pendingTxns > 0
                                  ? 'needs attention'
                                  : 'all clear',
                              trendUp: pendingTxns == 0 ? true : false,
                            ),
                          ],
                        ),

                        const SizedBox(height: 24),

                        // ── Quick Actions ───────────────────────────────────
                        _sectionHeader(
                          context,
                          Icons.bolt_rounded,
                          'Quick Actions',
                          null,
                        ),
                        const SizedBox(height: 12),

                        Row(
                          children: [
                            _ActionTile(
                              icon: Icons.add_circle_rounded,
                              label: 'Create Event',
                              color: AppColors.blue,
                              onTap: () => context.push('/admin/events/create'),
                            ),
                            const SizedBox(width: 10),
                            _ActionTile(
                              icon: Icons.gavel_rounded,
                              label: 'Declare Result',
                              color: AppColors.accent,
                              onTap: () =>
                                  context.push('/admin/events/declare'),
                            ),
                            const SizedBox(width: 10),
                            _ActionTile(
                              icon: Icons.manage_accounts_rounded,
                              label: 'Manage Users',
                              color: AppColors.purple,
                              onTap: () => context.go('/admin/users'),
                            ),
                          ],
                        ),

                        const SizedBox(height: 24),

                        // ── Recent Activity ─────────────────────────────────
                        _sectionHeader(
                          context,
                          Icons.history_rounded,
                          'Recent Activity',
                          'View All',
                          onAction: () => context.go('/admin/reports'),
                        ),
                        const SizedBox(height: 12),

                        _ActivityFeed(),

                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _sectionHeader(
    BuildContext context,
    IconData icon,
    String title,
    String? actionLabel, {
    VoidCallback? onAction,
  }) {
    return Row(
      children: [
        Container(
          width: 3,
          height: 18,
          decoration: BoxDecoration(
            color: AppColors.accent,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 10),
        Icon(icon, size: 17, color: AppColors.accent),
        const SizedBox(width: 7),
        Text(
          title,
          style: GoogleFonts.poppins(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: AppColors.white,
            letterSpacing: 0.2,
          ),
        ),
        if (actionLabel != null) ...[
          const Spacer(),
          GestureDetector(
            onTap: onAction,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  actionLabel,
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppColors.accent,
                  ),
                ),
                const SizedBox(width: 2),
                const Icon(
                  Icons.chevron_right_rounded,
                  size: 16,
                  color: AppColors.accent,
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

// ── Hero Header ──────────────────────────────────────────────────────────────
class _HeroHeader extends StatelessWidget {
  final AuthProvider auth;
  const _HeroHeader({required this.auth});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primary, const Color(0xFF0D1B30)],
        ),
        border: const Border(
          bottom: BorderSide(color: AppColors.cardBorder, width: 1),
        ),
      ),
      child: Stack(
        children: [
          // Subtle decorative circle
          Positioned(
            top: -20,
            right: -20,
            child: Container(
              width: 130,
              height: 130,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.accent.withValues(alpha: 0.05),
              ),
            ),
          ),
          Positioned(
            bottom: -30,
            right: 60,
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.blue.withValues(alpha: 0.06),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Avatar
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                      colors: [AppColors.accent, AppColors.accentDark],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.accent.withValues(alpha: 0.35),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      (auth.currentUser?.name ?? 'A')
                          .substring(0, 1)
                          .toUpperCase(),
                      style: GoogleFonts.poppins(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: AppColors.background,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                // Text
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            'Admin Panel',
                            style: GoogleFonts.poppins(
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                              color: AppColors.white,
                              height: 1.1,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 7,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.accent.withValues(alpha: 0.18),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: AppColors.accent.withValues(alpha: 0.4),
                                width: 1,
                              ),
                            ),
                            child: Text(
                              'SUPER',
                              style: GoogleFonts.poppins(
                                fontSize: 8,
                                fontWeight: FontWeight.w700,
                                color: AppColors.accent,
                                letterSpacing: 1.2,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 3),
                      Text(
                        'Welcome back, ${auth.currentUser?.name ?? "Admin"}',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                          height: 1.3,
                        ),
                      ),
                    ],
                  ),
                ),
                // Logout button
                GestureDetector(
                  onTap: () {
                    auth.logout();
                    context.go('/login');
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 11,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.red.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: AppColors.red.withValues(alpha: 0.28),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.logout_rounded,
                          color: AppColors.red,
                          size: 14,
                        ),
                        const SizedBox(width: 5),
                        Text(
                          'Logout',
                          style: GoogleFonts.poppins(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: AppColors.red,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Stat Card ────────────────────────────────────────────────────────────────
class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  final String trend;
  final bool? trendUp; // true=up, false=down, null=neutral

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    required this.trend,
    this.trendUp,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.22), width: 1),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 18),
              ),
              if (trendUp != null)
                Icon(
                  trendUp!
                      ? Icons.arrow_upward_rounded
                      : Icons.arrow_downward_rounded,
                  color: trendUp! ? AppColors.green : AppColors.red,
                  size: 14,
                ),
            ],
          ),
          const Spacer(),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: AppColors.white,
              height: 1.1,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            trend,
            style: GoogleFonts.poppins(
              fontSize: 9,
              color: trendUp == true
                  ? AppColors.green.withValues(alpha: 0.85)
                  : AppColors.textMuted,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

// ── Action Tile ──────────────────────────────────────────────────────────────
class _ActionTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ActionTile({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: color.withValues(alpha: 0.25), width: 1),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(9),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 22),
              ),
              const SizedBox(height: 8),
              Text(
                label,
                style: GoogleFonts.poppins(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: AppColors.white,
                  height: 1.3,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Activity Feed ─────────────────────────────────────────────────────────────
class _ActivityFeed extends StatelessWidget {
  const _ActivityFeed();

  static const _items = [
    _ActivityData(
      icon: Icons.person_add_rounded,
      title: 'New user registered',
      subtitle: 'Rahul Sharma joined',
      time: '1h ago',
      color: AppColors.blue,
    ),
    _ActivityData(
      icon: Icons.sports_cricket_rounded,
      title: 'Bet placed',
      subtitle: '₹500 on RCB vs KKR',
      time: '2h ago',
      color: AppColors.orange,
    ),
    _ActivityData(
      icon: Icons.emoji_events_rounded,
      title: 'Result declared',
      subtitle: 'IND vs ENG — India won',
      time: '1d ago',
      color: AppColors.accent,
    ),
    _ActivityData(
      icon: Icons.south_east_rounded,
      title: 'Deposit approved',
      subtitle: '₹5,000 for Priya Patel',
      time: '2d ago',
      color: AppColors.green,
    ),
    _ActivityData(
      icon: Icons.north_east_rounded,
      title: 'Withdrawal request',
      subtitle: '₹2,000 from Rahul Sharma',
      time: '3h ago',
      color: AppColors.red,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cardBorder, width: 1),
      ),
      child: Column(
        children: List.generate(_items.length, (i) {
          final item = _items[i];
          final isLast = i == _items.length - 1;
          return _ActivityRow(item: item, isLast: isLast);
        }),
      ),
    );
  }
}

class _ActivityData {
  final IconData icon;
  final String title;
  final String subtitle;
  final String time;
  final Color color;

  const _ActivityData({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.time,
    required this.color,
  });
}

class _ActivityRow extends StatelessWidget {
  final _ActivityData item;
  final bool isLast;

  const _ActivityRow({required this.item, required this.isLast});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
      decoration: BoxDecoration(
        border: isLast
            ? null
            : Border(
                bottom: BorderSide(
                  color: AppColors.cardBorder.withValues(alpha: 0.6),
                ),
              ),
      ),
      child: Row(
        children: [
          // Timeline dot + icon
          Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: item.color.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
              ),
              Icon(item.icon, color: item.color, size: 17),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.white,
                    height: 1.3,
                  ),
                ),
                Text(
                  item.subtitle,
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    color: AppColors.textSecondary,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              item.time,
              style: GoogleFonts.poppins(
                fontSize: 9,
                fontWeight: FontWeight.w500,
                color: AppColors.textMuted,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
