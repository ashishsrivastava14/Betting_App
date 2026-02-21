import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../models/event_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/event_provider.dart';
import '../../theme/app_theme.dart';
import '../../utils/app_utils.dart';
import '../../widgets/event_card.dart';
import '../../widgets/empty_state.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final eventProvider = context.watch<EventProvider>();

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: Row(
                children: [
                  // Logo
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [AppColors.accent, AppColors.primary],
                      ),
                    ),
                    child: const Icon(Icons.sports_cricket,
                        color: Colors.white, size: 22),
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'BetZone',
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: AppColors.accent,
                        ),
                      ),
                      Text(
                        'Hi, ${auth.currentUser?.name.split(' ').first ?? "User"} 🏏',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  // Wallet balance chip
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.accent.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                          color: AppColors.accent.withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.account_balance_wallet,
                            color: AppColors.gold, size: 16),
                        const SizedBox(width: 4),
                        Text(
                          AppUtils.formatCurrency(
                              auth.currentUser?.walletBalance ?? 0),
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: AppColors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // Sport banner
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.primary,
                    AppColors.accent.withValues(alpha: 0.3),
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
                image: DecorationImage(
                  image: const NetworkImage(
                    'https://images.unsplash.com/photo-1531415074968-036ba1b575da?w=400',
                  ),
                  fit: BoxFit.cover,
                  colorFilter: ColorFilter.mode(
                    AppColors.background.withValues(alpha: 0.7),
                    BlendMode.darken,
                  ),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'CRICKET BETTING',
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: AppColors.white,
                            letterSpacing: 1,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Bet on live matches & win big!',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: AppColors.white70,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.sports_cricket,
                      size: 48, color: AppColors.accent),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // Tabs
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.circular(12),
              ),
              child: TabBar(
                controller: _tabController,
                indicator: BoxDecoration(
                  color: AppColors.accent,
                  borderRadius: BorderRadius.circular(12),
                ),
                labelColor: AppColors.background,
                unselectedLabelColor: AppColors.white70,
                labelStyle: GoogleFonts.poppins(
                    fontSize: 12, fontWeight: FontWeight.w600),
                unselectedLabelStyle: GoogleFonts.poppins(fontSize: 12),
                dividerColor: Colors.transparent,
                indicatorSize: TabBarIndicatorSize.tab,
                tabs: const [
                  Tab(text: 'All'),
                  Tab(text: 'Live'),
                  Tab(text: 'Upcoming'),
                  Tab(text: 'Settled'),
                ],
              ),
            ),

            const SizedBox(height: 8),

            // Event lists
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildEventList(eventProvider.allEvents),
                  _buildEventList(eventProvider.liveEvents),
                  _buildEventList(eventProvider.upcomingEvents),
                  _buildEventList(eventProvider.settledEvents),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEventList(List<EventModel> events) {
    if (events.isEmpty) {
      return const EmptyStateWidget(
        icon: Icons.sports_cricket,
        title: 'No Events Found',
        subtitle: 'Check back later for upcoming matches',
      );
    }

    return RefreshIndicator(
      color: AppColors.accent,
      backgroundColor: AppColors.card,
      onRefresh: () async {
        await Future.delayed(const Duration(seconds: 1));
        if (mounted) {
          context.read<EventProvider>().refresh();
        }
      },
      child: ListView.builder(
        padding: const EdgeInsets.only(top: 4, bottom: 16),
        itemCount: events.length,
        itemBuilder: (_, index) => EventCard(event: events[index]),
      ),
    );
  }
}
