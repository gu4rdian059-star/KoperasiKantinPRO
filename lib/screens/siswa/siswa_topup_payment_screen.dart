import 'dart:math';
import 'package:flutter/material.dart';
import '../../state/app_state_provider.dart';
import 'siswa_token_screen.dart'; // import for qr vector drawing

class SiswaTopupPaymentScreen extends StatefulWidget {
  final String studentNis;
  final double amount;
  final String method;

  const SiswaTopupPaymentScreen({
    super.key,
    required this.studentNis,
    required this.amount,
    required this.method,
  });

  @override
  State<SiswaTopupPaymentScreen> createState() => _SiswaTopupPaymentScreenState();
}

class _SiswaTopupPaymentScreenState extends State<SiswaTopupPaymentScreen> {
  bool _isSuccess = false;
  late final String _paymentCode;
  late final double _adminFee;
  late final double _totalPayment;

  @override
  void initState() {
    super.initState();
    // Configure fee
    _adminFee = (widget.method == 'Alfamart' || widget.method == 'Indomaret') ? 2500.0 : 0.0;
    _totalPayment = widget.amount + _adminFee;

    // Generate simulated payment code / VA
    if (widget.method.contains('VA')) {
      _paymentCode = "8001 ${Random().nextInt(9000) + 1000} ${Random().nextInt(9000) + 1000} ${Random().nextInt(9000) + 1000}";
    } else if (widget.method == 'QRIS') {
      _paymentCode = "SekolahPRO QRIS Gateway";
    } else {
      _paymentCode = "PAY-${Random().nextInt(900000) + 100000}";
    }
  }

  void _confirmSimulatedPayment() {
    final appState = AppStateProvider.of(context);
    
    try {
      // Process credit to child
      appState.topUpWallet(
        studentNis: widget.studentNis,
        amount: widget.amount,
        method: widget.method,
      );

      setState(() {
        _isSuccess = true;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Pembayaran gagal: $e'), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isMobile = screenWidth < 768;

    Widget mainContent;

    if (_isSuccess) {
      // Payment Done screen as in Done Top Up Siswa / Unduh Resi TF Siswa
      mainContent = Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: const BoxDecoration(color: Color(0xFFE8F5E9), shape: BoxShape.circle),
            child: const Icon(Icons.check_circle, color: Color(0xFF4CAF50), size: 52),
          ),
          const SizedBox(height: 16),
          const Text(
            'Top Up Berhasil!',
            textAlign: TextAlign.center,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22, color: Color(0xFF0F172A)),
          ),
          const SizedBox(height: 8),
          const Text(
            'Saldo E-Wallet Anda telah berhasil ditambahkan.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13, color: Color(0xFF64748B)),
          ),
          const SizedBox(height: 24),
          
          // Receipt breakdown
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Column(
              children: [
                _buildRow('Status', 'SUKSES', color: const Color(0xFF10B981)),
                const SizedBox(height: 8),
                _buildRow('Nominal Saldo', 'Rp ${widget.amount.toInt()}'),
                const SizedBox(height: 8),
                _buildRow('Metode', widget.method),
                const SizedBox(height: 8),
                _buildRow('Waktu', '${DateTime.now().hour}:${DateTime.now().minute.toString().padLeft(2, '0')}, ${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}'),
                const Divider(height: 24, color: Color(0xFFE2E8F0)),
                _buildRow('Total Terbayar', 'Rp ${_totalPayment.toInt()}', isBold: true),
              ],
            ),
          ),
          
          const SizedBox(height: 28),

          // Action button
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1A56DB),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Selesai & Tutup', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      );
    } else {
      // Pending Payment Details Screen
      mainContent = Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('TOTAL PEMBAYARAN', style: TextStyle(fontSize: 11, color: Color(0xFF64748B), fontWeight: FontWeight.bold)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(color: const Color(0xFFFFFBEB), borderRadius: BorderRadius.circular(8)),
                child: const Text('Menunggu Pembayaran', style: TextStyle(color: Color(0xFFB45309), fontSize: 10, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Rp ${_totalPayment.toInt().toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}',
                style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF1A56DB)),
              ),
              const Text('Rincian', style: TextStyle(color: Color(0xFF1A56DB), fontSize: 12, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 20),
          const Divider(height: 1),
          const SizedBox(height: 20),

          // Instruction specs depending on method
          if (widget.method == 'QRIS') ...[
            const Text('PINDAI KODE QRIS UNTUK BAYAR', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF64748B))),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade200, width: 2),
                borderRadius: BorderRadius.circular(16),
              ),
              child: CustomPaint(
                size: const Size(140, 140),
                painter: _QrPainterPayment(),
              ),
            ),
            const SizedBox(height: 10),
            const Text('QRIS valid selama 10 menit', style: TextStyle(fontSize: 11, color: Colors.grey)),
          ] else if (widget.method.contains('VA')) ...[
            const Text('SALIN NOMOR VIRTUAL ACCOUNT', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF64748B))),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: const Color(0xFFF8FAFC), borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFE2E8F0))),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _paymentCode,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1E293B), letterSpacing: 1.0),
                  ),
                  const Icon(Icons.copy, size: 18, color: Color(0xFF1A56DB)),
                ],
              ),
            ),
            const SizedBox(height: 12),
            const Text('Petunjuk Transfer:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
            const SizedBox(height: 4),
            const Text(
              '1. Buka Mobile Banking atau pergi ke ATM Anda\n'
              '2. Masuk ke menu Transfer > Virtual Account\n'
              '3. Masukkan kode VA di atas dan konfirmasi total bayar\n'
              '4. Transaksi akan terverifikasi secara otomatis',
              style: TextStyle(fontSize: 11, color: Color(0xFF64748B), height: 1.5),
            ),
          ] else ...[
            // Minimarket Alfamart / Indomaret
            const Text('TUNJUKKAN KODE PEMBAYARAN KASIR', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF64748B))),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: const Color(0xFFF8FAFC), borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFE2E8F0))),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _paymentCode,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1E293B), letterSpacing: 2.0),
                  ),
                  const Icon(Icons.copy, size: 18, color: Color(0xFF1A56DB)),
                ],
              ),
            ),
            const SizedBox(height: 12),
            const Text('Petunjuk Pembayaran:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
            const SizedBox(height: 4),
            Text(
              '1. Pergi ke gerai ${widget.method} terdekat\n'
              '2. Katakan ke kasir untuk bayar SekolahPRO / Merchant Payment\n'
              '3. Tunjukkan kode pembayaran di atas ke kasir\n'
              '4. Lakukan pembayaran sebesar Rp ${_totalPayment.toInt()} (sudah termasuk biaya admin)',
              style: const TextStyle(fontSize: 11, color: Color(0xFF64748B), height: 1.5),
            ),
          ],

          const SizedBox(height: 32),

          // Simulation Button: Complete transaction simulation
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: _confirmSimulatedPayment,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF10B981),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Simulasi Pembayaran Berhasil', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ),
          const SizedBox(height: 12),
          // Cancel button
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batalkan Transaksi', style: TextStyle(color: Color(0xFFEF4444))),
          ),
        ],
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      appBar: AppBar(
        title: Text(_isSuccess ? 'Transaksi Sukses' : 'Menunggu Pembayaran'),
        leading: _isSuccess
            ? null
            : IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => Navigator.pop(context),
              ),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: isMobile
              ? Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: mainContent,
                )
              : SizedBox(
                  width: 480,
                  child: Card(
                    elevation: 4,
                    color: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                    child: Padding(
                      padding: const EdgeInsets.all(32.0),
                      child: mainContent,
                    ),
                  ),
                ),
        ),
      ),
    );
  }

  Widget _buildRow(String label, String val, {bool isBold = false, Color? color}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, color: Color(0xFF64748B))),
        Text(
          val,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
            color: color ?? (isBold ? const Color(0xFF1A56DB) : const Color(0xFF1E293B)),
          ),
        ),
      ],
    );
  }
}

