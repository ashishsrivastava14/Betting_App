import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../models/payment_account_model.dart';
import '../../models/transaction_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/payment_account_provider.dart';
import '../../providers/wallet_provider.dart';
import '../../theme/app_theme.dart';
import '../../utils/app_utils.dart';

class DepositScreen extends StatefulWidget {
  const DepositScreen({super.key});

  @override
  State<DepositScreen> createState() => _DepositScreenState();
}

class _DepositScreenState extends State<DepositScreen> {
  final _amountController = TextEditingController();
  double _amount = 0;
  final _quickAmounts = [500, 1000, 2000, 5000, 10000];

  PaymentAccountModel? _selectedAccount;
  String? _screenshotPath;
  bool _submitting = false;

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _pickScreenshot() async {
    final file =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (file != null) setState(() => _screenshotPath = file.path);
  }

  void _submit() {
    if (_amount <= 0) {
      _snack('Please enter a valid amount');
      return;
    }
    if (_selectedAccount == null) {
      _snack('Please select a payment account');
      return;
    }
    if (_screenshotPath == null) {
      _snack('Please upload a payment screenshot');
      return;
    }

    final auth = context.read<AuthProvider>();
    final wallet = context.read<WalletProvider>();
    final user = auth.currentUser;
    if (user == null) return;

    setState(() => _submitting = true);

    wallet.addTransaction(TransactionModel(
      id: 'TXN${DateTime.now().millisecondsSinceEpoch}',
      userId: user.id,
      type: 'deposit',
      amount: _amount,
      status: 'pending',
      createdAt: DateTime.now(),
      notes: 'Deposit via ${_selectedAccount!.name}',
      paymentAccountId: _selectedAccount!.id,
      paymentAccountName: '${_selectedAccount!.name} (${_selectedAccount!.type.label})',
      depositScreenshotPath: _screenshotPath,
    ));

    setState(() => _submitting = false);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Deposit request submitted for ${AppUtils.formatCurrency(_amount)}. Pending admin approval.',
          style: GoogleFonts.poppins(fontSize: 13),
        ),
        backgroundColor: AppColors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
    context.pop();
  }

  void _snack(String msg) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    final accounts =
        context.watch<PaymentAccountProvider>().activeAccounts;

    return Scaffold(
      appBar: AppBar(
        title: Text('Deposit',
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
            // ── Step 1: Amount ──────────────────────────────────
            _stepHeader('1', 'Enter Deposit Amount'),
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

            // Quick amounts
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

            // ── Step 2: Select Payment Account ───────────────────
            _stepHeader('2', 'Select Payment Account'),
            const SizedBox(height: 12),

            if (accounts.isEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.card,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.cardBorder),
                ),
                child: Text(
                  'No payment accounts configured by admin.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                      color: AppColors.textSecondary, fontSize: 13),
                ),
              )
            else
              ...accounts.map((a) => _AccountCard(
                    account: a,
                    isSelected: _selectedAccount?.id == a.id,
                    onTap: () =>
                        setState(() => _selectedAccount = a),
                  )),

            // Show account details when selected
            if (_selectedAccount != null) ...[
              const SizedBox(height: 16),
              _AccountDetails(account: _selectedAccount!),
            ],

            const SizedBox(height: 28),

            // ── Step 3: Upload Screenshot ────────────────────────
            _stepHeader('3', 'Upload Payment Screenshot'),
            const SizedBox(height: 4),
            Text(
              'After completing the payment, upload a screenshot as proof.',
              style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                  height: 1.4),
            ),
            const SizedBox(height: 12),

            GestureDetector(
              onTap: _pickScreenshot,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: double.infinity,
                height: _screenshotPath != null ? 200 : 120,
                decoration: BoxDecoration(
                  color: AppColors.card,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: _screenshotPath != null
                        ? AppColors.green.withValues(alpha: 0.5)
                        : AppColors.accent.withValues(alpha: 0.4),
                    width: 1.5,
                  ),
                ),
                child: _screenshotPath != null
                    ? Stack(children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(13),
                          child: !kIsWeb &&
                                  File(_screenshotPath!).existsSync()
                              ? Image.file(
                                  File(_screenshotPath!),
                                  width: double.infinity,
                                  height: double.infinity,
                                  fit: BoxFit.cover,
                                )
                              : Center(
                                  child: Text('Screenshot selected',
                                      style: GoogleFonts.poppins(
                                          color: AppColors.green,
                                          fontSize: 13)),
                                ),
                        ),
                        Positioned(
                          top: 8,
                          right: 8,
                          child: GestureDetector(
                            onTap: () =>
                                setState(() => _screenshotPath = null),
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: AppColors.background),
                              child: const Icon(Icons.close,
                                  size: 16, color: AppColors.white),
                            ),
                          ),
                        ),
                      ])
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.cloud_upload_rounded,
                              size: 36, color: AppColors.accent),
                          const SizedBox(height: 8),
                          Text('Tap to upload screenshot',
                              style: GoogleFonts.poppins(
                                  fontSize: 13,
                                  color: AppColors.textSecondary)),
                          const SizedBox(height: 4),
                          Text('JPG, PNG supported',
                              style: GoogleFonts.poppins(
                                  fontSize: 11,
                                  color: AppColors.textMuted)),
                        ],
                      ),
              ),
            ),

            const SizedBox(height: 28),

            // ── Submit ───────────────────────────────────────────
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
                            strokeWidth: 2, color: AppColors.background))
                    : Text('Submit Deposit Request',
                        style: GoogleFonts.poppins(
                            fontSize: 15,
                            fontWeight: FontWeight.w700)),
              ),
            ),

            const SizedBox(height: 16),

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
                      'Your deposit will be credited after admin verification, usually within 30 minutes.',
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
          shape: BoxShape.circle,
          color: AppColors.accent,
        ),
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
}

