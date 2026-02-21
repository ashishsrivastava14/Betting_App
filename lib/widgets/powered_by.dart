import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';

class PoweredBy extends StatelessWidget {
  final Color? textColor;

  const PoweredBy({super.key, this.textColor});

  @override
  Widget build(BuildContext context) {
    final color = (textColor ?? AppColors.textMuted).withValues(alpha: 0.65);
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'Powered by ',
          style: GoogleFonts.poppins(
            fontSize: 9,
            fontWeight: FontWeight.w400,
            color: color,
            letterSpacing: 0.2,
          ),
        ),
        Image.asset(
          'assets/images/QuickPrepAI_Logo.png',
          height: 14,
          errorBuilder: (_, __, ___) => Text(
            'QuickPrepAI',
            style: GoogleFonts.poppins(
              fontSize: 9,
              fontWeight: FontWeight.w600,
              color: color,
              letterSpacing: 0.2,
            ),
          ),
        ),
      ],
    );
  }
}
