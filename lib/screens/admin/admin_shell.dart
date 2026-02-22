import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_theme.dart';
import '../../widgets/powered_by.dart';

class AdminShell extends StatefulWidget {
  final Widget child;

  const AdminShell({super.key, required this.child});

  @override
  State<AdminShell> createState() => _AdminShellState();
}

class _AdminShellState extends State<AdminShell> {
  int _currentIndex = 0;

  static const _routes = [
    '/admin',
    '/admin/events',
    '/admin/users',
    '/admin/wallet',
    '/admin/reports',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: widget.child,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          border: Border(top: BorderSide(color: AppColors.cardBorder)),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _navItem(0, Icons.dashboard_rounded, 'DASHBOARD', imagePath: 'assets/images/bt_logo.png'),
                _navItem(1, Icons.event_note_rounded, 'EVENTS'),
                _navItem(2, Icons.people_rounded, 'USERS'),
                _navItem(3, Icons.account_balance_wallet_rounded, 'WALLET'),
                _navItem(4, Icons.bar_chart_rounded, 'REPORTS'),
              ],
            ),
          ),
              const PoweredBy(),
              const SizedBox(height: 4),
            ],
          ),
        ),
      ),
    );
  }

  Widget _navItem(int index, IconData icon, String label, {String? imagePath}) {
    final isSelected = _currentIndex == index;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() => _currentIndex = index);
          context.go(_routes[index]);
        },
        behavior: HitTestBehavior.opaque,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              height: 3,
              width: isSelected ? 24 : 0,
              margin: const EdgeInsets.only(bottom: 6),
              decoration: BoxDecoration(
                color: AppColors.accent,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            if (imagePath != null)
              ColorFiltered(
                colorFilter: ColorFilter.mode(
                  isSelected
                      ? AppColors.accent
                      : AppColors.textMuted,
                  BlendMode.srcIn,
                ),
                child: Image.asset(
                  imagePath,
                  width: 22,
                  height: 22,
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) => Icon(
                    icon,
                    size: 22,
                    color: isSelected ? AppColors.accent : AppColors.textMuted,
                  ),
                ),
              )
            else
              Icon(
                icon,
                size: 22,
                color: isSelected ? AppColors.accent : AppColors.textMuted,
              ),
            const SizedBox(height: 3),
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 8,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected ? AppColors.accent : AppColors.textMuted,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}