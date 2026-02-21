import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../mock_data/mock_users.dart';
import '../../theme/app_theme.dart';
import '../../utils/app_utils.dart';

class AdminUsersScreen extends StatefulWidget {
  const AdminUsersScreen({super.key});

  @override
  State<AdminUsersScreen> createState() => _AdminUsersScreenState();
}

class _AdminUsersScreenState extends State<AdminUsersScreen> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final users = mockUsers
        .where((u) => u.role == 'user')
        .where((u) => u.name.toLowerCase().contains(_searchQuery.toLowerCase()) || u.phone.contains(_searchQuery))
        .toList();

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: Row(
                children: [
                  const Icon(Icons.people_rounded, color: AppColors.accent, size: 22),
                  const SizedBox(width: 10),
                  Text('Manage Users', style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.white)),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: TextFormField(
                style: GoogleFonts.poppins(color: AppColors.white),
                onChanged: (v) => setState(() => _searchQuery = v),
                decoration: InputDecoration(
                  hintText: 'Search by name or phone...',
                  prefixIcon: const Icon(Icons.search),
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: RefreshIndicator(
                color: AppColors.accent,
                backgroundColor: AppColors.card,
                onRefresh: () async { await Future.delayed(const Duration(seconds: 1)); setState(() {}); },
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: users.length,
                  itemBuilder: (context, index) {
                    final user = users[index];
                    return GestureDetector(
                      onTap: () => context.push('/admin/users/${user.id}'),
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: AppColors.card,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.cardBorder),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: AppColors.accent.withValues(alpha: 0.12),
                                border: Border.all(color: AppColors.accent.withValues(alpha: 0.3)),
                              ),
                              child: Center(
                                child: Text(user.name[0].toUpperCase(),
                                    style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.accent)),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(children: [
                                    Expanded(child: Text(user.name, style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.white))),
                                    if (user.kycVerified) const Icon(Icons.verified, color: AppColors.green, size: 16),
                                  ]),
                                  Text('+91 ${user.phone}', style: GoogleFonts.poppins(fontSize: 12, color: AppColors.textSecondary)),
                                  Text('Balance: ${AppUtils.formatCurrency(user.walletBalance)}',
                                      style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.accent)),
                                ],
                              ),
                            ),
                            Column(
                              children: [
                                Switch(
                                  value: !user.isBlocked,
                                  onChanged: (v) {
                                    setState(() { user.isBlocked = !v; });
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text(user.isBlocked ? '${user.name} blocked' : '${user.name} unblocked')),
                                    );
                                  },
                                  activeThumbColor: AppColors.green,
                                  activeTrackColor: AppColors.green.withValues(alpha: 0.3),
                                  inactiveTrackColor: AppColors.red.withValues(alpha: 0.3),
                                ),
                                Text(user.isBlocked ? 'Blocked' : 'Active',
                                    style: GoogleFonts.poppins(fontSize: 10, color: user.isBlocked ? AppColors.red : AppColors.green)),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}