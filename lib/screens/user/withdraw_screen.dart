import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
  final _holderController = TextEditingController();

  double _amount = 0;
  String _method = 'upi'; // 'upi' | 'phonepe' | 'googlepay' | 'paytm' | 'bank'
  bool _submitting = false;

  final _quickAmounts = [500, 1000, 2000, 5000, 10000];

  @override
  void dispose() {
    _amountController.dispose();
    _upiController.dispose();
    _bankNameController.dispose();
    _accountController.dispose();
    _ifscController.dispose();
    _holderController.dispose();
    super.dispose();
  }

  void _submit() {
    final auth = context.read<AuthProvider>();
    final wallet = context.read<WalletProvider>();
    final user = auth.currentUser;
    if (user == null) return;

    if (_amount <= 0) {
      _snack('Please enter an amount');
      return;
    }
    if (_amount > user.walletBalance) {
      _snack('Insufficient balance');
      return;
    }

    String? paymentDetails;

    if (_method == 'bank') {
      if (_holderController.text.trim().isEmpty ||
          _bankNameController.text.trim().isEmpty ||
          _accountController.text.trim().isEmpty ||
          _ifscController.text.trim().isEmpty) {
        _snack('Please fill all bank details');
        return;
      }
      paymentDetails =
          'Bank: ${_bankNameController.text.trim()}, A/C: ${_accountController.text.trim()}, '
          'IFSC: ${_ifscController.text.trim()}, Name: ${_holderController.text.trim()}';
    } else {
      // UPI variants
      if (_upiController.text.trim().isEmpty) {
        _snack('Please enter your ${_methodLabel(_method)} ID');
        return;
      }
      paymentDetails = '${_methodLabel(_method)}: ${_upiController.text.trim()}';
    }

    setState(() => _submitting = true);

    wallet.addTransaction(TransactionModel(
      id: 'TXN${DateTime.now().millisecondsSinceEpoch}',
      userId: user.id,
      type: 'withdrawal',
      amount: _amount,
      status: 'pending',
      createdAt: DateTime.now(),
      notes: 'Withdrawal request via ${_methodLabel(_method)}',
      withdrawalPaymentDetails: paymentDetails,
    ));

    setState(() => _submitting = false);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Withdrawal request of ${AppUtils.formatCurrency(_amount)} submitted. Admin will process it shortly.',
          style: GoogleFonts.poppins(fontSize: 13),
        ),
        backgroundColor: AppColors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
    context.pop();
  }

  void _snack(String msg) =>
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(msg)));

  String _methodLabel(String method) {
    switch (method) {
      case 'upi': return 'UPI';
      case 'phonepe': return 'PhonePe';
      case 'googlepay': return 'Google Pay';
      case 'paytm': return 'Paytm';
      case 'bank': return 'Bank Transfer';
      default: return 'UPI';
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final user = auth.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: Text('Withdraw',
            style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.card,
              border: Border.all(color: AppColors.cardBorder),
            ),
            child: const Icon(Icons.arrow_back, size: 18),
          ),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Available balance
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.cardBorder),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(children: [
                    const Icon(Icons.account_balance_wallet,
                        color: AppColors.accent, size: 18),
                    const SizedBox(width: 8),
                    Text('Available Balance',
                        style: GoogleFonts.poppins(
                            color: AppColors.textSecondary, fontSize: 13)),
                  ]),
                  Text(
                    AppUtils.formatCurrency(user?.walletBalance ?? 0),
                    style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.accent),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // ── Step 1: Amount ──────────────────────────────────
            _stepHeader('1', 'Enter Withdrawal Amount'),
            const SizedBox(height: 12),

            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.cardBorder),
              ),
              child: TextFormField(
                controller: _amountController,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                style: GoogleFonts.poppins(
                    color: AppColors.accent,
                    fontSize: 28,
                    fontWeight: FontWeight.w700),
                onChanged: (v) =>
                    setState(() => _amount = double.tryParse(v) ?? 0),
                decoration: InputDecoration(
                  hintText: '0',
                  hintStyle: GoogleFonts.poppins(
                      color: AppColors.textMuted,
                      fontSize: 28,
                      fontWeight: FontWeight.w700),
                  prefixIcon: const Icon(Icons.currency_rupee,
                      size: 28, color: AppColors.accent),
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  fillColor: Colors.transparent,
                  filled: true,
                ),
              ),
            ),

            const SizedBox(height: 12),

            Row(
              children: _quickAmounts.map((amt) {
                final isSelected = _amount == amt.toDouble();
                return Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() {
                      _amount = amt.toDouble();
                      _amountController.text = amt.toString();
                    }),
                    child: Container(
                      margin: EdgeInsets.only(
                          right: amt == _quickAmounts.last ? 0 : 8),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.accent.withValues(alpha: 0.15)
                            : AppColors.card,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: isSelected
                              ? AppColors.accent
                              : AppColors.cardBorder,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          amt >= 1000 ? '${amt ~/ 1000}K' : '$amt',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: isSelected
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

            const SizedBox(height: 28),

            // ── Step 2: Payment Method ───────────────────────────
            _stepHeader('2', 'Payout Method'),
            const SizedBox(height: 12),

            // Method chips
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _methodChip('UPI', 'upi', Icons.phone_android),
                  const SizedBox(width: 8),
                  _methodChip('PhonePe', 'phonepe', Icons.smartphone),
                  const SizedBox(width: 8),
                  _methodChip('Google Pay', 'googlepay', Icons.g_mobiledata),
                  const SizedBox(width: 8),
                  _methodChip('Paytm', 'paytm', Icons.wallet),
                  const SizedBox(width: 8),
                  _methodChip(
                      'Bank Transfer', 'bank', Icons.account_balance),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Method-specific fields
            if (_method == 'bank') ...[
              _textField(_holderController, 'Account Holder Name',
                  Icons.person_outline),
              const SizedBox(height: 10),
              _textField(_bankNameController, 'Bank Name',
                  Icons.account_balance_outlined),
              const SizedBox(height: 10),
              _textField(_accountController, 'Account Number', Icons.numbers,
                  inputType: TextInputType.number),
              const SizedBox(height: 10),
              _textField(_ifscController, 'IFSC Code',
                  Icons.qr_code_scanner,
                  caps: TextCapitalization.characters),
            ] else ...[
              _textField(
                _upiController,
                _method == 'phonepe'
                    ? 'PhonePe Number / UPI ID (e.g. 9999@ybl)'
                    : _method == 'googlepay'
                        ? 'Google Pay UPI ID (e.g. name@okaxis)'
                        : _method == 'paytm'
                            ? 'Paytm Number / UPI ID'
                            : 'UPI ID (e.g. name@upi)',
                Icons.alternate_email,
              ),
            ],

            const SizedBox(height: 28),

            // Submit
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _submitting ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accent,
                  foregroundColor: AppColors.background,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
                child: _submitting
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.background))
                    : Text('Submit Withdrawal Request',
                        style: GoogleFonts.poppins(
                            fontSize: 15,
                            fontWeight: FontWeight.w700)),
              ),
            ),

            const SizedBox(height: 16),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.accent.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                    color: AppColors.accent.withValues(alpha: 0.2)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.info_outline,
                      color: AppColors.accent, size: 18),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Admin will verify your request and process the payment within 24 hours. '
                      'You will receive a payment confirmation screenshot once processed.',
                      style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: AppColors.accent,
                          height: 1.5),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _stepHeader(String step, String label) {
    return Row(children: [
      Container(
        width: 24,
        height: 24,
        decoration: const BoxDecoration(
            shape: BoxShape.circle, color: AppColors.accent),
        child: Center(
          child: Text(step,
              style: GoogleFonts.poppins(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: AppColors.background)),
        ),
      ),
      const SizedBox(width: 8),
      Text(label,
          style: GoogleFonts.poppins(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: AppColors.white)),
    ]);
  }

  Widget _methodChip(String label, String value, IconData icon) {
    final sel = _method == value;
    return GestureDetector(
      onTap: () => setState(() {
        _method = value;
        _upiController.clear();
      }),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: sel
              ? AppColors.accent.withValues(alpha: 0.12)
              : AppColors.card,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: sel ? AppColors.accent : AppColors.cardBorder,
            width: sel ? 1.5 : 1,
          ),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(icon,
              size: 16,
              color: sel ? AppColors.accent : AppColors.textMuted),
          const SizedBox(width: 6),
          Text(label,
              style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight:
                      sel ? FontWeight.w600 : FontWeight.w400,
                  color:
                      sel ? AppColors.accent : AppColors.textMuted)),
        ]),
      ),
    );
  }

  Widget _textField(
    TextEditingController ctrl,
    String hint,
    IconData icon, {
    TextInputType inputType = TextInputType.text,
    TextCapitalization caps = TextCapitalization.none,
  }) {
    return TextFormField(
      controller: ctrl,
      keyboardType: inputType,
      textCapitalization: caps,
      style: GoogleFonts.poppins(color: AppColors.white, fontSize: 14),
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icon, size: 18),
        isDense: true,
        contentPadding:
            const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
      ),
    );
  }
}
