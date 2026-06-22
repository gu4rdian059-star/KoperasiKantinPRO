import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '../../state/app_state.dart';
import '../../state/app_state_provider.dart';
import '../../models/parent.dart';
import '../../models/student.dart';
import '../../models/transaction.dart';
import '../role_selection_screen.dart';
import '../siswa/siswa_topup_payment_screen.dart'; // import payment simulator for easy reuse!

class OrtuDashboard extends StatefulWidget {
  const OrtuDashboard({super.key});

  @override
  State<OrtuDashboard> createState() => _OrtuDashboardState();
}

class _OrtuDashboardState extends State<OrtuDashboard> {
  int _currentIndex = 0;
  String? _selectedNis; // currently viewed child's NIS
  
  // Forms & controls
  final _limitController = TextEditingController();
  final _linkChildController = TextEditingController();
  final _topUpAmountController = TextEditingController();

  // Selected method for top-up from parent portal
  String _selectedTopUpMethod = 'BCA VA';

  @override
  void dispose() {
    _limitController.dispose();
    _linkChildController.dispose();
    _topUpAmountController.dispose();
    super.dispose();
  }

  void _showSnackBar(String msg, Color bg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg, style: const TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: bg,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final appState = AppStateProvider.of(context);
    final Parent parent = appState.currentUser as Parent;
    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isMobile = screenWidth < 768;

    // Set initial child selection if not set
    if (_selectedNis == null && parent.linkedStudentNises.isNotEmpty) {
      _selectedNis = parent.linkedStudentNises.first;
    }

    // Get selected child data
    Student? activeChild;
    if (_selectedNis != null && appState.students.any((s) => s.nis == _selectedNis)) {
      activeChild = appState.students.firstWhere((s) => s.nis == _selectedNis);
    }

    // Active pages
    final List<Widget> pages = [
      _buildHome(context, parent, activeChild, appState),
      _buildAllergensPage(context, activeChild, appState),
      _buildNotificationsPage(context, parent, appState),
      _buildLinkingPage(context, parent, appState),
    ];

    final List<String> pageTitles = [
      'Dashboard Orang Tua',
      'Informasi Alergen Anak',
      'Pengaturan Notifikasi',
      'Hubungkan Akun Anak'
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
                color: Color(0xFF10B981),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.family_restroom, color: Colors.white, size: 16),
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
                // Desktop Sidebar drawer
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
                      // Parent Info Header
                      Container(
                        padding: const EdgeInsets.all(24),
                        color: const Color(0xFF10B981).withOpacity(0.04),
                        child: Row(
                          children: [
                            CircleAvatar(
                              backgroundColor: const Color(0xFF10B981),
                              child: Text(
                                parent.name[0],
                                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    parent.name,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF0F172A),
                                    ),
                                  ),
                                  Text(
                                    'Ortu • ${parent.phone}',
                                    style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Divider(height: 1),
                      // Nav Links
                      Expanded(
                        child: ListView(
                          padding: const EdgeInsets.all(12),
                          children: [
                            _buildSideNavItem(0, 'Dashboard Anak', Icons.family_restroom),
                            _buildSideNavItem(1, 'Kelola Alergen', Icons.warning_amber),
                            _buildSideNavItem(2, 'Konfigurasi Notifikasi', Icons.notifications_active),
                            _buildSideNavItem(3, 'Hubungkan Anak Baru', Icons.person_add),
                          ],
                        ),
                      ),
                      // Bottom version panel
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          children: [
                            const Text(
                              'SekolahPRO Parent v1.0',
                              style: TextStyle(fontSize: 10, color: Color(0xFF94A3B8)),
                            ),
                            const SizedBox(height: 8),
                            SizedBox(
                              width: double.infinity,
                              child: OutlinedButton.icon(
                                icon: const Icon(Icons.arrow_back, size: 14),
                                label: const Text('Ganti Akun Role'),
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
                // Dynamic page view container
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
              selectedItemColor: const Color(0xFF10B981),
              unselectedItemColor: const Color(0xFF64748B),
              showUnselectedLabels: true,
              type: BottomNavigationBarType.fixed,
              items: const [
                BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Dashboard'),
                BottomNavigationBarItem(icon: Icon(Icons.warning_amber), label: 'Alergen'),
                BottomNavigationBarItem(icon: Icon(Icons.notifications), label: 'Notifikasi'),
                BottomNavigationBarItem(icon: Icon(Icons.link), label: 'Hubungkan'),
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
        selectedTileColor: const Color(0xFF10B981).withOpacity(0.08),
        selectedColor: const Color(0xFF10B981),
        leading: Icon(icon, color: isSelected ? const Color(0xFF10B981) : const Color(0xFF64748B)),
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

  // --- TAB 1: PARENT MAIN DASHBOARD VIEW ---
  Widget _buildHome(BuildContext context, Parent parent, Student? activeChild, AppState appState) {
    if (parent.linkedStudentNises.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.link_off, size: 52, color: Color(0xFF94A3B8)),
              const SizedBox(height: 16),
              const Text(
                'Akun Anak Belum Terhubung',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
              ),
              const SizedBox(height: 8),
              const Text(
                'Anda harus menghubungkan akun siswa SekolahPRO milik anak Anda agar dapat mulai memantau pengeluaran.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Color(0xFF64748B), height: 1.4),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                icon: const Icon(Icons.person_add),
                label: const Text('Hubungkan Sekarang'),
                onPressed: () => setState(() => _currentIndex = 3),
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF10B981), foregroundColor: Colors.white),
              ),
            ],
          ),
        ),
      );
    }

    // Children list cards
    final List<Student> children = appState.students
        .where((s) => parent.linkedStudentNises.contains(s.nis))
        .toList();

    // Transactions log for selected child
    final childTxs = appState.transactions
        .where((tx) => tx.studentNis == activeChild?.nis)
        .toList();

    // Specific notifications for parent phone
    final parentNotifs = appState.systemNotifications
        .where((n) => n['parentPhone'] == parent.phone)
        .toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Row containing Child Cards slider
          const Text(
            'Kartu Akun Anak Anda',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 180,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: children.length,
              itemBuilder: (context, idx) {
                final child = children[idx];
                final isSelected = child.nis == _selectedNis;
                
                // Color alert per child balance
                Color bColor = const Color(0xFF4CAF50);
                if (child.balance < 5000.0) {
                  bColor = const Color(0xFFF44336);
                } else if (child.balance <= 20000.0) {
                  bColor = const Color(0xFFFFC107);
                }

                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedNis = child.nis;
                    });
                  },
                  child: Container(
                    width: 280,
                    margin: const EdgeInsets.only(right: 16.0, bottom: 8),
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: isSelected
                          ? const LinearGradient(
                              colors: [Color(0xFF047857), Color(0xFF065F46)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            )
                          : null,
                      color: isSelected ? null : Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isSelected ? Colors.transparent : Colors.grey.shade200,
                        width: 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: isSelected
                              ? const Color(0xFF059669).withOpacity(0.2)
                              : Colors.black.withOpacity(0.02),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              child.name,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: isSelected ? Colors.white : const Color(0xFF0F172A),
                              ),
                            ),
                            if (isSelected)
                              const Icon(Icons.check_circle, color: Colors.white, size: 18)
                          ],
                        ),
                        Text(
                          'Kelas: ${child.className} • NIS ${child.nis}',
                          style: TextStyle(
                            fontSize: 11,
                            color: isSelected ? const Color(0xFFA7F3D0) : const Color(0xFF64748B),
                          ),
                        ),
                        const Spacer(),
                        const Text(
                          'SALDO E-WALLET',
                          style: TextStyle(fontSize: 9, color: Color(0xFF94A3B8), fontWeight: FontWeight.bold, letterSpacing: 0.5),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Rp ${child.balance.toInt().toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: isSelected ? Colors.white : const Color(0xFF1E293B),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: bColor.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: bColor, width: 1),
                              ),
                              child: Text(
                                child.balance < 5000.0 ? 'Rendah' : 'Cukup',
                                style: TextStyle(color: bColor, fontSize: 9, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 24),

          // Child limit adjustment card & Quick Top Up Linker
          if (activeChild != null) ...[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Spending cap panel
                Expanded(
                  flex: 1,
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.grey.shade100),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.dashboard_customize, color: Color(0xFF10B981), size: 20),
                            SizedBox(width: 8),
                            Text(
                              'Batas Pengeluaran Harian',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          activeChild.dailySpendingLimit > 0.0
                              ? 'Batas Aktif: Rp ${activeChild.dailySpendingLimit.toInt()} / Hari\n(Tersisa Hari ini: Rp ${activeChild.remainderDailyLimit.toInt()})'
                              : 'Status: Tanpa Batasan (Bebas belanja)',
                          style: const TextStyle(fontSize: 12, color: Color(0xFF475569), height: 1.4),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _limitController,
                                keyboardType: TextInputType.number,
                                decoration: const InputDecoration(
                                  hintText: 'Ubah Limit (Rp)',
                                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                  border: OutlineInputBorder(),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            ElevatedButton(
                              onPressed: () {
                                final double? lim = double.tryParse(_limitController.text);
                                if (lim != null) {
                                  appState.updateChildSpendingLimit(activeChild!.nis, lim);
                                  _limitController.clear();
                                  _showSnackBar('Batas harian ${activeChild.name} diperbarui!', Colors.green);
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                backgroundColor: const Color(0xFF10B981),
                                foregroundColor: Colors.white,
                              ),
                              child: const Text('Ubah'),
                            ),
                          ],
                        ),
                        if (activeChild.dailySpendingLimit > 0.0) ...[
                          const SizedBox(height: 8),
                          TextButton(
                            onPressed: () {
                              appState.updateChildSpendingLimit(activeChild!.nis, 0.0);
                              _showSnackBar('Batasan belanja dinonaktifkan!', Colors.green);
                            },
                            child: const Text('Hapus Batasan Harian', style: TextStyle(color: Colors.red, fontSize: 12)),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                // Rapid Top Up widget
                Expanded(
                  flex: 1,
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.grey.shade100),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.add_circle, color: Color(0xFF10B981), size: 20),
                            SizedBox(width: 8),
                            Text(
                              'Top Up Cepat Saldo Anak',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _topUpAmountController,
                                keyboardType: TextInputType.number,
                                decoration: const InputDecoration(
                                  hintText: 'Nominal Saldo (Rp)',
                                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                  border: OutlineInputBorder(),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            ElevatedButton(
                              onPressed: () {
                                final double? amount = double.tryParse(_topUpAmountController.text);
                                if (amount == null || amount < 10000.0) {
                                  _showSnackBar('Nominal minimal adalah Rp 10.000', Colors.red);
                                  return;
                                }
                                if (activeChild!.balance + amount > 500000.0) {
                                  _showSnackBar('Maksimal limit saldo anak terlampaui (Rp 500k)!', Colors.red);
                                  return;
                                }
                                
                                // Open payment simulator gateway directly from parent view
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => SiswaTopupPaymentScreen(
                                      studentNis: activeChild!.nis,
                                      amount: amount,
                                      method: _selectedTopUpMethod,
                                    ),
                                  ),
                                );
                                _topUpAmountController.clear();
                              },
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                backgroundColor: const Color(0xFF10B981),
                                foregroundColor: Colors.white,
                              ),
                              child: const Text('Top Up'),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        // Dropdown choice
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade300), borderRadius: BorderRadius.circular(6)),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: _selectedTopUpMethod,
                              items: const [
                                DropdownMenuItem(value: 'BCA VA', child: Text('BCA Virtual Account', style: TextStyle(fontSize: 11))),
                                DropdownMenuItem(value: 'QRIS', child: Text('QRIS Instant Pay', style: TextStyle(fontSize: 11))),
                                DropdownMenuItem(value: 'Alfamart', child: Text('Alfamart Store', style: TextStyle(fontSize: 11))),
                              ],
                              onChanged: (val) {
                                if (val != null) setState(() => _selectedTopUpMethod = val);
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],

          const SizedBox(height: 32),

          // Double panel layout: Transactions logs and Simulated SMS Alerts notifications
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Transactions
              Expanded(
                flex: 6,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Riwayat Transaksi Belanja Anak',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFF0F172A)),
                        ),
                        // Simulated PDF Export
                        ElevatedButton.icon(
                          icon: const Icon(Icons.picture_as_pdf, size: 14),
                          label: const Text('Unduh PDF', style: TextStyle(fontSize: 11)),
                          onPressed: () => _simulatePdfDownload(context, activeChild),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF10B981),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    if (childTxs.isEmpty)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.grey.shade100),
                        ),
                        child: const Center(
                          child: Text('Belum ada transaksi belanja siswa.', style: TextStyle(color: Colors.grey)),
                        ),
                      )
                    else
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: childTxs.length,
                        itemBuilder: (context, index) {
                          final tx = childTxs[index];
                          return _buildTransactionItemRow(tx);
                        },
                      ),
                  ],
                ),
              ),

              const SizedBox(width: 20),

              // Simulated SMS Alert / Notifs
              Expanded(
                flex: 5,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Pusat Notifikasi & Alert [WhatsApp/SMS]',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFF0F172A)),
                    ),
                    const SizedBox(height: 12),
                    if (parentNotifs.isEmpty)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.grey.shade100),
                        ),
                        child: const Center(
                          child: Text('Belum ada WhatsApp alert terbaru.', style: TextStyle(color: Colors.grey)),
                        ),
                      )
                    else
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: parentNotifs.length,
                        itemBuilder: (context, idx) {
                          final notif = parentNotifs[idx];
                          return _buildNotificationBox(notif);
                        },
                      ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionItemRow(TransactionModel tx) {
    Color typeColor = const Color(0xFF10B981);
    IconData typeIcon = Icons.add_circle;

    if (tx.type == 'Pembelian') {
      typeColor = const Color(0xFFEF4444);
      typeIcon = Icons.shopping_bag;
    }

    final formattedDate = "${tx.timestamp.day}/${tx.timestamp.month} ${tx.timestamp.hour.toString().padLeft(2, '0')}:${tx.timestamp.minute.toString().padLeft(2, '0')}";

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Row(
        children: [
          Icon(typeIcon, color: typeColor, size: 18),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(tx.merchantName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                    Text(
                      tx.type == 'Pembelian' ? '- Rp ${tx.amount.toInt()}' : '+ Rp ${tx.amount.toInt()}',
                      style: TextStyle(fontWeight: FontWeight.bold, color: tx.type == 'Pembelian' ? Colors.red : Colors.green),
                    ),
                  ],
                ),
                Text(tx.itemsSummary, style: const TextStyle(fontSize: 11, color: Colors.grey), maxLines: 1, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 2),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(formattedDate, style: const TextStyle(fontSize: 10, color: Colors.grey)),
                    if (tx.hasAllergenWarning)
                      const Text(
                        '⚠️ ALERT ALERGEN',
                        style: TextStyle(color: Colors.red, fontSize: 9, fontWeight: FontWeight.bold),
                      )
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationBox(Map<String, dynamic> notif) {
    Color bg = const Color(0xFFF1F5F9);
    IconData icon = Icons.notifications;
    Color iconColor = const Color(0xFF64748B);

    if (notif['type'] == 'alergen') {
      bg = const Color(0xFFFEF2F2);
      icon = Icons.warning_amber;
      iconColor = const Color(0xFFEF4444);
    } else if (notif['type'] == 'saldo_rendah') {
      bg = const Color(0xFFFFFBEB);
      icon = Icons.trending_down;
      iconColor = const Color(0xFFF59E0B);
    } else if (notif['type'] == 'topup') {
      bg = const Color(0xFFECFDF5);
      icon = Icons.done_all;
      iconColor = const Color(0xFF10B981);
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: iconColor.withOpacity(0.1)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: iconColor, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  notif['title'] ?? 'Notifikasi Alert',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: iconColor),
                ),
                const SizedBox(height: 4),
                Text(
                  notif['body'] ?? '',
                  style: const TextStyle(fontSize: 11, color: Color(0xFF334155), height: 1.4),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _simulatePdfDownload(BuildContext context, Student? activeChild) {
    if (activeChild == null) return;
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(
            children: [
              const Icon(Icons.picture_as_pdf, color: Colors.red),
              const SizedBox(width: 8),
              Text('Export Laporan ${activeChild.name}'),
            ],
          ),
          content: const Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Sedang merender data transaksi ke format PDF...'),
            ],
          ),
        );
      },
    );

    Timer(const Duration(seconds: 2), () {
      Navigator.pop(context); // close progress dialog
      _showSnackBar('Laporan riwayat transaksi ${activeChild.name}.pdf berhasil diunduh!', Colors.green);
    });
  }

  // --- TAB 2: ALLERGENS PROFILING CHECKBOXES ---
  Widget _buildAllergensPage(BuildContext context, Student? activeChild, AppState appState) {
    if (activeChild == null) return const Center(child: Text('Data siswa tidak ditemukan.'));

    final Map<String, String> allergenOptions = {
      'SF': 'Seafood (ikan, udang, cumi) 🦐',
      'ML': 'Susu & Produk Olahan Susu 🥛',
      'EG': 'Telur 🥚',
      'NT': 'Kacang-kacangan (tanah, almond, dll) 🥜',
      'GL': 'Gluten / Tepung Terigu 🌾',
      'SY': 'Kedelai & Olahannya (tahu/tempe) 🫘',
      'CH': 'Cabai / Pedas Berlebih 🌶️',
    };

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: const Color(0xFFFFFBEB), borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFFFDE68A))),
            child: Row(
              children: [
                const Icon(Icons.info, color: Color(0xFFD97706)),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Daftarkan alergi makan ${activeChild.name} di bawah ini. Aplikasi akan secara otomatis memperingatkan anak dengan pop-up konfirmasi jika mereka membeli produk Kantin yang mengandung bahan-bahan tersebut.',
                    style: const TextStyle(fontSize: 12, color: Color(0xFFB45309), height: 1.4),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Card(
            color: Colors.white,
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Riwayat Alergi Terdaftar untuk ${activeChild.name}',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  const SizedBox(height: 16),
                  ...allergenOptions.keys.map((code) {
                    final isChecked = activeChild!.allergens.contains(code);
                    return CheckboxListTile(
                      activeColor: const Color(0xFF10B981),
                      title: Text(allergenOptions[code]!, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                      value: isChecked,
                      onChanged: (val) {
                        final currentList = List<String>.from(activeChild!.allergens);
                        if (val == true) {
                          currentList.add(code);
                        } else {
                          currentList.remove(code);
                        }
                        appState.updateChildAllergens(activeChild.nis, currentList);
                        _showSnackBar('Profil alergen ${activeChild.name} diperbarui!', Colors.green);
                        setState(() {});
                      },
                    );
                  }),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- TAB 3: NOTIFICATIONS SPEC FLAGS ---
  Widget _buildNotificationsPage(BuildContext context, Parent parent, AppState appState) {
    final notifSettings = parent.notificationSettings;
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Konfigurasi Pengiriman Alert WhatsApp / Push Notif',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
          ),
          const SizedBox(height: 6),
          const Text('Atur notifikasi mana yang ingin Anda terima ke perangkat Anda secara realtime.', style: TextStyle(fontSize: 12, color: Colors.grey)),
          const SizedBox(height: 20),
          Card(
            color: Colors.white,
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  _buildNotifToggleRow(
                    context,
                    parent.phone,
                    'Setiap transaksi belanja anak',
                    'Mengirim rincian nama item belanja, merchant, dan sisa saldo seketika setelah anak jajan.',
                    'transaksi',
                    notifSettings['transaksi'] ?? true,
                    appState,
                  ),
                  const Divider(),
                  _buildNotifToggleRow(
                    context,
                    parent.phone,
                    'Peringatan saldo rendah',
                    'Mengirim notifikasi ketika dompet e-wallet anak bersaldo di bawah Rp 5.000.',
                    'saldo_rendah',
                    notifSettings['saldo_rendah'] ?? true,
                    appState,
                  ),
                  const Divider(),
                  _buildNotifToggleRow(
                    context,
                    parent.phone,
                    'Peringatan makanan alergen',
                    'CRITICAL ALERT: Mengirim peringatan jika anak memotong bypass dialog peringatan menu alergen.',
                    'alergen',
                    notifSettings['alergen'] ?? true,
                    appState,
                  ),
                  const Divider(),
                  _buildNotifToggleRow(
                    context,
                    parent.phone,
                    'Laporan rekap mingguan',
                    'Mengirim rangkuman total spending & breakdown merchant anak setiap Jumat jam 17:00.',
                    'rekap',
                    notifSettings['rekap'] ?? true,
                    appState,
                  ),
                  const Divider(),
                  _buildNotifToggleRow(
                    context,
                    parent.phone,
                    'Konfirmasi Top Up Sukses',
                    'Mengirim notifikasi konfirmasi setelah parent/siswa mengisi saldo SekolahPRO.',
                    'topup',
                    notifSettings['topup'] ?? true,
                    appState,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotifToggleRow(
    BuildContext context,
    String phone,
    String title,
    String desc,
    String settingKey,
    bool isEnabled,
    AppState appState,
  ) {
    return SwitchListTile(
      activeColor: const Color(0xFF10B981),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
      subtitle: Text(desc, style: const TextStyle(fontSize: 11, color: Colors.grey)),
      value: isEnabled,
      onChanged: (val) {
        appState.updateParentNotificationSetting(phone, settingKey, val);
        _showSnackBar('Konfigurasi notifikasi berhasil diubah!', Colors.green);
        setState(() {});
      },
    );
  }

  // --- TAB 4: BULK LINKING NEW CHILDREN ---
  Widget _buildLinkingPage(BuildContext context, Parent parent, AppState appState) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: SizedBox(
          width: 500,
          child: Card(
            elevation: 3,
            color: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.person_add, color: Color(0xFF10B981), size: 28),
                      SizedBox(width: 12),
                      Text(
                        'Hubungkan Profil Anak',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Anda dapat memantau hingga maksimal 5 akun anak dalam satu dashboard Orang Tua.',
                    style: TextStyle(fontSize: 13, color: Color(0xFF64748B), height: 1.4),
                  ),
                  const SizedBox(height: 24),
                  const Text('Masukkan Kode Linking Anak', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _linkChildController,
                    decoration: InputDecoration(
                      hintText: 'Contoh: BUDI123 atau SITI321',
                      prefixIcon: const Icon(Icons.link),
                      contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () {
                        if (_linkChildController.text.isEmpty) return;
                        try {
                          appState.linkChildAccount(parent.phone, _linkChildController.text.trim());
                          _showSnackBar('Akun anak berhasil ditambahkan!', Colors.green);
                          setState(() {
                            _currentIndex = 0;
                            _selectedNis = parent.linkedStudentNises.last;
                          });
                          _linkChildController.clear();
                        } catch (e) {
                          _showSnackBar(e.toString().replaceFirst('Exception: ', ''), Colors.red);
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF10B981),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text('Hubungkan Sekarang', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
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
