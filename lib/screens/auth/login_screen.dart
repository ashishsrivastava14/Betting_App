import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../theme/app_theme.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _phoneController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                const SizedBox(height: 48),

                // Logo
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.accent.withValues(alpha: 0.12),
                    border: Border.all(color: AppColors.accent, width: 2),
                  ),
                  child: const Icon(Icons.sports_cricket, size: 48, color: AppColors.accent),
                ),
                const SizedBox(height: 20),

                Text(
                  'BetZone',
                  style: GoogleFonts.poppins(
                    fontSize: 30,
                    fontWeight: FontWeight.w800,
                    color: AppColors.accent,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Cricket Betting Platform',
                  style: GoogleFonts.poppins(fontSize: 13, color: AppColors.textSecondary, letterSpacing: 1),
                ),

                const SizedBox(height: 48),

                // Sign In heading
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Sign In',
                    style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.w700, color: AppColors.white),
                  ),
                ),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Enter your mobile number to continue',
                    style: GoogleFonts.poppins(fontSize: 13, color: AppColors.textSecondary),
                  ),
                ),
                const SizedBox(height: 20),

                // Phone input
                TextFormField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  maxLength: 10,
                  style: GoogleFonts.poppins(color: AppColors.white, fontSize: 16),
                  decoration: InputDecoration(
                    hintText: 'Mobile Number',
                    prefixIcon: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.phone, color: AppColors.accent, size: 20),
                          const SizedBox(width: 8),
                          Text('+91', style: GoogleFonts.poppins(color: AppColors.white, fontWeight: FontWeight.w600)),
                          const SizedBox(width: 8),
                          Container(width: 1, height: 24, color: AppColors.cardBorder),
                        ],
                      ),
                    ),
                    counterText: '',
                  ),
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Enter phone number';
                    if (v.length != 10) return 'Enter valid 10-digit number';
                    return null;
                  },
                ),
                const SizedBox(height: 28),

                // Send OTP button
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: Consumer<AuthProvider>(
                    builder: (context, auth, _) {
                      return ElevatedButton.icon(
                        onPressed: auth.isLoading
                            ? null
                            : () {
                                if (_formKey.currentState!.validate()) {
                                  auth.sendOtp(_phoneController.text.trim());
                                  context.push('/otp');
                                }
                              },
                        icon: auth.isLoading
                            ? const SizedBox.shrink()
                            : const Icon(Icons.bolt, size: 20),
                        label: auth.isLoading
                            ? const SizedBox(
                                height: 24, width: 24,
                                child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.background),
                              )
                            : Text(
                                'SEND OTP',
                                style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w700, letterSpacing: 1),
                              ),
                      );
                    },
                  ),
                ),

                const SizedBox(height: 32),

                // Footer
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('By continuing, you agree to our ',
                        style: GoogleFonts.poppins(color: AppColors.textMuted, fontSize: 11)),
                    Text('Terms',
                        style: GoogleFonts.poppins(color: AppColors.accent, fontSize: 11, fontWeight: FontWeight.w600)),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}