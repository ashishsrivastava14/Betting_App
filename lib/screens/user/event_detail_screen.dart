import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../models/bet_model.dart';
import '../../models/transaction_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/bet_provider.dart';
import '../../providers/event_provider.dart';
import '../../providers/wallet_provider.dart';
import '../../theme/app_theme.dart';
import '../../utils/app_utils.dart';
import '../../widgets/countdown_timer.dart';

class EventDetailScreen extends StatefulWidget {
  final String eventId;

  const EventDetailScreen({super.key, required this.eventId});

  @override
  State<EventDetailScreen> createState() => _EventDetailScreenState();
}

class _EventDetailScreenState extends State<EventDetailScreen> {
  String? _selectedOption;
  double _betAmount = 0;
  final _amountController = TextEditingController();
  final _quickAmounts = [100, 500, 1000, 5000];

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  double get _potentialWin {
    if (_selectedOption == null || _betAmount <= 0) return 0;
    final event = context.read<EventProvider>().getEventById(widget.eventId);
    if (event == null) return 0;
    final option = event.options.firstWhere((o) => o.label == _selectedOption);
    return _betAmount * option.multiplier;
  }

  void _placeBet() {
    final auth = context.read<AuthProvider>();
    final eventProvider = context.read<EventProvider>();
    final walletProvider = context.read<WalletProvider>();
    final event = eventProvider.getEventById(widget.eventId);

    if (event == null) return;
    if (_selectedOption == null) {
      _showSnackbar('Please select a betting option');
      return;
    }
    if (_betAmount <= 0) {
      _showSnackbar('Please enter bet amount');
      return;
    }
    if (_betAmount > (auth.currentUser?.walletBalance ?? 0)) {
      _showSnackbar('Insufficient wallet balance');
      return;
    }
    if (event.status == 'closed' || event.status == 'settled') {
      _showSnackbar('Betting is closed for this event');
      return;
    }

    final option = event.options.firstWhere((o) => o.label == _selectedOption);
    final bet = BetModel(
      id: AppUtils.generateId('BET'),
      userId: auth.currentUser!.id,
      eventId: event.id,
      selectedOption: _selectedOption!,
      amount: _betAmount,
      multiplier: option.multiplier,
      status: 'active',
      createdAt: DateTime.now(),
    );

    // Deduct balance
    walletProvider.deductBalance(auth.currentUser!, _betAmount);

    // Add bet transaction
    walletProvider.addTransaction(TransactionModel(
      id: AppUtils.generateId('TXN'),
      userId: auth.currentUser!.id,
      type: 'bet_debit',
      amount: _betAmount,
      status: 'completed',
      createdAt: DateTime.now(),
      notes: 'Bet on ${event.name} - $_selectedOption',
    ));

    // Add bet to provider
    context.read<BetProvider>().placeBet(bet);

    // Show success dialog
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.card,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.green.withValues(alpha: 0.2),
              ),
              child:
                  const Icon(Icons.check_circle, color: AppColors.green, size: 48),
            ),
            const SizedBox(height: 16),
            Text(
              'Bet Placed!',
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: AppColors.white,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'You bet ${AppUtils.formatCurrency(_betAmount)} on $_selectedOption',
              style: GoogleFonts.poppins(
                  fontSize: 13, color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              'Potential Win: ${AppUtils.formatCurrency(bet.potentialWin)}',
              style: GoogleFonts.poppins(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: AppColors.gold,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              context.go('/home');
            },
            child: Text('OK',
                style: GoogleFonts.poppins(
                    color: AppColors.accent, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );

    setState(() {
      _selectedOption = null;
      _betAmount = 0;
      _amountController.clear();
    });
  }

  void _showSnackbar(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final event = context.watch<EventProvider>().getEventById(widget.eventId);
    final auth = context.watch<AuthProvider>();

    if (event == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Event')),
        body: const Center(child: Text('Event not found')),
      );
    }

    final isBettingOpen =
        event.status == 'live' || event.status == 'upcoming';

    return Scaffold(
      appBar: AppBar(
        title: Text(event.eventType),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/home'),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Match header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.primary, AppColors.card],
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                    color: AppColors.accent.withValues(alpha: 0.2)),
              ),
              child: Column(
                children: [
                  Text(
                    event.name,
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _teamWidget(event.team1),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 14, vertical: 6),
                              decoration: BoxDecoration(
                                color: AppColors.accent.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                'VS',
                                style: GoogleFonts.poppins(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.accent,
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              AppUtils.formatDateShort(event.startTime),
                              style: GoogleFonts.poppins(
                                fontSize: 11,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      _teamWidget(event.team2),
                    ],
                  ),
                  if (isBettingOpen) ...[
                    const SizedBox(height: 16),
                    CountdownTimerWidget(
                      targetTime: event.betCloseTime,
                      prefix: '⏱ Bets close in: ',
                    ),
                  ] else ...[
                    const SizedBox(height: 12),
                    if (event.winningOption != null)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: AppColors.gold.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.emoji_events,
                                color: AppColors.gold, size: 18),
                            const SizedBox(width: 6),
                            Text(
                              'Winner: ${event.winningOption}',
                              style: GoogleFonts.poppins(
                                fontWeight: FontWeight.w700,
                                color: AppColors.gold,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Betting Options
            Text(
              'Select Your Bet',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.white,
              ),
            ),
            const SizedBox(height: 12),

            ...event.options.map((opt) {
              final isSelected = _selectedOption == opt.label;
              return GestureDetector(
                onTap: isBettingOpen
                    ? () => setState(() => _selectedOption = opt.label)
                    : null,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.accent.withValues(alpha: 0.15)
                        : AppColors.card,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: isSelected
                          ? AppColors.accent
                          : AppColors.cardLight,
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isSelected
                              ? AppColors.accent
                              : AppColors.cardLight,
                          border: Border.all(
                            color: isSelected
                                ? AppColors.accent
                                : AppColors.grey,
                          ),
                        ),
                        child: isSelected
                            ? const Icon(Icons.check,
                                size: 16, color: AppColors.background)
                            : null,
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Text(
                          opt.label,
                          style: GoogleFonts.poppins(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: AppColors.white,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.accent.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '${opt.multiplier}x',
                          style: GoogleFonts.poppins(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: AppColors.accent,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),

            if (isBettingOpen) ...[
              const SizedBox(height: 24),

              // Amount input
              Text(
                'Enter Amount',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.white,
                ),
              ),
              const SizedBox(height: 12),

              TextFormField(
                controller: _amountController,
                keyboardType: TextInputType.number,
                style: GoogleFonts.poppins(
                    color: AppColors.white, fontSize: 18),
                onChanged: (v) {
                  setState(() {
                    _betAmount = double.tryParse(v) ?? 0;
                  });
                },
                decoration: InputDecoration(
                  hintText: '₹ Enter amount',
                  prefixIcon: const Icon(Icons.currency_rupee),
                ),
              ),

              const SizedBox(height: 12),

              // Quick amount chips
              Wrap(
                spacing: 10,
                children: _quickAmounts.map((amt) {
                  return ActionChip(
                    label: Text('₹$amt'),
                    backgroundColor: AppColors.cardLight,
                    labelStyle: GoogleFonts.poppins(
                      color: AppColors.accent,
                      fontWeight: FontWeight.w600,
                    ),
                    side: BorderSide(
                        color: AppColors.accent.withValues(alpha: 0.3)),
                    onPressed: () {
                      setState(() {
                        _betAmount = amt.toDouble();
                        _amountController.text = amt.toString();
                      });
                    },
                  );
                }).toList(),
              ),

              const SizedBox(height: 20),

              // Potential win
              if (_selectedOption != null && _betAmount > 0)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.gold.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                        color: AppColors.gold.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Potential Win',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      Text(
                        AppUtils.formatCurrency(_potentialWin),
                        style: GoogleFonts.poppins(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: AppColors.gold,
                        ),
                      ),
                    ],
                  ),
                ),

              const SizedBox(height: 16),

              // Wallet balance
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.account_balance_wallet,
                      color: AppColors.textSecondary, size: 14),
                  const SizedBox(width: 4),
                  Text(
                    'Balance: ${AppUtils.formatCurrency(auth.currentUser?.walletBalance ?? 0)}',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Place bet button
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _placeBet,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: Text(
                    'PLACE BET',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 24),
            ] else ...[
              const SizedBox(height: 24),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.red.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                      color: AppColors.red.withValues(alpha: 0.3)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.lock, color: AppColors.red, size: 18),
                    const SizedBox(width: 8),
                    Text(
                      'Betting is closed for this event',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: AppColors.red,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _teamWidget(String name) {
    return Column(
      children: [
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.cardLight,
            border: Border.all(
                color: AppColors.accent.withValues(alpha: 0.3)),
          ),
          child: Center(
            child: Text(
              name.substring(0, name.length >= 2 ? 2 : name.length).toUpperCase(),
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: AppColors.accent,
              ),
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          name,
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.white,
          ),
        ),
      ],
    );
  }
}
