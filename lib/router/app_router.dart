import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../providers/auth_provider.dart';

// Auth screens
import '../screens/auth/splash_screen.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/otp_screen.dart';

// User screens
import '../screens/user/user_shell.dart';
import '../screens/user/home_screen.dart';
import '../screens/user/event_detail_screen.dart';
import '../screens/user/dashboard_screen.dart';
import '../screens/user/wallet_screen.dart';
import '../screens/user/deposit_screen.dart';
import '../screens/user/withdraw_screen.dart';
import '../screens/user/profile_screen.dart';

// Admin screens
import '../screens/admin/admin_shell.dart';
import '../screens/admin/admin_dashboard_screen.dart';
import '../screens/admin/admin_events_screen.dart';
import '../screens/admin/admin_create_event_screen.dart';
import '../screens/admin/admin_declare_result_screen.dart';
import '../screens/admin/admin_users_screen.dart';
import '../screens/admin/admin_user_detail_screen.dart';
import '../screens/admin/admin_wallet_screen.dart';
import '../screens/admin/admin_reports_screen.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>();
final GlobalKey<NavigatorState> _userShellKey = GlobalKey<NavigatorState>();
final GlobalKey<NavigatorState> _adminShellKey = GlobalKey<NavigatorState>();

GoRouter createRouter(AuthProvider authProvider) {
  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/splash',
    refreshListenable: authProvider,
    redirect: (context, state) {
      final isLoggedIn = authProvider.isLoggedIn;
      final isAuthRoute = state.matchedLocation == '/login' ||
          state.matchedLocation == '/otp' ||
          state.matchedLocation == '/splash';

      if (!isLoggedIn && !isAuthRoute) return '/login';

      if (isLoggedIn && isAuthRoute) {
        return authProvider.isAdmin ? '/admin' : '/home';
      }

      return null;
    },
    routes: [
      GoRoute(path: '/splash', builder: (_, _) => const SplashScreen()),
      GoRoute(path: '/login', builder: (_, _) => const LoginScreen()),
      GoRoute(path: '/otp', builder: (_, _) => const OtpScreen()),

      // ── User Shell ──
      ShellRoute(
        navigatorKey: _userShellKey,
        builder: (_, _, child) => UserShell(child: child),
        routes: [
          GoRoute(
            path: '/home',
            pageBuilder: (_, _) => const NoTransitionPage(child: HomeScreen()),
          ),
          GoRoute(
            path: '/dashboard',
            pageBuilder: (_, _) =>
                const NoTransitionPage(child: DashboardScreen()),
          ),
          GoRoute(
            path: '/wallet',
            pageBuilder: (_, _) =>
                const NoTransitionPage(child: WalletScreen()),
          ),
          GoRoute(
            path: '/profile',
            pageBuilder: (_, _) =>
                const NoTransitionPage(child: ProfileScreen()),
          ),
        ],
      ),

      // User detail routes (outside shell)
      GoRoute(
        path: '/event/:id',
        builder: (_, state) =>
            EventDetailScreen(eventId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: '/deposit',
        builder: (_, _) => const DepositScreen(),
      ),
      GoRoute(
        path: '/withdraw',
        builder: (_, _) => const WithdrawScreen(),
      ),

      // ── Admin Shell ──
      ShellRoute(
        navigatorKey: _adminShellKey,
        builder: (_, _, child) => AdminShell(child: child),
        routes: [
          GoRoute(
            path: '/admin',
            pageBuilder: (_, _) =>
                const NoTransitionPage(child: AdminDashboardScreen()),
          ),
          GoRoute(
            path: '/admin/events',
            pageBuilder: (_, _) =>
                const NoTransitionPage(child: AdminEventsScreen()),
          ),
          GoRoute(
            path: '/admin/users',
            pageBuilder: (_, _) =>
                const NoTransitionPage(child: AdminUsersScreen()),
          ),
          GoRoute(
            path: '/admin/wallet',
            pageBuilder: (_, _) =>
                const NoTransitionPage(child: AdminWalletScreen()),
          ),
          GoRoute(
            path: '/admin/reports',
            pageBuilder: (_, _) =>
                const NoTransitionPage(child: AdminReportsScreen()),
          ),
        ],
      ),

      // Admin detail routes (outside shell)
      GoRoute(
        path: '/admin/events/create',
        builder: (_, _) => const AdminCreateEventScreen(),
      ),
      GoRoute(
        path: '/admin/events/declare',
        builder: (_, _) => const AdminDeclareResultScreen(),
      ),
      GoRoute(
        path: '/admin/users/:id',
        builder: (_, state) =>
            AdminUserDetailScreen(userId: state.pathParameters['id']!),
      ),
    ],
  );
}
