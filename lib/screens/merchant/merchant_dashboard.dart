import 'dart:async';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import '../../state/app_state.dart';
import '../../state/app_state_provider.dart';
import '../../models/merchant.dart';
import '../../models/product.dart';
import '../../models/transaction.dart';
import '../role_selection_screen.dart';

class MerchantDashboard extends StatefulWidget {
  const MerchantDashboard({super.key});

  @override
  State<MerchantDashboard> createState() => _MerchantDashboardState();
}

class _MerchantDashboardState extends State<MerchantDashboard> {
  int _currentIndex = 0;
  
  // Camera state
  CameraController? _cameraController;
  List<CameraDescription>? _cameras;
  bool _isCameraInitialized = false;
  bool _cameraError = false;

  // Scan analysis state
  bool _isAnalyzing = false;
  TransactionModel? _scannedTx;
  String? _scanError;
  Timer? _scanTimer;
  
  // Controllers
  final _manualTokenController = TextEditingController();
  final _prodNameController = TextEditingController();
  final _prodPriceController = TextEditingController();
  final _prodStockController = TextEditingController();
  final _prodImageUrlController = TextEditingController();
  
  // Edit product state
  Product? _editingProduct;
  final List<String> _selectedAllergens = [];

  // Feedback notifications
  String? _feedbackMessage;
  bool _isFeedbackSuccess = true;
  Timer? _feedbackTimer;

  // Filter range
  DateTime? _reportStartDate;
  DateTime? _reportEndDate;

  @override
  void initState() {
    super.initState();
    _initCamera();
  }

  Future<void> _initCamera() async {
    try {
      _cameras = await availableCameras();
      if (_cameras != null && _cameras!.isNotEmpty) {
        _cameraController = CameraController(
          _cameras![0],
          ResolutionPreset.medium,
          enableAudio: false,
        );
        await _cameraController!.initialize();
        if (mounted) {
          setState(() {
            _isCameraInitialized = true;
          });
        }
      } else {
        setState(() {
          _cameraError = true;
        });
      }
    } catch (e) {
      debugPrint('Error initializing camera: $e');
      if (mounted) {
        setState(() {
          _cameraError = true;
        });
      }
    }
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    _manualTokenController.dispose();
    _prodNameController.dispose();
    _prodPriceController.dispose();
    _prodStockController.dispose();
    _prodImageUrlController.dispose();
    _feedbackTimer?.cancel();
    _scanTimer?.cancel();
    super.dispose();
  }

  void _showFeedback(String message, bool isSuccess) {
    _feedbackTimer?.cancel();
    setState(() {
      _feedbackMessage = message;
      _isFeedbackSuccess = isSuccess;
    });

    // Simulate beep/vibrate alert in UI
    _feedbackTimer = Timer(const Duration(seconds: 4), () {
      if (mounted) {
        setState(() {
          _feedbackMessage = null;
        });
      }
    });
  }

  void _processToken(AppState appState, String merchantId, String token) {
    if (token.isEmpty) return;

    try {
      final tx = appState.verifyAndProcessToken(merchantId, token.trim().toUpperCase());
      _manualTokenController.clear();
      
      // Success buzzer!
      _showFeedback(
        "🔊 BEEP! TOKEN ${tx.qrToken} BERHASIL DIPROSES!\n"
        "Nama Siswa: ${tx.studentName}\n"
        "Pesanan: ${tx.itemsSummary}\n"
        "Total Bayar: Rp ${tx.amount.toInt()}",
        true,
      );
    } catch (e) {
      // Failure buzzer!
      _showFeedback(
        "❌ ERROR SCAN!\n"
        "${e.toString().replaceFirst('Exception: ', '')}",
        false,
      );
    }
  }

