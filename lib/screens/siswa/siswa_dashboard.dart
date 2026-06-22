import 'package:flutter/material.dart';
import '../../state/app_state.dart';
import '../../state/app_state_provider.dart';
import '../../models/student.dart';
import '../../models/merchant.dart';
import '../../models/transaction.dart';
import '../role_selection_screen.dart';
import 'siswa_katalog.dart';
import 'siswa_riwayat.dart';
import 'siswa_settings.dart';
import 'siswa_topup.dart';

class SiswaDashboard extends StatefulWidget {
  const SiswaDashboard({super.key});

  @override
  State<SiswaDashboard> createState() => _SiswaDashboardState();
}

class _SiswaDashboardState extends State<SiswaDashboard> {
  int _currentIndex = 0;

  // Auto-logout simulator: 15 minutes countdown visual indicator
  int _sessionMinutesLeft = 15;
  int _sessionSecondsLeft = 0;
  bool _isSessionWarningDismissed = false;

  @override
  Widget build(BuildContext context) {
    final appState = AppStateProvider.of(context);
    final Student student = appState.currentUser as Student;
    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isMobile = screenWidth < 768;

    // Active pages
    final List<Widget> pages = [
      _buildHome(context, student, appState),
      const SiswaKatalogPage(),
      const SiswaRiwayatPage(),
      const SiswaSettingsPage(),
    ];

    final List<String> pageTitles = [
      'Dashboard Siswa',
      'Katalog Merchant',
      'Riwayat Belanja',
      'Pengaturan Akun'
    ];

    // Auto logout prompt if time expires (simulated)
    Widget sessionTimerWidget = Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFFEF3C7),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFFDE68A)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.timer, color: Color(0xFFD97706), size: 16),
          const SizedBox(width: 6),
          Text(
            'Sesi: ${widget.hashCode.toString().substring(0, 3)} | ${_sessionMinutesLeft.toString().padLeft(2, '0')}:${_sessionSecondsLeft.toString().padLeft(2, '0')}',
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Color(0xFFB45309),
            ),
          ),
        ],
      ),
    );

    Widget headerActions = Row(
      children: [
        sessionTimerWidget,
        const SizedBox(width: 12),
        IconButton(
          icon: const Icon(Icons.logout, color: Color(0xFFEF4444)),
          tooltip: 'Keluar Akun',
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
                color: Color(0xFF1A56DB),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.school, color: Colors.white, size: 16),
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
                // Desktop side navigation bar drawer
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
                      // User profile panel
                      Container(
                        padding: const EdgeInsets.all(24),
                        color: const Color(0xFF1A56DB).withOpacity(0.04),
                        child: Row(
                          children: [
                            CircleAvatar(
                              backgroundColor: const Color(0xFF1A56DB),
                              child: Text(
                                student.name[0],
                                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    student.name,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF0F172A),
                                    ),
                                  ),
                                  Text(
                                    'NIS: ${student.nis} • ${student.className}',
                                    style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Divider(height: 1),
                      // Navigation links
                      Expanded(
                        child: ListView(
                          padding: const EdgeInsets.all(12),
                          children: [
                            _buildSideNavItem(0, 'Beranda Utama', Icons.dashboard),
                            _buildSideNavItem(1, 'Belanja Merchant', Icons.storefront),
                            _buildSideNavItem(2, 'Riwayat Transaksi', Icons.receipt_long),
                            _buildSideNavItem(3, 'Ubah PIN Keamanan', Icons.security),
                          ],
                        ),
                      ),
                      // Back to selection
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          children: [
                            const Text(
                              'SekolahPRO Student v1.0',
                              style: TextStyle(fontSize: 10, color: Color(0xFF94A3B8)),
                            ),
                            const SizedBox(height: 8),
                            SizedBox(
                              width: double.infinity,
                              child: OutlinedButton.icon(
                                icon: const Icon(Icons.arrow_back, size: 14),
                                label: const Text('Ganti Role User'),
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
                // Core Page content
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
              selectedItemColor: const Color(0xFF1A56DB),
              unselectedItemColor: const Color(0xFF64748B),
              showUnselectedLabels: true,
              type: BottomNavigationBarType.fixed,
              items: const [
                BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Beranda'),
                BottomNavigationBarItem(icon: Icon(Icons.storefront), label: 'Katalog'),
                BottomNavigationBarItem(icon: Icon(Icons.receipt_long), label: 'Riwayat'),
                BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Pengaturan'),
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
        selectedTileColor: const Color(0xFF1A56DB).withOpacity(0.08),
        selectedColor: const Color(0xFF1A56DB),
        leading: Icon(icon, color: isSelected ? const Color(0xFF1A56DB) : const Color(0xFF64748B)),
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

  // --- HOME PORTAL CONTENT ---
  Widget _buildHome(BuildContext context, Student student, AppState appState) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isMobile = screenWidth < 768;

    // E-Wallet balance card colors matching spec:
    // Saldo > Rp 20.000: Hijau (#4CAF50), Rp 5.000 - Rp 20.000: Kuning (#FFC107), < Rp 5.000: Merah (#F44336)
    Color balanceColor = const Color(0xFF4CAF50); // Green default
    String balanceStatus = 'Cukup';
    if (student.balance < 5000.0) {
      balanceColor = const Color(0xFFF44336); // Red
      balanceStatus = 'Segera Top Up!';
    } else if (student.balance <= 20000.0) {
      balanceColor = const Color(0xFFFFC107); // Yellow
      balanceStatus = 'Hampir Habis';
    }

    // Filter Budi's 5 recent transactions
    final myTransactions = appState.transactions
        .where((tx) => tx.studentNis == student.nis)
        .take(5)
        .toList();

    return RefreshIndicator(
      onRefresh: () async {
        await Future.delayed(const Duration(milliseconds: 500));
        setState(() {});
      },
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Student Welcome details (Mobile only)
            if (isMobile) ...[
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor: const Color(0xFF1A56DB).withOpacity(0.1),
                    child: Text(student.name[0], style: const TextStyle(fontWeight: FontWeight.bold)),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Halo, ${student.name} 👋',
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                        ),
                        Text(
                          'Kelas ${student.className} • NIS ${student.nis}',
                          style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
            ],

            // Balance card and Quick Action Panel
            isMobile
                ? Column(
                    children: [
                      _buildBalanceCard(student, balanceColor, balanceStatus),
                      const SizedBox(height: 16),
                      _buildQuickActions(context),
                    ],
                  )
                : Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 5,
                        child: _buildBalanceCard(student, balanceColor, balanceStatus),
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        flex: 6,
                        child: _buildQuickActions(context),
                      ),
                    ],
                  ),

            const SizedBox(height: 32),

            // Active Merchants
            const Text(
              'Pesan Makanan & ATK di Sekolah',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
            ),
            const SizedBox(height: 16),
            isMobile
                ? Column(
                    children: appState.merchants.map((m) => _buildMerchantCard(context, m)).toList(),
                  )
                : GridView.count(
                    shrinkWrap: true,
                    crossAxisCount: 2,
                    crossAxisSpacing: 20,
                    mainAxisSpacing: 20,
                    childAspectRatio: 2.2,
                    physics: const NeverScrollableScrollPhysics(),
                    children: appState.merchants.map((m) => _buildMerchantCard(context, m)).toList(),
                  ),

            const SizedBox(height: 32),

            // Recent 5 Transactions
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  '5 Transaksi Terakhir',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                ),
                TextButton(
                  onPressed: () => setState(() => _currentIndex = 2),
                  child: const Text('Lihat Semua', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (myTransactions.isEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Column(
                  children: [
                    Icon(Icons.receipt_long, color: Color(0xFF94A3B8), size: 40),
                    SizedBox(height: 12),
                    Text(
                      'Belum ada transaksi',
                      style: TextStyle(color: Color(0xFF64748B), fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: myTransactions.length,
                itemBuilder: (context, idx) {
                  final tx = myTransactions[idx];
                  return _buildTransactionItem(tx);
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildBalanceCard(Student student, Color balanceColor, String balanceStatus) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF1E293B),
            Color(0xFF0F172A),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'SALDO E-WALLET SekolahPRO',
                style: TextStyle(
                  color: Color(0xFF94A3B8),
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.0,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: balanceColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: balanceColor, width: 1),
                ),
                child: Text(
                  balanceStatus,
                  style: TextStyle(
                    color: balanceColor,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Rp ${student.balance.toInt().toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 36,
              fontWeight: FontWeight.bold,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 12),
          const Divider(color: Color(0xFF334155), height: 1),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Batas Harian Terpakai', style: TextStyle(color: Color(0xFF64748B), fontSize: 11)),
                  const SizedBox(height: 2),
                  Text(
                    student.dailySpendingLimit > 0.0
                        ? 'Rp ${(student.dailySpendingLimit - student.remainderDailyLimit).toInt()} / Rp ${student.dailySpendingLimit.toInt()}'
                        : 'Bebas (Tanpa Batas)',
                    style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const Icon(Icons.qr_code, color: Colors.white70, size: 24),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Akses Cepat Pintasan',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF0F172A)),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildShortcutButton(
                icon: Icons.add_circle,
                label: 'Top Up',
                color: const Color(0xFF10B981),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const SiswaTopupScreen()),
                  );
                },
              ),
              _buildShortcutButton(
                icon: Icons.storefront,
                label: 'Katalog',
                color: const Color(0xFF1A56DB),
                onTap: () => setState(() => _currentIndex = 1),
              ),
              _buildShortcutButton(
                icon: Icons.receipt_long,
                label: 'Riwayat',
                color: const Color(0xFFF59E0B),
                onTap: () => setState(() => _currentIndex = 2),
              ),
              _buildShortcutButton(
                icon: Icons.security,
                label: 'Ubah PIN',
                color: const Color(0xFF8B5CF6),
                onTap: () => setState(() => _currentIndex = 3),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildShortcutButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Color(0xFF334155),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMerchantCard(BuildContext context, Merchant merchant) {
    // Operations hours status color spec:
    // Buka: Hijau (#4CAF50), Tutup Sementara: Kuning (#FFC107), Tutup Hari Ini: Abu-abu (#9E9E9E)
    Color statusColor = const Color(0xFF4CAF50);
    String statusText = 'Buka';

    if (merchant.isTempClosed) {
      statusColor = const Color(0xFFFFC107);
      statusText = 'Tutup Sementara';
    } else if (!merchant.isOpen) {
      statusColor = const Color(0xFF9E9E9E);
      statusText = 'Tutup Hari Ini';
    }

    return Card(
      color: Colors.white,
      surfaceTintColor: Colors.white,
      elevation: 3,
      shadowColor: Colors.black.withOpacity(0.04),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: Colors.grey.shade100),
      ),
      margin: const EdgeInsets.only(bottom: 16.0),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () {
          // Open Katalog for selected merchant
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => SiswaMerchantKatalogScreen(merchantId: merchant.id),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: (merchant.id == 'M001' ? const Color(0xFFEF4444) : const Color(0xFF3B82F6)).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  merchant.id == 'M001' ? Icons.fastfood : Icons.menu_book,
                  color: merchant.id == 'M001' ? const Color(0xFFEF4444) : const Color(0xFF3B82F6),
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      merchant.name,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF0F172A)),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Kategori: ${merchant.category}',
                      style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Jam: ${merchant.startTime} - ${merchant.endTime}',
                      style: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8), fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ),
              // Status Badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: statusColor, width: 1),
                ),
                child: Text(
                  statusText,
                  style: TextStyle(
                    color: statusColor,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTransactionItem(TransactionModel tx) {
    Color typeColor = const Color(0xFF10B981);
    IconData typeIcon = Icons.add_circle;

    if (tx.type == 'Pembelian') {
      typeColor = const Color(0xFFEF4444);
      typeIcon = Icons.shopping_bag;
    }

    Color statusColor = const Color(0xFF9E9E9E);
    if (tx.status == 'Selesai') {
      statusColor = const Color(0xFF4CAF50);
    } else if (tx.status == 'Menunggu') {
      statusColor = const Color(0xFFFFC107);
    } else if (tx.status == 'Dibatalkan') {
      statusColor = const Color(0xFFF44336);
    }

    final formattedDate = "${tx.timestamp.day}/${tx.timestamp.month} ${tx.timestamp.hour.toString().padLeft(2, '0')}:${tx.timestamp.minute.toString().padLeft(2, '0')}";

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: typeColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(typeIcon, color: typeColor, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      tx.merchantName,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF0F172A)),
                    ),
                    Text(
                      tx.type == 'Pembelian' ? '- Rp ${tx.amount.toInt()}' : '+ Rp ${tx.amount.toInt()}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: tx.type == 'Pembelian' ? const Color(0xFFEF4444) : const Color(0xFF10B981),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        tx.itemsSummary,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                      ),
                    ),
                    Text(
                      formattedDate,
                      style: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8)),
                    ),
                  ],
                ),
                if (tx.hasAllergenWarning) ...[
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFFBEB),
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: const Color(0xFFFDE68A)),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.warning, color: Color(0xFFD97706), size: 10),
                        SizedBox(width: 4),
                        Text(
                          'Alergen Dilanjutkan',
                          style: TextStyle(color: Color(0xFFB45309), fontSize: 9, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 12),
          // Status Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              tx.status,
              style: TextStyle(color: statusColor, fontSize: 10, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
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
