import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../mock_data/mock_users.dart';
import '../../mock_data/mock_transactions.dart';
import '../../models/transaction_model.dart';
import '../../theme/app_theme.dart';
import '../../utils/app_utils.dart';


class AdminWalletScreen extends StatefulWidget {
  const AdminWalletScreen({super.key});

  @override
  State<AdminWalletScreen> createState() => _AdminWalletScreenState();
}

class _AdminWalletScreenState extends State<AdminWalletScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
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
                  const Icon(Icons.account_balance_wallet_rounded, color: AppColors.accent, size: 22),
                  const SizedBox(width: 10),
                  Text('Wallet Management', style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.white)),
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
                labelStyle: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600),
                unselectedLabelStyle: GoogleFonts.poppins(fontSize: 12),
                dividerHeight: 0,
                padding: const EdgeInsets.all(3),
                tabs: const [
                  Tab(text: 'PENDING REQUESTS'),
                  Tab(text: 'CREDIT / DEBIT'),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _PendingRequestsTab(),
                  _CreditDebitTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PendingRequestsTab extends StatefulWidget {
  @override
  State<_PendingRequestsTab> createState() => _PendingRequestsTabState();
}

class _PendingRequestsTabState extends State<_PendingRequestsTab> {
  @override
  Widget build(BuildContext context) {
    final pending = mockTransactions.where((t) => t.status == 'pending').toList();

    if (pending.isEmpty) {
      return Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Icon(Icons.check_circle_outline, size: 56, color: AppColors.green.withValues(alpha: 0.4)),
          const SizedBox(height: 12),
          Text('No pending requests', style: GoogleFonts.poppins(fontSize: 14, color: AppColors.textSecondary)),
        ]),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: pending.length,
      itemBuilder: (context, index) {
        final txn = pending[index];
        final user = mockUsers.firstWhere((u) => u.id == txn.userId);
        final isDeposit = txn.type == 'deposit';

        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.cardBorder),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: (isDeposit ? AppColors.green : AppColors.red).withValues(alpha: 0.12),
                  ),
                  child: Icon(
                    isDeposit ? Icons.arrow_downward_rounded : Icons.arrow_upward_rounded,
                    color: isDeposit ? AppColors.green : AppColors.red,
                    size: 18,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(user.name, style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.white)),
                    Text('${txn.type.toUpperCase()} Request', style: GoogleFonts.poppins(fontSize: 11, color: AppColors.textSecondary)),
                  ]),
                ),
                Text(AppUtils.formatCurrency(txn.amount),
                    style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.accent)),
              ]),
              const SizedBox(height: 10),
              Row(children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      setState(() { txn.status = 'rejected'; });
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Request rejected')));
                    },
                    icon: const Icon(Icons.close, size: 16),
                    label: const Text('REJECT'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.red,
                      side: const BorderSide(color: AppColors.red),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      textStyle: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      setState(() {
                        txn.status = 'approved';
                        if (isDeposit) {
                          user.walletBalance += txn.amount;
                        } else {
                          user.walletBalance -= txn.amount;
                        }
                      });
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Request approved')));
                    },
                    icon: const Icon(Icons.check, size: 16),
                    label: const Text('APPROVE'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.green,
                      foregroundColor: AppColors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      textStyle: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              ]),
            ],
          ),
        );
      },
    );
  }
}

class _CreditDebitTab extends StatefulWidget {
  @override
  State<_CreditDebitTab> createState() => _CreditDebitTabState();
}

class _CreditDebitTabState extends State<_CreditDebitTab> {
  String? _selectedUserId;
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();
  bool _isCredit = true;

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _label('Select User'),
            DropdownButtonFormField<String>(
              initialValue: _selectedUserId,
              dropdownColor: AppColors.card,
              style: GoogleFonts.poppins(color: AppColors.white, fontSize: 14),
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.person_outline),
                isDense: true,
                contentPadding: EdgeInsets.symmetric(vertical: 12, horizontal: 12),
              ),
              items: users.map((u) => DropdownMenuItem(value: u.id, child: Text(u.name))).toList(),
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
              controller: _amountController,
              keyboardType: TextInputType.number,
              style: GoogleFonts.poppins(color: AppColors.white),
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.currency_rupee),
                isDense: true,
                contentPadding: EdgeInsets.symmetric(vertical: 12, horizontal: 12),
              ),
            ),
            const SizedBox(height: 16),

            _label('Note (optional)'),
            TextFormField(
              controller: _noteController,
              style: GoogleFonts.poppins(color: AppColors.white),
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.note_outlined),
                isDense: true,
                contentPadding: EdgeInsets.symmetric(vertical: 12, horizontal: 12),
              ),
            ),
            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton.icon(
                onPressed: () {
                  if (_selectedUserId == null || _amountController.text.isEmpty) return;
                  final amount = double.tryParse(_amountController.text) ?? 0;
                  if (amount <= 0) return;
                  final user = mockUsers.firstWhere((u) => u.id == _selectedUserId);
                  setState(() {
                    if (_isCredit) {
                      user.walletBalance += amount;
                    } else {
                      user.walletBalance -= amount;
                    }
                    mockTransactions.add(TransactionModel(
                      id: 'txn_${DateTime.now().millisecondsSinceEpoch}',
                      userId: _selectedUserId!,
                      type: _isCredit ? 'deposit' : 'withdrawal',
                      amount: amount,
                      status: 'approved',
                      createdAt: DateTime.now(),
                    ));
                    _amountController.clear();
                    _noteController.clear();
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('${_isCredit ? 'Credited' : 'Debited'} ${AppUtils.formatCurrency(amount)} to ${user.name}')),
                  );
                },
                icon: Icon(_isCredit ? Icons.add_circle_outline : Icons.remove_circle_outline, size: 20),
                label: Text(_isCredit ? 'CREDIT AMOUNT' : 'DEBIT AMOUNT',
                    style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _isCredit ? AppColors.green : AppColors.red,
                  foregroundColor: AppColors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _label(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(text, style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w500, color: AppColors.textSecondary)),
    );
  }

  Widget _typeChip(String label, bool isCredit) {
    final selected = _isCredit == isCredit;
    return GestureDetector(
      onTap: () => setState(() => _isCredit = isCredit),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? (isCredit ? AppColors.green : AppColors.red).withValues(alpha: 0.15) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: selected ? (isCredit ? AppColors.green : AppColors.red) : AppColors.cardBorder),
        ),
        child: Text(label,
            style: GoogleFonts.poppins(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: selected ? (isCredit ? AppColors.green : AppColors.red) : AppColors.textSecondary,
            )),
      ),
    );
  }
}