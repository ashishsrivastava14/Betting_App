import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import '../models/event_model.dart';
import '../theme/app_theme.dart';
import 'countdown_timer.dart';
import 'status_badge.dart';

class EventCard extends StatelessWidget {
  final EventModel event;

  const EventCard({super.key, required this.event});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push('/event/${event.id}'),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: event.status == 'live'
                ? AppColors.green.withValues(alpha: 0.3)
                : AppColors.cardLight,
            width: event.status == 'live' ? 1.5 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top row: event type + status badge
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        _getEventTypeIcon(),
                        color: AppColors.accent,
                        size: 16,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        event.eventType,
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: AppColors.accent,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  StatusBadge(status: event.status),
                ],
              ),
              const SizedBox(height: 12),

              // Teams
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: Text(
                      event.team1,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.white,
                      ),
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.accent.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'VS',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AppColors.accent,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      event.team2,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.white,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Event name
              Text(
                event.name,
                style: GoogleFonts.poppins(
                  fontSize: 11,
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),

              // Countdown or result
              if (event.status == 'upcoming' || event.status == 'live')
                Center(
                  child: CountdownTimerWidget(
                    targetTime: event.betCloseTime,
                    prefix: 'Bets close in: ',
                  ),
                )
              else if (event.winningOption != null)
                Center(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.emoji_events,
                          color: AppColors.gold, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        'Winner: ${event.winningOption}',
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.gold,
                        ),
                      ),
                    ],
                  ),
                ),

              const SizedBox(height: 10),

              // Odds chips
              Wrap(
                spacing: 8,
                runSpacing: 6,
                alignment: WrapAlignment.center,
                children: event.options.map((opt) {
                  final isWinner =
                      event.winningOption != null && opt.label == event.winningOption;
                  return Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: isWinner
                          ? AppColors.green.withValues(alpha: 0.2)
                          : AppColors.cardLight,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isWinner ? AppColors.green : AppColors.accent.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Text(
                      '${opt.label}  ${opt.multiplier}x',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: isWinner ? AppColors.green : AppColors.white,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getEventTypeIcon() {
    switch (event.eventType) {
      case 'Toss':
        return Icons.flip;
      case 'Over Runs':
        return Icons.score;
      default:
        return Icons.sports_cricket;
    }
  }
}
