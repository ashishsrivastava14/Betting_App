import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../providers/auth_provider.dart';
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

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  void _proceedToWhatsApp() async {
    if (_amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter an amount')),
      );
      return;
    }

    final auth = context.read<AuthProvider>();
    final userId = auth.currentUser?.id ?? 'Unknown';
    final message = Uri.encodeComponent(
      'Hi Admin, I want to deposit ₹${_amount.toInt()}. My User ID is $userId.',
    );

    final url = Uri.parse('https://wa.me/919999999999?text=$message');

    try {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open WhatsApp')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Deposit'),
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
            const SizedBox(height: 16),

            // Amount input
            Text(
              'Enter Deposit Amount',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.white,
              ),
            ),
            const SizedBox(height: 16),

            TextFormField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              style: GoogleFonts.poppins(
                  color: AppColors.white, fontSize: 24, fontWeight: FontWeight.w700),
              onChanged: (v) {
                setState(() => _amount = double.tryParse(v) ?? 0);
              },
              decoration: InputDecoration(
                hintText: '₹ 0',
                prefixIcon: const Icon(Icons.currency_rupee, size: 28),
              ),
            ),

            const SizedBox(height: 16),

            // Quick chips
            Wrap(
              spacing: 10,
              runSpacing: 8,
              children: _quickAmounts.map((amt) {
                return ActionChip(
                  label: Text('₹${AppUtils.formatCurrency(amt.toDouble()).replaceAll('₹', '')}'),
                  backgroundColor: AppColors.cardLight,
                  labelStyle: GoogleFonts.poppins(
                    color: AppColors.accent,
                    fontWeight: FontWeight.w600,
                  ),
                  side: BorderSide(
                      color: AppColors.accent.withValues(alpha: 0.3)),
                  onPressed: () {
                    setState(() {
                      _amount = amt.toDouble();
                      _amountController.text = amt.toString();
                    });
                  },
                );
              }).toList(),
            ),

            const SizedBox(height: 32),

            // Proceed button
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                onPressed: _proceedToWhatsApp,
                icon: const Icon(Icons.chat, size: 20),
                label: Text(
                  'Proceed to WhatsApp',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF25D366),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Note
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.orange.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                    color: AppColors.orange.withValues(alpha: 0.3)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.info_outline,
                      color: AppColors.orange, size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Admin will verify and credit within 30 minutes. Your deposit will reflect in your wallet once approved.',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: AppColors.orange,
                        height: 1.5,
                      ),
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
}
