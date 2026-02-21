import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/wallet_provider.dart';
import '../../theme/app_theme.dart';
import '../../utils/app_utils.dart';
import '../../widgets/status_badge.dart';

class WalletScreen extends StatelessWidget {
  const WalletScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final walletProvider = context.watch<WalletProvider>();
    final user = auth.currentUser;

    if (user == null) return const SizedBox();

    final transactions = walletProvider.getTransactionsForUser(user.id);

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
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: AppColors.card,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.accent.withValues(alpha: 0.3)),
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
                const SizedBox(height: 20),
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
                  ],
                ),
                const SizedBox(height: 10),
                if (transactions.isEmpty)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(32),
                    decoration: BoxDecoration(
                      color: AppColors.card,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.cardBorder),
                    ),
                    child: Column(
                      children: [
                        Icon(Icons.receipt_long, size: 40, color: AppColors.textMuted),
                        const SizedBox(height: 8),
                        Text(
                          'No transactions yet',
                          style: GoogleFonts.poppins(fontSize: 13, color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  )
                else
                  ...transactions.map((txn) => _transactionTile(txn)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _actionBtn(IconData icon, String label, Color color, VoidCallback onTap) {
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
            Text(label, style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600, color: color)),
          ],
        ),
      ),
    );
  }

  Widget _transactionTile(dynamic txn) {
    IconData icon;
    Color iconColor;
    switch (txn.type) {
      case 'deposit':
        icon = Icons.arrow_downward;
        iconColor = AppColors.green;
        break;
      case 'withdrawal':
        icon = Icons.arrow_upward;
        iconColor = AppColors.red;
        break;
      case 'bet_debit':
        icon = Icons.sports_cricket;
        iconColor = AppColors.orange;
        break;
      case 'win_credit':
        icon = Icons.emoji_events;
        iconColor = AppColors.gold;
        break;
      default:
        icon = Icons.swap_horiz;
        iconColor = AppColors.grey;
    }
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
            width: 40,
            height: 40,
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
                  txn.type.replaceAll('_', ' ').toUpperCase(),
                  style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.white),
                ),
                Text(
                  txn.notes ?? '',
                  style: GoogleFonts.poppins(fontSize: 11, color: AppColors.textSecondary),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  AppUtils.formatDateShort(txn.createdAt),
                  style: GoogleFonts.poppins(fontSize: 10, color: AppColors.textMuted),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${isCredit ? '+' : '-'}${AppUtils.formatCurrency(txn.amount)}',
                style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w700, color: isCredit ? AppColors.green : AppColors.red),
              ),
              const SizedBox(height: 4),
              StatusBadge(status: txn.status, fontSize: 9),
            ],
          ),
        ],
      ),
    );
  }
}