import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_theme.dart';
import '../../widgets/powered_by.dart';

class UserShell extends StatefulWidget {
  final Widget child;

  const UserShell({super.key, required this.child});

  @override
  State<UserShell> createState() => _UserShellState();
}

class _UserShellState extends State<UserShell> {
  int _currentIndex = 0;

  static const _routes = ['/home', '/dashboard', '/wallet', '/profile'];

  static const _navItems = [
    _NavItem(Icons.grid_view_rounded, Icons.grid_view_rounded, 'PICK \'EM'),
    _NavItem(Icons.dashboard_outlined, Icons.dashboard, 'DASHBOARD'),
    _NavItem(
        Icons.account_balance_wallet_outlined,
        Icons.account_balance_wallet,
        'WALLET'),
    _NavItem(Icons.person_outline, Icons.person, 'ACCOUNT'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: widget.child,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          border: Border(
            top: BorderSide(color: AppColors.cardBorder, width: 1),
          ),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(_navItems.length, (index) {
                final item = _navItems[index];
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
                        Icon(
                          isSelected ? item.activeIcon : item.icon,
                          size: 22,
                          color: isSelected
                              ? AppColors.accent
                              : AppColors.grey,
                        ),
                        const SizedBox(height: 3),
                        Text(
                          item.label,
                          style: GoogleFonts.poppins(
                            fontSize: 9,
                            fontWeight:
                                isSelected ? FontWeight.w700 : FontWeight.w500,
                            color: isSelected
                                ? AppColors.accent
                                : AppColors.grey,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
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
}

class _NavItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;

  const _NavItem(this.icon, this.activeIcon, this.label);
}
