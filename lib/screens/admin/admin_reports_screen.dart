import 'dart:io';
import 'package:excel/excel.dart' hide Border;
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../../utils/file_download_stub.dart'
    if (dart.library.html) '../../utils/file_download_web.dart';
import '../../mock_data/mock_bets.dart';
import '../../mock_data/mock_events.dart';
import '../../mock_data/mock_transactions.dart';
import '../../mock_data/mock_users.dart';
import '../../models/bet_model.dart';
import '../../models/transaction_model.dart';
import '../../theme/app_theme.dart';
import '../../utils/app_utils.dart';

// â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
enum _Period { today, week, month, all }

extension _PeriodLabel on _Period {
  String get label {
    switch (this) {
      case _Period.today:
        return 'Today';
      case _Period.week:
        return 'This Week';
      case _Period.month:
        return 'This Month';
      case _Period.all:
        return 'All Time';
    }
  }
}

// â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
class AdminReportsScreen extends StatefulWidget {
  const AdminReportsScreen({super.key});

  @override
  State<AdminReportsScreen> createState() => _AdminReportsScreenState();
}

class _AdminReportsScreenState extends State<AdminReportsScreen> {
  _Period _period = _Period.week;
  bool _exporting = false;

  // â”€â”€ Period helpers â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  DateTime get _cutoff {
    final now = DateTime.now();
    switch (_period) {
      case _Period.today:
        return DateTime(now.year, now.month, now.day);
      case _Period.week:
        return now.subtract(const Duration(days: 7));
      case _Period.month:
        return now.subtract(const Duration(days: 30));
      case _Period.all:
        return DateTime(2000);
    }
  }

  List<BetModel> get _bets =>
      mockBets.where((b) => b.createdAt.isAfter(_cutoff)).toList();

  List<TransactionModel> get _txns =>
      mockTransactions.where((t) => t.createdAt.isAfter(_cutoff)).toList();

  // â”€â”€ Chart data: daily deposit vs withdrawal for last N days â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  List<_DayRevenue> _buildDailyRevenue() {
    final int days = _period == _Period.today
        ? 24 // hours
        : _period == _Period.week
            ? 7
            : _period == _Period.month
                ? 30
                : 12; // months for all-time

    final bool byHour = _period == _Period.today;
    final bool byMonth = _period == _Period.all;
    final now = DateTime.now();
    final result = <_DayRevenue>[];

    for (int i = days - 1; i >= 0; i--) {
      DateTime start, end;
      String label;
      if (byHour) {
        start = now.subtract(Duration(hours: i + 1));
        end = now.subtract(Duration(hours: i));
        label = '${end.hour}h';
      } else if (byMonth) {
        final m = now.month - i;
        final year = now.year + (m - 1) ~/ 12;
        final month = ((m - 1) % 12) + 1;
        start = DateTime(year, month, 1);
        end = DateTime(year, month + 1, 1);
        label = DateFormat('MMM').format(start);
      } else {
        start = DateTime(now.year, now.month, now.day)
            .subtract(Duration(days: i));
        end = start.add(const Duration(days: 1));
        label = DateFormat('d MMM').format(start);
      }

      final dep = _txns
          .where((t) =>
              t.type == 'deposit' &&
              t.status == 'completed' &&
              t.createdAt.isAfter(start) &&
              t.createdAt.isBefore(end))
          .fold<double>(0, (s, t) => s + t.amount);

      final wit = _txns
          .where((t) =>
              t.type == 'withdrawal' &&
              t.status == 'completed' &&
              t.createdAt.isAfter(start) &&
              t.createdAt.isBefore(end))
          .fold<double>(0, (s, t) => s + t.amount);

      result.add(_DayRevenue(label: label, deposits: dep, withdrawals: wit));
    }
    return result;
  }

  // â”€â”€ Excel Export â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  Future<void> _exportExcel() async {
    setState(() => _exporting = true);
    try {
      final bets = _bets;
      final txns = _txns;
      final periodLabel = _period.label;
      final excel = Excel.createExcel();

      // â”€â”€ Sheet 1: Summary â”€â”€
      final summary = excel['Summary'];
      excel.setDefaultSheet('Summary');
      _writeRow(summary, ['BetZone Report â€” $periodLabel'], bold: true, size: 14);
      _writeRow(summary, ['Generated: ${DateFormat('dd MMM yyyy, HH:mm').format(DateTime.now())}']);
      _writeRow(summary, []);
      _writeRow(summary, ['Metric', 'Value'], bold: true, color: 'CFB53B');
      _writeRow(summary, [
        'Total Bets',
        bets.length,
      ]);
      _writeRow(summary, [
        'Bet Volume (â‚¹)',
        bets.fold<double>(0, (s, b) => s + b.amount),
      ]);
      _writeRow(summary, [
        'Bets Won',
        bets.where((b) => b.status == 'won').length,
      ]);
      _writeRow(summary, [
        'Bets Lost',
        bets.where((b) => b.status == 'lost').length,
      ]);
      _writeRow(summary, [
        'Bets Active/Pending',
        bets.where((b) => b.status == 'active' || b.status == 'pending').length,
      ]);
      _writeRow(summary, [
        'Total Deposits (â‚¹)',
        txns
            .where((t) => t.type == 'deposit' && t.status == 'completed')
            .fold<double>(0, (s, t) => s + t.amount),
      ]);
      _writeRow(summary, [
        'Total Withdrawals (â‚¹)',
        txns
            .where((t) => t.type == 'withdrawal' && t.status == 'completed')
            .fold<double>(0, (s, t) => s + t.amount),
      ]);
      _writeRow(summary, [
        'Pending Withdrawals',
        txns
            .where((t) => t.type == 'withdrawal' && t.status == 'pending')
            .length,
      ]);
      _writeRow(summary, [
        'Active Users',
        mockUsers.where((u) => u.role == 'user' && !u.isBlocked).length,
      ]);

      // â”€â”€ Sheet 2: Bets â”€â”€
      final betsSheet = excel['Bets'];
      _writeRow(betsSheet, [
        'Bet ID', 'User ID', 'Event ID', 'Selection',
        'Amount (â‚¹)', 'Multiplier', 'Potential Win (â‚¹)', 'Status', 'Date',
      ], bold: true, color: 'CFB53B');
      for (final b in bets) {
        _writeRow(betsSheet, [
          b.id, b.userId, b.eventId, b.selectedOption,
          b.amount, b.multiplier, b.potentialWin, b.status,
          DateFormat('dd/MM/yyyy HH:mm').format(b.createdAt),
        ]);
      }

      // â”€â”€ Sheet 3: Transactions â”€â”€
      final txnSheet = excel['Transactions'];
      _writeRow(txnSheet, [
        'Txn ID', 'User ID', 'Type', 'Amount (â‚¹)', 'Status', 'Notes', 'Date',
      ], bold: true, color: 'CFB53B');
      for (final t in txns) {
        _writeRow(txnSheet, [
          t.id, t.userId, t.type, t.amount, t.status, t.notes,
          DateFormat('dd/MM/yyyy HH:mm').format(t.createdAt),
        ]);
      }

      // â”€â”€ Sheet 4: Event-wise â”€â”€
      final eventSheet = excel['Events'];
      _writeRow(eventSheet, [
        'Event ID', 'Match', 'Total Bets', 'Volume (â‚¹)',
        'Won Bets', 'Lost Bets', 'Active Bets',
      ], bold: true, color: 'CFB53B');
      for (final event in mockEvents) {
        final eb = bets.where((b) => b.eventId == event.id).toList();
        _writeRow(eventSheet, [
          event.id,
          '${event.team1} vs ${event.team2}',
          eb.length,
          eb.fold<double>(0, (s, b) => s + b.amount),
          eb.where((b) => b.status == 'won').length,
          eb.where((b) => b.status == 'lost').length,
          eb.where((b) => b.status == 'active').length,
        ]);
      }

      // Delete default empty sheet
      excel.delete('Sheet1');

      final bytes = excel.save();
      if (bytes == null) throw Exception('Failed to generate Excel file');
      final fileName =
          'BetZone_Report_${periodLabel.replaceAll(' ', '_')}_${DateFormat('yyyyMMdd_HHmm').format(DateTime.now())}.xlsx';

      if (kIsWeb) {
        // Web: trigger browser file download
        downloadFileOnWeb(bytes, fileName);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Downloaded: $fileName'),
            backgroundColor: AppColors.green,
            behavior: SnackBarBehavior.floating,
          ));
        }
      } else {
        // Mobile / Desktop: save to temp dir then share
        final dir = await getTemporaryDirectory();
        final file = File('${dir.path}/$fileName');
        await file.writeAsBytes(bytes, flush: true);
        await Share.shareXFiles(
          [XFile(file.path)],
          subject: 'BetZone Report',
          text: 'BetZone report for $periodLabel',
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Export failed: $e'),
          backgroundColor: AppColors.red,
          behavior: SnackBarBehavior.floating,
        ));
      }
    } finally {
      if (mounted) setState(() => _exporting = false);
    }
  }

  void _writeRow(
    Sheet sheet,
    List<dynamic> values, {
    bool bold = false,
    String? color,
    double? size,
  }) {
    // Write values then style
    final rowIndex = sheet.maxRows;
    for (int i = 0; i < values.length; i++) {
      final cell = sheet.cell(
          CellIndex.indexByColumnRow(columnIndex: i, rowIndex: rowIndex));
      final v = values[i];
      if (v is String) {
        cell.value = TextCellValue(v);
      } else if (v is int) {
        cell.value = IntCellValue(v);
      } else if (v is double) {
        cell.value = DoubleCellValue(v);
      } else {
        cell.value = TextCellValue(v?.toString() ?? '');
      }
      if (bold || color != null || size != null) {
        cell.cellStyle = CellStyle(
          bold: bold,
          fontSize: size?.toInt(),
          fontColorHex: color != null
              ? ExcelColor.fromHexString(color)
              : ExcelColor.black,
        );
      }
    }
  }

  // â”€â”€ Build â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  @override
  Widget build(BuildContext context) {
    final bets = _bets;
    final txns = _txns;

    final totalBets = bets.length;
    final betVolume = bets.fold<double>(0, (s, b) => s + b.amount);
    final wonBets = bets.where((b) => b.status == 'won').length;
    final lostBets = bets.where((b) => b.status == 'lost').length;
    final activeBets =
        bets.where((b) => b.status == 'active' || b.status == 'pending').length;
    final totalDeposits = txns
        .where((t) => t.type == 'deposit' && t.status == 'completed')
        .fold<double>(0, (s, t) => s + t.amount);
    final totalWithdrawals = txns
        .where((t) => t.type == 'withdrawal' && t.status == 'completed')
        .fold<double>(0, (s, t) => s + t.amount);
    final netRevenue = totalDeposits - totalWithdrawals;
    final pendingWithdrawals =
        txns.where((t) => t.type == 'withdrawal' && t.status == 'pending');
    final pendingWdAmount =
        pendingWithdrawals.fold<double>(0, (s, t) => s + t.amount);

    final dailyData = _buildDailyRevenue();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // â”€â”€ Header â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
            Container(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
              decoration: const BoxDecoration(
                color: AppColors.surface,
                border: Border(bottom: BorderSide(color: AppColors.cardBorder)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 3,
                        height: 22,
                        decoration: BoxDecoration(
                          color: AppColors.accent,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(width: 10),
                      const Icon(Icons.bar_chart_rounded,
                          color: AppColors.accent, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'Reports & Analytics',
                        style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: AppColors.white),
                      ),
                      const Spacer(),
                      // Export button
                      GestureDetector(
                        onTap: _exporting ? null : _exportExcel,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 7),
                          decoration: BoxDecoration(
                            color: _exporting
                                ? AppColors.cardLight
                                : AppColors.green.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                                color: _exporting
                                    ? AppColors.cardBorder
                                    : AppColors.green.withValues(alpha: 0.35)),
                          ),
                          child: _exporting
                              ? SizedBox(
                                  width: 14,
                                  height: 14,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: AppColors.green,
                                  ),
                                )
                              : Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(Icons.download_rounded,
                                        size: 14, color: AppColors.green),
                                    const SizedBox(width: 5),
                                    Text(
                                      'Export Excel',
                                      style: GoogleFonts.poppins(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w700,
                                          color: AppColors.green),
                                    ),
                                  ],
                                ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Period tabs
                  SizedBox(
                    height: 34,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: _Period.values.map((p) {
                        final sel = _period == p;
                        return GestureDetector(
                          onTap: () => setState(() => _period = p),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 180),
                            margin: const EdgeInsets.only(right: 8),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 6),
                            decoration: BoxDecoration(
                              color: sel ? AppColors.accent : AppColors.card,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                  color: sel
                                      ? AppColors.accent
                                      : AppColors.cardBorder),
                            ),
                            child: Text(
                              p.label,
                              style: GoogleFonts.poppins(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: sel
                                      ? AppColors.background
                                      : AppColors.textSecondary),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ),

            // â”€â”€ Scrollable Body â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // â”€â”€ KPI row 1 â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
                    Row(
                      children: [
                        _KpiCard(
                          icon: Icons.trending_up_rounded,
                          label: 'Net Revenue',
                          value: AppUtils.formatCurrency(netRevenue),
                          color: netRevenue >= 0 ? AppColors.green : AppColors.red,
                          sub: netRevenue >= 0 ? 'Profitable' : 'Net Loss',
                        ),
                        const SizedBox(width: 10),
                        _KpiCard(
                          icon: Icons.receipt_long_rounded,
                          label: 'Bet Volume',
                          value: AppUtils.formatCurrency(betVolume),
                          color: AppColors.accent,
                          sub: '$totalBets bets',
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        _KpiCard(
                          icon: Icons.south_east_rounded,
                          label: 'Deposits',
                          value: AppUtils.formatCurrency(totalDeposits),
                          color: AppColors.green,
                          sub: '${txns.where((t) => t.type == 'deposit').length} txns',
                        ),
                        const SizedBox(width: 10),
                        _KpiCard(
                          icon: Icons.north_east_rounded,
                          label: 'Withdrawals',
                          value: AppUtils.formatCurrency(totalWithdrawals),
                          color: AppColors.red,
                          sub: '${pendingWithdrawals.length} pending (${AppUtils.formatCurrency(pendingWdAmount)})',
                        ),
                      ],
                    ),

                    const SizedBox(height: 22),

                    // â”€â”€ Revenue trend chart â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
                    _sectionHeader(
                        Icons.show_chart_rounded, 'Revenue Trend'),
                    const SizedBox(height: 12),
                    _RevenueTrendChart(dailyData: dailyData),

                    const SizedBox(height: 22),

                    // â”€â”€ Bet outcomes row â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
                    _sectionHeader(
                        Icons.pie_chart_rounded, 'Bet Outcomes'),
                    const SizedBox(height: 12),
                    _BetOutcomesRow(
                      won: wonBets,
                      lost: lostBets,
                      active: activeBets,
                      betVolume: betVolume,
                    ),

                    const SizedBox(height: 22),

                    // â”€â”€ Event-wise table â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
                    _sectionHeader(
                        Icons.table_chart_rounded, 'Event-wise Performance'),
                    const SizedBox(height: 12),
                    _EventTable(bets: bets),

                    const SizedBox(height: 22),

                    // â”€â”€ Recent transactions â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
                    _sectionHeader(
                        Icons.swap_horiz_rounded, 'Recent Transactions'),
                    const SizedBox(height: 12),
                    _TransactionLog(txns: txns.take(15).toList()),

                    const SizedBox(height: 22),

                    // â”€â”€ Top bettors â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
                    _sectionHeader(
                        Icons.leaderboard_rounded, 'Top Bettors'),
                    const SizedBox(height: 12),
                    _TopBettors(bets: bets),

                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionHeader(IconData icon, String label) {
    return Row(
      children: [
        Container(
          width: 3,
          height: 16,
          decoration: BoxDecoration(
            color: AppColors.accent,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Icon(icon, color: AppColors.accent, size: 16),
        const SizedBox(width: 7),
        Text(
          label,
          style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: AppColors.white),
        ),
      ],
    );
  }
}

// â”€â”€ KPI Card â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
class _KpiCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  final String sub;

  const _KpiCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    required this.sub,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withValues(alpha: 0.2)),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: color, size: 16),
                ),
                const Spacer(),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              value,
              style: GoogleFonts.poppins(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: AppColors.white),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: GoogleFonts.poppins(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary),
            ),
            const SizedBox(height: 3),
            Text(
              sub,
              style: GoogleFonts.poppins(
                  fontSize: 9, color: color.withValues(alpha: 0.8)),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

// â”€â”€ Revenue Trend Chart â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
class _DayRevenue {
  final String label;
  final double deposits;
  final double withdrawals;
  const _DayRevenue(
      {required this.label,
      required this.deposits,
      required this.withdrawals});
}

class _RevenueTrendChart extends StatelessWidget {
  final List<_DayRevenue> dailyData;
  const _RevenueTrendChart({required this.dailyData});

  @override
  Widget build(BuildContext context) {
    if (dailyData.isEmpty) {
      return _emptyCard('No data for this period');
    }

    final maxY = dailyData
            .map((d) =>
                d.deposits > d.withdrawals ? d.deposits : d.withdrawals)
            .fold<double>(0, (a, b) => a > b ? a : b) *
        1.3;
    final step = dailyData.length;

    return Container(
      padding: const EdgeInsets.fromLTRB(8, 16, 16, 8),
      height: 200,
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 8, bottom: 8),
            child: Row(
              children: [
                _legendDot(AppColors.green, 'Deposits'),
                const SizedBox(width: 16),
                _legendDot(AppColors.red, 'Withdrawals'),
              ],
            ),
          ),
          Expanded(
            child: LineChart(
              LineChartData(
                minY: 0,
                maxY: maxY <= 0 ? 1000 : maxY,
                lineTouchData: LineTouchData(
                  touchTooltipData: LineTouchTooltipData(
                    getTooltipColor: (_) => AppColors.cardLight,
                    getTooltipItems: (spots) => spots
                        .map((s) => LineTooltipItem(
                              AppUtils.formatCurrency(s.y),
                              GoogleFonts.poppins(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: s.barIndex == 0
                                      ? AppColors.green
                                      : AppColors.red),
                            ))
                        .toList(),
                  ),
                ),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  getDrawingHorizontalLine: (_) => FlLine(
                    color: AppColors.cardBorder.withValues(alpha: 0.5),
                    strokeWidth: 1,
                  ),
                ),
                borderData: FlBorderData(show: false),
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
                      reservedSize: 24,
                      interval: step <= 7 ? 1 : (step / 6).ceilToDouble(),
                      getTitlesWidget: (v, _) {
                        final idx = v.toInt();
                        if (idx < 0 || idx >= dailyData.length) {
                          return const SizedBox.shrink();
                        }
                        return Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Text(
                            dailyData[idx].label,
                            style: GoogleFonts.poppins(
                                fontSize: 8,
                                color: AppColors.textMuted),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                lineBarsData: [
                  LineChartBarData(
                    spots: List.generate(
                        dailyData.length,
                        (i) => FlSpot(
                            i.toDouble(), dailyData[i].deposits)),
                    isCurved: true,
                    color: AppColors.green,
                    barWidth: 2,
                    dotData: const FlDotData(show: false),
                    belowBarData: BarAreaData(
                      show: true,
                      color: AppColors.green.withValues(alpha: 0.08),
                    ),
                  ),
                  LineChartBarData(
                    spots: List.generate(
                        dailyData.length,
                        (i) => FlSpot(
                            i.toDouble(), dailyData[i].withdrawals)),
                    isCurved: true,
                    color: AppColors.red,
                    barWidth: 2,
                    dotData: const FlDotData(show: false),
                    belowBarData: BarAreaData(
                      show: true,
                      color: AppColors.red.withValues(alpha: 0.06),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _legendDot(Color color, String label) {
    return Row(
      children: [
        Container(
            width: 8,
            height: 8,
            decoration:
                BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 5),
        Text(label,
            style: GoogleFonts.poppins(
                fontSize: 10, color: AppColors.textSecondary)),
      ],
    );
  }
}

// â”€â”€ Bet Outcomes â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
class _BetOutcomesRow extends StatelessWidget {
  final int won, lost, active;
  final double betVolume;
  const _BetOutcomesRow(
      {required this.won,
      required this.lost,
      required this.active,
      required this.betVolume});

  @override
  Widget build(BuildContext context) {
    final total = won + lost + active;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: total == 0
          ? _emptyCard('No bets in this period')
          : Row(
              children: [
                SizedBox(
                  width: 120,
                  height: 120,
                  child: PieChart(
                    PieChartData(
                      sectionsSpace: 3,
                      centerSpaceRadius: 28,
                      sections: [
                        if (won > 0)
                          PieChartSectionData(
                            value: won.toDouble(),
                            color: AppColors.green,
                            radius: 32,
                            title: '$won',
                            titleStyle: GoogleFonts.poppins(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: Colors.white),
                          ),
                        if (lost > 0)
                          PieChartSectionData(
                            value: lost.toDouble(),
                            color: AppColors.red,
                            radius: 32,
                            title: '$lost',
                            titleStyle: GoogleFonts.poppins(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: Colors.white),
                          ),
                        if (active > 0)
                          PieChartSectionData(
                            value: active.toDouble(),
                            color: AppColors.orange,
                            radius: 32,
                            title: '$active',
                            titleStyle: GoogleFonts.poppins(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: Colors.white),
                          ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _outcomeRow('Won', won, total, AppColors.green),
                      const SizedBox(height: 8),
                      _outcomeRow('Lost', lost, total, AppColors.red),
                      const SizedBox(height: 8),
                      _outcomeRow(
                          'Active', active, total, AppColors.orange),
                      const SizedBox(height: 12),
                      Text(
                        'Win Rate: ${total > 0 ? (won / total * 100).toStringAsFixed(1) : '0.0'}%',
                        style: GoogleFonts.poppins(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: AppColors.accent),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  Widget _outcomeRow(String label, int val, int total, Color color) {
    final pct = total > 0 ? val / total : 0.0;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
                width: 8,
                height: 8,
                decoration:
                    BoxDecoration(color: color, shape: BoxShape.circle)),
            const SizedBox(width: 6),
            Text(label,
                style: GoogleFonts.poppins(
                    fontSize: 11, color: AppColors.textSecondary)),
            const Spacer(),
            Text('$val',
                style: GoogleFonts.poppins(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: AppColors.white)),
          ],
        ),
        const SizedBox(height: 3),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: pct,
            backgroundColor: AppColors.cardBorder,
            color: color,
            minHeight: 4,
          ),
        ),
      ],
    );
  }
}

// â”€â”€ Event Table â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
class _EventTable extends StatelessWidget {
  final List<BetModel> bets;
  const _EventTable({required this.bets});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        children: [
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: const BoxDecoration(
              color: AppColors.cardLight,
              borderRadius:
                  BorderRadius.vertical(top: Radius.circular(14)),
            ),
            child: Row(children: [
              Expanded(
                  flex: 3,
                  child: Text('Match',
                      style: GoogleFonts.poppins(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: AppColors.accent))),
              Expanded(
                  flex: 1,
                  child: Text('Bets',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: AppColors.accent))),
              Expanded(
                  flex: 2,
                  child: Text('Volume',
                      textAlign: TextAlign.right,
                      style: GoogleFonts.poppins(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: AppColors.accent))),
              Expanded(
                  flex: 1,
                  child: Text('W/L',
                      textAlign: TextAlign.right,
                      style: GoogleFonts.poppins(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: AppColors.accent))),
            ]),
          ),
          ...mockEvents.map((event) {
            final eb = bets.where((b) => b.eventId == event.id).toList();
            final volume = eb.fold<double>(0, (s, b) => s + b.amount);
            final w = eb.where((b) => b.status == 'won').length;
            final l = eb.where((b) => b.status == 'lost').length;
            return Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 14, vertical: 10),
              decoration: const BoxDecoration(
                border: Border(
                    top: BorderSide(
                        color: AppColors.cardBorder, width: 0.5)),
              ),
              child: Row(children: [
                Expanded(
                  flex: 3,
                  child: Text(
                    '${event.team1} vs ${event.team2}',
                    style: GoogleFonts.poppins(
                        fontSize: 11.5, color: AppColors.white),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Text(
                    '${eb.length}',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                        fontSize: 11.5,
                        color: AppColors.textSecondary),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    AppUtils.formatCurrency(volume),
                    textAlign: TextAlign.right,
                    style: GoogleFonts.poppins(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w700,
                        color: AppColors.accent),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Text(
                    '$w/$l',
                    textAlign: TextAlign.right,
                    style: GoogleFonts.poppins(
                        fontSize: 11,
                        color: w > l ? AppColors.green : AppColors.red),
                  ),
                ),
              ]),
            );
          }),
        ],
      ),
    );
  }
}

// â”€â”€ Transaction Log â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
class _TransactionLog extends StatelessWidget {
  final List<TransactionModel> txns;
  const _TransactionLog({required this.txns});

  @override
  Widget build(BuildContext context) {
    if (txns.isEmpty) return _emptyCard('No transactions in this period');
    return Container(
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        children: List.generate(txns.length, (i) {
          final t = txns[i];
          final isCredit =
              t.type == 'deposit' || t.type == 'win_credit';
          final color = isCredit ? AppColors.green : AppColors.red;
          final isLast = i == txns.length - 1;
          return Container(
            padding: const EdgeInsets.symmetric(
                horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              border: isLast
                  ? null
                  : const Border(
                      bottom: BorderSide(
                          color: AppColors.cardBorder, width: 0.5)),
            ),
            child: Row(
              children: [
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: color.withValues(alpha: 0.1),
                  ),
                  child: Icon(
                    isCredit
                        ? Icons.south_east_rounded
                        : Icons.north_east_rounded,
                    color: color,
                    size: 16,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        t.type.replaceAll('_', ' ').toUpperCase(),
                        style: GoogleFonts.poppins(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: AppColors.white),
                      ),
                      Text(
                        'UID: ${t.userId}  â€¢  ${t.notes}',
                        style: GoogleFonts.poppins(
                            fontSize: 10, color: AppColors.textMuted),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${isCredit ? '+' : '-'}${AppUtils.formatCurrency(t.amount)}',
                      style: GoogleFonts.poppins(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: color),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: (t.status == 'completed'
                                ? AppColors.green
                                : t.status == 'pending'
                                    ? AppColors.orange
                                    : AppColors.red)
                            .withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        t.status,
                        style: GoogleFonts.poppins(
                            fontSize: 9,
                            fontWeight: FontWeight.w600,
                            color: t.status == 'completed'
                                ? AppColors.green
                                : t.status == 'pending'
                                    ? AppColors.orange
                                    : AppColors.red),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        }),
      ),
    );
  }
}

// â”€â”€ Top Bettors â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
class _TopBettors extends StatelessWidget {
  final List<BetModel> bets;
  const _TopBettors({required this.bets});

  @override
  Widget build(BuildContext context) {
    // Aggregate by userId
    final Map<String, double> volumes = {};
    final Map<String, int> counts = {};
    for (final b in bets) {
      volumes[b.userId] = (volumes[b.userId] ?? 0) + b.amount;
      counts[b.userId] = (counts[b.userId] ?? 0) + 1;
    }

    final sorted = volumes.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final top = sorted.take(5).toList();

    if (top.isEmpty) return _emptyCard('No betting activity');

    final maxVol = top.first.value;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        children: List.generate(top.length, (i) {
          final userId = top[i].key;
          final vol = top[i].value;
          final betCount = counts[userId] ?? 0;
          final user = mockUsers
              .where((u) => u.id == userId)
              .firstOrNull;
          final name = user?.name ?? userId;
          final colors = [
            AppColors.accent, AppColors.blue, AppColors.green,
            AppColors.purple, AppColors.orange
          ];
          final color = colors[i % colors.length];

          return Container(
            padding: const EdgeInsets.symmetric(
                horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              border: i == 0
                  ? null
                  : const Border(
                      top: BorderSide(
                          color: AppColors.cardBorder, width: 0.5)),
            ),
            child: Row(
              children: [
                Container(
                  width: 26,
                  height: 26,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      '#${i + 1}',
                      style: GoogleFonts.poppins(
                          fontSize: 9,
                          fontWeight: FontWeight.w800,
                          color: color),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: GoogleFonts.poppins(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.white),
                      ),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(3),
                        child: LinearProgressIndicator(
                          value: maxVol > 0 ? vol / maxVol : 0,
                          backgroundColor: AppColors.cardBorder,
                          color: color,
                          minHeight: 3,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      AppUtils.formatCurrency(vol),
                      style: GoogleFonts.poppins(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: AppColors.white),
                    ),
                    Text(
                      '$betCount bets',
                      style: GoogleFonts.poppins(
                          fontSize: 9, color: AppColors.textMuted),
                    ),
                  ],
                ),
              ],
            ),
          );
        }),
      ),
    );
  }
}

Widget _emptyCard(String msg) {
  return Container(
    width: double.infinity,
    padding: const EdgeInsets.all(24),
    decoration: BoxDecoration(
      color: AppColors.card,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: AppColors.cardBorder),
    ),
    child: Text(
      msg,
      textAlign: TextAlign.center,
      style: GoogleFonts.poppins(
          fontSize: 13, color: AppColors.textSecondary),
    ),
  );
}

