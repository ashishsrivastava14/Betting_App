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

  Color _getTeamColor(int index) {
    return index == 0 ? const Color(0xFF3498DB) : const Color(0xFFE74C3C);
  }

  String _getTeamInitials(String name) {
    final words = name.trim().split(' ');
    if (words.length >= 2) {
      return '${words[0][0]}${words[1][0]}'.toUpperCase();
    }
    return name.substring(0, name.length >= 3 ? 3 : name.length).toUpperCase();
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

    walletProvider.deductBalance(auth.currentUser!, _betAmount);
    walletProvider.addTransaction(TransactionModel(
      id: AppUtils.generateId('TXN'),
      userId: auth.currentUser!.id,
      type: 'bet_debit',
      amount: _betAmount,
      status: 'completed',
      createdAt: DateTime.now(),
      notes: 'Bet on ${event.name} - $_selectedOption',
    ));
    context.read<BetProvider>().placeBet(bet);
    // Notify AuthProvider so wallet balance updates everywhere in the UI.
    auth.refreshBalance();

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
                color: AppColors.green.withValues(alpha: 0.15),
              ),
              child: const Icon(Icons.check_circle,
                  color: AppColors.green, size: 48),
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
              'You bet ${AppUtils.formatCurrency(bet.amount)} on ${bet.selectedOption}',
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
              setState(() {
                _selectedOption = null;
                _betAmount = 0;
                _amountController.clear();
              });
              context.go('/home');
            },
            child: Text('OK',
                style: GoogleFonts.poppins(
                    color: AppColors.accent, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
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
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Text(event.eventType),
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.surface,
              border: Border.all(color: AppColors.cardBorder),
            ),
            child: const Icon(Icons.arrow_back, size: 18),
          ),
          onPressed: () => context.go('/home'),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.cardBorder),
            ),
            child: Row(
              children: [
                const Icon(Icons.account_balance_wallet_outlined,
                    size: 14, color: AppColors.accent),
                const SizedBox(width: 4),
                Text(
                  AppUtils.formatCurrency(
                      auth.currentUser?.walletBalance ?? 0),
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Match Header Card ──
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.cardBorder),
              ),
              child: Column(
                children: [
                  Text(
                    event.name,
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  // Teams row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _teamAvatar(event.team1, 0),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 5),
                              decoration: BoxDecoration(
                                color: AppColors.surface,
                                borderRadius: BorderRadius.circular(8),
                                border:
                                    Border.all(color: AppColors.cardBorder),
                              ),
                              child: Text(
                                'VS',
                                style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              AppUtils.formatDateShort(event.startTime),
                              style: GoogleFonts.poppins(
                                fontSize: 10,
                                color: AppColors.textMuted,
                              ),
                            ),
                          ],
                        ),
                      ),
                      _teamAvatar(event.team2, 1),
                    ],
                  ),
                  const SizedBox(height: 16),
                  if (isBettingOpen)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 7),
                      decoration: BoxDecoration(
                        color: event.status == 'live'
                            ? AppColors.green.withValues(alpha: 0.1)
                            : AppColors.accent.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: event.status == 'live'
                              ? AppColors.green.withValues(alpha: 0.3)
                              : AppColors.accent.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.timer_outlined,
                              size: 14,
                              color: event.status == 'live'
                                  ? AppColors.green
                                  : AppColors.accent),
                          const SizedBox(width: 6),
                          CountdownTimerWidget(
                            targetTime: event.betCloseTime,
                            prefix: 'Bets close in: ',
                          ),
                        ],
                      ),
                    )
                  else if (event.winningOption != null)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 7),
                      decoration: BoxDecoration(
                        color: AppColors.gold.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                            color: AppColors.gold.withValues(alpha: 0.3)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.emoji_events,
                              color: AppColors.gold, size: 16),
                          const SizedBox(width: 6),
                          Text(
                            'Winner: ${event.winningOption}',
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.w700,
                              fontSize: 13,
                              color: AppColors.gold,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // ── Betting Options ──
            _sectionHeader('Select Your Bet', Icons.how_to_vote_outlined),
            const SizedBox(height: 10),

            ...event.options.map((opt) {
              final isSelected = _selectedOption == opt.label;
              return GestureDetector(
                onTap: isBettingOpen
                    ? () => setState(() => _selectedOption = opt.label)
                    : null,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.accent.withValues(alpha: 0.1)
                        : AppColors.card,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected
                          ? AppColors.accent
                          : AppColors.cardBorder,
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 22,
                        height: 22,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isSelected
                              ? AppColors.accent
                              : Colors.transparent,
                          border: Border.all(
                            color: isSelected
                                ? AppColors.accent
                                : AppColors.grey,
                            width: 2,
                          ),
                        ),
                        child: isSelected
                            ? const Icon(Icons.check,
                                size: 14, color: AppColors.background)
                            : null,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          opt.label,
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: isSelected
                                ? AppColors.accent
                                : AppColors.white,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.accent.withValues(alpha: 0.2)
                              : AppColors.surface,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          '${opt.multiplier}x',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            color: isSelected
                                ? AppColors.accent
                                : AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),

            if (isBettingOpen) ...[
              const SizedBox(height: 20),
              _sectionHeader('Enter Amount', Icons.currency_rupee),
              const SizedBox(height: 10),

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
              const SizedBox(height: 10),

              // Quick chips
              Row(
                children: _quickAmounts.map((amt) {
                  final isActive = _betAmount == amt.toDouble();
                  return Expanded(
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _betAmount = amt.toDouble();
                          _amountController.text = amt.toString();
                        });
                      },
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 3),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: isActive
                              ? AppColors.accent.withValues(alpha: 0.15)
                              : AppColors.surface,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: isActive
                                ? AppColors.accent
                                : AppColors.cardBorder,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            '₹$amt',
                            style: GoogleFonts.poppins(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: isActive
                                  ? AppColors.accent
                                  : AppColors.textSecondary,
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),

              const SizedBox(height: 16),

              // Potential win
              if (_selectedOption != null && _betAmount > 0)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.gold.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                        color: AppColors.gold.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.emoji_events,
                              color: AppColors.gold, size: 18),
                          const SizedBox(width: 8),
                          Text(
                            'Potential Win',
                            style: GoogleFonts.poppins(
                              fontSize: 13,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                      Text(
                        AppUtils.formatCurrency(_potentialWin),
                        style: GoogleFonts.poppins(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: AppColors.gold,
                        ),
                      ),
                    ],
                  ),
                ),

              const SizedBox(height: 20),

              // Place bet button
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _placeBet,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.bolt, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'PLACE BET',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ] else ...[
              const SizedBox(height: 20),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.red.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                      color: AppColors.red.withValues(alpha: 0.3)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.lock_outline,
                        color: AppColors.red, size: 18),
                    const SizedBox(width: 8),
                    Text(
                      'Betting is closed for this event',
                      style: GoogleFonts.poppins(
                        fontSize: 13,
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

  Widget _sectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.accent),
        const SizedBox(width: 8),
        Text(
          title,
          style: GoogleFonts.poppins(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: AppColors.white,
          ),
        ),
      ],
    );
  }

  Widget _teamAvatar(String name, int index) {
    final logoAsset = AppUtils.getTeamLogoAsset(name);
    return Column(
      children: [
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: _getTeamColor(index).withValues(alpha: 0.15),
            border: Border.all(
                color: _getTeamColor(index).withValues(alpha: 0.5),
                width: 2),
          ),
          child: ClipOval(
            child: logoAsset != null
                ? Image.asset(
                    logoAsset,
                    width: 60,
                    height: 60,
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) => Center(
                      child: Text(
                        _getTeamInitials(name),
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: _getTeamColor(index),
                        ),
                      ),
                    ),
                  )
                : Center(
                    child: Text(
                      _getTeamInitials(name),
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: _getTeamColor(index),
                      ),
                    ),
                  ),
          ),
        ),
        const SizedBox(height: 6),
        SizedBox(
          width: 80,
          child: Text(
            name,
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.white,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
