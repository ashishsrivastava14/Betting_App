import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'providers/event_provider.dart';
import 'providers/bet_provider.dart';
import 'providers/wallet_provider.dart';
import 'providers/notification_provider.dart';
import 'providers/payment_account_provider.dart';
import 'router/app_router.dart';
import 'theme/app_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  final authProvider = AuthProvider();
  final eventProvider = EventProvider();
  final betProvider = BetProvider();
  final walletProvider = WalletProvider();
  final notificationProvider = NotificationProvider();
  final paymentAccountProvider = PaymentAccountProvider();
  final router = createRouter(authProvider);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: authProvider),
        ChangeNotifierProvider.value(value: eventProvider),
        ChangeNotifierProvider.value(value: betProvider),
        ChangeNotifierProvider.value(value: walletProvider),
        ChangeNotifierProvider.value(value: notificationProvider),
        ChangeNotifierProvider.value(value: paymentAccountProvider),
      ],
      child: MaterialApp.router(
        title: 'BetZone',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.darkTheme,
        routerConfig: router,
      ),
    ),
  );
}
