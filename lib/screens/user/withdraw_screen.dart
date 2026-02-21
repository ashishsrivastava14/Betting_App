import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../models/transaction_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/wallet_provider.dart';
import '../../theme/app_theme.dart';
import '../../utils/app_utils.dart';

class WithdrawScreen extends StatefulWidget {
  const WithdrawScreen({super.key});

  @override
  State<WithdrawScreen> createState() => _WithdrawScreenState();
}

class _WithdrawScreenState extends State<WithdrawScreen> {
  final _amountController = TextEditingController();
  final _upiController = TextEditingController();
  final _bankNameController = TextEditingController();
  final _accountController = TextEditingController();
  final _ifscController = TextEditingController();
  double _amount = 0;
  String _method = 'upi'; // 'upi' | 'bank'

  @override
  void dispose() {
    _amountController.dispose();
    _upiController.dispose();
    _bankNameController.dispose();
    _accountController.dispose();
    _ifscController.dispose();
    super.dispose();
  }

  void _submitWithdrawal() {
    final auth = context.read<AuthProvider>();
    final walletProvider = context.read<WalletProvider>();
    final user = auth.currentUser;

    if (user == null) return;

    if (_amount <= 0) {
      _showSnackbar('Please enter amount');
      return;
    }
    if (_amount > user.walletBalance) {
      _showSnackbar('Insufficient balance');
      return;
    }
    if (_method == 'upi' && _upiController.text.trim().isEmpty) {
      _showSnackbar('Please enter UPI ID');
      return;
    }
    if (_method == 'bank' &&
        (_bankNameController.text.trim().isEmpty ||
            _accountController.text.trim().isEmpty)) {
      _showSnackbar('Please fill bank details');
      return;
    }

    final notes = _method == 'upi'
        ? 'Withdrawal to UPI: ${_upiController.text.trim()}'
        : 'Withdrawal to Bank: ${_bankNameController.text.trim()}';

    walletProvider.addTransaction(TransactionModel(
      id: AppUtils.generateId('TXN'),
      userId: user.id,
      type: 'withdrawal',
      amount: _amount,
      status: 'pending',
      createdAt: DateTime.now(),
      notes: notes,
    ));

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
                color: AppColors.accent.withValues(alpha: 0.2),
              ),
              child: const Icon(Icons.check_circle,
                  color: AppColors.accent, size: 48),
            ),
            const SizedBox(height: 16),
            Text(
              'Request Submitted',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.white,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Your withdrawal of ${AppUtils.formatCurrency(_amount)} is pending admin approval.',
              style: GoogleFonts.poppins(
                  fontSize: 13, color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              context.pop();
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
    final auth = context.watch<AuthProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Withdraw'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Balance display
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Available Balance',
                    style: GoogleFonts.poppins(
                        color: AppColors.textSecondary, fontSize: 14),
                  ),
                  Text(
                    AppUtils.formatCurrency(
                        auth.currentUser?.walletBalance ?? 0),
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppColors.accent,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Amount
            Text(
              'Withdrawal Amount',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.white,
              ),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              style: GoogleFonts.poppins(color: AppColors.white, fontSize: 18),
              onChanged: (v) =>
                  setState(() => _amount = double.tryParse(v) ?? 0),
              decoration: const InputDecoration(
                hintText: '₹ Enter amount',
                prefixIcon: Icon(Icons.currency_rupee),
              ),
            ),

            const SizedBox(height: 24),

            // Payment method tabs
            Text(
              'Payment Method',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.white,
              ),
            ),
            const SizedBox(height: 12),

            Row(
              children: [
                _methodChip('UPI', 'upi', Icons.phone_android),
                const SizedBox(width: 12),
                _methodChip('Bank Transfer', 'bank', Icons.account_balance),
              ],
            ),

            const SizedBox(height: 16),

            if (_method == 'upi') ...[
              TextFormField(
                controller: _upiController,
                style: GoogleFonts.poppins(color: AppColors.white),
                decoration: const InputDecoration(
                  hintText: 'Enter UPI ID (e.g. name@upi)',
                  prefixIcon: Icon(Icons.alternate_email),
                ),
              ),
            ] else ...[
              TextFormField(
                controller: _bankNameController,
                style: GoogleFonts.poppins(color: AppColors.white),
                decoration: const InputDecoration(
                  hintText: 'Bank Name',
                  prefixIcon: Icon(Icons.account_balance),
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _accountController,
                style: GoogleFonts.poppins(color: AppColors.white),
                decoration: const InputDecoration(
                  hintText: 'Account Number',
                  prefixIcon: Icon(Icons.numbers),
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _ifscController,
                style: GoogleFonts.poppins(color: AppColors.white),
                decoration: const InputDecoration(
                  hintText: 'IFSC Code',
                  prefixIcon: Icon(Icons.code),
                ),
              ),
            ],

            const SizedBox(height: 32),

            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _submitWithdrawal,
                child: Text(
                  'Submit Withdrawal Request',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _methodChip(String label, String value, IconData icon) {
    final isSelected = _method == value;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _method = value),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.accent.withValues(alpha: 0.15)
                : AppColors.card,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? AppColors.accent : AppColors.cardLight,
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon,
                  color: isSelected ? AppColors.accent : AppColors.grey,
                  size: 18),
              const SizedBox(width: 6),
              Text(
                label,
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                  color: isSelected ? AppColors.accent : AppColors.grey,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
