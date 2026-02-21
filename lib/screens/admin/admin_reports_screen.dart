import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../mock_data/mock_bets.dart';
import '../../mock_data/mock_transactions.dart';
import '../../mock_data/mock_events.dart';
import '../../theme/app_theme.dart';
import '../../utils/app_utils.dart';

class AdminReportsScreen extends StatelessWidget {
  const AdminReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final totalBets = mockBets.length;
    final totalBetAmount = mockBets.fold<double>(0, (s, b) => s + b.amount);
    final totalDeposits = mockTransactions.where((t) => t.type == 'deposit' && t.status == 'approved').fold<double>(0, (s, t) => s + t.amount);
    final totalWithdrawals = mockTransactions.where((t) => t.type == 'withdrawal' && t.status == 'approved').fold<double>(0, (s, t) => s + t.amount);
    final wonBets = mockBets.where((b) => b.status == 'won').length;
    final lostBets = mockBets.where((b) => b.status == 'lost').length;
    final pendingBets = mockBets.where((b) => b.status == 'pending').length;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.bar_chart_rounded, color: AppColors.accent, size: 22),
                  const SizedBox(width: 10),
                  Text('Reports', style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.white)),
                ],
              ),
              const SizedBox(height: 16),

              // Summary Stats
              Row(children: [
                _statCard('Total Bets', '$totalBets', Icons.receipt_long_rounded, AppColors.blue),
                const SizedBox(width: 10),
                _statCard('Bet Volume', AppUtils.formatCurrency(totalBetAmount), Icons.monetization_on_outlined, AppColors.accent),
              ]),
              const SizedBox(height: 10),
              Row(children: [
                _statCard('Deposits', AppUtils.formatCurrency(totalDeposits), Icons.arrow_downward_rounded, AppColors.green),
                const SizedBox(width: 10),
                _statCard('Withdrawals', AppUtils.formatCurrency(totalWithdrawals), Icons.arrow_upward_rounded, AppColors.red),
              ]),
              const SizedBox(height: 20),

              // Bet Status Chart
              _sectionHeader(Icons.pie_chart_outline, 'Bet Status Distribution'),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.card,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.cardBorder),
                ),
                child: Row(
                  children: [
                    SizedBox(
                      width: 140,
                      height: 140,
                      child: PieChart(
                        PieChartData(
                          sectionsSpace: 2,
                          centerSpaceRadius: 30,
                          sections: [
                            PieChartSectionData(value: wonBets.toDouble(), color: AppColors.green, radius: 30, title: '$wonBets',
                                titleStyle: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.white)),
                            PieChartSectionData(value: lostBets.toDouble(), color: AppColors.red, radius: 30, title: '$lostBets',
                                titleStyle: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.white)),
                            PieChartSectionData(value: pendingBets.toDouble(), color: AppColors.orange, radius: 30, title: '$pendingBets',
                                titleStyle: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.white)),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 24),
                    Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      _legendItem('Won', AppColors.green),
                      const SizedBox(height: 8),
                      _legendItem('Lost', AppColors.red),
                      const SizedBox(height: 8),
                      _legendItem('Pending', AppColors.orange),
                    ]),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Revenue Bar Chart
              _sectionHeader(Icons.show_chart_rounded, 'Revenue Overview'),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(16),
                height: 220,
                decoration: BoxDecoration(
                  color: AppColors.card,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.cardBorder),
                ),
                child: BarChart(
                  BarChartData(
                    alignment: BarChartAlignment.spaceAround,
                    maxY: (totalDeposits > totalWithdrawals ? totalDeposits : totalWithdrawals) * 1.3,
                    barGroups: [
                      BarChartGroupData(x: 0, barRods: [
                        BarChartRodData(toY: totalDeposits, color: AppColors.green, width: 28, borderRadius: const BorderRadius.vertical(top: Radius.circular(6))),
                      ]),
                      BarChartGroupData(x: 1, barRods: [
                        BarChartRodData(toY: totalWithdrawals, color: AppColors.red, width: 28, borderRadius: const BorderRadius.vertical(top: Radius.circular(6))),
                      ]),
                      BarChartGroupData(x: 2, barRods: [
                        BarChartRodData(toY: totalBetAmount, color: AppColors.accent, width: 28, borderRadius: const BorderRadius.vertical(top: Radius.circular(6))),
                      ]),
                    ],
                    titlesData: FlTitlesData(
                      leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (v, _) {
                            final labels = ['Deposits', 'Withdrawals', 'Bets'];
                            return Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Text(labels[v.toInt()], style: GoogleFonts.poppins(fontSize: 10, color: AppColors.textSecondary)),
                            );
                          },
                        ),
                      ),
                    ),
                    gridData: const FlGridData(show: false),
                    borderData: FlBorderData(show: false),
                    barTouchData: BarTouchData(
                      touchTooltipData: BarTouchTooltipData(
                        getTooltipColor: (_) => AppColors.cardLight,
                        getTooltipItem: (group, groupIndex, rod, rodIndex) {
                          return BarTooltipItem(
                            AppUtils.formatCurrency(rod.toY),
                            GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.white),
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Event-wise Table
              _sectionHeader(Icons.table_chart_rounded, 'Event-wise Earnings'),
              const SizedBox(height: 12),
              Container(
                decoration: BoxDecoration(
                  color: AppColors.card,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.cardBorder),
                ),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      decoration: const BoxDecoration(
                        color: AppColors.cardLight,
                        borderRadius: BorderRadius.vertical(top: Radius.circular(14)),
                      ),
                      child: Row(children: [
                        Expanded(flex: 3, child: Text('Event', style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.accent))),
                        Expanded(flex: 1, child: Text('Bets', textAlign: TextAlign.center, style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.accent))),
                        Expanded(flex: 2, child: Text('Volume', textAlign: TextAlign.right, style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.accent))),
                      ]),
                    ),
                    ...mockEvents.map((event) {
                      final eventBets = mockBets.where((b) => b.eventId == event.id).toList();
                      final volume = eventBets.fold<double>(0, (s, b) => s + b.amount);
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        decoration: const BoxDecoration(
                          border: Border(top: BorderSide(color: AppColors.cardBorder, width: 0.5)),
                        ),
                        child: Row(children: [
                          Expanded(
                            flex: 3,
                            child: Text('${event.team1} vs ${event.team2}',
                                style: GoogleFonts.poppins(fontSize: 12, color: AppColors.white),
                                overflow: TextOverflow.ellipsis),
                          ),
                          Expanded(
                            flex: 1,
                            child: Text('${eventBets.length}', textAlign: TextAlign.center,
                                style: GoogleFonts.poppins(fontSize: 12, color: AppColors.textSecondary)),
                          ),
                          Expanded(
                            flex: 2,
                            child: Text(AppUtils.formatCurrency(volume), textAlign: TextAlign.right,
                                style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.accent)),
                          ),
                        ]),
                      );
                    }),
                  ],
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  static Widget _statCard(String label, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.cardBorder),
        ),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: color.withValues(alpha: 0.12),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(value, style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.white), overflow: TextOverflow.ellipsis),
                  Text(label, style: GoogleFonts.poppins(fontSize: 10, color: AppColors.textSecondary)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  static Widget _sectionHeader(IconData icon, String label) {
    return Row(children: [
      Icon(icon, color: AppColors.accent, size: 18),
      const SizedBox(width: 8),
      Text(label, style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.white)),
    ]);
  }

  static Widget _legendItem(String label, Color color) {
    return Row(children: [
      Container(width: 12, height: 12, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(3))),
      const SizedBox(width: 8),
      Text(label, style: GoogleFonts.poppins(fontSize: 12, color: AppColors.textSecondary)),
    ]);
  }
}