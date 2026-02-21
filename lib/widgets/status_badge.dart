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
        bgColor = AppColors.green.withValues(alpha: 0.2);
        textColor = AppColors.green;
        icon = Icons.circle;
        break;
      case 'upcoming':
        bgColor = Colors.blue.withValues(alpha: 0.2);
        textColor = Colors.lightBlueAccent;
        icon = Icons.schedule;
        break;
      case 'closed':
        bgColor = AppColors.orange.withValues(alpha: 0.2);
        textColor = AppColors.orange;
        icon = Icons.lock;
        break;
      case 'settled':
        bgColor = AppColors.grey.withValues(alpha: 0.2);
        textColor = AppColors.grey;
        icon = Icons.check_circle;
        break;
      case 'active':
        bgColor = AppColors.accent.withValues(alpha: 0.2);
        textColor = AppColors.accent;
        icon = Icons.pending;
        break;
      case 'won':
        bgColor = AppColors.green.withValues(alpha: 0.2);
        textColor = AppColors.green;
        icon = Icons.emoji_events;
        break;
      case 'lost':
        bgColor = AppColors.red.withValues(alpha: 0.2);
        textColor = AppColors.red;
        icon = Icons.cancel;
        break;
      case 'pending':
        bgColor = AppColors.orange.withValues(alpha: 0.2);
        textColor = AppColors.orange;
        icon = Icons.hourglass_empty;
        break;
      case 'approved':
        bgColor = AppColors.green.withValues(alpha: 0.2);
        textColor = AppColors.green;
        icon = Icons.check;
        break;
      case 'completed':
        bgColor = AppColors.grey.withValues(alpha: 0.2);
        textColor = AppColors.grey;
        icon = Icons.done_all;
        break;
      default:
        bgColor = AppColors.grey.withValues(alpha: 0.2);
        textColor = AppColors.grey;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon,
                size: status == 'live' ? 8 : 12,
                color: textColor),
            const SizedBox(width: 4),
          ],
          Text(
            status.toUpperCase(),
            style: GoogleFonts.poppins(
              fontSize: fontSize ?? 10,
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
