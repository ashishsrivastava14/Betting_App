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
    final wonBets = betProvider
        .getBetsForUser(user.id)
        .where((b) => b.status == 'won')
        .length;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              const SizedBox(height: 16),

              // Avatar
              Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [AppColors.accent, AppColors.primary],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.accent.withValues(alpha: 0.3),
                      blurRadius: 15,
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    user.name.isNotEmpty
                        ? user.name[0].toUpperCase()
                        : 'U',
                    style: GoogleFonts.poppins(
                      fontSize: 36,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                user.name,
                style: GoogleFonts.poppins(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: AppColors.white,
                ),
              ),
              Text(
                '+91 ${user.phone}',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),

              const SizedBox(height: 24),

              // Stats row
              Row(
                children: [
                  _statItem('Balance',
                      AppUtils.formatCurrency(user.walletBalance)),
                  _divider(),
                  _statItem('Total Bets', '$totalBets'),
                  _divider(),
                  _statItem('Won', '$wonBets'),
                ],
              ),

              const SizedBox(height: 24),

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
                  valueColor:
                      user.kycVerified ? AppColors.green : AppColors.orange,
                ),
                _infoRow(Icons.badge, 'User ID', user.id),
              ]),

              const SizedBox(height: 16),

              // Actions card
              _infoCard([
                _actionRow(Icons.headset_mic, 'Contact Support', () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Support feature coming soon!')),
                  );
                }),
                _actionRow(Icons.description, 'Terms & Conditions', () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Terms page coming soon!')),
                  );
                }),
                _actionRow(Icons.info_outline, 'About BetZone', () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('BetZone v1.0')),
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
                  icon: const Icon(Icons.logout, color: AppColors.red),
                  label: Text(
                    'Logout',
                    style: GoogleFonts.poppins(
                      color: AppColors.red,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.red),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
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

  Widget _statItem(String label, String value) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.accent,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 11,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _divider() {
    return Container(
      width: 1,
      height: 30,
      color: AppColors.cardLight,
    );
  }

  Widget _infoCard(List<Widget> children) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(children: children),
    );
  }

  Widget _infoRow(IconData icon, String label, String value,
      {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: AppColors.accent, size: 18),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: valueColor ?? AppColors.white,
            ),
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
            Expanded(
              child: Text(
                label,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: AppColors.white,
                ),
              ),
            ),
            const Icon(Icons.chevron_right,
                color: AppColors.grey, size: 20),
          ],
        ),
      ),
    );
  }
}
