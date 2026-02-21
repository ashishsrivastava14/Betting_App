import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/bet_provider.dart';
import '../../theme/app_theme.dart';
import '../../utils/app_utils.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final betProvider = context.watch<BetProvider>();
    final user = auth.currentUser;

    if (user == null) return const SizedBox();

    final totalBets = betProvider.getBetsForUser(user.id).length;
    final wonBets = betProvider.getBetsForUser(user.id).where((b) => b.status == 'won').length;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              const SizedBox(height: 16),

              // Avatar
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.accent.withValues(alpha: 0.15),
                  border: Border.all(color: AppColors.accent, width: 2),
                ),
                child: Center(
                  child: Text(
                    user.name.isNotEmpty ? user.name[0].toUpperCase() : 'U',
                    style: GoogleFonts.poppins(
                      fontSize: 32,
                      fontWeight: FontWeight.w800,
                      color: AppColors.accent,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                user.name,
                style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.white),
              ),
              Text(
                '+91 ${user.phone}',
                style: GoogleFonts.poppins(fontSize: 13, color: AppColors.textSecondary),
              ),

              const SizedBox(height: 20),

              // Stats row
              Container(
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  color: AppColors.card,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.cardBorder),
                ),
                child: Row(
                  children: [
                    _statItem('Balance', AppUtils.formatCurrency(user.walletBalance), AppColors.accent),
                    Container(width: 1, height: 30, color: AppColors.cardBorder),
                    _statItem('Total Bets', '$totalBets', AppColors.blue),
                    Container(width: 1, height: 30, color: AppColors.cardBorder),
                    _statItem('Won', '$wonBets', AppColors.green),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Profile info card
              _infoCard([
                _infoRow(Icons.person, 'Name', user.name),
                _infoRow(Icons.phone, 'Phone', '+91 ${user.phone}'),
                _infoRow(Icons.cake, 'Date of Birth', user.dob),
                _infoRow(Icons.location_on, 'Location', user.location),
                _infoRow(
                  Icons.verified_user,
                  'KYC Status',
                  user.kycVerified ? 'Verified' : 'Not Verified',
                  valueColor: user.kycVerified ? AppColors.green : AppColors.orange,
                ),
                _infoRow(Icons.badge, 'User ID', user.id),
              ]),

              const SizedBox(height: 12),

              // Actions card
              _infoCard([
                _actionRow(Icons.headset_mic, 'Contact Support', () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Support feature coming soon!')),
                  );
                }),
                _actionRow(Icons.description, 'Terms & Conditions', () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Terms page coming soon!')),
                  );
                }),
                _actionRow(Icons.info_outline, 'About BetZone', () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('BetZone v1.0')),
                  );
                }),
              ]),

              const SizedBox(height: 16),

              // Logout
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () {
                    auth.logout();
                    context.go('/login');
                  },
                  icon: const Icon(Icons.logout, color: AppColors.red, size: 18),
                  label: Text(
                    'Logout',
                    style: GoogleFonts.poppins(color: AppColors.red, fontWeight: FontWeight.w600),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.red),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _statItem(String label, String value, Color color) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w700, color: color),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          Text(label, style: GoogleFonts.poppins(fontSize: 10, color: AppColors.textSecondary)),
        ],
      ),
    );
  }

  Widget _infoCard(List<Widget> children) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(children: children),
    );
  }

  Widget _infoRow(IconData icon, String label, String value, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: AppColors.accent, size: 18),
          const SizedBox(width: 12),
          Expanded(
            child: Text(label, style: GoogleFonts.poppins(fontSize: 13, color: AppColors.textSecondary)),
          ),
          Text(
            value,
            style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600, color: valueColor ?? AppColors.white),
          ),
        ],
      ),
    );
  }

  Widget _actionRow(IconData icon, String label, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          children: [
            Icon(icon, color: AppColors.accent, size: 18),
            const SizedBox(width: 12),
            Expanded(child: Text(label, style: GoogleFonts.poppins(fontSize: 14, color: AppColors.white))),
            const Icon(Icons.chevron_right, color: AppColors.textMuted, size: 20),
          ],
        ),
      ),
    );
  }
}