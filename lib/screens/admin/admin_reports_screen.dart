import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../providers/bet_provider.dart';
import '../../providers/event_provider.dart';
import '../../theme/app_theme.dart';
import '../../utils/app_utils.dart';

class AdminReportsScreen extends StatelessWidget {
  const AdminReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final betProvider = context.watch<BetProvider>();
    final eventProvider = context.watch<EventProvider>();

    // Mock chart data
    final wonBets =
        betProvider.bets.where((b) => b.status == 'won').length;
    final lostBets =
        betProvider.bets.where((b) => b.status == 'lost').length;
    final activeBets =
        betProvider.bets.where((b) => b.status == 'active').length;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Reports & Analytics',
                style: GoogleFonts.poppins(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: AppColors.white,
                ),
              ),

              const SizedBox(height: 20),

              // Daily Revenue Bar Chart
              _sectionTitle('Daily Revenue (Last 7 Days)'),
              const SizedBox(height: 12),
              Container(
                height: 220,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.card,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: BarChart(
                  BarChartData(
                    alignment: BarChartAlignment.spaceAround,
                    maxY: 15000,
                    barTouchData: BarTouchData(
                      touchTooltipData: BarTouchTooltipData(
                        getTooltipColor: (_) => AppColors.cardLight,
                        getTooltipItem: (group, groupIndex, rod, rodIndex) {
                          return BarTooltipItem(
                            AppUtils.formatCurrency(rod.toY),
                            GoogleFonts.poppins(
                              color: AppColors.accent,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          );
                        },
                      ),
                    ),
                    titlesData: FlTitlesData(
                      leftTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false)),
                      rightTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false)),
                      topTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false)),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (value, meta) {
                            final days = [
                              'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'
                            ];
                            return Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Text(
                                days[value.toInt() % 7],
                                style: GoogleFonts.poppins(
                                  fontSize: 10,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    gridData: const FlGridData(show: false),
                    borderData: FlBorderData(show: false),
                    barGroups: [
                      _barGroup(0, 8500),
                      _barGroup(1, 12000),
                      _barGroup(2, 6800),
                      _barGroup(3, 9500),
                      _barGroup(4, 11200),
                      _barGroup(5, 14500),
                      _barGroup(6, 7200),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Win/Loss Pie Chart
              _sectionTitle('Bet Distribution'),
              const SizedBox(height: 12),
              Container(
                height: 220,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.card,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: PieChart(
                        PieChartData(
                          centerSpaceRadius: 30,
                          sectionsSpace: 3,
                          sections: [
                            PieChartSectionData(
                              value: wonBets.toDouble(),
                              color: AppColors.green,
                              title: 'Won',
                              titleStyle: GoogleFonts.poppins(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                              radius: 55,
                            ),
                            PieChartSectionData(
                              value: lostBets.toDouble(),
                              color: AppColors.red,
                              title: 'Lost',
                              titleStyle: GoogleFonts.poppins(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                              radius: 55,
                            ),
                            PieChartSectionData(
                              value: activeBets.toDouble(),
                              color: AppColors.accent,
                              title: 'Active',
                              titleStyle: GoogleFonts.poppins(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                              radius: 55,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _legendItem('Won', '$wonBets', AppColors.green),
                        const SizedBox(height: 8),
                        _legendItem('Lost', '$lostBets', AppColors.red),
                        const SizedBox(height: 8),
                        _legendItem(
                            'Active', '$activeBets', AppColors.accent),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Event-wise earnings table
              _sectionTitle('Event-wise Earnings'),
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: AppColors.card,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    // Header
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: AppColors.cardLight,
                        borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(16)),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            flex: 3,
                            child: Text('Event',
                                style: _headerStyle()),
                          ),
                          Expanded(
                            flex: 2,
                            child: Text('Total Bets',
                                style: _headerStyle(),
                                textAlign: TextAlign.center),
                          ),
                          Expanded(
                            flex: 2,
                            child: Text('Earnings',
                                style: _headerStyle(),
                                textAlign: TextAlign.end),
                          ),
                        ],
                      ),
                    ),
                    ...eventProvider.adminAllEvents.map((event) {
                      final eventBets = betProvider
                          .getBetsForEvent(event.id);
                      final totalBetAmount = eventBets.fold<double>(
                          0, (sum, b) => sum + b.amount);
                      final totalPayout = eventBets
                          .where((b) => b.status == 'won')
                          .fold<double>(
                              0, (sum, b) => sum + b.potentialWin);
                      final earnings = totalBetAmount - totalPayout;

                      return Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 10),
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(
                              color: AppColors.cardLight
                                  .withValues(alpha: 0.5),
                            ),
                          ),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              flex: 3,
                              child: Text(
                                event.name,
                                style: GoogleFonts.poppins(
                                  fontSize: 11,
                                  color: AppColors.white,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child: Text(
                                '${eventBets.length}',
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  color: AppColors.textSecondary,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child: Text(
                                AppUtils.formatCurrency(earnings),
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: earnings >= 0
                                      ? AppColors.green
                                      : AppColors.red,
                                ),
                                textAlign: TextAlign.end,
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Export button
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('Export feature coming soon')),
                    );
                  },
                  icon: const Icon(Icons.download),
                  label: Text(
                    'Export Report',
                    style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.accent),
                    foregroundColor: AppColors.accent,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  BarChartGroupData _barGroup(int x, double y) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: y,
          color: AppColors.accent,
          width: 18,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
          backDrawRodData: BackgroundBarChartRodData(
            show: true,
            toY: 15000,
            color: AppColors.cardLight,
          ),
        ),
      ],
    );
  }

  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.poppins(
        fontSize: 16,
        fontWeight: FontWeight.w700,
        color: AppColors.white,
      ),
    );
  }

  Widget _legendItem(String label, String value, Color color) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          '$label ($value)',
          style: GoogleFonts.poppins(
            fontSize: 12,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  TextStyle _headerStyle() {
    return GoogleFonts.poppins(
      fontSize: 11,
      fontWeight: FontWeight.w700,
      color: AppColors.accent,
    );
  }
}
