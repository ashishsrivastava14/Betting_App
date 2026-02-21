import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
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
                child: ClipOval(
                  child: user.imageUrl != null
                      ? Image.asset(
                          user.imageUrl!,
                          width: 80,
                          height: 80,
                          fit: BoxFit.cover,
                          errorBuilder: (_, _, _) => Center(
                            child: Text(
                              user.name.isNotEmpty ? user.name[0].toUpperCase() : 'U',
                              style: GoogleFonts.poppins(
                                fontSize: 32,
                                fontWeight: FontWeight.w800,
                                color: AppColors.accent,
                              ),
                            ),
                          ),
                        )
                      : Center(
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
                  _showContactSupport(context);
                }),
                _actionRow(Icons.description, 'Terms & Conditions', () {
                  _showTermsAndConditions(context);
                }),
                _actionRow(Icons.info_outline, 'About BetZone', () {
                  _showAboutBetZone(context);
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

  // ── Contact Support ─────────────────────────────────────────────────────────
  void _showContactSupport(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.card,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(ctx).viewInsets.bottom +
              MediaQuery.of(ctx).padding.bottom,
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: AppColors.cardBorder,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),

              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.accent.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.headset_mic, color: AppColors.accent, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Contact Support',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppColors.white,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Our team is available Mon – Sat, 9 AM to 6 PM (IST)',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 24),

              _contactTile(
                context,
                icon: Icons.email_outlined,
                title: 'Email Us',
                subtitle: 'support@betzone.in',
                onTap: () => _launch('mailto:support@betzone.in'),
              ),
              const SizedBox(height: 12),
              _contactTile(
                context,
                icon: Icons.phone_outlined,
                title: 'Call Us',
                subtitle: '+91 98765 43210',
                onTap: () => _launch('tel:+919876543210'),
              ),
              const SizedBox(height: 12),
              _contactTile(
                context,
                icon: Icons.chat_bubble_outline_rounded,
                title: 'WhatsApp Support',
                subtitle: 'Chat with us on WhatsApp',
                onTap: () => _launch('https://wa.me/919876543210'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _contactTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.cardBorder),
        ),
        child: Row(
          children: [
            Icon(icon, color: AppColors.accent, size: 22),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: GoogleFonts.poppins(
                          fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.white)),
                  Text(subtitle,
                      style: GoogleFonts.poppins(fontSize: 12, color: AppColors.textSecondary)),
                ],
              ),
            ),
            const Icon(Icons.open_in_new_rounded, size: 16, color: AppColors.textMuted),
          ],
        ),
      ),
    );
  }

  Future<void> _launch(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  // ── Terms & Conditions ───────────────────────────────────────────────────────
  void _showTermsAndConditions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.card,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) {
        return DraggableScrollableSheet(
          initialChildSize: 0.85,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          expand: false,
          builder: (__, scrollController) => Column(
            children: [
              // Handle + header
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 36,
                        height: 4,
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: AppColors.cardBorder,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.accent.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(Icons.description_rounded,
                              color: AppColors.accent, size: 20),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Terms & Conditions',
                          style: GoogleFonts.poppins(
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                            color: AppColors.white,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Last updated: February 2026',
                      style: GoogleFonts.poppins(fontSize: 11, color: AppColors.textSecondary),
                    ),
                    const Divider(height: 24, color: AppColors.cardBorder),
                  ],
                ),
              ),

              // Scrollable body
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
                  children: const [
                    _TermsSection(
                      title: '1. Eligibility',
                      body:
                          'You must be at least 18 years of age and a resident of a jurisdiction where fantasy sports and skill-based gaming are permitted. By using BetZone, you confirm that you meet these requirements.',
                    ),
                    _TermsSection(
                      title: '2. Account Responsibility',
                      body:
                          'You are responsible for maintaining the confidentiality of your account credentials. Any activity conducted through your account is your sole responsibility. Report unauthorised access immediately.',
                    ),
                    _TermsSection(
                      title: '3. Deposits & Withdrawals',
                      body:
                          'All deposits are processed securely. Withdrawals are subject to KYC verification and may take 2–5 business days. BetZone reserves the right to withhold funds pending fraud investigation.',
                    ),
                    _TermsSection(
                      title: '4. Fair Play',
                      body:
                          'Any attempt to manipulate results, use bots, or exploit system vulnerabilities will result in immediate account suspension and forfeiture of all winnings.',
                    ),
                    _TermsSection(
                      title: '5. Privacy',
                      body:
                          'We collect and process personal data in accordance with our Privacy Policy. Your data is never sold to third parties. By registering, you consent to our data practices.',
                    ),
                    _TermsSection(
                      title: '6. Limitation of Liability',
                      body:
                          'BetZone is not liable for losses arising from technical failures, internet outages, or events beyond our reasonable control. Our maximum liability is limited to the amount deposited in the last 30 days.',
                    ),
                    _TermsSection(
                      title: '7. Governing Law',
                      body:
                          'These terms are governed by the laws of India. Any disputes shall be subject to the exclusive jurisdiction of the courts of Mumbai, Maharashtra.',
                    ),
                    _TermsSection(
                      title: '8. Changes to Terms',
                      body:
                          'BetZone reserves the right to modify these Terms at any time. Continued use of the platform after changes constitutes your acceptance of the revised Terms.',
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ── About BetZone ────────────────────────────────────────────────────────────
  void _showAboutBetZone(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => Dialog(
        backgroundColor: AppColors.card,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Logo
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [AppColors.accent, AppColors.accentDark],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.accent.withValues(alpha: 0.35),
                      blurRadius: 20,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: const Icon(Icons.sports_cricket,
                    size: 32, color: AppColors.background),
              ),
              const SizedBox(height: 16),

              Text(
                'BetZone',
                style: GoogleFonts.poppins(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: AppColors.white,
                  letterSpacing: 2,
                ),
              ),
              Text(
                'Cricket Betting Platform',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 20),

              _aboutRow('Version', '1.0.0 (Build 1)'),
              _aboutRow('Platform', 'Android • iOS • Web'),
              _aboutRow('Developer', 'QuickPrepAI'),
              _aboutRow('Contact', 'support@betzone.in'),
              _aboutRow('Website', 'www.betzone.in'),

              const SizedBox(height: 20),

              Text(
                '© 2026 BetZone. All rights reserved.\nPlay responsibly. 18+ only.',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 11,
                  color: AppColors.textMuted,
                  height: 1.6,
                ),
              ),
              const SizedBox(height: 20),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accent,
                    foregroundColor: AppColors.background,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                  ),
                  child: Text('Close',
                      style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _aboutRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(label,
                style: GoogleFonts.poppins(
                    fontSize: 12, color: AppColors.textSecondary)),
          ),
          Expanded(
            flex: 3,
            child: Text(value,
                style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.white)),
          ),
        ],
      ),
    );
  }
}

// ── Terms section widget ─────────────────────────────────────────────────────
class _TermsSection extends StatelessWidget {
  final String title;
  final String body;

  const _TermsSection({required this.title, required this.body});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AppColors.accent,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            body,
            style: GoogleFonts.poppins(
              fontSize: 13,
              color: AppColors.textSecondary,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}