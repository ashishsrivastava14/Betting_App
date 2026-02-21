import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../mock_data/mock_users.dart';
import '../../providers/bet_provider.dart';
import '../../providers/event_provider.dart';
import '../../providers/wallet_provider.dart';
import '../../theme/app_theme.dart';
import '../../utils/app_utils.dart';
import '../../widgets/status_badge.dart';

class AdminUserDetailScreen extends StatelessWidget {
  final String userId;

  const AdminUserDetailScreen({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    final user = mockUsers.cast().firstWhere(
      (u) => u.id == userId,
      orElse: () => null,
    );

    if (user == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('User')),
        body: const Center(child: Text('User not found')),
      );
    }

    final betProvider = context.watch<BetProvider>();
    final eventProvider = context.watch<EventProvider>();
    final walletProvider = context.watch<WalletProvider>();
    final userBets = betProvider.getBetsForUser(userId);
    final userTxns = walletProvider.getTransactionsForUser(userId);

    return Scaffold(
      appBar: AppBar(
        title: Text(user.name),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // User info
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.accent.withValues(alpha: 0.15),
                    ),
                    child: Center(
                      child: Text(
                        user.name[0].toUpperCase(),
                        style: GoogleFonts.poppins(
                          fontSize: 28,
                          fontWeight: FontWeight.w700,
                          color: AppColors.accent,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    user.name,
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppColors.white,
                    ),
                  ),
                  Text(
                    '+91 ${user.phone} • ${user.location}',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      StatusBadge(
                        status: user.kycVerified ? 'approved' : 'pending',
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Balance: ${AppUtils.formatCurrency(user.walletBalance)}',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppColors.accent,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Bet History
            Text(
              'Bet History (${userBets.length})',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.white,
              ),
            ),
            const SizedBox(height: 10),

            ...userBets.map((bet) {
              final event = eventProvider.getEventById(bet.eventId);
              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.card,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            event?.name ?? 'Unknown',
                            style: GoogleFonts.poppins(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: AppColors.white,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            '${bet.selectedOption} • ${bet.multiplier}x • ${AppUtils.formatCurrency(bet.amount)}',
                            style: GoogleFonts.poppins(
                              fontSize: 11,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    StatusBadge(status: bet.status),
                  ],
                ),
              );
            }),

            const SizedBox(height: 20),

            // Transactions
            Text(
              'Transactions (${userTxns.length})',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.white,
              ),
            ),
            const SizedBox(height: 10),

            ...userTxns.map((txn) {
              final isCredit =
                  txn.type == 'deposit' || txn.type == 'win_credit';
              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.card,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
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
                            txn.notes,
                            style: GoogleFonts.poppins(
                              fontSize: 11,
                              color: AppColors.textSecondary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
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
                            color: isCredit
                                ? AppColors.green
                                : AppColors.red,
                          ),
                        ),
                        StatusBadge(status: txn.status, fontSize: 9),
                      ],
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