  void _startScanAnalysis(AppState appState, String merchantId, List<TransactionModel> waitingTokens) {
    if (_isAnalyzing || _scannedTx != null || _scanError != null) return;

    setState(() {
      _isAnalyzing = true;
      _scanError = null;
      _scannedTx = null;
    });

    _scanTimer?.cancel();
    _scanTimer = Timer(const Duration(milliseconds: 1800), () {
      if (!mounted) return;

      if (waitingTokens.isEmpty) {
        setState(() {
          _isAnalyzing = false;
          _scanError = "Tidak ada siswa mengantri untuk pembayaran QRIS";
        });
        Future.delayed(const Duration(seconds: 3), () {
          if (mounted) setState(() => _scanError = null);
        });
        return;
      }

      // Capture first transaction in queue
      final tx = waitingTokens.first;
      try {
        final processedTx = appState.verifyAndProcessToken(merchantId, tx.qrToken ?? '');
        setState(() {
          _isAnalyzing = false;
          _scannedTx = processedTx;
        });

        // Buzz feedback!
        _showFeedback(
          "🔊 BEEP! BERHASIL PINDAI!\n"
          "${tx.studentName} — Rp ${tx.amount.toInt()}\n"
          "Pesanan: ${tx.itemsSummary}",
          true,
        );

        Future.delayed(const Duration(milliseconds: 2500), () {
          if (mounted) {
            setState(() {
              _scannedTx = null;
            });
          }
        });
      } catch (e) {
        setState(() {
          _isAnalyzing = false;
          _scanError = e.toString().replaceFirst('Exception: ', '');
        });
        Future.delayed(const Duration(seconds: 3), () {
          if (mounted) setState(() => _scanError = null);
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final appState = AppStateProvider.of(context);
    final Merchant merchant = appState.currentUser as Merchant;
    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isMobile = screenWidth < 768;

    // Filter products of this merchant
    final myProducts = appState.products
        .where((p) => p.merchantId == merchant.id)
        .toList();

    // Filter sales transactions of this merchant
    List<TransactionModel> mySales = appState.transactions
        .where((tx) => tx.merchantId == merchant.id && tx.status == 'Selesai')
        .toList();

    // Apply reports custom filters
    if (_reportStartDate != null && _reportEndDate != null) {
      mySales = mySales.where((tx) {
        final date = tx.timestamp;
        final start = DateTime(_reportStartDate!.year, _reportStartDate!.month, _reportStartDate!.day);
        final end = DateTime(_reportEndDate!.year, _reportEndDate!.month, _reportEndDate!.day, 23, 59, 59);
        return date.isAfter(start) && date.isBefore(end);
      }).toList();
    }

    // Dynamic stats
    double todayRevenue = 0.0;
    int todayTxCount = 0;
    final now = DateTime.now();

    for (var tx in mySales) {
      if (tx.timestamp.day == now.day &&
          tx.timestamp.month == now.month &&
          tx.timestamp.year == now.year) {
        todayRevenue += tx.amount;
        todayTxCount++;
      }
    }

    // Active pages
    final List<Widget> pages = [
      _buildHome(context, merchant, todayRevenue, todayTxCount, appState),
      _buildProductsPage(context, merchant, myProducts, appState),
      _buildReportsPage(context, merchant, mySales),
    ];

    final List<String> pageTitles = [
      'Dashboard Kasir Merchant',
      'Kelola Katalog & Stok',
      'Laporan Penjualan Hari Ini'
    ];

    Widget headerActions = Row(
      children: [
        IconButton(
          icon: const Icon(Icons.logout, color: Color(0xFFEF4444)),
          tooltip: 'Keluar',
          onPressed: () => _handleLogout(context),
        ),
      ],
    );

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(
                color: Color(0xFFF59E0B),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.storefront, color: Colors.white, size: 16),
            ),
            const SizedBox(width: 10),
            Text(pageTitles[_currentIndex]),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: headerActions,
          ),
        ],
      ),
      body: isMobile
          ? pages[_currentIndex]
          : Row(
              children: [
                // Desktop Drawer
                Container(
                  width: 260,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.shade200,
                        blurRadius: 0,
                        spreadRadius: 1,
                        offset: const Offset(1, 0),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      // Header
                      Container(
                        padding: const EdgeInsets.all(24),
                        color: const Color(0xFFF59E0B).withOpacity(0.04),
                        child: Row(
                          children: [
                            CircleAvatar(
                              backgroundColor: const Color(0xFFF59E0B),
                              child: Text(
                                merchant.name[0],
                                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    merchant.name,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF0F172A),
                                    ),
                                  ),
                                  Text(
                                    'Kasir • ID ${merchant.id}',
                                    style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Divider(height: 1),
                      // Links
                      Expanded(
                        child: ListView(
                          padding: const EdgeInsets.all(12),
                          children: [
                            _buildSideNavItem(0, 'Dashboard Scan', Icons.qr_code_scanner),
                            _buildSideNavItem(1, 'Manajemen Produk', Icons.inventory_2),
                            _buildSideNavItem(2, 'Laporan Keuangan', Icons.analytics),
                          ],
                        ),
                      ),
                      // Bottom version panel
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          children: [
                            const Text(
                              'SekolahPRO Merchant v1.0',
                              style: TextStyle(fontSize: 10, color: Color(0xFF94A3B8)),
                            ),
                            const SizedBox(height: 8),
                            SizedBox(
                              width: double.infinity,
                              child: OutlinedButton.icon(
                                icon: const Icon(Icons.arrow_back, size: 14),
                                label: const Text('Ganti Akun Kasir'),
                                onPressed: () => _handleLogout(context),
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                  side: BorderSide(color: Colors.grey.shade300),
                                  foregroundColor: const Color(0xFF64748B),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                // Main content pane
                Expanded(
                  child: Container(
                    color: const Color(0xFFF8FAFC),
                    child: pages[_currentIndex],
                  ),
                ),
              ],
            ),
      bottomNavigationBar: isMobile
          ? BottomNavigationBar(
              currentIndex: _currentIndex,
              onTap: (index) => setState(() => _currentIndex = index),
              selectedItemColor: const Color(0xFFF59E0B),
              unselectedItemColor: const Color(0xFF64748B),
              showUnselectedLabels: true,
              type: BottomNavigationBarType.fixed,
              items: const [
                BottomNavigationBarItem(icon: Icon(Icons.qr_code_scanner), label: 'Kasir Scan'),
                BottomNavigationBarItem(icon: Icon(Icons.inventory_2), label: 'Produk'),
                BottomNavigationBarItem(icon: Icon(Icons.analytics), label: 'Laporan'),
              ],
            )
          : null,
    );
  }

  Widget _buildSideNavItem(int index, String label, IconData icon) {
    final bool isSelected = _currentIndex == index;
    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      child: ListTile(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        selected: isSelected,
        selectedTileColor: const Color(0xFFF59E0B).withOpacity(0.08),
        selectedColor: const Color(0xFFF59E0B),
        leading: Icon(icon, color: isSelected ? const Color(0xFFF59E0B) : const Color(0xFF64748B)),
        title: Text(
          label,
          style: TextStyle(
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            fontSize: 14,
          ),
        ),
        onTap: () => setState(() => _currentIndex = index),
      ),
    );
  }

  // --- TAB 1: CASHIER SCAN MAIN SCREEN ---
  Widget _buildHome(BuildContext context, Merchant merchant, double todayRevenue, int todayTxCount, AppState appState) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isMobile = screenWidth < 768;

    // Filter waiting tokens for this merchant specifically to simulate scanner click capture
    final waitingTokens = appState.transactions
        .where((tx) => tx.merchantId == merchant.id && tx.status == 'Menunggu')
        .toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Simulated Beep/Vibrate alert banner
          if (_feedbackMessage != null) ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              margin: const EdgeInsets.only(bottom: 24),
              decoration: BoxDecoration(
                color: _isFeedbackSuccess ? const Color(0xFFECFDF5) : const Color(0xFFFEF2F2),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: _isFeedbackSuccess ? const Color(0xFF10B981) : const Color(0xFFFCA5A5), width: 1.5),
              ),
              child: Row(
                children: [
                  Icon(
                    _isFeedbackSuccess ? Icons.volume_up : Icons.vibration,
                    color: _isFeedbackSuccess ? const Color(0xFF10B981) : const Color(0xFFEF4444),
                    size: 28,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      _feedbackMessage!,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                        color: _isFeedbackSuccess ? const Color(0xFF047857) : const Color(0xFF991B1B),
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],

          // Daily stats row
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'Pendapatan Hari Ini',
                  'Rp ${todayRevenue.toInt().toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}',
                  Icons.monetization_on,
                  const Color(0xFF10B981),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatCard(
                  'Total Transaksi Sukses',
                  '$todayTxCount Transaksi',
                  Icons.receipt_long,
                  const Color(0xFF3B82F6),
                ),
              ),
            ],
          ),

          const SizedBox(height: 32),

          // Double column checkout interfaces
          isMobile
              ? Column(
                  children: [
                    _buildScannerBox(appState, merchant, waitingTokens),
                    const SizedBox(height: 20),
                    _buildManualInputBox(appState, merchant),
                  ],
                )
              : Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 6,
                      child: _buildScannerBox(appState, merchant, waitingTokens),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      flex: 5,
                      child: _buildManualInputBox(appState, merchant),
                    ),
                  ],
                ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String label, String val, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade100),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.01), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(fontSize: 12, color: Color(0xFF64748B))),
                const SizedBox(height: 4),
                Text(
                  val,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Color(0xFF0F172A)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScannerBox(AppState appState, Merchant merchant, List<TransactionModel> waitingTokens) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.qr_code_scanner, color: Color(0xFFF59E0B)),
              const SizedBox(width: 10),
              Text(
                _isCameraInitialized ? 'Kamera Pemindai Token QR' : 'Kamera Pemindai Token QR (Simulasi)',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // High-Fidelity Laptop Camera View
          GestureDetector(
            onTap: () => _startScanAnalysis(appState, merchant.id, waitingTokens),
            child: Container(
              height: 240,
              width: double.infinity,
              decoration: BoxDecoration(
                color: const Color(0xFF0F172A),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: _isAnalyzing
                      ? const Color(0xFFF59E0B)
                      : (_scannedTx != null
                          ? const Color(0xFF10B981)
                          : (_scanError != null ? const Color(0xFFEF4444) : Colors.transparent)),
                  width: 2.5,
                ),
              ),
              child: Stack(
                children: [
                  // Real Live Camera Feed
                  if (_isCameraInitialized && _cameraController != null)
                    Positioned.fill(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: AspectRatio(
                          aspectRatio: _cameraController!.value.aspectRatio,
                          child: CameraPreview(_cameraController!),
                        ),
                      ),
                    ),
                  
                  // Overlay error if camera fails
                  if (_cameraError)
                    const Positioned.fill(
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.videocam_off, color: Colors.white54, size: 40),
                            SizedBox(height: 8),
                            Text(
                              'Kamera tidak terdeteksi / izin ditolak.\nMengaktifkan mode simulasi.',
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.white70, fontSize: 11),
                            ),
                          ],
                        ),
                      ),
                    ),

                  // Scan target guides
                  Center(
                    child: Container(
                      width: 140,
                      height: 140,
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: _isAnalyzing
                              ? const Color(0xFFF59E0B)
                              : (_scannedTx != null ? const Color(0xFF10B981) : const Color(0xFFFFB534)),
                          width: 3,
                        ),
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  ),
                  // Scanning green horizontal laser bar animation
                  if (!_isAnalyzing && _scannedTx == null && _scanError == null)
                    const Positioned(
                      top: 120,
                      left: 30,
                      right: 30,
                      child: Divider(color: Color(0xFF10B981), thickness: 2),
                    ),

                  // ── FUTURISTIC ANALYZING RADAR SWEEP OVERLAY ──
                  if (_isAnalyzing)
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.72),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(
                                width: 90,
                                height: 90,
                                child: Stack(
                                  children: [
                                    Center(
                                      child: Container(
                                        width: 74,
                                        height: 74,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          border: Border.all(color: const Color(0xFFF59E0B), width: 1.5),
                                        ),
                                      ),
                                    ),
                                    // Sweep bar rotation animation
                                    TweenAnimationBuilder<double>(
                                      tween: Tween(begin: 0.0, end: 2 * 3.14159),
                                      duration: const Duration(milliseconds: 1400),
                                      builder: (context, angle, child) {
                                        return Transform.rotate(
                                          angle: angle,
                                          child: Center(
                                            child: Container(
                                              width: 74,
                                              height: 74,
                                              decoration: const BoxDecoration(
                                                shape: BoxShape.circle,
                                                gradient: SweepGradient(
                                                  colors: [
                                                    Colors.transparent,
                                                    Colors.transparent,
                                                    Color(0x33F59E0B),
                                                    Color(0xFFF59E0B),
                                                  ],
                                                  stops: [0.0, 0.45, 0.75, 1.0],
                                                ),
                                              ),
                                            ),
                                          ),
                                        );
                                      },
                                      onEnd: () {},
                                    ),
                                    const Center(
                                      child: Icon(Icons.qr_code_scanner, color: Color(0xFFF59E0B), size: 32),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 16),
                              const Text(
                                'MENGANALISIS KODE QRIS...',
                                style: TextStyle(
                                  color: Color(0xFFF59E0B),
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1.2,
                                ),
                              ),
                              const SizedBox(height: 3),
                              const Text(
                                'Memverifikasi keamanan SekolahPRO',
                                style: TextStyle(color: Colors.white54, fontSize: 10),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                  // ── SUCCESS OVERLAY ──
                  if (_scannedTx != null)
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          color: const Color(0xEE10B981),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                                child: const Icon(Icons.check, color: Color(0xFF10B981), size: 36),
                              ),
                              const SizedBox(height: 14),
                              const Text(
                                'PEMBAYARAN BERHASIL ✓',
                                style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold, letterSpacing: 0.8),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _scannedTx!.studentName,
                                style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w500),
                              ),
                              Text(
                                'Rp ${_scannedTx!.amount.toInt()}',
                                style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w800),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                  // ── ERROR SCAN OVERLAY ──
                  if (_scanError != null)
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          color: const Color(0xEEEF4444),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                                child: const Icon(Icons.close, color: Color(0xFFEF4444), size: 36),
                              ),
                              const SizedBox(height: 14),
                              const Text(
                                'PEMINDAIAN GAGAL',
                                style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold, letterSpacing: 0.8),
                              ),
                              const SizedBox(height: 6),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 20),
                                child: Text(
                                  _scanError!,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(color: Colors.white, fontSize: 11),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                  // Camera status labels
                  if (!_isAnalyzing && _scannedTx == null && _scanError == null)
                    Positioned(
                      bottom: 16,
                      left: 0,
                      right: 0,
                      child: Center(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(color: Colors.black.withOpacity(0.6), borderRadius: BorderRadius.circular(20)),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.circle, color: Color(0xFF10B981), size: 10),
                              const SizedBox(width: 8),
                              Text(
                                _isCameraInitialized ? 'KAMERA LIVE AKTIF' : 'SIMULASI SCAN AKTIF',
                                style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 0.5),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Interactivity simulator for easily testing waiting tokens
          const Text(
            'Klik Token Aktif Siswa di Bawah untuk Simulasi Pindai:',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Color(0xFF64748B)),
          ),
          const SizedBox(height: 8),
          if (waitingTokens.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: const Color(0xFFF8FAFC), borderRadius: BorderRadius.circular(12)),
              child: const Center(
                child: Text('Tidak ada siswa mengantri pembayaran', style: TextStyle(color: Colors.grey, fontSize: 12)),
              ),
            )
          else
            SizedBox(
              height: 100,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: waitingTokens.length,
                itemBuilder: (context, idx) {
                  final tx = waitingTokens[idx];
                  return Card(
                    color: const Color(0xFFFEF3C7),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(10),
                      onTap: () => _processToken(appState, merchant.id, tx.qrToken ?? ''),
                      child: Container(
                        width: 160,
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(tx.studentName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12), maxLines: 1, overflow: TextOverflow.ellipsis),
                            const SizedBox(height: 2),
                            Text('Token: ${tx.qrToken}', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFFD97706))),
                            const SizedBox(height: 2),
                            Text('Rp ${tx.amount.toInt()}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildManualInputBox(AppState appState, Merchant merchant) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.keyboard, color: Color(0xFFF59E0B)),
              SizedBox(width: 10),
              Text(
                'Masukkan Token Manual',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            'Gunakan menu ini jika kode QR token siswa tidak terbaca oleh pemindai kamera.',
            style: TextStyle(fontSize: 12, color: Colors.grey, height: 1.4),
          ),
          const SizedBox(height: 20),
          const Text('Masukkan 8 Digit Token Belanja', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          TextField(
            controller: _manualTokenController,
            textCapitalization: TextCapitalization.characters,
            decoration: InputDecoration(
              hintText: 'Contoh: TK81X29A',
              prefixIcon: const Icon(Icons.confirmation_num),
              contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: () => _processToken(appState, merchant.id, _manualTokenController.text),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFF59E0B),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Verifikasi & Klaim Pembayaran', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }

  // --- TAB 2: PRODUCTS MANAGEMENT PAGE ---
  Widget _buildProductsPage(BuildContext context, Merchant merchant, List<Product> myProducts, AppState appState) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isMobile = screenWidth < 768;

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Daftar Produk Toko Anda',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              ElevatedButton.icon(
                icon: const Icon(Icons.add),
                label: const Text('Tambah Produk Baru'),
                onPressed: () => _showProductEditorModal(context, merchant, null, appState),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFF59E0B),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Expanded(
            child: myProducts.isEmpty
                ? const Center(child: Text('Toko Anda belum memiliki produk terdaftar.', style: TextStyle(color: Colors.grey)))
                : isMobile
                    ? ListView.builder(
                        itemCount: myProducts.length,
                        itemBuilder: (context, idx) {
                          final p = myProducts[idx];
                          return _buildProductListItem(context, merchant, p, appState);
                        },
                      )
                    : GridView.builder(
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                          childAspectRatio: 0.85,
                        ),
                        itemCount: myProducts.length,
                        itemBuilder: (context, idx) {
                          final p = myProducts[idx];
                          return _buildProductGridItem(context, merchant, p, appState);
                        },
                      ),
          ),
        ],
      ),
    );
  }

  // Mobile list row
  Widget _buildProductListItem(BuildContext context, Merchant merchant, Product p, AppState appState) {
    return Card(
      color: Colors.white,
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(p.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  const SizedBox(height: 4),
                  Text('Kategori: ${p.category} • Rp ${p.price.toInt()}', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                  const SizedBox(height: 4),
                  // Stock count increment/decrement row
                  Row(
                    children: [
                      const Text('Stok: ', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                      IconButton(
                        icon: const Icon(Icons.remove, size: 14, color: Colors.red),
                        onPressed: () {
                          if (p.stock > 0) appState.updateProductStock(p.id, p.stock - 1);
                        },
                      ),
                      Text('${p.stock}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                      IconButton(
                        icon: const Icon(Icons.add, size: 14, color: Colors.green),
                        onPressed: () {
                          appState.updateProductStock(p.id, p.stock + 1);
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.edit, color: Color(0xFFF59E0B), size: 20),
                  onPressed: () => _showProductEditorModal(context, merchant, p, appState),
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red, size: 20),
                  onPressed: () {
                    appState.deleteProduct(p.id);
                    _showFeedback('Produk ${p.name} berhasil dihapus!', true);
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Desktop grid item
  Widget _buildProductGridItem(BuildContext context, Merchant merchant, Product p, AppState appState) {
    return Card(
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: BorderSide(color: Colors.grey.shade100)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(color: const Color(0xFFF8FAFC), borderRadius: BorderRadius.circular(8)),
                  child: Text(p.category, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey)),
                ),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit, color: Color(0xFFF59E0B), size: 18),
                      onPressed: () => _showProductEditorModal(context, merchant, p, appState),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red, size: 18),
                      onPressed: () {
                        appState.deleteProduct(p.id);
                        _showFeedback('Produk ${p.name} berhasil dihapus!', true);
                      },
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(p.name, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            const SizedBox(height: 4),
            Text('Rp ${p.price.toInt()}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFFF59E0B))),
            const Spacer(),
            const Divider(),
            const SizedBox(height: 4),
            // Stock realtime modification row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Ubah Ketersediaan Stok:', style: TextStyle(fontSize: 11, color: Colors.grey)),
                Row(
                  children: [
                    GestureDetector(
                      onTap: () {
                        if (p.stock > 0) appState.updateProductStock(p.id, p.stock - 1);
                      },
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(color: Colors.grey.shade100, shape: BoxShape.circle),
                        child: const Icon(Icons.remove, size: 12, color: Colors.red),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10.0),
                      child: Text('${p.stock}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                    ),
                    GestureDetector(
                      onTap: () => appState.updateProductStock(p.id, p.stock + 1),
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(color: Color(0xFFF59E0B), shape: BoxShape.circle),
                        child: const Icon(Icons.add, size: 12, color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showProductEditorModal(BuildContext context, Merchant merchant, Product? product, AppState appState) {
    _editingProduct = product;
    _selectedAllergens.clear();

    if (product != null) {
      _prodNameController.text = product.name;
      _prodPriceController.text = product.price.toInt().toString();
      _prodStockController.text = product.stock.toString();
      _prodImageUrlController.text = product.imageUrl;
      _selectedAllergens.addAll(product.allergens);
    } else {
      _prodNameController.clear();
      _prodPriceController.clear();
      _prodStockController.clear();
      _prodImageUrlController.clear();
    }

    final Map<String, String> allergenChoices = {
      'SF': 'Seafood 🦐',
      'ML': 'Susu 🥛',
      'EG': 'Telur 🥚',
      'NT': 'Kacang 🥜',
      'GL': 'Gluten 🌾',
      'SY': 'Kedelai 🫘',
      'CH': 'Cabai 🌶️',
    };

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.only(topLeft: Radius.circular(24), topRight: Radius.circular(24))),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return SingleChildScrollView(
              padding: EdgeInsets.only(
                left: 24,
                right: 24,
                top: 24,
                bottom: MediaQuery.of(context).viewInsets.bottom + 24,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    product != null ? 'Edit Detail Produk' : 'Tambah Produk Baru',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  
                  // Product Name
                  const Text('Nama Produk', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 6),
                  TextField(
                    controller: _prodNameController,
                    decoration: const InputDecoration(hintText: 'Contoh: Nasi Goreng Ayam Geprek', border: OutlineInputBorder()),
                  ),
                  const SizedBox(height: 12),

                  // Pricing & Stock
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Harga Jual (Rp)', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 6),
                            TextField(
                              controller: _prodPriceController,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(hintText: 'Contoh: 15000', border: OutlineInputBorder()),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Jumlah Stok', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 6),
                            TextField(
                              controller: _prodStockController,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(hintText: 'Contoh: 20', border: OutlineInputBorder()),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Product image URL (optional)
                  const Text('URL Foto Produk (Opsional)', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 6),
                  TextField(
                    controller: _prodImageUrlController,
                    decoration: const InputDecoration(hintText: 'http://...', border: OutlineInputBorder()),
                  ),
                  const SizedBox(height: 16),

                  // Allergens Checklist: Kantin M001 ONLY!
                  if (merchant.id == 'M001') ...[
                    const Text('Label Alergen Menu (Wajib Input Kantin)', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.red)),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: allergenChoices.keys.map((code) {
                        final isSelected = _selectedAllergens.contains(code);
                        return FilterChip(
                          label: Text(allergenChoices[code]!, style: const TextStyle(fontSize: 11)),
                          selected: isSelected,
                          selectedColor: const Color(0xFFF59E0B).withOpacity(0.2),
                          checkmarkColor: const Color(0xFFF59E0B),
                          onSelected: (selected) {
                            setModalState(() {
                              if (selected) {
                                _selectedAllergens.add(code);
                              } else {
                                _selectedAllergens.remove(code);
                              }
                            });
                          },
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 24),
                  ],

                  // Submit button
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () {
                        if (_prodNameController.text.isEmpty ||
                            _prodPriceController.text.isEmpty ||
                            _prodStockController.text.isEmpty) {
                          return;
                        }
                        
                        appState.addOrUpdateProduct(
                          merchantId: merchant.id,
                          productId: product?.id,
                          name: _prodNameController.text,
                          price: double.tryParse(_prodPriceController.text) ?? 0.0,
                          stock: int.tryParse(_prodStockController.text) ?? 0,
                          category: merchant.id == 'M001' ? 'Makanan' : 'ATK',
                          allergens: List.from(_selectedAllergens),
                          imageUrl: _prodImageUrlController.text,
                        );

                        Navigator.pop(context); // close bottom sheet
                        _showFeedback(
                          product != null ? 'Produk berhasil diubah!' : 'Produk baru ditambahkan!',
                          true,
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFF59E0B),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text('Simpan Data Produk', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // --- TAB 3: REPORTS PAGE ---
  Widget _buildReportsPage(BuildContext context, Merchant merchant, List<TransactionModel> mySales) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey.shade100),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Filter Rentang Tanggal Penjualan', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        icon: const Icon(Icons.date_range, size: 14),
                        label: Text(
                          _reportStartDate != null
                              ? '${_reportStartDate!.day}/${_reportStartDate!.month}/${_reportStartDate!.year}'
                              : 'Pilih Tanggal Awal',
                          style: const TextStyle(fontSize: 11),
                        ),
                        onPressed: () => _selectReportsDateRange(context),
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Text('s/d', style: TextStyle(fontSize: 11, color: Colors.grey)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton.icon(
                        icon: const Icon(Icons.date_range, size: 14),
                        label: Text(
                          _reportEndDate != null
                              ? '${_reportEndDate!.day}/${_reportEndDate!.month}/${_reportEndDate!.year}'
                              : 'Pilih Tanggal Akhir',
                          style: const TextStyle(fontSize: 11),
                        ),
                        onPressed: () => _selectReportsDateRange(context),
                      ),
                    ),
                  ],
                ),
                if (_reportStartDate != null) ...[
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _reportStartDate = null;
                        _reportEndDate = null;
                      });
                    },
                    child: const Text('Reset Saringan', style: TextStyle(fontSize: 12, color: Colors.red)),
                  ),
                ],
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Sales List table
          const Text('Rincian Transaksi Penjualan Sukses', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
          const SizedBox(height: 12),
          Expanded(
            child: mySales.isEmpty
                ? const Center(child: Text('Tidak ada penjualan terdaftar.', style: TextStyle(color: Colors.grey)))
                : ListView.builder(
                    itemCount: mySales.length,
                    itemBuilder: (context, index) {
                      final tx = mySales[index];
                      final formattedDate = "${tx.timestamp.day}/${tx.timestamp.month} ${tx.timestamp.hour.toString().padLeft(2, '0')}:${tx.timestamp.minute.toString().padLeft(2, '0')}";
                      return Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey.shade100)),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(tx.itemsSummary, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13), maxLines: 1, overflow: TextOverflow.ellipsis),
                                  const SizedBox(height: 2),
                                  Text('Pembeli: ${tx.studentName} (${tx.studentNis})', style: const TextStyle(fontSize: 11, color: Colors.grey)),
                                  const SizedBox(height: 2),
                                  Text(formattedDate, style: const TextStyle(fontSize: 10, color: Colors.grey)),
                                ],
                              ),
                            ),
                            Text('Rp ${tx.amount.toInt()}', style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF10B981))),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Future<void> _selectReportsDateRange(BuildContext context) async {
    final range = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2025),
      lastDate: DateTime.now().add(const Duration(days: 30)),
    );

    if (range != null) {
      setState(() {
        _reportStartDate = range.start;
        _reportEndDate = range.end;
      });
    }
  }

  void _handleLogout(BuildContext context) {
    AppStateProvider.of(context).logout();
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const RoleSelectionScreen()),
      (route) => false,
    );
  }
}
