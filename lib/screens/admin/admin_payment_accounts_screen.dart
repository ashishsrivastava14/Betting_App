import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../models/payment_account_model.dart';
import '../../providers/payment_account_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/dummy_screenshot.dart';

class AdminPaymentAccountsScreen extends StatelessWidget {
  const AdminPaymentAccountsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Payment Accounts',
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
          onPressed: () => Navigator.pop(context),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openAccountSheet(context, null),
        backgroundColor: AppColors.accent,
        foregroundColor: AppColors.background,
        icon: const Icon(Icons.add),
        label: Text('Add Account',
            style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
      ),
      body: Consumer<PaymentAccountProvider>(
        builder: (context, provider, _) {
          final accounts = provider.accounts;
          if (accounts.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.account_balance_wallet_outlined,
                      size: 56, color: AppColors.textMuted),
                  const SizedBox(height: 12),
                  Text('No payment accounts yet',
                      style: GoogleFonts.poppins(
                          color: AppColors.textSecondary, fontSize: 14)),
                  const SizedBox(height: 8),
                  Text('Tap + to add one',
                      style: GoogleFonts.poppins(
                          color: AppColors.textMuted, fontSize: 12)),
                ],
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: accounts.length,
            itemBuilder: (context, i) =>
                _AccountTile(account: accounts[i]),
          );
        },
      ),
    );
  }
}

class _AccountTile extends StatelessWidget {
  final PaymentAccountModel account;
  const _AccountTile({required this.account});