// ─────────────────────────────────────────────────────────────
// Account selection card
// ─────────────────────────────────────────────────────────────
class _AccountCard extends StatelessWidget {
  final PaymentAccountModel account;
  final bool isSelected;
  final VoidCallback onTap;

  const _AccountCard({
    required this.account,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.accent.withValues(alpha: 0.08)
              : AppColors.card,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.accent : AppColors.cardBorder,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _typeColor(account.type).withValues(alpha: 0.12),
            ),
            child: Icon(_typeIcon(account.type),
                color: _typeColor(account.type), size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
              Text(account.name,
                  style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.white)),
              Text(account.type.label,
                  style: GoogleFonts.poppins(
                      fontSize: 12, color: AppColors.textSecondary)),
            ]),
          ),
          if (isSelected)
            const Icon(Icons.check_circle_rounded,
                color: AppColors.accent, size: 20),
        ]),
      ),
    );
  }

  IconData _typeIcon(PaymentMethodType type) {
    switch (type) {
      case PaymentMethodType.bank:
        return Icons.account_balance;
      case PaymentMethodType.upi:
        return Icons.phone_android;
      case PaymentMethodType.qrCode:
        return Icons.qr_code;
      case PaymentMethodType.phonePe:
        return Icons.smartphone;
      case PaymentMethodType.googlePay:
        return Icons.g_mobiledata;
      case PaymentMethodType.paytm:
        return Icons.wallet;
    }
  }

  Color _typeColor(PaymentMethodType type) {
    switch (type) {
      case PaymentMethodType.bank:
        return AppColors.blue;
      case PaymentMethodType.upi:
        return AppColors.orange;
      case PaymentMethodType.qrCode:
        return AppColors.purple;
      case PaymentMethodType.phonePe:
        return const Color(0xFF5F259F);
      case PaymentMethodType.googlePay:
        return AppColors.green;
      case PaymentMethodType.paytm:
        return const Color(0xFF00BAF2);
    }
  }
}

// ─────────────────────────────────────────────────────────────
// Account payment details card (shown after selection)
// ─────────────────────────────────────────────────────────────
class _AccountDetails extends StatelessWidget {
  final PaymentAccountModel account;
  const _AccountDetails({required this.account});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.accent.withValues(alpha: 0.3)),
      ),
      child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
        Row(children: [
          const Icon(Icons.info_outline,
              size: 15, color: AppColors.accent),
          const SizedBox(width: 6),
          Text('Payment Details',
              style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppColors.accent)),
        ]),
        const SizedBox(height: 12),
        ..._buildDetails(context),
      ]),
    );
  }

  List<Widget> _buildDetails(BuildContext context) {
    switch (account.type) {
      case PaymentMethodType.bank:
        return [
          if (account.accountHolderName != null)
            _row('Account Name', account.accountHolderName!, context),
          if (account.bankName != null)
            _row('Bank Name', account.bankName!, context),
          if (account.accountNumber != null)
            _row('Account Number', account.accountNumber!, context,
                copyable: true),
          if (account.ifscCode != null)
            _row('IFSC Code', account.ifscCode!, context, copyable: true),
        ];
      case PaymentMethodType.qrCode:
        if (account.qrCodePath != null &&
            !kIsWeb &&
            File(account.qrCodePath!).existsSync()) {
          return [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.file(
                File(account.qrCodePath!),
                height: 200,
                fit: BoxFit.contain,
              ),
            ),
            const SizedBox(height: 8),
            Text('Scan QR to pay',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                    fontSize: 12, color: AppColors.textSecondary)),
          ];
        }
        return [
          Text('QR Code not available',
              style: GoogleFonts.poppins(
                  fontSize: 12, color: AppColors.textSecondary)),
        ];
      default: // UPI, PhonePe, GooglePay, Paytm
        return [
          if (account.upiId != null)
            _row(account.type.label + ' ID', account.upiId!, context,
                copyable: true),
        ];
    }
  }

  Widget _row(String label, String value, BuildContext context,
      {bool copyable = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(children: [
        Expanded(
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
            Text(label,
                style: GoogleFonts.poppins(
                    fontSize: 11, color: AppColors.textMuted)),
            const SizedBox(height: 2),
            Text(value,
                style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.white)),
          ]),
        ),
        if (copyable)
          GestureDetector(
            onTap: () {
              Clipboard.setData(ClipboardData(text: value));
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Copied: $value',
                      style: GoogleFonts.poppins(fontSize: 12)),
                  duration: const Duration(seconds: 2),
                ),
              );
            },
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.accent.withValues(alpha: 0.1),
              ),
              child: const Icon(Icons.copy_rounded,
                  size: 14, color: AppColors.accent),
            ),
          ),
      ]),
    );
  }
}
