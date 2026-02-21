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
                Text(
                  'Wallet',
                  style: GoogleFonts.poppins(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: AppColors.white,
                  ),
                ),
                const SizedBox(height: 16),

                // Balance card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [AppColors.primary, AppColors.card],
                    ),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                        color: AppColors.accent.withValues(alpha: 0.2)),
                  ),
                  child: Column(
                    children: [
                      Text(
                        'Available Balance',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        AppUtils.formatCurrency(user.walletBalance),
                        style: GoogleFonts.poppins(
                          fontSize: 36,
                          fontWeight: FontWeight.w800,
                          color: AppColors.accent,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () => context.push('/deposit'),
                              icon: const Icon(Icons.add, size: 18),
                              label: Text('Deposit',
                                  style: GoogleFonts.poppins(
                                      fontWeight: FontWeight.w600)),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.green,
                                foregroundColor: Colors.white,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () => context.push('/withdraw'),
                              icon: const Icon(Icons.remove, size: 18),
                              label: Text('Withdraw',
                                  style: GoogleFonts.poppins(
                                      fontWeight: FontWeight.w600)),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.red,
                                foregroundColor: Colors.white,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Transaction History
                Text(
                  'Transaction History',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.white,
                  ),
                ),
                const SizedBox(height: 12),

                if (transactions.isEmpty)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(32),
                    decoration: BoxDecoration(
                      color: AppColors.card,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      children: [
                        Icon(Icons.receipt_long,
                            size: 48,
                            color: AppColors.accent.withValues(alpha: 0.3)),
                        const SizedBox(height: 8),
                        Text(
                          'No transactions yet',
                          style: GoogleFonts.poppins(
                            color: AppColors.textSecondary,
                          ),
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
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.cardLight),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  txn.type.replaceAll('_', ' ').toUpperCase(),
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.white,
                  ),
                ),
                Text(
                  txn.notes ?? '',
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    color: AppColors.textSecondary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  AppUtils.formatDateShort(txn.createdAt),
                  style: GoogleFonts.poppins(
                    fontSize: 10,
                    color: AppColors.grey,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${isCredit ? '+' : '-'}${AppUtils.formatCurrency(txn.amount)}',
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: isCredit ? AppColors.green : AppColors.red,
                ),
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
