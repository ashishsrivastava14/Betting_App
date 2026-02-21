import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
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