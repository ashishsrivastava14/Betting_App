import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../mock_data/mock_users.dart';
import '../../models/payment_account_model.dart';
import '../../models/transaction_model.dart';
import '../../providers/payment_account_provider.dart';
import '../../providers/wallet_provider.dart';
import '../../theme/app_theme.dart';
import '../../utils/app_utils.dart';
import '../../widgets/dummy_screenshot.dart';

class AdminWalletScreen extends StatefulWidget {
  const AdminWalletScreen({super.key});

  @override
  State<AdminWalletScreen> createState() => _AdminWalletScreenState();
}

class _AdminWalletScreenState extends State<AdminWalletScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: Row(
                children: [
                  const Icon(Icons.account_balance_wallet_rounded,
                      color: AppColors.accent, size: 22),
                  const SizedBox(width: 10),
                  Text('Wallet Management',
                      style: GoogleFonts.poppins(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: AppColors.white)),
                ],
              ),
            ),
            const SizedBox(height: 14),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.cardBorder),
              ),
              child: TabBar(
                controller: _tabController,
                indicator: BoxDecoration(
                  color: AppColors.accent,
                  borderRadius: BorderRadius.circular(8),
                ),
                indicatorSize: TabBarIndicatorSize.tab,
                labelColor: AppColors.background,
                unselectedLabelColor: AppColors.textSecondary,
                labelStyle: GoogleFonts.poppins(
                    fontSize: 10, fontWeight: FontWeight.w700),
                unselectedLabelStyle: GoogleFonts.poppins(fontSize: 10),
                dividerHeight: 0,
                padding: const EdgeInsets.all(3),
                tabs: const [
                  Tab(text: 'PENDING'),
                  Tab(text: 'CREDIT/DEBIT'),
                  Tab(text: 'PAY ACCOUNTS'),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: const [
                  _PendingRequestsTab(),
                  _CreditDebitTab(),
                  _PaymentAccountsTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Tab 1 – Pending Requests
// ─────────────────────────────────────────────────────────────
class _PendingRequestsTab extends StatelessWidget {
  const _PendingRequestsTab();

  @override
  Widget build(BuildContext context) {
    return Consumer<WalletProvider>(builder: (context, wallet, _) {
      final pending = wallet.pendingTransactions;

      if (pending.isEmpty) {
        return Center(
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Icon(Icons.check_circle_outline,
                size: 56, color: AppColors.green.withValues(alpha: 0.4)),
            const SizedBox(height: 12),
            Text('No pending requests',
                style: GoogleFonts.poppins(
                    fontSize: 14, color: AppColors.textSecondary)),
          ]),
        );
      }

      return ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: pending.length,
        itemBuilder: (context, index) {
          final txn = pending[index];
          final user = mockUsers.firstWhere((u) => u.id == txn.userId,
              orElse: () => mockUsers.first);
          return _PendingTile(
            txn: txn,
            userName: user.name,
            isDeposit: txn.type == 'deposit',
          );
        },
      );
    });
  }
}

class _PendingTile extends StatelessWidget {
  final TransactionModel txn;
  final String userName;
  final bool isDeposit;

  const _PendingTile({
    required this.txn,
    required this.userName,
    required this.isDeposit,
  });

