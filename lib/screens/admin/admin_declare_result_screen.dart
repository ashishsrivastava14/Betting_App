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
  State<AdminDeclareResultScreen> createState() =>
      _AdminDeclareResultScreenState();
}

class _AdminDeclareResultScreenState
    extends State<AdminDeclareResultScreen> {
  final Map<String, String?> _selectedWinners = {};

  void _settleBets(String eventId) {
    final winningOption = _selectedWinners[eventId];
    if (winningOption == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a winning option')),
      );
      return;
    }

    final eventProvider = context.read<EventProvider>();
    final betProvider = context.read<BetProvider>();
    final walletProvider = context.read<WalletProvider>();

    // Declare result
    eventProvider.declareResult(eventId, winningOption);

    // Get event
    final event = eventProvider.getEventById(eventId);
    if (event == null) return;

    // Settle bets
    betProvider.settleBetsForEvent(event);

    // Credit winners
    final eventBets = betProvider.getBetsForEvent(eventId);
    for (var bet in eventBets) {
      if (bet.status == 'won') {
        final user = mockUsers.firstWhere((u) => u.id == bet.userId);
        walletProvider.creditBalance(user, bet.potentialWin);
      }
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Result declared: $winningOption wins!'),
        backgroundColor: AppColors.green,
      ),
    );

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final eventProvider = context.watch<EventProvider>();
    // Show live and closed events that haven't been settled
    final events = eventProvider.adminAllEvents
        .where((e) =>
            e.status == 'live' ||
            e.status == 'closed' ||
            (e.status == 'upcoming'))
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Declare Results'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: events.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.event_busy,
                      size: 64,
                      color: AppColors.accent.withValues(alpha: 0.3)),
                  const SizedBox(height: 12),
                  Text(
                    'No events to settle',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: events.length,
              itemBuilder: (context, index) {
                final event = events[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 14),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.card,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.cardLight),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              event.name,
                              style: GoogleFonts.poppins(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: AppColors.white,
                              ),
                            ),
                          ),
                          StatusBadge(status: event.status),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '${event.team1} vs ${event.team2}',
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      Text(
                        'Started: ${AppUtils.formatDate(event.startTime)}',
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          color: AppColors.grey,
                        ),
                      ),

                      const SizedBox(height: 14),

                      Text(
                        'Select Winner:',
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.accent,
                        ),
                      ),
                      const SizedBox(height: 8),

                      Wrap(
                        spacing: 10,
                        runSpacing: 8,
                        children: event.options.map((opt) {
                          final isSelected =
                              _selectedWinners[event.id] == opt.label;
                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                _selectedWinners[event.id] = opt.label;
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 10),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? AppColors.green
                                        .withValues(alpha: 0.2)
                                    : AppColors.cardLight,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: isSelected
                                      ? AppColors.green
                                      : AppColors.grey.withValues(alpha: 0.3),
                                  width: isSelected ? 2 : 1,
                                ),
                              ),
                              child: Text(
                                '${opt.label} (${opt.multiplier}x)',
                                style: GoogleFonts.poppins(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: isSelected
                                      ? AppColors.green
                                      : AppColors.white,
                                ),
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
                          label: Text('Settle Bets',
                              style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.w600)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.gold,
                            foregroundColor: AppColors.background,
                            padding:
                                const EdgeInsets.symmetric(vertical: 12),
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
