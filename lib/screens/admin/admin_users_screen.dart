import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../mock_data/mock_users.dart';
import '../../models/user_model.dart';
import '../../theme/app_theme.dart';
import '../../utils/app_utils.dart';

class AdminUsersScreen extends StatefulWidget {
  const AdminUsersScreen({super.key});

  @override
  State<AdminUsersScreen> createState() => _AdminUsersScreenState();
}

class _AdminUsersScreenState extends State<AdminUsersScreen> {
  String _searchQuery = '';
  String _filterStatus = 'All'; // All | Active | Blocked | Unverified
  String _roleFilter = 'All'; // All | Users | Admins

  List<UserModel> get _filteredUsers {
    return mockUsers
        .where((u) {
          if (_roleFilter == 'Users') return u.role == 'user';
          if (_roleFilter == 'Admins') return u.role == 'admin';
          return true;
        })
        .where(
          (u) =>
              u.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
              u.phone.contains(_searchQuery),
        )
        .where((u) {
          if (_filterStatus == 'Active') return !u.isBlocked;
          if (_filterStatus == 'Blocked') return u.isBlocked;
          if (_filterStatus == 'Unverified') return !u.kycVerified;
          return true;
        })
        .toList();
  }

  // â”€â”€ Delete user â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  void _deleteUser(UserModel user) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.card,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.cardBorder),
        ),
        title: Text(
          'Delete User',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w700,
            color: AppColors.white,
          ),
        ),
        content: Text(
          'Are you sure you want to delete ${user.name}? This action cannot be undone.',
          style: GoogleFonts.poppins(
            fontSize: 13,
            color: AppColors.textSecondary,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(
              'Cancel',
              style: GoogleFonts.poppins(color: AppColors.textSecondary),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.red,
              foregroundColor: AppColors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(
              'Delete',
              style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
    if (confirmed == true && mounted) {
      setState(() => mockUsers.remove(user));
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${user.name} deleted'),
          backgroundColor: AppColors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  // â”€â”€ Add / Edit user sheet â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  void _openUserForm({UserModel? existing, String role = 'user'}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _UserFormSheet(
        existing: existing,
        initialRole: existing?.role ?? role,
        onSave: (updated) {
          setState(() {
            if (existing == null) {
              mockUsers.add(updated);
            } else {
              final idx = mockUsers.indexWhere((u) => u.id == existing.id);
              if (idx != -1) mockUsers[idx] = updated;
            }
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                existing == null
                    ? '${updated.name} added successfully'
                    : '${updated.name} updated successfully',
              ),
              backgroundColor: AppColors.green,
              behavior: SnackBarBehavior.floating,
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final users = _filteredUsers;
    final allUsers = mockUsers.where((u) {
      if (_roleFilter == 'Users') return u.role == 'user';
      if (_roleFilter == 'Admins') return u.role == 'admin';
      return true;
    }).toList();
    final activeCount = allUsers.where((u) => !u.isBlocked).length;
    final blockedCount = allUsers.where((u) => u.isBlocked).length;
    final unverifiedCount = allUsers.where((u) => !u.kycVerified).length;
    final adminCount = mockUsers.where((u) => u.role == 'admin').length;
    final regularUserCount = mockUsers.where((u) => u.role == 'user').length;

    return Scaffold(
      backgroundColor: AppColors.background,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openUserForm(
          role: _roleFilter == 'Admins' ? 'admin' : 'user',
        ),
        backgroundColor:
            _roleFilter == 'Admins' ? AppColors.purple : AppColors.accent,
        foregroundColor: AppColors.background,
        icon: Icon(
          _roleFilter == 'Admins'
              ? Icons.admin_panel_settings_rounded
              : Icons.person_add_rounded,
        ),
        label: Text(
          _roleFilter == 'Admins' ? 'Add Admin' : 'Add User',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w700),
        ),
        elevation: 4,
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // â”€â”€ Header â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
            Container(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
              decoration: BoxDecoration(
                color: AppColors.surface,
                border: const Border(
                  bottom: BorderSide(color: AppColors.cardBorder),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 3,
                        height: 22,
                        decoration: BoxDecoration(
                          color: AppColors.accent,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(width: 10),
                      const Icon(
                        Icons.people_rounded,
                        color: AppColors.accent,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Manage Users',
                        style: GoogleFonts.poppins(
                          fontSize: 19,
                          fontWeight: FontWeight.w800,
                          color: AppColors.white,
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.accent.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: AppColors.accent.withValues(alpha: 0.3),
                          ),
                        ),
                        child: Text(
                          '${allUsers.length} ${_roleFilter == 'Admins' ? 'Admins' : _roleFilter == 'Users' ? 'Users' : 'Total'}',
                          style: GoogleFonts.poppins(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: AppColors.accent,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Stats row
                  Row(
                    children: [
                      _statChip(
                        Icons.person_rounded,
                        '$regularUserCount Users',
                        AppColors.blue,
                      ),
                      const SizedBox(width: 8),
                      _statChip(
                        Icons.admin_panel_settings_rounded,
                        '$adminCount Admins',
                        AppColors.purple,
                      ),
                      const SizedBox(width: 8),
                      _statChip(
                        Icons.block_rounded,
                        '$blockedCount Blocked',
                        AppColors.red,
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // â”€â”€ Search + Filter â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
            Container(
              color: AppColors.surface,
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: Column(
                children: [
                  // Role filter
                  const SizedBox(height: 10),
                  SizedBox(
                    height: 32,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: [
                        'All',
                        'Users',
                        'Admins',
                      ].map((r) => _roleFilterChip(r)).toList(),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    style: GoogleFonts.poppins(
                      color: AppColors.white,
                      fontSize: 13,
                    ),
                    onChanged: (v) => setState(() => _searchQuery = v),
                    decoration: InputDecoration(
                      hintText: 'Search by name or phone...',
                      hintStyle: GoogleFonts.poppins(
                        color: AppColors.textMuted,
                      ),
                      prefixIcon: const Icon(Icons.search, size: 20),
                      suffixIcon: _searchQuery.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear, size: 18),
                              onPressed: () =>
                                  setState(() => _searchQuery = ''),
                            )
                          : null,
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Filter chips
                  SizedBox(
                    height: 32,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: [
                        'All',
                        'Active',
                        'Blocked',
                        'Unverified',
                      ].map((f) => _filterChip(f)).toList(),
                    ),
                  ),
                ],
              ),
            ),

            // â”€â”€ User List â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
            Expanded(
              child: users.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.search_off_rounded,
                            size: 48,
                            color: AppColors.textMuted.withValues(alpha: 0.5),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'No users found',
                            style: GoogleFonts.poppins(
                              color: AppColors.textMuted,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    )
                  : RefreshIndicator(
                      color: AppColors.accent,
                      backgroundColor: AppColors.card,
                      onRefresh: () async {
                        await Future.delayed(const Duration(seconds: 1));
                        setState(() {});
                      },
                      child: ListView.builder(
                        padding: const EdgeInsets.fromLTRB(16, 12, 16, 96),
                        itemCount: users.length,
                        itemBuilder: (context, index) => _UserCard(
                          user: users[index],
                          onTap: () =>
                              context.push('/admin/users/${users[index].id}'),
                          onEdit: () => _openUserForm(existing: users[index]),
                          onDelete: () => _deleteUser(users[index]),
                          onToggleBlock: (val) => setState(() {
                            users[index].isBlocked = !val;
                          }),
                        ),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _statChip(IconData icon, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 5),
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 10.5,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _roleFilterChip(String label) {
    final isSelected = _roleFilter == label;
    final color = label == 'Admins'
        ? AppColors.purple
        : label == 'Users'
            ? AppColors.blue
            : AppColors.accent;
    return GestureDetector(
      onTap: () => setState(() {
        _roleFilter = label;
        _filterStatus = 'All';
      }),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? color : AppColors.card,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? color : AppColors.cardBorder,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              label == 'Admins'
                  ? Icons.admin_panel_settings_rounded
                  : label == 'Users'
                      ? Icons.person_rounded
                      : Icons.people_rounded,
              size: 12,
              color: isSelected ? AppColors.background : color,
            ),
            const SizedBox(width: 5),
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: isSelected ? AppColors.background : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _filterChip(String label) {
    final isSelected = _filterStatus == label;
    return GestureDetector(
      onTap: () => setState(() => _filterStatus = label),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.accent : AppColors.card,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.accent : AppColors.cardBorder,
          ),
        ),
        child: Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: isSelected ? AppColors.background : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}

// â”€â”€ User Card â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
class _UserCard extends StatelessWidget {
  final UserModel user;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final ValueChanged<bool> onToggleBlock;

  const _UserCard({
    required this.user,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
    required this.onToggleBlock,
  });

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: ValueKey(user.id),
      direction: DismissDirection.endToStart,
      confirmDismiss: (_) async {
        onDelete();
        return false; // deletion handled inside onDelete via dialog
      },
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: AppColors.red.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.delete_rounded, color: AppColors.red, size: 22),
            const SizedBox(height: 3),
            Text(
              'Delete',
              style: GoogleFonts.poppins(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: AppColors.red,
              ),
            ),
          ],
        ),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: user.role == 'admin'
              ? AppColors.purple.withValues(alpha: 0.05)
              : AppColors.card,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: user.role == 'admin'
                ? AppColors.purple.withValues(alpha: 0.35)
                : user.isBlocked
                    ? AppColors.red.withValues(alpha: 0.25)
                    : AppColors.cardBorder,
          ),
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(14),
          child: InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  // Avatar
                  Stack(
                    children: [
                      Container(
                        width: 46,
                        height: 46,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: _avatarColor(
                            user.name,
                          ).withValues(alpha: 0.15),
                          border: Border.all(
                            color: _avatarColor(
                              user.name,
                            ).withValues(alpha: 0.35),
                            width: 1.5,
                          ),
                        ),
                        child: ClipOval(
                          child: user.imageUrl != null
                              ? Image.asset(
                                  user.imageUrl!,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => _initials(user),
                                )
                              : _initials(user),
                        ),
                      ),
                      if (user.isBlocked)
                        Positioned(
                          right: 0,
                          bottom: 0,
                          child: Container(
                            width: 14,
                            height: 14,
                            decoration: BoxDecoration(
                              color: AppColors.red,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: AppColors.card,
                                width: 1.5,
                              ),
                            ),
                            child: const Icon(
                              Icons.block,
                              size: 8,
                              color: Colors.white,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(width: 12),

                  // Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                user.name,
                                style: GoogleFonts.poppins(
                                  fontSize: 13.5,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.white,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (user.role == 'admin') ...[  
                              const SizedBox(width: 4),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 5, vertical: 1),
                                decoration: BoxDecoration(
                                  color: AppColors.purple.withValues(alpha: 0.18),
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(
                                      color: AppColors.purple.withValues(alpha: 0.4)),
                                ),
                                child: Text(
                                  'ADMIN',
                                  style: GoogleFonts.poppins(
                                    fontSize: 8,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.purple,
                                  ),
                                ),
                              ),
                            ] else if (user.kycVerified) ...[  
                              const Icon(
                                Icons.verified_rounded,
                                color: AppColors.blue,
                                size: 15,
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 1),
                        Text(
                          '+91 ${user.phone}',
                          style: GoogleFonts.poppins(
                            fontSize: 11.5,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            const Icon(
                              Icons.location_on_rounded,
                              size: 11,
                              color: AppColors.textMuted,
                            ),
                            const SizedBox(width: 3),
                            Expanded(
                              child: Text(
                                user.location,
                                style: GoogleFonts.poppins(
                                  fontSize: 10.5,
                                  color: AppColors.textMuted,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),

                  // Right side: balance + actions
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      if (user.role != 'admin') ...[  
                        Text(
                          AppUtils.formatCurrency(user.walletBalance),
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: AppColors.accent,
                          ),
                        ),
                        const SizedBox(height: 4),
                      ],
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Block toggle
                          Transform.scale(
                            scale: 0.75,
                            alignment: Alignment.centerRight,
                            child: Switch(
                              value: !user.isBlocked,
                              onChanged: onToggleBlock,
                              activeThumbColor: AppColors.green,
                              activeTrackColor: AppColors.green.withValues(
                                alpha: 0.3,
                              ),
                              inactiveThumbColor: AppColors.red,
                              inactiveTrackColor: AppColors.red.withValues(
                                alpha: 0.3,
                              ),
                              materialTapTargetSize:
                                  MaterialTapTargetSize.shrinkWrap,
                            ),
                          ),
                          // Edit
                          GestureDetector(
                            onTap: onEdit,
                            child: Container(
                              padding: const EdgeInsets.all(5),
                              decoration: BoxDecoration(
                                color: AppColors.blue.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(7),
                              ),
                              child: const Icon(
                                Icons.edit_rounded,
                                size: 14,
                                color: AppColors.blue,
                              ),
                            ),
                          ),
                          const SizedBox(width: 5),
                          // Delete
                          GestureDetector(
                            onTap: onDelete,
                            child: Container(
                              padding: const EdgeInsets.all(5),
                              decoration: BoxDecoration(
                                color: AppColors.red.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(7),
                              ),
                              child: const Icon(
                                Icons.delete_rounded,
                                size: 14,
                                color: AppColors.red,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Color _avatarColor(String name) {
    final colors = [
      AppColors.blue,
      AppColors.purple,
      AppColors.green,
      AppColors.orange,
      AppColors.accent,
      AppColors.red,
    ];
    return colors[name.codeUnitAt(0) % colors.length];
  }

  Widget _initials(UserModel user) {
    return Center(
      child: Text(
        user.name.isNotEmpty ? user.name[0].toUpperCase() : '?',
        style: GoogleFonts.poppins(
          fontSize: 18,
          fontWeight: FontWeight.w800,
          color: _avatarColor(user.name),
        ),
      ),
    );
  }
}

// â”€â”€ Add / Edit User Form Sheet â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
class _UserFormSheet extends StatefulWidget {
  final UserModel? existing;
  final String initialRole;
  final ValueChanged<UserModel> onSave;

  const _UserFormSheet({
    this.existing,
    this.initialRole = 'user',
    required this.onSave,
  });

  @override
  State<_UserFormSheet> createState() => _UserFormSheetState();
}

class _UserFormSheetState extends State<_UserFormSheet> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nameCtrl;
  late final TextEditingController _phoneCtrl;
  late final TextEditingController _dobCtrl;
  late final TextEditingController _locationCtrl;
  late final TextEditingController _balanceCtrl;
  late bool _kycVerified;
  late bool _isBlocked;
  late String _role;

  bool get _isEditing => widget.existing != null;

  @override
  void initState() {
    super.initState();
    final u = widget.existing;
    _nameCtrl = TextEditingController(text: u?.name ?? '');
    _phoneCtrl = TextEditingController(text: u?.phone ?? '');
    _dobCtrl = TextEditingController(text: u?.dob ?? '');
    _locationCtrl = TextEditingController(text: u?.location ?? '');
    _balanceCtrl = TextEditingController(
      text: u != null ? u.walletBalance.toStringAsFixed(0) : '0',
    );
    _kycVerified = u?.kycVerified ?? false;
    _isBlocked = u?.isBlocked ?? false;
    _role = widget.initialRole;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _dobCtrl.dispose();
    _locationCtrl.dispose();
    _balanceCtrl.dispose();
    super.dispose();
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    final existing = widget.existing;

    // Generate a new ID for new users or admins
    String newId;
    if (_isEditing) {
      newId = existing!.id;
    } else if (_role == 'admin') {
      final adminCount = mockUsers.where((u) => u.role == 'admin').length;
      newId = 'ADM${(adminCount + 1).toString().padLeft(3, '0')}';
    } else {
      final userCount = mockUsers.where((u) => u.role == 'user').length;
      newId = 'USR${(userCount + 1).toString().padLeft(3, '0')}';
    }

    final updated = UserModel(
      id: newId,
      name: _nameCtrl.text.trim(),
      phone: _phoneCtrl.text.trim(),
      dob: _dobCtrl.text.trim(),
      location: _locationCtrl.text.trim(),
      imageUrl: existing?.imageUrl,
      walletBalance: double.tryParse(_balanceCtrl.text.trim()) ?? 0,
      kycVerified: _kycVerified,
      isBlocked: _isBlocked,
      role: _role,
    );

    Navigator.pop(context);
    widget.onSave(updated);
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: EdgeInsets.fromLTRB(20, 0, 20, bottom + 24),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle
            Center(
              child: Container(
                margin: const EdgeInsets.only(top: 10, bottom: 16),
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.cardBorder,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),

            // Title
            Row(
              children: [
                Icon(
                  _role == 'admin'
                      ? Icons.admin_panel_settings_rounded
                      : _isEditing
                          ? Icons.edit_rounded
                          : Icons.person_add_rounded,
                  color:
                      _role == 'admin' ? AppColors.purple : AppColors.accent,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  _isEditing
                      ? (_role == 'admin' ? 'Edit Admin' : 'Edit User')
                      : (_role == 'admin' ? 'Add New Admin' : 'Add New User'),
                  style: GoogleFonts.poppins(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    color: AppColors.white,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // Role selector
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.cardBorder),
              ),
              child: Row(
                children: [
                  _roleOption(
                      'user', 'Regular User', Icons.person_rounded, AppColors.blue),
                  const SizedBox(width: 4),
                  _roleOption(
                      'admin', 'Admin', Icons.admin_panel_settings_rounded, AppColors.purple),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // Fields
            Row(
              children: [
                Expanded(
                  child: _field(
                    _nameCtrl,
                    'Full Name',
                    Icons.person_rounded,
                    validator: (v) =>
                        (v == null || v.trim().isEmpty) ? 'Required' : null,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _field(
                    _phoneCtrl,
                    'Phone Number',
                    Icons.phone_rounded,
                    keyboardType: TextInputType.phone,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(10),
                    ],
                    validator: (v) {
                      if (v == null || v.trim().length != 10)
                        return '10 digits required';
                      return null;
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (_role != 'admin')
              Row(
                children: [
                  Expanded(
                    child: _field(
                      _dobCtrl,
                      'DOB (YYYY-MM-DD)',
                      Icons.cake_rounded,
                      validator: (v) =>
                          (v == null || v.trim().isEmpty) ? 'Required' : null,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _field(
                      _locationCtrl,
                      'Location',
                      Icons.location_on_rounded,
                      validator: (v) =>
                          (v == null || v.trim().isEmpty) ? 'Required' : null,
                    ),
                  ),
                ],
              )
            else
              _field(
                _locationCtrl,
                'Location',
                Icons.location_on_rounded,
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Required' : null,
              ),
            if (_role != 'admin') ...[  
              const SizedBox(height: 12),
              _field(
                _balanceCtrl,
                'Wallet Balance (₹)',
                Icons.account_balance_wallet_rounded,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
                ],
              ),
            ],
            const SizedBox(height: 14),

            // Toggles
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.cardBorder),
              ),
              child: Column(
                children: [
                  if (_role != 'admin') ...[  
                    _toggle(
                      Icons.verified_rounded,
                      'KYC Verified',
                      AppColors.blue,
                      _kycVerified,
                      (v) => setState(() => _kycVerified = v),
                    ),
                    const Divider(color: AppColors.cardBorder, height: 1),
                  ],
                  _toggle(
                    Icons.block_rounded,
                    'Blocked',
                    AppColors.red,
                    _isBlocked,
                    (v) => setState(() => _isBlocked = v),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Save button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _save,
                child: Text(
                  _isEditing ? 'Save Changes' : 'Add User',
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _roleOption(
      String value, String label, IconData icon, Color color) {
    final selected = _role == value;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _role = value),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: selected ? color.withValues(alpha: 0.15) : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: selected ? color : Colors.transparent,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 16,
                  color: selected ? color : AppColors.textMuted),
              const SizedBox(width: 6),
              Text(
                label,
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight:
                      selected ? FontWeight.w700 : FontWeight.w500,
                  color: selected ? color : AppColors.textMuted,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _field(
    TextEditingController ctrl,
    String hint,
    IconData icon, {
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: ctrl,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      validator: validator,
      style: GoogleFonts.poppins(color: AppColors.white, fontSize: 13),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: GoogleFonts.poppins(
          color: AppColors.textMuted,
          fontSize: 12,
        ),
        prefixIcon: Icon(icon, size: 18, color: AppColors.textSecondary),
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(
          vertical: 12,
          horizontal: 10,
        ),
      ),
    );
  }

  Widget _toggle(
    IconData icon,
    String label,
    Color color,
    bool value,
    ValueChanged<bool> onChanged,
  ) {
    return SwitchListTile(
      dense: true,
      contentPadding: EdgeInsets.zero,
      title: Row(
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 8),
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.white,
            ),
          ),
        ],
      ),
      value: value,
      onChanged: onChanged,
      activeColor: color,
      activeTrackColor: color.withValues(alpha: 0.3),
    );
  }
}
