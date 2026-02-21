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
      appBar: AppBar(
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.card,
              border: Border.all(color: AppColors.cardBorder),
            ),
            child: const Icon(Icons.arrow_back, size: 18),
          ),
          onPressed: () => context.go('/login'),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),

              const Icon(Icons.lock_outline, color: AppColors.accent, size: 40),
              const SizedBox(height: 12),

              Text(
                'Verify OTP',
                style: GoogleFonts.poppins(fontSize: 24, fontWeight: FontWeight.w700, color: AppColors.white),
              ),
              const SizedBox(height: 6),
              Text(
                'Enter the 6-digit code sent to +91 ${auth.pendingPhone ?? ""}',
                style: GoogleFonts.poppins(fontSize: 13, color: AppColors.textSecondary),
              ),

              const SizedBox(height: 32),

              // OTP Input
              PinCodeTextField(
                appContext: context,
                length: 6,
                onChanged: (value) { _otp = value; },
                onCompleted: (_) => _verifyOtp(),
                keyboardType: TextInputType.number,
                animationType: AnimationType.scale,
                pinTheme: PinTheme(
                  shape: PinCodeFieldShape.box,
                  borderRadius: BorderRadius.circular(12),
                  fieldHeight: 52,
                  fieldWidth: 46,
                  activeFillColor: AppColors.card,
                  inactiveFillColor: AppColors.card,
                  selectedFillColor: AppColors.card,
                  activeColor: AppColors.accent,
                  inactiveColor: AppColors.cardBorder,
                  selectedColor: AppColors.accent,
                ),
                enableActiveFill: true,
                textStyle: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.w700, color: AppColors.accent),
                cursorColor: AppColors.accent,
              ),

              const SizedBox(height: 28),

              // Verify button
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: _verifyOtp,
                  icon: const Icon(Icons.check_circle, size: 20),
                  label: Text(
                    'VERIFY',
                    style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w700, letterSpacing: 1),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Resend OTP
              Center(
                child: TextButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('OTP resent!')),
                    );
                  },
                  icon: const Icon(Icons.refresh, size: 16, color: AppColors.accent),
                  label: Text(
                    'Resend OTP',
                    style: GoogleFonts.poppins(color: AppColors.accent, fontWeight: FontWeight.w600),
                  ),
                ),
              ),

              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}