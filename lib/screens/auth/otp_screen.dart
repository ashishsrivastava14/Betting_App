import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../theme/app_theme.dart';

class OtpScreen extends StatefulWidget {
  const OtpScreen({super.key});

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  String _otp = '';

  void _verifyOtp() {
    if (_otp.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter 6-digit OTP')),
      );
      return;
    }

    final auth = context.read<AuthProvider>();
    final success = auth.verifyOtp(_otp);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Welcome, ${auth.currentUser?.name ?? "User"}!'),
          backgroundColor: AppColors.green,
        ),
      );
      if (auth.isAdmin) {
        context.go('/admin');
      } else {
        context.go('/home');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    return Scaffold(
      body: Stack(
        children: [
          // ── Background image ──
          Positioned.fill(
            child: Image.asset(
              'assets/images/cricket_bg.jpg',
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) =>
                  Container(color: AppColors.background),
            ),
          ),
          // ── Gradient overlay ──
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.3),
                    AppColors.background.withValues(alpha: 0.85),
                    AppColors.background,
                  ],
                  stops: const [0.0, 0.35, 0.55],
                ),
              ),
            ),
          ),

          // ── Content ──
          SafeArea(
            child: Column(
              children: [
                // Back button row
                Padding(
                  padding: const EdgeInsets.fromLTRB(8, 4, 16, 0),
                  child: Row(
                    children: [
                      IconButton(
                        icon: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.card.withValues(alpha: 0.7),
                            border: Border.all(
                                color: AppColors.cardBorder.withValues(alpha: 0.5)),
                          ),
                          child: const Icon(Icons.arrow_back, size: 18),
                        ),
                        onPressed: () => context.go('/login'),
                      ),
                    ],
                  ),
                ),

                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 28),
                    child: Column(
                      children: [
                        const SizedBox(height: 12),

                        // ── Shield icon with glow ──
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                AppColors.accent,
                                AppColors.accentDark,
                              ],
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.accent.withValues(alpha: 0.35),
                                blurRadius: 24,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                          child: const Icon(Icons.verified_user_rounded,
                              size: 38, color: AppColors.background),
                        ),
                        const SizedBox(height: 20),

                        Text(
                          'Verify OTP',
                          style: GoogleFonts.poppins(
                            fontSize: 26,
                            fontWeight: FontWeight.w700,
                            color: AppColors.white,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Enter the 6-digit code sent to',
                          style: GoogleFonts.poppins(
                              fontSize: 13, color: AppColors.textSecondary),
                        ),
                        Text(
                          '+91 ${auth.pendingPhone ?? ""}',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.accent,
                          ),
                        ),

                        const SizedBox(height: 32),

                        // ── OTP Card ──
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.fromLTRB(16, 24, 16, 24),
                          decoration: BoxDecoration(
                            color: AppColors.card.withValues(alpha: 0.85),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color:
                                  AppColors.cardBorder.withValues(alpha: 0.6),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.3),
                                blurRadius: 30,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              // OTP Input
                              PinCodeTextField(
                                appContext: context,
                                length: 6,
                                onChanged: (value) {
                                  _otp = value;
                                },
                                onCompleted: (_) => _verifyOtp(),
                                keyboardType: TextInputType.number,
                                animationType: AnimationType.scale,
                                pinTheme: PinTheme(
                                  shape: PinCodeFieldShape.box,
                                  borderRadius: BorderRadius.circular(12),
                                  fieldHeight: 52,
                                  fieldWidth: 44,
                                  activeFillColor:
                                      AppColors.surface.withValues(alpha: 0.7),
                                  inactiveFillColor:
                                      AppColors.surface.withValues(alpha: 0.7),
                                  selectedFillColor:
                                      AppColors.surface.withValues(alpha: 0.7),
                                  activeColor: AppColors.accent,
                                  inactiveColor: AppColors.cardBorder,
                                  selectedColor: AppColors.accent,
                                ),
                                enableActiveFill: true,
                                textStyle: GoogleFonts.poppins(
                                    fontSize: 22,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.accent),
                                cursorColor: AppColors.accent,
                              ),

                              const SizedBox(height: 24),

                              // Verify button
                              SizedBox(
                                width: double.infinity,
                                height: 54,
                                child: ElevatedButton(
                                  onPressed: _verifyOtp,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.accent,
                                    foregroundColor: AppColors.background,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                    elevation: 0,
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Icon(Icons.check_circle, size: 20),
                                      const SizedBox(width: 8),
                                      Text(
                                        'VERIFY',
                                        style: GoogleFonts.poppins(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w700,
                                          letterSpacing: 1.5,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 20),

                        // Resend OTP
                        TextButton.icon(
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('OTP resent!')),
                            );
                          },
                          icon: const Icon(Icons.refresh,
                              size: 16, color: AppColors.accent),
                          label: Text(
                            'Resend OTP',
                            style: GoogleFonts.poppins(
                                color: AppColors.accent,
                                fontWeight: FontWeight.w600),
                          ),
                        ),

                        const SizedBox(height: 32),

                        // ── Powered by ──
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Powered by ',
                              style: GoogleFonts.poppins(
                                fontSize: 11,
                                color: AppColors.textMuted.withValues(alpha: 0.7),
                              ),
                            ),
                            Image.asset(
                              'assets/images/QuickPrepAI_Logo.png',
                              height: 18,
                              errorBuilder: (_, __, ___) => Text(
                                'QuickPrepAI',
                                style: GoogleFonts.poppins(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textMuted.withValues(alpha: 0.7),
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}