// Draw payment QRIS QR block
class _QrPainterPayment extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = const Color(0xFF1E293B);
    
    // Draw corner markers
    canvas.drawRect(const Rect.fromLTWH(0, 0, 35, 35), paint);
    canvas.drawRect(const Rect.fromLTWH(7, 7, 21, 21), Paint()..color = Colors.white);
    canvas.drawRect(const Rect.fromLTWH(11, 11, 13, 13), paint);

    canvas.drawRect(Rect.fromLTWH(size.width - 35, 0, 35, 35), paint);
    canvas.drawRect(Rect.fromLTWH(size.width - 28, 7, 21, 21), Paint()..color = Colors.white);
    canvas.drawRect(Rect.fromLTWH(size.width - 24, 11, 13, 13), paint);

    canvas.drawRect(Rect.fromLTWH(0, size.height - 35, 35, 35), paint);
    canvas.drawRect(Rect.fromLTWH(7, size.height - 28, 21, 21), Paint()..color = Colors.white);
    canvas.drawRect(Rect.fromLTWH(11, size.height - 24, 13, 13), paint);

    // Draw some random blocks inside
    canvas.drawRect(const Rect.fromLTWH(45, 10, 10, 10), paint);
    canvas.drawRect(const Rect.fromLTWH(65, 5, 15, 10), paint);
    canvas.drawRect(const Rect.fromLTWH(45, 25, 20, 10), paint);
    
    canvas.drawRect(Rect.fromLTWH(45, size.height - 35, 10, 20), paint);
    canvas.drawRect(Rect.fromLTWH(65, size.height - 20, 25, 10), paint);
    
    canvas.drawRect(Rect.fromLTWH(size.width - 35, 45, 20, 10), paint);
    canvas.drawRect(Rect.fromLTWH(size.width - 25, 65, 10, 25), paint);

    // Center grid patterns
    canvas.drawRect(const Rect.fromLTWH(50, 50, 15, 15), paint);
    canvas.drawRect(const Rect.fromLTWH(75, 50, 10, 10), paint);
    canvas.drawRect(const Rect.fromLTWH(50, 75, 20, 15), paint);
    canvas.drawRect(const Rect.fromLTWH(80, 75, 10, 10), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
