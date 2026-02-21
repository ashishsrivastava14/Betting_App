import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../mock_data/mock_users.dart';
import '../../providers/wallet_provider.dart';
import '../../theme/app_theme.dart';
import '../../utils/app_utils.dart';

class AdminWalletScreen extends StatefulWidget {
  const AdminWalletScreen({super.key});

  @override
  State<AdminWalletScreen> createState() => _AdminWalletScreenState();
}

class _AdminWalletScreenState extends State<AdminWalletScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _creditAmountController = TextEditingController();
  final _creditNotesController = TextEditingController();
  String? _selectedUserId;
  bool _isCredit = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _creditAmountController.dispose();
    _creditNotesController.dispose();
    super.dispose();
  }

  void _manualTransaction() {
    if (_selectedUserId == null) {
      _showSnackbar('Please select a user');
      return;
    }
    final amount = double.tryParse(_creditAmountController.text) ?? 0;
    if (amount <= 0) {
      _showSnackbar('Please enter a valid amount');
      return;
    }

    final walletProvider = context.read<WalletProvider>();
    final notes = _creditNotesController.text.trim().isEmpty
        ? 'Manual ${_isCredit ? "credit" : "debit"} by admin'
        : _creditNotesController.text.trim();

    if (_isCredit) {
      walletProvider.manualCredit(_selectedUserId!, amount, notes);
    } else {
      walletProvider.manualDebit(_selectedUserId!, amount, notes);
    }

    _showSnackbar(
        '${_isCredit ? "Credited" : "Debited"} ${AppUtils.formatCurrency(amount)} successfully');
    _creditAmountController.clear();
    _creditNotesController.clear();
    setState(() => _selectedUserId = null);
  }

  void _showSnackbar(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final walletProvider = context.watch<WalletProvider>();
    final pendingTxns = walletProvider.pendingTransactions;

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: Text(
                'Wallet Management',
                style: GoogleFonts.poppins(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: AppColors.white,
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Tabs
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.circular(12),
              ),
              child: TabBar(
                controller: _tabController,
                indicator: BoxDecoration(
                  color: AppColors.accent,
                  borderRadius: BorderRadius.circular(12),
                ),
                labelColor: AppColors.background,
                unselectedLabelColor: AppColors.white70,
                labelStyle: GoogleFonts.poppins(
                    fontSize: 13, fontWeight: FontWeight.w600),
                dividerColor: Colors.transparent,
                tabs: const [
                  Tab(text: 'Pending Requests'),
                  Tab(text: 'Manual Credit/Debit'),
                ],
              ),
            ),

            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  // Pending requests tab
                  _buildPendingTab(pendingTxns, walletProvider),
                  // Manual credit/debit tab
                  _buildManualTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPendingTab(List pendingTxns, WalletProvider walletProvider) {
    if (pendingTxns.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.check_circle,
                size: 64,
                color: AppColors.green.withValues(alpha: 0.3)),
            const SizedBox(height: 12),
            Text(
              'No pending requests',
              style: GoogleFonts.poppins(
                fontSize: 16,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      color: AppColors.accent,
      backgroundColor: AppColors.card,
      onRefresh: () async =>
          await Future.delayed(const Duration(seconds: 1)),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: pendingTxns.length,
        itemBuilder: (context, index) {
          final txn = pendingTxns[index];
          final user = mockUsers.firstWhere((u) => u.id == txn.userId);

          return Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.cardLight),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      txn.type == 'deposit'
                          ? Icons.arrow_downward
                          : Icons.arrow_upward,
                      color: txn.type == 'deposit'
                          ? AppColors.green
                          : AppColors.red,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '${txn.type.replaceAll("_", " ").toUpperCase()} — ${user.name}',
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.white,
                        ),
                      ),
                    ),
                    Text(
                      AppUtils.formatCurrency(txn.amount),
                      style: GoogleFonts.poppins(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppColors.accent,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  '${txn.notes} • ${AppUtils.formatDateShort(txn.createdAt)}',
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          walletProvider.approveTransaction(txn.id);
                          setState(() {});
                          _showSnackbar('Transaction approved');
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.green,
                          foregroundColor: Colors.white,
                          padding:
                              const EdgeInsets.symmetric(vertical: 10),
                        ),
                        child: Text('Approve',
                            style: GoogleFonts.poppins(
                                fontWeight: FontWeight.w600)),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          walletProvider.rejectTransaction(txn.id);
                          setState(() {});
                          _showSnackbar('Transaction rejected');
                        },
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: AppColors.red),
                          padding:
                              const EdgeInsets.symmetric(vertical: 10),
                        ),
                        child: Text('Reject',
                            style: GoogleFonts.poppins(
                              color: AppColors.red,
                              fontWeight: FontWeight.w600,
                            )),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildManualTab() {
    final regularUsers =
        mockUsers.where((u) => u.role == 'user').toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Select User',
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            initialValue: _selectedUserId,
            dropdownColor: AppColors.card,
            style: GoogleFonts.poppins(color: AppColors.white),
            decoration: const InputDecoration(
              prefixIcon: Icon(Icons.person),
              hintText: 'Choose a user',
            ),
            items: regularUsers.map((u) {
              return DropdownMenuItem(
                value: u.id,
                child: Text('${u.name} (${u.phone})'),
              );
            }).toList(),
            onChanged: (v) => setState(() => _selectedUserId = v),
          ),

          const SizedBox(height: 16),

          // Credit / Debit toggle
          Row(
            children: [
              _toggleChip('Credit', true, AppColors.green),
              const SizedBox(width: 10),
              _toggleChip('Debit', false, AppColors.red),
            ],
          ),

          const SizedBox(height: 16),

          Text(
            'Amount',
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: _creditAmountController,
            keyboardType: TextInputType.number,
            style: GoogleFonts.poppins(color: AppColors.white),
            decoration: const InputDecoration(
              hintText: '₹ Enter amount',
              prefixIcon: Icon(Icons.currency_rupee),
            ),
          ),

          const SizedBox(height: 16),

          Text(
            'Notes',
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: _creditNotesController,
            style: GoogleFonts.poppins(color: AppColors.white),
            decoration: const InputDecoration(
              hintText: 'Optional notes',
              prefixIcon: Icon(Icons.note),
            ),
          ),

          const SizedBox(height: 24),

          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: _manualTransaction,
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    _isCredit ? AppColors.green : AppColors.red,
                foregroundColor: Colors.white,
              ),
              child: Text(
                _isCredit ? 'CREDIT AMOUNT' : 'DEBIT AMOUNT',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _toggleChip(String label, bool isCredit, Color color) {
    final selected = _isCredit == isCredit;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _isCredit = isCredit),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color:
                selected ? color.withValues(alpha: 0.15) : AppColors.card,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: selected ? color : AppColors.cardLight,
              width: selected ? 2 : 1,
            ),
          ),
          child: Center(
            child: Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: selected ? color : AppColors.grey,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