  @override
  Widget build(BuildContext context) {
    final wallet = context.read<WalletProvider>();
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // Header row
        Row(children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: (isDeposit ? AppColors.green : AppColors.red)
                  .withValues(alpha: 0.12),
            ),
            child: Icon(
              isDeposit
                  ? Icons.arrow_downward_rounded
                  : Icons.arrow_upward_rounded,
              color: isDeposit ? AppColors.green : AppColors.red,
              size: 18,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(userName,
                  style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.white)),
              Text('${txn.type.toUpperCase()} Request',
                  style: GoogleFonts.poppins(
                      fontSize: 11, color: AppColors.textSecondary)),
            ]),
          ),
          Text(AppUtils.formatCurrency(txn.amount),
              style: GoogleFonts.poppins(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppColors.accent)),
        ]),
        const SizedBox(height: 10),

        // Deposit details
        if (isDeposit) ...[
          if (txn.paymentAccountName != null)
            _detailRow(Icons.account_balance_wallet_outlined,
                'Paid via: ${txn.paymentAccountName!}'),
          const SizedBox(height: 6),
          if (txn.depositScreenshotPath != null)
            GestureDetector(
              onTap: () => _viewScreenshot(
                  context, txn.depositScreenshotPath!, 'Payment Screenshot'),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.blue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                      color: AppColors.blue.withValues(alpha: 0.3)),
                ),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  const Icon(Icons.image_outlined,
                      size: 14, color: AppColors.blue),
                  const SizedBox(width: 6),
                  Text('View Payment Screenshot',
                      style: GoogleFonts.poppins(
                          fontSize: 11,
                          color: AppColors.blue,
                          fontWeight: FontWeight.w600)),
                ]),
              ),
            )
          else
            _detailRow(
                Icons.image_not_supported_outlined, 'No screenshot uploaded'),
        ] else ...[
          // Withdrawal details
          if (txn.withdrawalPaymentDetails != null)
            _detailRow(Icons.send_outlined,
                'Pay to: ${txn.withdrawalPaymentDetails!}'),
          if (txn.notes.isNotEmpty) ...[
            const SizedBox(height: 4),
            _detailRow(Icons.notes_outlined, txn.notes),
          ],
        ],

        const SizedBox(height: 10),

        // Action buttons
        Row(children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () => _showRejectDialog(context, wallet),
              icon: const Icon(Icons.close, size: 16),
              label: const Text('REJECT'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.red,
                side: const BorderSide(color: AppColors.red),
                padding: const EdgeInsets.symmetric(vertical: 8),
                textStyle:
                    GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w600),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () => isDeposit
                  ? _approveDeposit(context, wallet)
                  : _approveWithdrawalDialog(context, wallet),
              icon: const Icon(Icons.check, size: 16),
              label: Text(isDeposit ? 'APPROVE' : 'APPROVE & PAY'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.green,
                foregroundColor: AppColors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 8),
                textStyle:
                    GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ]),
      ]),
    );
  }

  Widget _detailRow(IconData icon, String text) => Padding(
        padding: const EdgeInsets.only(bottom: 2),
        child: Row(children: [
          Icon(icon, size: 13, color: AppColors.textMuted),
          const SizedBox(width: 6),
          Expanded(
            child: Text(text,
                style: GoogleFonts.poppins(
                    fontSize: 11, color: AppColors.textSecondary),
                maxLines: 2,
                overflow: TextOverflow.ellipsis),
          ),
        ]),
      );

  void _approveDeposit(BuildContext context, WalletProvider wallet) {
    wallet.approveDeposit(txn.id);
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      content: Text('Deposit approved & wallet credited'),
      backgroundColor: AppColors.green,
    ));
  }

  void _approveWithdrawalDialog(BuildContext context, WalletProvider wallet) {
    showDialog(
      context: context,
      builder: (_) =>
          _WithdrawalApprovalDialog(txnId: txn.id, wallet: wallet),
    );
  }

  void _showRejectDialog(BuildContext context, WalletProvider wallet) {
    final ctrl = TextEditingController();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.card,
        title: Text('Reject Request',
            style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600, color: AppColors.white)),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          Text('Optionally provide a reason:',
              style: GoogleFonts.poppins(
                  fontSize: 13, color: AppColors.textSecondary)),
          const SizedBox(height: 10),
          TextFormField(
            controller: ctrl,
            style: GoogleFonts.poppins(color: AppColors.white, fontSize: 13),
            decoration:
                const InputDecoration(hintText: 'Reason (optional)', isDense: true),
          ),
        ]),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel',
                style: GoogleFonts.poppins(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.red, foregroundColor: Colors.white),
            onPressed: () {
              final messenger = ScaffoldMessenger.of(context);
              wallet.rejectTransaction(txn.id,
                  reason: ctrl.text.trim().isEmpty ? null : ctrl.text.trim());
              Navigator.pop(context);
              messenger.showSnackBar(
                  const SnackBar(content: Text('Request rejected')));
            },
            child: Text('Reject',
                style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  void _viewScreenshot(BuildContext context, String path, String title) {
    final screenH = MediaQuery.of(context).size.height;
    final screenW = MediaQuery.of(context).size.width;
    showDialog(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: AppColors.background,
        insetPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 40),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          // Header
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(children: [
              Expanded(
                  child: Text(title,
                      style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w600,
                          color: AppColors.white,
                          fontSize: 14))),
              IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close,
                      color: AppColors.textSecondary)),
            ]),
          ),
          // Image in a fixed-height box so it always renders
          SizedBox(
            width: screenW - 32,
            height: screenH * 0.55,
            child: ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(bottom: Radius.circular(12)),
              child: _resolveImage(path),
            ),
          ),
        ]),
      ),
    );
  }

  Widget _resolveImage(String path) {
    if (path.startsWith('dummy:') || path.startsWith('assets/')) {
      final asset =
          path.startsWith('assets/') ? path : 'assets/images/sample_Transaction.png';
      return Image.asset(asset, fit: BoxFit.cover);
    }
    if (path.startsWith('http://') || path.startsWith('https://')) {
      return Image.network(path, fit: BoxFit.cover);
    }
    if (!kIsWeb && File(path).existsSync()) {
      return Image.file(File(path), fit: BoxFit.cover);
    }
    return Image.asset('assets/images/sample_Transaction.png',
        fit: BoxFit.cover);
  }
}

