import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../providers/auth_provider.dart';
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
  String _method = 'upi';
  final _quickAmounts = [500, 1000, 2000, 5000, 10000];

  @override
  void dispose() {
    _amountController.dispose();
    _upiController.dispose();
    _bankNameController.dispose();
    _accountController.dispose();
    _ifscController.dispose();
    super.dispose();
  }

  void _proceedToWhatsApp() async {
    final auth = context.read<AuthProvider>();
    final user = auth.currentUser;

    if (user == null) return;
    if (_amount <= 0) {
      _showSnackbar('Please enter an amount');
      return;
    }
    if (_amount > user.walletBalance) {
      _showSnackbar('Insufficient balance');
      return;
    }
    if (_method == 'upi' && _upiController.text.trim().isEmpty) {
      _showSnackbar('Please enter your UPI ID');
      return;
    }
    if (_method == 'bank' &&
        (_bankNameController.text.trim().isEmpty ||
            _accountController.text.trim().isEmpty ||
            _ifscController.text.trim().isEmpty)) {
      _showSnackbar('Please fill all bank details');
      return;
    }

    final paymentDetails = _method == 'upi'
        ? 'UPI ID: ${_upiController.text.trim()}'
        : 'Bank: ${_bankNameController.text.trim()}, '
            'Account: ${_accountController.text.trim()}, '
            'IFSC: ${_ifscController.text.trim()}';

    final message = Uri.encodeComponent(
      'Hi Admin, I want to withdraw ${AppUtils.formatCurrency(_amount)}.\n'
      'My User ID is ${user.id}.\n'
      'Payment details — $paymentDetails.',
    );

    final url = Uri.parse('https://wa.me/919999999999?text=$message');

    try {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } catch (_) {
      if (mounted) {
        _showSnackbar('Could not open WhatsApp');
      }
    }
  }

  void _showSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    return Scaffold(
      appBar: AppBar(
        title: Text('Withdraw', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
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
            const SizedBox(height: 8),

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
                  Row(
                    children: [
                      const Icon(Icons.account_balance_wallet,
                          color: AppColors.accent, size: 18),
                      const SizedBox(width: 8),
                      Text('Available Balance',
                          style: GoogleFonts.poppins(
                              color: AppColors.textSecondary, fontSize: 13)),
                    ],
                  ),
                  Text(
                    AppUtils.formatCurrency(auth.currentUser?.walletBalance ?? 0),
                    style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.accent),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Amount input
            Row(
              children: [
                const Icon(Icons.currency_rupee, color: AppColors.accent, size: 20),
                const SizedBox(width: 8),
                Text(
                  'Enter Withdrawal Amount',
                  style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.white),
                ),
              ],
            ),
            const SizedBox(height: 16),

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

            const SizedBox(height: 16),

            // Quick amount chips
            Row(
              children: _quickAmounts.map((amt) {
                final isSelected = _amount == amt.toDouble();
                return Expanded(
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _amount = amt.toDouble();
                        _amountController.text = amt.toString();
                      });
                    },
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

            const SizedBox(height: 24),

            // Payment method
            _sectionHeader(Icons.payment, 'Payment Method'),
            const SizedBox(height: 10),

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
                    prefixIcon: Icon(Icons.account_balance)),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _accountController,
                style: GoogleFonts.poppins(color: AppColors.white),
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                    hintText: 'Account Number',
                    prefixIcon: Icon(Icons.numbers)),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _ifscController,
                style: GoogleFonts.poppins(color: AppColors.white),
                decoration: const InputDecoration(
                    hintText: 'IFSC Code', prefixIcon: Icon(Icons.code)),
              ),
            ],

            const SizedBox(height: 32),

            // WhatsApp button
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                onPressed: _proceedToWhatsApp,
                icon: const Icon(Icons.chat, size: 20),
                label: Text(
                  'Proceed to WhatsApp',
                  style: GoogleFonts.poppins(
                      fontSize: 15, fontWeight: FontWeight.w700),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF25D366),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Info note
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
                      'Admin will process your withdrawal within 24 hours after verification. Ensure your payment details are correct.',
                      style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: AppColors.accent,
                          height: 1.5),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionHeader(IconData icon, String label) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.accent),
        const SizedBox(width: 8),
        Text(label,
            style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.white)),
      ],
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
                ? AppColors.accent.withValues(alpha: 0.12)
                : AppColors.card,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? AppColors.accent : AppColors.cardBorder,
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon,
                  color:
                      isSelected ? AppColors.accent : AppColors.textMuted,
                  size: 18),
              const SizedBox(width: 6),
              Text(
                label,
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight:
                      isSelected ? FontWeight.w600 : FontWeight.w400,
                  color:
                      isSelected ? AppColors.accent : AppColors.textMuted,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}