import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../providers/bet_provider.dart';
import '../../providers/event_provider.dart';
import '../../providers/wallet_provider.dart';
import '../../mock_data/mock_users.dart';
import '../../theme/app_theme.dart';
import '../../utils/app_utils.dart';
import '../../widgets/status_badge.dart';

class AdminDeclareResultScreen extends StatefulWidget {
  const AdminDeclareResultScreen({super.key});

  @override
  State<AdminDeclareResultScreen> createState() => _AdminDeclareResultScreenState();
}

class _AdminDeclareResultScreenState extends State<AdminDeclareResultScreen> {
  final Map<String, String?> _selectedWinners = {};

  void _settleBets(String eventId) {
    final winningOption = _selectedWinners[eventId];
    if (winningOption == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select a winning option')));
      return;
    }
    final eventProvider = context.read<EventProvider>();
    final betProvider = context.read<BetProvider>();
    final walletProvider = context.read<WalletProvider>();
    eventProvider.declareResult(eventId, winningOption);
    final event = eventProvider.getEventById(eventId);
    if (event == null) return;
    betProvider.settleBetsForEvent(event);
    final eventBets = betProvider.getBetsForEvent(eventId);
    for (var bet in eventBets) {
      if (bet.status == 'won') {
        final user = mockUsers.firstWhere((u) => u.id == bet.userId);
        walletProvider.creditBalance(user, bet.potentialWin);
      }
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Result declared: $winningOption wins!'), backgroundColor: AppColors.green),
    );
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final eventProvider = context.watch<EventProvider>();
    final events = eventProvider.adminAllEvents
        .where((e) => e.status == 'live' || e.status == 'closed' || e.status == 'upcoming')
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: Text('Declare Results', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(shape: BoxShape.circle, color: AppColors.card, border: Border.all(color: AppColors.cardBorder)),
            child: const Icon(Icons.arrow_back, size: 18),
          ),
          onPressed: () => context.pop(),
        ),
      ),
      body: events.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.event_busy, size: 48, color: AppColors.textMuted),
                  const SizedBox(height: 12),
                  Text('No events to settle', style: GoogleFonts.poppins(fontSize: 14, color: AppColors.textSecondary)),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: events.length,
              itemBuilder: (context, index) {
                final event = events[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.card,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.cardBorder),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(children: [
                        Expanded(child: Text(event.name, style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.white))),
                        StatusBadge(status: event.status),
                      ]),
                      const SizedBox(height: 4),
                      Text('${event.team1} vs ${event.team2}', style: GoogleFonts.poppins(fontSize: 12, color: AppColors.textSecondary)),
                      Text('Started: ${AppUtils.formatDate(event.startTime)}', style: GoogleFonts.poppins(fontSize: 11, color: AppColors.textMuted)),
                      const SizedBox(height: 12),
                      Text('Select Winner:', style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.accent)),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 10,
                        runSpacing: 8,
                        children: event.options.map((opt) {
                          final isSelected = _selectedWinners[event.id] == opt.label;
                          return GestureDetector(
                            onTap: () { setState(() { _selectedWinners[event.id] = opt.label; }); },
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                              decoration: BoxDecoration(
                                color: isSelected ? AppColors.green.withValues(alpha: 0.12) : AppColors.cardLight,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: isSelected ? AppColors.green : AppColors.cardBorder, width: isSelected ? 2 : 1),
                              ),
                              child: Text(
                                '${opt.label} (${opt.multiplier}x)',
                                style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600, color: isSelected ? AppColors.green : AppColors.white),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 14),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () => _settleBets(event.id),
                          icon: const Icon(Icons.gavel, size: 18),
                          label: Text('Settle Bets', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.accent,
                            foregroundColor: AppColors.background,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}