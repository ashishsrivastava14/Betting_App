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
  int _selectedFilter = 0;
  String _sortBy = 'default';

  static const _sortOptions = [
    ('default',      'Default',            Icons.list_rounded),
    ('deadline_asc', 'Deadline: Soonest',  Icons.timer_outlined),
    ('deadline_desc','Deadline: Latest',   Icons.timer_off_outlined),
    ('name_asc',     'Name: A → Z',        Icons.sort_by_alpha),
  ];

  final _filters = [
    {'label': 'All', 'icon': Icons.grid_view_rounded},
    {'label': 'Live', 'icon': Icons.sports_cricket},
    {'label': 'Upcoming', 'icon': Icons.schedule},
    {'label': 'Settled', 'icon': Icons.check_circle_outline},
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        setState(() => _selectedFilter = _tabController.index);
      }
    });
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
      body: Stack(
        children: [
          // ── Collage Background ──
          Positioned.fill(
            child: Image.asset(
              'assets/images/bg-images.png',
              fit: BoxFit.cover,
              opacity: const AlwaysStoppedAnimation(0.12),
            ),
          ),
          Positioned(
            top: -20,
            right: -30,
            width: 210,
            height: 210,
            child: Transform.rotate(
              angle: 0.3,
              child: Image.asset(
                'assets/images/cricket_bg.jpg',
                fit: BoxFit.cover,
                opacity: const AlwaysStoppedAnimation(0.09),
              ),
            ),
          ),
          Positioned(
            top: 200,
            left: -40,
            width: 190,
            height: 190,
            child: Transform.rotate(
              angle: -0.25,
              child: Image.asset(
                'assets/images/bg-images.png',
                fit: BoxFit.cover,
                opacity: const AlwaysStoppedAnimation(0.08),
              ),
            ),
          ),
          Positioned(
            top: 380,
            right: -20,
            width: 200,
            height: 200,
            child: Transform.rotate(
              angle: 0.15,
              child: Image.asset(
                'assets/images/cricket_bg.jpg',
                fit: BoxFit.cover,
                opacity: const AlwaysStoppedAnimation(0.09),
              ),
            ),
          ),
          Positioned(
            bottom: 80,
            left: -20,
            width: 220,
            height: 220,
            child: Transform.rotate(
              angle: -0.2,
              child: Image.asset(
                'assets/images/bg-images.png',
                fit: BoxFit.cover,
                opacity: const AlwaysStoppedAnimation(0.08),
              ),
            ),
          ),
          Positioned(
            bottom: 60,
            right: -30,
            width: 185,
            height: 185,
            child: Transform.rotate(
              angle: 0.35,
              child: Image.asset(
                'assets/images/cricket_bg.jpg',
                fit: BoxFit.cover,
                opacity: const AlwaysStoppedAnimation(0.07),
              ),
            ),
          ),
          // ── Main Content ──
          SafeArea(
            child: Column(
          children: [
            // ── Top Bar ──
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
              child: Row(
                children: [
                  // Wallet balance left
                  _walletChip(
                    Icons.account_balance_wallet_outlined,
                    AppUtils.formatCurrency(
                        auth.currentUser?.walletBalance ?? 0),
                  ),
                  const Spacer(),
                  // Logo center
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.surface,
                      border: Border.all(
                          color: AppColors.accent.withValues(alpha: 0.5),
                          width: 2),
                    ),
                    child: const Icon(Icons.sports_cricket,
                        color: AppColors.accent, size: 22),
                  ),
                  const Spacer(),
                  // Notification bell right
                  _walletChip(
                    Icons.notifications_outlined,
                    'BetZone',
                  ),
                ],
              ),
            ),

            const SizedBox(height: 14),

            // ── Category Filter Pills ──
            SizedBox(
              height: 40,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _filters.length,
                separatorBuilder: (_, _) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final isSelected = _selectedFilter == index;
                  return GestureDetector(
                    onTap: () {
                      setState(() => _selectedFilter = index);
                      _tabController.animateTo(index);
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.accent
                            : AppColors.surface,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: isSelected
                              ? AppColors.accent
                              : AppColors.cardBorder,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            _filters[index]['icon'] as IconData,
                            size: 16,
                            color: isSelected
                                ? AppColors.background
                                : AppColors.textSecondary,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            _filters[index]['label'] as String,
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: isSelected
                                  ? AppColors.background
                                  : AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 16),

            // ── Section Header ──
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Text(
                    'Contests for you',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.white,
                    ),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: _showSortSheet,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: _sortBy != 'default'
                            ? AppColors.accent.withValues(alpha: 0.15)
                            : AppColors.surface,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: _sortBy != 'default'
                              ? AppColors.accent
                              : AppColors.cardBorder,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.sort,
                              size: 14,
                              color: _sortBy != 'default'
                                  ? AppColors.accent
                                  : AppColors.textSecondary),
                          const SizedBox(width: 4),
                          Text(
                            _sortBy != 'default' ? 'SORTED' : 'SORT',
                            style: GoogleFonts.poppins(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: _sortBy != 'default'
                                  ? AppColors.accent
                                  : AppColors.textSecondary,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 8),

            // ── Event Lists ──
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildEventList(_applySort(eventProvider.allEvents)),
                  _buildEventList(_applySort(eventProvider.liveEvents)),
                  _buildEventList(_applySort(eventProvider.upcomingEvents)),
                  _buildEventList(_applySort(eventProvider.settledEvents)),
                ],
              ),
            ),
          ],
        ),
      ),
        ],
      ),
    );
  }

  List<EventModel> _applySort(List<EventModel> events) {
    final list = List<EventModel>.from(events);
    switch (_sortBy) {
      case 'deadline_asc':
        list.sort((a, b) => a.betCloseTime.compareTo(b.betCloseTime));
      case 'deadline_desc':
        list.sort((a, b) => b.betCloseTime.compareTo(a.betCloseTime));
      case 'name_asc':
        list.sort((a, b) => a.name.compareTo(b.name));
    }
    return list;
  }

  void _showSortSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.card,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => StatefulBuilder(
        builder: (ctx, setSheetState) {
          return Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Handle bar
                Center(
                  child: Container(
                    width: 36, height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.cardBorder,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Sort by',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.white,
                  ),
                ),
                const SizedBox(height: 12),
                ..._sortOptions.map((opt) {
                  final (value, label, icon) = opt;
                  final isActive = _sortBy == value;
                  return GestureDetector(
                    onTap: () {
                      setState(() => _sortBy = value);
                      setSheetState(() {});
                      Navigator.pop(ctx);
                    },
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 12),
                      decoration: BoxDecoration(
                        color: isActive
                            ? AppColors.accent.withValues(alpha: 0.12)
                            : AppColors.surface,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: isActive
                              ? AppColors.accent
                              : AppColors.cardBorder,
                          width: isActive ? 1.5 : 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(icon,
                              size: 18,
                              color: isActive
                                  ? AppColors.accent
                                  : AppColors.textSecondary),
                          const SizedBox(width: 12),
                          Text(
                            label,
                            style: GoogleFonts.poppins(
                              fontSize: 13,
                              fontWeight: isActive
                                  ? FontWeight.w700
                                  : FontWeight.w500,
                              color: isActive
                                  ? AppColors.accent
                                  : AppColors.white,
                            ),
                          ),
                          const Spacer(),
                          if (isActive)
                            const Icon(Icons.check_circle,
                                size: 18, color: AppColors.accent),
                        ],
                      ),
                    ),
                  );
                }),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _walletChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: AppColors.accent, size: 16),
          const SizedBox(width: 6),
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.white,
            ),
          ),
        ],
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
