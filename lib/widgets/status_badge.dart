import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';

class StatusBadge extends StatelessWidget {
  final String status;
  final double? fontSize;

  const StatusBadge({super.key, required this.status, this.fontSize});

  @override
  Widget build(BuildContext context) {
    Color bgColor;
    Color textColor;
    IconData? icon;

    switch (status.toLowerCase()) {
      case 'live':
        bgColor = AppColors.green.withValues(alpha: 0.15);
        textColor = AppColors.greenLight;
        icon = Icons.circle;
        break;
      case 'upcoming':
        bgColor = AppColors.blue.withValues(alpha: 0.15);
        textColor = AppColors.blue;
        icon = Icons.schedule;
        break;
      case 'closed':
        bgColor = AppColors.orange.withValues(alpha: 0.15);
        textColor = AppColors.orange;
        icon = Icons.lock;
        break;
      case 'settled':
        bgColor = AppColors.grey.withValues(alpha: 0.15);
        textColor = AppColors.greyLight;
        icon = Icons.check_circle;
        break;
      case 'active':
        bgColor = AppColors.accent.withValues(alpha: 0.15);
        textColor = AppColors.accent;
        icon = Icons.pending;
        break;
      case 'won':
        bgColor = AppColors.green.withValues(alpha: 0.15);
        textColor = AppColors.greenLight;
        icon = Icons.emoji_events;
        break;
      case 'lost':
        bgColor = AppColors.red.withValues(alpha: 0.15);
        textColor = AppColors.redLight;
        icon = Icons.cancel;
        break;
      case 'pending':
        bgColor = AppColors.orange.withValues(alpha: 0.15);
        textColor = AppColors.orange;
        icon = Icons.hourglass_empty;
        break;
      case 'approved':
        bgColor = AppColors.green.withValues(alpha: 0.15);
        textColor = AppColors.greenLight;
        icon = Icons.check;
        break;
      case 'completed':
        bgColor = AppColors.grey.withValues(alpha: 0.15);
        textColor = AppColors.greyLight;
        icon = Icons.done_all;
        break;
      default:
        bgColor = AppColors.grey.withValues(alpha: 0.15);
        textColor = AppColors.greyLight;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: textColor.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon,
                size: status == 'live' ? 7 : 11,
                color: textColor),
            const SizedBox(width: 3),
          ],
          Text(
            status.toUpperCase(),
            style: GoogleFonts.poppins(
              fontSize: fontSize ?? 9,
              fontWeight: FontWeight.w700,
              color: textColor,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}
