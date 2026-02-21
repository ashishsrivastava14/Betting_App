import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../providers/event_provider.dart';
import '../../theme/app_theme.dart';
import '../../utils/app_utils.dart';
import '../../widgets/status_badge.dart';

class AdminEventsScreen extends StatelessWidget {
  const AdminEventsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final eventProvider = context.watch<EventProvider>();
    final events = eventProvider.adminAllEvents;

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: Row(
                children: [
                  const Icon(Icons.event_note_rounded, color: AppColors.accent, size: 22),
                  const SizedBox(width: 10),
                  Text(
                    'Manage Events',
                    style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.white),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.card,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.cardBorder),
                    ),
                    child: Text(
                      '${events.length}',
                      style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.accent),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: RefreshIndicator(
                color: AppColors.accent,
                backgroundColor: AppColors.card,
                onRefresh: () async {
                  await Future.delayed(const Duration(seconds: 1));
                },
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: events.length,
                  itemBuilder: (context, index) {
                    final event = events[index];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: event.isEnabled ? AppColors.card : AppColors.card.withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.cardBorder),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  event.name,
                                  style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.white),
                                ),
                              ),
                              StatusBadge(status: event.status),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${event.team1} vs ${event.team2} \u2022 ${event.eventType}',
                            style: GoogleFonts.poppins(fontSize: 12, color: AppColors.textSecondary),
                          ),
                          Text(
                            'Start: ${AppUtils.formatDate(event.startTime)}',
                            style: GoogleFonts.poppins(fontSize: 11, color: AppColors.textMuted),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              if (!event.isEnabled)
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: AppColors.red.withValues(alpha: 0.12),
                                    borderRadius: BorderRadius.circular(6),
                                    border: Border.all(color: AppColors.red.withValues(alpha: 0.3)),
                                  ),
                                  child: Text(
                                    'DISABLED',
                                    style: GoogleFonts.poppins(fontSize: 10, fontWeight: FontWeight.w600, color: AppColors.red),
                                  ),
                                ),
                              const Spacer(),
                              IconButton(
                                icon: Icon(
                                  event.isEnabled ? Icons.toggle_on : Icons.toggle_off,
                                  color: event.isEnabled ? AppColors.green : AppColors.textMuted,
                                  size: 30,
                                ),
                                onPressed: () {
                                  eventProvider.toggleEventEnabled(event.id);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text(event.isEnabled ? 'Event enabled' : 'Event disabled')),
                                  );
                                },
                              ),
                              if (event.status == 'live' || event.status == 'closed')
                                IconButton(
                                  icon: const Icon(Icons.gavel, color: AppColors.accent, size: 20),
                                  onPressed: () => context.push('/admin/events/declare'),
                                  tooltip: 'Declare Result',
                                ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/admin/events/create'),
        icon: const Icon(Icons.add, size: 20),
        label: Text('Create Event', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
        backgroundColor: AppColors.accent,
        foregroundColor: AppColors.background,
        elevation: 0,
      ),
    );
  }
}