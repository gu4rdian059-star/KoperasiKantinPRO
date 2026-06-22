import 'dart:math';
import 'package:flutter/material.dart';
import '../../state/app_state_provider.dart';
import '../../models/student.dart';
import 'siswa_topup_payment_screen.dart';

class SiswaTopupScreen extends StatefulWidget {
  const SiswaTopupScreen({super.key});

  @override
  State<SiswaTopupScreen> createState() => _SiswaTopupScreenState();
}

class _SiswaTopupScreenState extends State<SiswaTopupScreen> {
  final _amountController = TextEditingController();
  String _selectedMethod = 'BCA VA'; // default Method
  String? _errorMessage;

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  void _processTopUpRequest() {
    final double? amount = double.tryParse(_amountController.text);
    if (amount == null || amount < 10000.0) {
      setState(() {
        _errorMessage = 'Minimal top up adalah Rp 10.000';
      });
      return;
    }

    final appState = AppStateProvider.of(context);
    final Student student = appState.currentUser as Student;

    if (student.balance + amount > 500000.0) {
      setState(() {
        _errorMessage = 'Akumulasi saldo tidak boleh melebihi Rp 500.000';
      });
      return;
    }

    setState(() {
      _errorMessage = null;
    });

    // Navigate to simulated payment screen
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => SiswaTopupPaymentScreen(
          studentNis: student.nis,
          amount: amount,
          method: _selectedMethod,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      appBar: AppBar(
        title: const Text('Top Up Saldo E-Wallet'),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: SizedBox(
            width: 500,
            child: Card(
              elevation: 4,
              color: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Header title
                    const Row(
                      children: [
                        Icon(Icons.add_circle, color: Color(0xFF10B981), size: 28),
                        SizedBox(width: 12),
                        Text(
                          'Isi Saldo SekolahPRO',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Color(0xFF0F172A)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Masukkan nominal top up (Min Rp 10.000) dan pilih metode pembayaran di bawah',
                      style: TextStyle(fontSize: 13, color: Color(0xFF64748B)),
                    ),
                    const SizedBox(height: 24),

                    // Custom Error Box
                    if (_errorMessage != null) ...[
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        margin: const EdgeInsets.only(bottom: 20),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFEF2F2),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: const Color(0xFFFCA5A5)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.error_outline, color: Color(0xFFEF4444), size: 16),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                _errorMessage!,
                                style: const TextStyle(color: Color(0xFFB91C1C), fontSize: 12, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],

                    // Amount input textfield
                    const Text('Nominal Isi Saldo (Rp)', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _amountController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        hintText: 'Contoh: 50000',
                        prefixIcon: const Icon(Icons.account_balance_wallet, size: 20),
                        contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Quick select nominal boxes
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildQuickAmountButton(10000),
                        _buildQuickAmountButton(20000),
                        _buildQuickAmountButton(50000),
                        _buildQuickAmountButton(100000),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Select Payment Method Dropdown
                    const Text('Pilih Metode Pembayaran', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          isExpanded: true,
                          value: _selectedMethod,
                          items: const [
                            DropdownMenuItem(value: 'BCA VA', child: Text('Transfer Bank BCA (Virtual Account) — Gratis')),
                            DropdownMenuItem(value: 'BRI VA', child: Text('Transfer Bank BRI (Virtual Account) — Gratis')),
                            DropdownMenuItem(value: 'Mandiri VA', child: Text('Transfer Bank Mandiri (Virtual Account) — Gratis')),
                            DropdownMenuItem(value: 'BNI VA', child: Text('Transfer Bank BNI (Virtual Account) — Gratis')),
                            DropdownMenuItem(value: 'QRIS', child: Text('QRIS Instant (Gopay/OVO/Dana/LinkAja) — Gratis')),
                            DropdownMenuItem(value: 'Alfamart', child: Text('Minimarket Alfamart — Admin Rp 2.500')),
                            DropdownMenuItem(value: 'Indomaret', child: Text('Minimarket Indomaret — Admin Rp 2.500')),
                          ],
                          onChanged: (val) {
                            if (val != null) setState(() => _selectedMethod = val);
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Proceed button
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: _processTopUpRequest,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF10B981),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: const Text('Lanjutkan Pembayaran', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildQuickAmountButton(int value) {
    return InkWell(
      onTap: () {
        setState(() {
          _amountController.text = value.toString();
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Text(
          '${value ~/ 1000}k',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF475569)),
        ),
      ),
    );
  }
}
