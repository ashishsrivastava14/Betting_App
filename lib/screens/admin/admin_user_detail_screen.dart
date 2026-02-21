import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../mock_data/mock_users.dart';
import '../../mock_data/mock_bets.dart';
import '../../mock_data/mock_transactions.dart';
import '../../theme/app_theme.dart';
import '../../utils/app_utils.dart';
import '../../widgets/status_badge.dart';

class AdminUserDetailScreen extends StatelessWidget {
  final String userId;
  const AdminUserDetailScreen({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    final user = mockUsers.firstWhere((u) => u.id == userId);
    final userBets = mockBets.where((b) => b.userId == userId).toList();
    final userTxns = mockTransactions.where((t) => t.userId == userId).toList();

    return Scaffold(
      appBar: AppBar(
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.card,
                border: Border.all(color: AppColors.cardBorder),
              ),
              child: const Icon(Icons.arrow_back, size: 18),
            ),
          ),
        ),
        title: Text('User Details', style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile Header Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.cardBorder),
              ),
              child: Column(
                children: [
                  Container(
                    width: 68,
                    height: 68,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.accent.withValues(alpha: 0.12),
                      border: Border.all(color: AppColors.accent, width: 2),
                    ),
                    child: ClipOval(
                      child: user.imageUrl != null
                          ? Image.asset(
                              user.imageUrl!,
                              width: 68,
                              height: 68,
                              fit: BoxFit.cover,
                              errorBuilder: (_, _, _) => Center(
                                child: Text(user.name[0].toUpperCase(),
                                    style: GoogleFonts.poppins(fontSize: 28, fontWeight: FontWeight.w700, color: AppColors.accent)),
                              ),
                            )
                          : Center(
                              child: Text(user.name[0].toUpperCase(),
                                  style: GoogleFonts.poppins(fontSize: 28, fontWeight: FontWeight.w700, color: AppColors.accent)),
                            ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                    Text(user.name, style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.white)),
                    if (user.kycVerified) ...[const SizedBox(width: 6), const Icon(Icons.verified, color: AppColors.green, size: 18)],
                  ]),
                  Text('+91 ${user.phone}', style: GoogleFonts.poppins(fontSize: 13, color: AppColors.textSecondary)),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      _miniStat('Balance', AppUtils.formatCurrency(user.walletBalance), AppColors.accent),
                      _miniStat('Bets', '${userBets.length}', AppColors.blue),
                      _miniStat('Won', '${userBets.where((b) => b.status == 'won').length}', AppColors.green),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Info Card
            _buildInfoCard(user),
            const SizedBox(height: 20),

            // Bets Section
            _sectionHeader(Icons.receipt_long_rounded, 'Betting History'),
            const SizedBox(height: 10),
            if (userBets.isEmpty)
              _emptyCard('No bets placed yet')
            else
              ...userBets.map((bet) => Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.card,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppColors.cardBorder),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.blue.withValues(alpha: 0.12),
                          ),
                          child: const Icon(Icons.sports_cricket, color: AppColors.blue, size: 18),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Option: ${bet.selectedOption}', style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.white)),
                              Text('Amount: ${AppUtils.formatCurrency(bet.amount)}', style: GoogleFonts.poppins(fontSize: 11, color: AppColors.textSecondary)),
                            ],
                          ),
                        ),
                        StatusBadge(status: bet.status),
                      ],
                    ),
                  )),
            const SizedBox(height: 20),

            // Transactions Section
            _sectionHeader(Icons.swap_horiz_rounded, 'Transactions'),
            const SizedBox(height: 10),
            if (userTxns.isEmpty)
              _emptyCard('No transactions')
            else
              ...userTxns.map((txn) {
                final isCredit = txn.type == 'deposit' || txn.type == 'win_credit';
                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.card,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.cardBorder),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: (isCredit ? AppColors.green : AppColors.red).withValues(alpha: 0.12),
                        ),
                        child: Icon(
                          isCredit ? Icons.arrow_downward_rounded : Icons.arrow_upward_rounded,
                          color: isCredit ? AppColors.green : AppColors.red,
                          size: 18,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(txn.type.replaceAll('_', ' ').toUpperCase(),
                                style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.white)),
                            Text(AppUtils.formatDate(txn.createdAt),
                                style: GoogleFonts.poppins(fontSize: 10, color: AppColors.textSecondary)),
                          ],
                        ),
                      ),
                      Text(
                        '${isCredit ? '+' : '-'}${AppUtils.formatCurrency(txn.amount)}',
                        style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w700, color: isCredit ? AppColors.green : AppColors.red),
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

  Widget _miniStat(String label, String value, Color color) {
    return Expanded(
      child: Column(children: [
        Text(value, style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w700, color: color)),
        Text(label, style: GoogleFonts.poppins(fontSize: 10, color: AppColors.textSecondary)),
      ]),
    );
  }

  Widget _buildInfoCard(dynamic user) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        children: [
          _infoRow(Icons.person_outline, 'Role', user.role.toUpperCase()),
          const Divider(color: AppColors.cardBorder, height: 16),
          _infoRow(Icons.shield_outlined, 'KYC', user.kycVerified ? 'Verified' : 'Pending'),
          const Divider(color: AppColors.cardBorder, height: 16),
          _infoRow(Icons.block, 'Status', user.isBlocked ? 'Blocked' : 'Active'),
          const Divider(color: AppColors.cardBorder, height: 16),
          _infoRow(Icons.calendar_today_outlined, 'Joined', AppUtils.formatDate(user.createdAt)),
        ],
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Row(children: [
      Icon(icon, size: 16, color: AppColors.textSecondary),
      const SizedBox(width: 8),
      Text('$label:', style: GoogleFonts.poppins(fontSize: 12, color: AppColors.textSecondary)),
      const Spacer(),
      Text(value, style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.white)),
    ]);
  }

  Widget _sectionHeader(IconData icon, String label) {
    return Row(children: [
      Icon(icon, color: AppColors.accent, size: 18),
      const SizedBox(width: 8),
      Text(label, style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.white)),
    ]);
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
      child: Text(msg, textAlign: TextAlign.center, style: GoogleFonts.poppins(fontSize: 13, color: AppColors.textSecondary)),
    );
  }
}