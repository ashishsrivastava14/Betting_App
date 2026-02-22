import 'package:excel/excel.dart' as xl;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../utils/excel_download.dart';
import '../../models/transaction_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/wallet_provider.dart';
import '../../theme/app_theme.dart';
import '../../utils/app_utils.dart';
import '../../widgets/status_badge.dart';

class WalletScreen extends StatefulWidget {
  const WalletScreen({super.key});

  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  String _activeFilter = 'all';
  bool _isExporting = false;

  static const _filters = [
    ('all',        'All',         Icons.list_rounded),
    ('deposit',    'Deposits',    Icons.arrow_downward_rounded),
    ('withdrawal', 'Withdrawals', Icons.arrow_upward_rounded),
    ('bet',        'Bets',        Icons.sports_cricket),
  ];

  List<TransactionModel> _applyFilter(List<TransactionModel> txns) {
    switch (_activeFilter) {
      case 'deposit':
        return txns.where((t) => t.type == 'deposit').toList();
      case 'withdrawal':
        return txns.where((t) => t.type == 'withdrawal').toList();
      case 'bet':
        return txns
            .where((t) => t.type == 'bet_debit' || t.type == 'win_credit')
            .toList();
      default:
        return txns;
    }
  }

  // ── Export to Excel ──
  Future<void> _exportToExcel(List<TransactionModel> txns, String userId) async {
    if (_isExporting) return;
    setState(() => _isExporting = true);
    try {
      await _doExport(txns, userId);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Exported ${txns.length} transactions successfully',
            style: GoogleFonts.poppins(fontSize: 13),
          ),
          backgroundColor: AppColors.green,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Export failed: $e',
            style: GoogleFonts.poppins(fontSize: 13),
          ),
          backgroundColor: AppColors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    } finally {
      if (mounted) setState(() => _isExporting = false);
    }
  }

  Future<void> _doExport(List<TransactionModel> txns, String userId) async {
    final excel = xl.Excel.createExcel();
    excel.rename('Sheet1', 'Transactions');
    final sheet = excel['Transactions'];

    // --- Header row style ---
    final headerBg = xl.ExcelColor.fromHexString('#CFB53B');
    final headerFont = xl.CellStyle(
      bold: true,
      fontColorHex: xl.ExcelColor.fromHexString('#0D1117'),
      backgroundColorHex: headerBg,
      horizontalAlign: xl.HorizontalAlign.Center,
    );

    final headers = [
      'Transaction ID',
      'Type',
      'Amount (₹)',
      'Status',
      'Date & Time',
      'Notes',
    ];

    sheet.appendRow(headers.map((h) => xl.TextCellValue(h)).toList());
    for (int col = 0; col < headers.length; col++) {
      final cell = sheet.cell(xl.CellIndex.indexByColumnRow(columnIndex: col, rowIndex: 0));
      cell.cellStyle = headerFont;
    }

    // Set column widths
    sheet.setColumnWidth(0, 18);
    sheet.setColumnWidth(1, 14);
    sheet.setColumnWidth(2, 14);
    sheet.setColumnWidth(3, 12);
    sheet.setColumnWidth(4, 22);
    sheet.setColumnWidth(5, 30);

    // --- Data rows ---
    final dtFormatter = DateFormat('dd MMM yyyy, hh:mm a');
    for (final txn in txns) {
      final typeLabel = switch (txn.type) {
        'deposit'    => 'Deposit',
        'withdrawal' => 'Withdrawal',
        'bet_debit'  => 'Bet Placed',
        'win_credit' => 'Win Credit',
        _            => txn.type,
      };
      sheet.appendRow([
        xl.TextCellValue(txn.id),
        xl.TextCellValue(typeLabel),
        xl.DoubleCellValue(txn.amount),
        xl.TextCellValue(txn.status.toUpperCase()),
        xl.TextCellValue(dtFormatter.format(txn.createdAt)),
        xl.TextCellValue(txn.notes),
      ]);
    }

    // --- Save & share ---
    final bytes = excel.encode();
    if (bytes == null) throw Exception('Failed to encode Excel file');

    final fileName =
        'transactions_${userId}_${DateFormat('yyyyMMdd_HHmmss').format(DateTime.now())}.xlsx';
    await saveAndShareExcel(bytes, fileName, 'Transaction History – $userId');
  }

  (IconData, Color, String) _txnMeta(String type) {
    switch (type) {
      case 'deposit':
        return (Icons.arrow_downward_rounded, AppColors.green, 'Deposit');
      case 'withdrawal':
        return (Icons.arrow_upward_rounded, AppColors.red, 'Withdrawal');
      case 'bet_debit':
        return (Icons.sports_cricket, AppColors.orange, 'Bet Placed');
      case 'win_credit':
        return (Icons.emoji_events, AppColors.gold, 'Win Credit');
      default:
        return (Icons.swap_horiz, AppColors.grey, 'Transaction');
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final walletProvider = context.watch<WalletProvider>();
    final user = auth.currentUser;

    if (user == null) return const SizedBox();

    final allTxns = walletProvider.getTransactionsForUser(user.id);
    final filteredTxns = _applyFilter(allTxns);

    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          color: AppColors.accent,
          backgroundColor: AppColors.card,
          onRefresh: () async {
            await Future.delayed(const Duration(seconds: 1));
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Header ──
                Row(
                  children: [
                    const Icon(Icons.account_balance_wallet_rounded,
                        color: AppColors.accent, size: 24),
                    const SizedBox(width: 10),
                    Text(
                      'Wallet',
                      style: GoogleFonts.poppins(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: AppColors.white,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // ── Balance card ──
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: AppColors.card,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                        color: AppColors.accent.withValues(alpha: 0.3)),
                  ),
                  child: Column(
                    children: [
                      const Icon(Icons.account_balance_wallet,
                          color: AppColors.accent, size: 32),
                      const SizedBox(height: 8),
                      Text(
                        'Available Balance',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        AppUtils.formatCurrency(user.walletBalance),
                        style: GoogleFonts.poppins(
                          fontSize: 32,
                          fontWeight: FontWeight.w800,
                          color: AppColors.accent,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: _actionBtn(
                              Icons.arrow_downward_rounded,
                              'Deposit',
                              AppColors.green,
                              () => context.push('/deposit'),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _actionBtn(
                              Icons.arrow_upward_rounded,
                              'Withdraw',
                              AppColors.red,
                              () => context.push('/withdraw'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // ── Transaction History header ──
                Row(
                  children: [
                    const Icon(Icons.receipt_long,
                        size: 18, color: AppColors.accent),
                    const SizedBox(width: 8),
                    Text(
                      'Transaction History',
                      style: GoogleFonts.poppins(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppColors.white,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '${filteredTxns.length} records',
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        color: AppColors.textMuted,
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Export to Excel button
                    if (allTxns.isNotEmpty)
                      GestureDetector(
                        onTap: _isExporting
                            ? null
                            : () => _exportToExcel(allTxns, user.id),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: _isExporting
                                ? AppColors.green.withValues(alpha: 0.06)
                                : AppColors.green.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                                color: AppColors.green.withValues(alpha: _isExporting ? 0.15 : 0.35)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (_isExporting)
                                const SizedBox(
                                  width: 13,
                                  height: 13,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 1.5,
                                    valueColor: AlwaysStoppedAnimation<Color>(AppColors.green),
                                  ),
                                )
                              else
                                const Icon(Icons.file_download_outlined,
                                    size: 13, color: AppColors.green),
                              const SizedBox(width: 4),
                              Text(
                                _isExporting ? 'Exporting...' : 'Export',
                                style: GoogleFonts.poppins(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: _isExporting
                                      ? AppColors.green.withValues(alpha: 0.5)
                                      : AppColors.green,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 12),

                // ── Filter chips ──
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: _filters.map((f) {
                      final (value, label, icon) = f;
                      final isActive = _activeFilter == value;
                      return GestureDetector(
                        onTap: () =>
                            setState(() => _activeFilter = value),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 180),
                          margin: const EdgeInsets.only(right: 8),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 7),
                          decoration: BoxDecoration(
                            color: isActive
                                ? AppColors.accent.withValues(alpha: 0.15)
                                : AppColors.card,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: isActive
                                  ? AppColors.accent
                                  : AppColors.cardBorder,
                              width: isActive ? 1.5 : 1,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(icon,
                                  size: 13,
                                  color: isActive
                                      ? AppColors.accent
                                      : AppColors.textSecondary),
                              const SizedBox(width: 5),
                              Text(
                                label,
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  fontWeight: isActive
                                      ? FontWeight.w700
                                      : FontWeight.w500,
                                  color: isActive
                                      ? AppColors.accent
                                      : AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 12),

                // ── Transaction list ──
                if (filteredTxns.isEmpty)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 40),
                    decoration: BoxDecoration(
                      color: AppColors.card,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.cardBorder),
                    ),
                    child: Column(
                      children: [
                        Icon(Icons.receipt_long,
                            size: 40, color: AppColors.textMuted),
                        const SizedBox(height: 8),
                        Text(
                          allTxns.isEmpty
                              ? 'No transactions yet'
                              : 'No ${_filters.firstWhere((f) => f.$1 == _activeFilter).$2.toLowerCase()} found',
                          style: GoogleFonts.poppins(
                              fontSize: 13,
                              color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  )
                else
                  ...filteredTxns.map((txn) => _transactionTile(txn)),

                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _actionBtn(
      IconData icon, String label, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 6),
            Text(label,
                style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: color)),
          ],
        ),
      ),
    );
  }

  Widget _transactionTile(TransactionModel txn) {
    final (icon, iconColor, label) = _txnMeta(txn.type);
    final isCredit = txn.type == 'deposit' || txn.type == 'win_credit';

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: iconColor.withValues(alpha: 0.12),
            ),
            child: Icon(icon, color: iconColor, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.poppins(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.white),
                ),
                if (txn.notes.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    txn.notes,
                    style: GoogleFonts.poppins(
                        fontSize: 11, color: AppColors.textSecondary),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                const SizedBox(height: 2),
                Text(
                  AppUtils.formatDateShort(txn.createdAt),
                  style: GoogleFonts.poppins(
                      fontSize: 10, color: AppColors.textMuted),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${isCredit ? '+' : '-'}${AppUtils.formatCurrency(txn.amount)}',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: isCredit ? AppColors.green : AppColors.red,
                ),
              ),
              const SizedBox(height: 4),
              StatusBadge(status: txn.status, fontSize: 9.0),
            ],
          ),
        ],
      ),
    );
  }
}