  @override
  Widget build(BuildContext context) {
    final provider = context.read<PaymentAccountProvider>();
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: account.isActive
              ? AppColors.accent.withValues(alpha: 0.3)
              : AppColors.cardBorder,
        ),
      ),
      child: Column(
        children: [
          ListTile(
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
            leading: Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _typeColor(account.type).withValues(alpha: 0.12),
              ),
              child: Icon(_typeIcon(account.type),
                  color: _typeColor(account.type), size: 20),
            ),
            title: Text(account.name,
                style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.white)),
            subtitle: Text(account.type.label,
                style: GoogleFonts.poppins(
                    fontSize: 12, color: AppColors.textSecondary)),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Active toggle
                GestureDetector(
                  onTap: () => provider.toggleActive(account.id),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: account.isActive
                          ? AppColors.green.withValues(alpha: 0.12)
                          : AppColors.red.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: account.isActive
                            ? AppColors.green.withValues(alpha: 0.4)
                            : AppColors.red.withValues(alpha: 0.4),
                      ),
                    ),
                    child: Text(
                      account.isActive ? 'ACTIVE' : 'OFF',
                      style: GoogleFonts.poppins(
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                        color: account.isActive
                            ? AppColors.green
                            : AppColors.red,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                // Edit
                IconButton(
                  icon: const Icon(Icons.edit_outlined,
                      size: 18, color: AppColors.textSecondary),
                  onPressed: () => _openAccountSheet(context, account),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
                const SizedBox(width: 4),
                // Delete
                IconButton(
                  icon: const Icon(Icons.delete_outline,
                      size: 18, color: AppColors.red),
                  onPressed: () => _confirmDelete(context, provider),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
          ),
          // Details summary
          Padding(
            padding:
                const EdgeInsets.only(left: 70, right: 14, bottom: 12),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                _detailSummary(account),
                style: GoogleFonts.poppins(
                    fontSize: 11, color: AppColors.textMuted),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _detailSummary(PaymentAccountModel a) {
    switch (a.type) {
      case PaymentMethodType.bank:
        final parts = <String>[];
        if (a.bankName != null) parts.add(a.bankName!);
        if (a.accountNumber != null) parts.add('A/C: ${a.accountNumber}');
        if (a.ifscCode != null) parts.add('IFSC: ${a.ifscCode}');
        return parts.join(' • ');
      case PaymentMethodType.qrCode:
        return a.qrCodePath != null ? 'QR uploaded' : 'No QR uploaded';
      default:
        return a.upiId ?? '—';
    }
  }

  void _confirmDelete(
      BuildContext context, PaymentAccountProvider provider) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.card,
        title: Text('Delete Account',
            style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600, color: AppColors.white)),
        content: Text(
            'Remove "${account.name}" from payment accounts?',
            style: GoogleFonts.poppins(
                color: AppColors.textSecondary, fontSize: 13)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel',
                style: GoogleFonts.poppins(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.red,
                foregroundColor: Colors.white),
            onPressed: () {
              provider.removeAccount(account.id);
              Navigator.pop(context);
            },
            child: Text('Delete',
                style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
          ),
        ],
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
// Add / Edit bottom sheet
// ─────────────────────────────────────────────────────────────
void _openAccountSheet(BuildContext context, PaymentAccountModel? existing) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.card,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (_) => ChangeNotifierProvider.value(
      value: context.read<PaymentAccountProvider>(),
      child: _AccountFormSheet(existing: existing),
    ),
  );
}

class _AccountFormSheet extends StatefulWidget {
  final PaymentAccountModel? existing;
  const _AccountFormSheet({this.existing});

  @override
  State<_AccountFormSheet> createState() => _AccountFormSheetState();
}

class _AccountFormSheetState extends State<_AccountFormSheet> {
  late PaymentMethodType _type;
  final _nameCtrl = TextEditingController();
  final _upiCtrl = TextEditingController();
  final _bankNameCtrl = TextEditingController();
  final _accountCtrl = TextEditingController();
  final _ifscCtrl = TextEditingController();
  final _holderCtrl = TextEditingController();
  String? _qrCodePath;

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    _type = e?.type ?? PaymentMethodType.bank;
    _nameCtrl.text = e?.name ?? '';
    _upiCtrl.text = e?.upiId ?? '';
    _bankNameCtrl.text = e?.bankName ?? '';
    _accountCtrl.text = e?.accountNumber ?? '';
    _ifscCtrl.text = e?.ifscCode ?? '';
    _holderCtrl.text = e?.accountHolderName ?? '';
    _qrCodePath = e?.qrCodePath;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _upiCtrl.dispose();
    _bankNameCtrl.dispose();
    _accountCtrl.dispose();
    _ifscCtrl.dispose();
    _holderCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickQr() async {
    final picker = ImagePicker();
    final file = await picker.pickImage(source: ImageSource.gallery);
    if (file != null) setState(() => _qrCodePath = file.path);
  }

  void _save() {
    if (_nameCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Account name is required')));
      return;
    }
    final provider = context.read<PaymentAccountProvider>();
    if (widget.existing == null) {
      // Add
      final account = provider.buildNew(
        name: _nameCtrl.text.trim(),
        type: _type,
        upiId: _upiCtrl.text.trim().isEmpty ? null : _upiCtrl.text.trim(),
        bankName: _bankNameCtrl.text.trim().isEmpty
            ? null
            : _bankNameCtrl.text.trim(),
        accountNumber: _accountCtrl.text.trim().isEmpty
            ? null
            : _accountCtrl.text.trim(),
        ifscCode:
            _ifscCtrl.text.trim().isEmpty ? null : _ifscCtrl.text.trim(),
        accountHolderName: _holderCtrl.text.trim().isEmpty
            ? null
            : _holderCtrl.text.trim(),
        qrCodePath: _qrCodePath,
      );
      provider.addAccount(account);
    } else {
      // Update
      final updated = widget.existing!.copyWith(
        name: _nameCtrl.text.trim(),
        type: _type,
        upiId: _upiCtrl.text.trim().isEmpty ? null : _upiCtrl.text.trim(),
        bankName: _bankNameCtrl.text.trim().isEmpty
            ? null
            : _bankNameCtrl.text.trim(),
        accountNumber: _accountCtrl.text.trim().isEmpty
            ? null
            : _accountCtrl.text.trim(),
        ifscCode:
            _ifscCtrl.text.trim().isEmpty ? null : _ifscCtrl.text.trim(),
        accountHolderName: _holderCtrl.text.trim().isEmpty
            ? null
            : _holderCtrl.text.trim(),
        qrCodePath: _qrCodePath,
      );
      provider.updateAccount(updated);
    }
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(widget.existing == null
            ? 'Account added'
            : 'Account updated'),
        backgroundColor: AppColors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.existing != null;
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 16,
        right: 16,
        top: 16,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle bar
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.cardBorder,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              isEdit ? 'Edit Account' : 'Add Payment Account',
              style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.white),
            ),
            const SizedBox(height: 16),

            // Account name
            _label('Account Name'),
            _textField(_nameCtrl, 'e.g. Account 1, Main UPI',
                Icons.badge_outlined),
            const SizedBox(height: 14),

            // Payment type
            _label('Payment Method'),
            SizedBox(
              height: 42,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: PaymentMethodType.values.map((t) {
                  final sel = _type == t;
                  return GestureDetector(
                    onTap: () => setState(() => _type = t),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: sel
                            ? AppColors.accent.withValues(alpha: 0.15)
                            : AppColors.background,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: sel
                              ? AppColors.accent
                              : AppColors.cardBorder,
                        ),
                      ),
                      child: Text(t.label,
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            fontWeight: sel
                                ? FontWeight.w600
                                : FontWeight.w400,
                            color: sel
                                ? AppColors.accent
                                : AppColors.textSecondary,
                          )),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 14),

            // Type-specific fields
            if (_type.usesBank) ...[
              _label('Account Holder Name'),
              _textField(_holderCtrl, 'Full name', Icons.person_outline),
              const SizedBox(height: 10),
              _label('Bank Name'),
              _textField(_bankNameCtrl, 'e.g. HDFC Bank',
                  Icons.account_balance_outlined),
              const SizedBox(height: 10),
              _label('Account Number'),
              _textField(_accountCtrl, 'Account number', Icons.numbers,
                  inputType: TextInputType.number),
              const SizedBox(height: 10),
              _label('IFSC Code'),
              _textField(
                  _ifscCtrl, 'e.g. HDFC0001234', Icons.qr_code_scanner,
                  caps: TextCapitalization.characters),
            ] else if (_type.usesQr) ...[
              _label('QR Code Image'),
              GestureDetector(
                onTap: _pickQr,
                child: Container(
                  height: 120,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                        color: AppColors.accent.withValues(alpha: 0.4),
                        style: BorderStyle.solid),
                  ),
                  child: _qrCodePath != null
                      ? (_qrCodePath!.startsWith('assets/')
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Image.asset(_qrCodePath!,
                                  fit: BoxFit.contain))
                          : _qrCodePath!.startsWith('https://')
                              ? NetworkQrImage(
                                  url: _qrCodePath!, size: 110)
                              : !kIsWeb
                                  ? ClipRRect(
                                      borderRadius:
                                          BorderRadius.circular(10),
                                      child: Image.file(
                                          File(_qrCodePath!),
                                          fit: BoxFit.contain))
                                  : const Icon(Icons.qr_code,
                                      size: 56,
                                      color: AppColors.accent))
                      : Stack(
                          alignment: Alignment.center,
                          children: [
                            // Sample QR as background hint
                            Opacity(
                              opacity: 0.4,
                              child: Image.asset(
                                'assets/images/sample_QR.png',
                                width: 110,
                                height: 110,
                                fit: BoxFit.contain,
                              ),
                            ),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.upload_rounded,
                                    size: 28, color: AppColors.accent),
                                const SizedBox(height: 4),
                                Text('Tap to upload QR code',
                                    style: GoogleFonts.poppins(
                                        fontSize: 11,
                                        color: AppColors.textSecondary)),
                              ],
                            ),
                          ],
                        ),
                ),
              ),
            ] else ...[
              _label(_type == PaymentMethodType.upi
                  ? 'UPI ID'
                  : '${_type.label} UPI ID / Number'),
              _textField(
                  _upiCtrl,
                  _type == PaymentMethodType.phonePe
                      ? 'e.g. 9999999999@ybl'
                      : _type == PaymentMethodType.googlePay
                          ? 'e.g. betzone@okaxis'
                          : 'e.g. name@paytm',
                  Icons.alternate_email),
            ],

            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accent,
                  foregroundColor: AppColors.background,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                child: Text(isEdit ? 'Save Changes' : 'Add Account',
                    style: GoogleFonts.poppins(
                        fontSize: 14, fontWeight: FontWeight.w700)),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _label(String text) => Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Text(text,
            style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: AppColors.textSecondary)),
      );

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
            const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
      ),
    );
  }
}
