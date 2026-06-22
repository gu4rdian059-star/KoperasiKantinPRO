import 'dart:async';
import 'package:flutter/material.dart';
import '../../models/transaction.dart';

class SiswaTokenScreen extends StatefulWidget {
  final TransactionModel transaction;

  const SiswaTokenScreen({super.key, required this.transaction});

  @override
  State<SiswaTokenScreen> createState() => _SiswaTokenScreenState();
}

class _SiswaTokenScreenState extends State<SiswaTokenScreen> {
  Timer? _countdownTimer;
  int _secondsRemaining = 1800; // 30 minutes in seconds

  @override
  void initState() {
    super.initState();
    // Start 30 minutes countdown
    _secondsRemaining = widget.transaction.qrTokenExpiry != null
        ? widget.transaction.qrTokenExpiry!.difference(DateTime.now()).inSeconds
        : 1800;
    if (_secondsRemaining < 0) _secondsRemaining = 0;
    _startTimer();
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          if (_secondsRemaining > 0) {
            _secondsRemaining--;
          } else {
            _countdownTimer?.cancel();
          }
        });
      }
    });
  }

  String _formatTime() {
    final int minutes = _secondsRemaining ~/ 60;
    final int seconds = _secondsRemaining % 60;
    return "${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}";
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isMobile = screenWidth < 768;

    Widget receiptContent = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Success Tick
        Container(
          padding: const EdgeInsets.all(12),
          decoration: const BoxDecoration(color: Color(0xFFE8F5E9), shape: BoxShape.circle),
          child: const Icon(Icons.check_circle, color: Color(0xFF4CAF50), size: 52),
        ),
        const SizedBox(height: 16),
        const Text(
          'Pembelian Berhasil Diinisiasi!',
          textAlign: TextAlign.center,
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Color(0xFF0F172A)),
        ),
        const SizedBox(height: 8),
        const Text(
          'Tunjukkan kode QR di bawah ke kasir untuk mengambil pesanan Anda',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 13, color: Color(0xFF64748B)),
        ),
        const SizedBox(height: 24),

        // High-Fidelity Mock QR Code representation using clean widget layouts
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.grey.shade200, width: 2),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4)),
            ],
          ),
          child: Column(
            children: [
              // Custom QR Grid widget representation
              Container(
                width: 180,
                height: 180,
                color: Colors.white,
                child: CustomPaint(
                  painter: _QrPainter(),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'KODE TOKEN MANUAL',
                style: TextStyle(fontSize: 10, color: Color(0xFF94A3B8), fontWeight: FontWeight.bold, letterSpacing: 1.0),
              ),
              const SizedBox(height: 4),
              // Token Code Display
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  widget.transaction.qrToken ?? '',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E293B),
                    letterSpacing: 3.0,
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 20),

        // Countdown Timer Text
        Text(
          _secondsRemaining > 0 ? 'Masa Berlaku Token' : 'TOKEN KADALUARSA',
          style: TextStyle(
            fontSize: 11,
            color: _secondsRemaining > 0 ? const Color(0xFF64748B) : Colors.red,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.0,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          _formatTime(),
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: _secondsRemaining > 0 ? const Color(0xFF1A56DB) : Colors.red,
          ),
        ),
        const SizedBox(height: 24),

        // Brief Transaction details
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Column(
            children: [
              _buildReceiptRow('Merchant', widget.transaction.merchantName),
              const SizedBox(height: 8),
              _buildReceiptRow('Pesanan', widget.transaction.itemsSummary),
              const SizedBox(height: 8),
              _buildReceiptRow('Tanggal', '${widget.transaction.timestamp.day}/${widget.transaction.timestamp.month}/${widget.transaction.timestamp.year}'),
              const Divider(height: 20, color: Color(0xFFE2E8F0)),
              _buildReceiptRow('Total Belanja', 'Rp ${widget.transaction.amount.toInt()}', isBold: true),
            ],
          ),
        ),

        const SizedBox(height: 28),

        // Return button
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
            child: const Text('Kembali ke Dashboard', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ),
      ],
    );

    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      appBar: AppBar(
        title: const Text('QR Token Transaksi'),
        leading: IconButton(
          icon: const Icon(Icons.close),
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
                  child: receiptContent,
                )
              : SizedBox(
                  width: 480,
                  child: Card(
                    elevation: 4,
                    color: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                    child: Padding(
                      padding: const EdgeInsets.all(32.0),
                      child: receiptContent,
                    ),
                  ),
                ),
        ),
      ),
    );
  }

  Widget _buildReceiptRow(String label, String val, {bool isBold = false}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, color: Color(0xFF64748B))),
        const SizedBox(width: 20),
        Expanded(
          child: Text(
            val,
            textAlign: TextAlign.right,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 12,
              fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
              color: isBold ? const Color(0xFF1A56DB) : const Color(0xFF1E293B),
            ),
          ),
        ),
      ],
    );
  }
}

// Vector artist for simulated QR code blocks
class _QrPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.black;
    
    // Draw corner anchor blocks (Fidelity QR markers)
    // Top-Left
    canvas.drawRect(const Rect.fromLTWH(0, 0, 45, 45), paint);
    canvas.drawRect(const Rect.fromLTWH(10, 10, 25, 25), Paint()..color = Colors.white);
    canvas.drawRect(const Rect.fromLTWH(15, 15, 15, 15), paint);

    // Top-Right
    canvas.drawRect(Rect.fromLTWH(size.width - 45, 0, 45, 45), paint);
    canvas.drawRect(Rect.fromLTWH(size.width - 35, 10, 25, 25), Paint()..color = Colors.white);
    canvas.drawRect(Rect.fromLTWH(size.width - 30, 15, 15, 15), paint);

    // Bottom-Left
    canvas.drawRect(Rect.fromLTWH(0, size.height - 45, 45, 45), paint);
    canvas.drawRect(Rect.fromLTWH(10, size.height - 35, 25, 25), Paint()..color = Colors.white);
    canvas.drawRect(Rect.fromLTWH(15, size.height - 30, 15, 15), paint);

    // Draw some random high-fidelity pixels inside the center grid
    canvas.drawRect(Rect.fromLTWH(size.width - 45, size.height - 45, 15, 15), paint);
    canvas.drawRect(Rect.fromLTWH(size.width - 25, size.height - 25, 15, 15), paint);
    canvas.drawRect(Rect.fromLTWH(size.width - 25, size.height - 45, 10, 10), paint);

    canvas.drawRect(const Rect.fromLTWH(60, 15, 15, 15), paint);
    canvas.drawRect(const Rect.fromLTWH(85, 5, 20, 10), paint);
    canvas.drawRect(const Rect.fromLTWH(60, 40, 10, 20), paint);

    canvas.drawRect(Rect.fromLTWH(65, size.height - 45, 15, 25), paint);
    canvas.drawRect(Rect.fromLTWH(95, size.height - 25, 20, 15), paint);
    canvas.drawRect(Rect.fromLTWH(size.width - 45, 65, 25, 15), paint);

    // Center noise patterns
    canvas.drawRect(const Rect.fromLTWH(65, 65, 20, 20), paint);
    canvas.drawRect(const Rect.fromLTWH(95, 65, 15, 15), paint);
    canvas.drawRect(const Rect.fromLTWH(75, 95, 25, 20), paint);
    canvas.drawRect(const Rect.fromLTWH(115, 95, 15, 15), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