// ─────────────────────────────────────────────────────────────
// Withdrawal approval dialog – upload payment proof
// ─────────────────────────────────────────────────────────────
class _WithdrawalApprovalDialog extends StatefulWidget {
  final String txnId;
  final WalletProvider wallet;
  const _WithdrawalApprovalDialog(
      {required this.txnId, required this.wallet});

  @override
  State<_WithdrawalApprovalDialog> createState() =>
      _WithdrawalApprovalDialogState();
}

class _WithdrawalApprovalDialogState
    extends State<_WithdrawalApprovalDialog> {
  // Pre-filled with sample receipt so the dialog is never blank
  String _screenshotPath = 'assets/images/sample_Transaction.png';

  Future<void> _pick() async {
    final file =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (file != null) setState(() => _screenshotPath = file.path);
  }

  Widget _buildPreview() {
    if (_screenshotPath.startsWith('assets/')) {
      return Image.asset(_screenshotPath,
          width: double.infinity, height: double.infinity, fit: BoxFit.cover);
    }
    if (!kIsWeb && File(_screenshotPath).existsSync()) {
      return Image.file(File(_screenshotPath),
          width: double.infinity, height: double.infinity, fit: BoxFit.cover);
    }
    return Image.asset('assets/images/sample_Transaction.png',
        width: double.infinity, height: double.infinity, fit: BoxFit.cover);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.card,
      title: Text('Approve & Pay',
          style: GoogleFonts.poppins(
              fontWeight: FontWeight.w600, color: AppColors.white)),
      content: SizedBox(
        width: double.maxFinite,
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Text(
            'Payment receipt to share with user as confirmation:',
            style: GoogleFonts.poppins(
                fontSize: 12, color: AppColors.textSecondary, height: 1.5),
          ),
          const SizedBox(height: 10),
          GestureDetector(
            onTap: _pick,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Stack(
                alignment: Alignment.bottomRight,
                children: [
                  SizedBox(
                    height: 200,
                    width: double.maxFinite,
                    child: _buildPreview(),
                  ),
                  Container(
                    margin: const EdgeInsets.all(6),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.65),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(mainAxisSize: MainAxisSize.min, children: [
                      const Icon(Icons.edit_outlined,
                          size: 11, color: AppColors.accent),
                      const SizedBox(width: 4),
                      Text('Tap to change',
                          style: GoogleFonts.poppins(
                              fontSize: 9, color: AppColors.accent)),
                    ]),
                  ),
                ],
              ),
            ),
          ),
        ]),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Cancel',
              style: GoogleFonts.poppins(color: AppColors.textSecondary)),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.green,
              foregroundColor: Colors.white),
          onPressed: () {
            // Capture messenger BEFORE pop so context is still valid
            final messenger = ScaffoldMessenger.of(context);
            widget.wallet.approveWithdrawal(widget.txnId,
                screenshotPath: _screenshotPath);
            Navigator.pop(context);
            messenger.showSnackBar(const SnackBar(
              content: Text('Withdrawal approved & wallet debited'),
              backgroundColor: AppColors.green,
            ));
          },
          child: Text('Approve',
              style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Tab 2 – Manual Credit / Debit
// ─────────────────────────────────────────────────────────────
class _CreditDebitTab extends StatefulWidget {
  const _CreditDebitTab();

  @override
  State<_CreditDebitTab> createState() => _CreditDebitTabState();
}

class _CreditDebitTabState extends State<_CreditDebitTab> {
  String? _selectedUserId;
  final _amountCtrl = TextEditingController();
  final _noteCtrl = TextEditingController();
  bool _isCredit = true;

  @override
  void dispose() {
    _amountCtrl.dispose();
    _noteCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final users = mockUsers.where((u) => u.role == 'user').toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.cardBorder),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          _label('Select User'),
          DropdownButtonFormField<String>(
            value: _selectedUserId,
            dropdownColor: AppColors.card,
            style: GoogleFonts.poppins(color: AppColors.white, fontSize: 14),
            decoration: const InputDecoration(
              prefixIcon: Icon(Icons.person_outline),
              isDense: true,
              contentPadding:
                  EdgeInsets.symmetric(vertical: 12, horizontal: 12),
            ),
            items: users
                .map((u) =>
                    DropdownMenuItem(value: u.id, child: Text(u.name)))
                .toList(),
            onChanged: (v) => setState(() => _selectedUserId = v),
          ),
          const SizedBox(height: 16),

          _label('Type'),
          Row(children: [
            _typeChip('Credit', true),
            const SizedBox(width: 10),
            _typeChip('Debit', false),
          ]),
          const SizedBox(height: 16),

          _label('Amount'),
          TextFormField(
            controller: _amountCtrl,
            keyboardType: TextInputType.number,
            style: GoogleFonts.poppins(color: AppColors.white),
            decoration: const InputDecoration(
              prefixIcon: Icon(Icons.currency_rupee),
              isDense: true,
              contentPadding:
                  EdgeInsets.symmetric(vertical: 12, horizontal: 12),
            ),
          ),
          const SizedBox(height: 16),

          _label('Note (optional)'),
          TextFormField(
            controller: _noteCtrl,
            style: GoogleFonts.poppins(color: AppColors.white),
            decoration: const InputDecoration(
              prefixIcon: Icon(Icons.note_outlined),
              isDense: true,
              contentPadding:
                  EdgeInsets.symmetric(vertical: 12, horizontal: 12),
            ),
          ),
          const SizedBox(height: 20),

          Consumer<WalletProvider>(builder: (context, wallet, _) {
            return SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton.icon(
                onPressed: () {
                  if (_selectedUserId == null || _amountCtrl.text.isEmpty) return;
                  final amount = double.tryParse(_amountCtrl.text) ?? 0;
                  if (amount <= 0) return;
                  if (_isCredit) {
                    wallet.manualCredit(
                        _selectedUserId!, amount, _noteCtrl.text.trim());
                  } else {
                    wallet.manualDebit(
                        _selectedUserId!, amount, _noteCtrl.text.trim());
                  }
                  final user = mockUsers
                      .firstWhere((u) => u.id == _selectedUserId);
                  setState(() {
                    _amountCtrl.clear();
                    _noteCtrl.clear();
                  });
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text(
                        '${_isCredit ? 'Credited' : 'Debited'} ${AppUtils.formatCurrency(amount)} to ${user.name}'),
                  ));
                },
                icon: Icon(
                    _isCredit
                        ? Icons.add_circle_outline
                        : Icons.remove_circle_outline,
                    size: 20),
                label: Text(
                    _isCredit ? 'CREDIT AMOUNT' : 'DEBIT AMOUNT',
                    style: GoogleFonts.poppins(
                        fontSize: 14, fontWeight: FontWeight.w600)),
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      _isCredit ? AppColors.green : AppColors.red,
                  foregroundColor: AppColors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
              ),
            );
          }),
        ]),
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

  Widget _typeChip(String label, bool isCredit) {
    final sel = _isCredit == isCredit;
    return GestureDetector(
      onTap: () => setState(() => _isCredit = isCredit),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: BoxDecoration(
          color: sel
              ? (isCredit ? AppColors.green : AppColors.red)
                  .withValues(alpha: 0.15)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
              color: sel
                  ? (isCredit ? AppColors.green : AppColors.red)
                  : AppColors.cardBorder),
        ),
        child: Text(label,
            style: GoogleFonts.poppins(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: sel
                  ? (isCredit ? AppColors.green : AppColors.red)
                  : AppColors.textSecondary,
            )),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Tab 3 – Payment Accounts summary
// ─────────────────────────────────────────────────────────────
class _PaymentAccountsTab extends StatelessWidget {
  const _PaymentAccountsTab();

  @override
  Widget build(BuildContext context) {
    return Consumer<PaymentAccountProvider>(builder: (context, provider, _) {
      final accounts = provider.accounts;
      return SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(children: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () =>
                  context.push('/admin/payment-accounts'),
              icon: const Icon(Icons.settings_outlined, size: 18),
              label: Text('Manage Payment Accounts',
                  style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accent,
                foregroundColor: AppColors.background,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
          const SizedBox(height: 16),
          if (accounts.isEmpty)
            Padding(
              padding: const EdgeInsets.all(24),
              child: Text('No accounts configured',
                  style: GoogleFonts.poppins(
                      color: AppColors.textSecondary, fontSize: 13)),
            )
          else
            ...accounts.map((a) => Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.card,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: a.isActive
                          ? AppColors.accent.withValues(alpha: 0.25)
                          : AppColors.cardBorder,
                    ),
                  ),
                  child: Row(children: [
                    Expanded(
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                          Text(a.name,
                              style: GoogleFonts.poppins(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.white)),
                          Text(a.type.label,
                              style: GoogleFonts.poppins(
                                  fontSize: 11,
                                  color: AppColors.textSecondary)),
                        ])),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: a.isActive
                            ? AppColors.green.withValues(alpha: 0.12)
                            : AppColors.red.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(a.isActive ? 'ACTIVE' : 'OFF',
                          style: GoogleFonts.poppins(
                              fontSize: 9,
                              fontWeight: FontWeight.w700,
                              color: a.isActive
                                  ? AppColors.green
                                  : AppColors.red)),
                    ),
                  ]),
                )),
        ]),
      );
    });
  }
}
