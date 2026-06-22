import 'dart:async';
import 'package:flutter/material.dart';
import '../../state/app_state.dart';
import '../../state/app_state_provider.dart';
import '../../models/merchant.dart';
import '../../models/student.dart';
import '../../models/parent.dart';
import '../../models/transaction.dart';
import '../../models/voucher.dart';
import '../role_selection_screen.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  int _currentIndex = 0;

  // Controllers for Admin utilities
  final _merchantNameController = TextEditingController();
  final _merchantUsernameController = TextEditingController();
  final _merchantPasswordController = TextEditingController();
  final _merchantHoursStart = TextEditingController(text: '07:00');
  final _merchantHoursEnd = TextEditingController(text: '16:00');
  
  final _bulkImportController = TextEditingController(
    text: '200101,Ahmad Subarjo,X-IPS 1,35000\n'
         '200102,Rina Malasari,XI-IPA 2,75000\n'
         '200103,Doni Herdian,XII-IPS 3,5000'
  );

  final _topUpNisController = TextEditingController();
  final _topUpAmountController = TextEditingController();

  final _voucherCodeController = TextEditingController();
  final _voucherValueController = TextEditingController();
  final _voucherDescController = TextEditingController();

  String _voucherType = 'Subsidi'; // 'Subsidi', 'Diskon', 'Hadiah'
  String _merchantCategory = 'Makanan & Minuman'; // 'Makanan & Minuman', 'ATK & Perlengkapan'

  @override
  void dispose() {
    _merchantNameController.dispose();
    _merchantUsernameController.dispose();
    _merchantPasswordController.dispose();
    _merchantHoursStart.dispose();
    _merchantHoursEnd.dispose();
    _bulkImportController.dispose();
    _topUpNisController.dispose();
    _topUpAmountController.dispose();
    _voucherCodeController.dispose();
    _voucherValueController.dispose();
    _voucherDescController.dispose();
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
    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isMobile = screenWidth < 768;

    // Admin statistical counters
    double totalDeposits = 0.0;
    for (var s in appState.students) {
      totalDeposits += s.balance;
    }

    final linkedStudentsCount = appState.students.where((s) => s.isLinked).length;

    // Active pages
    final List<Widget> pages = [
      _buildHome(context, totalDeposits, linkedStudentsCount, appState),
      _buildMerchantAdminPage(context, appState),
      _buildSiswaAdminPage(context, appState),
      _buildTopUpManualPage(context, appState),
      _buildVoucherAdminPage(context, appState),
      _buildLaporanFinansialPage(context, appState),
    ];

    final List<String> pageTitles = [
      'Dashboard Administrator',
      'Kelola Merchant & Kantin',
      'Kelola Siswa & Ortu',
      'Top Up E-Wallet Manual',
      'Kelola Voucher & Subsidi',
      'Laporan Keuangan Sekolah'
    ];

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(
                color: Color(0xFF8B5CF6),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.admin_panel_settings, color: Colors.white, size: 16),
            ),
            const SizedBox(width: 10),
            Text(pageTitles[_currentIndex]),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.red),
            onPressed: () => _handleLogout(context),
          ),
        ],
      ),
      body: isMobile
          ? pages[_currentIndex]
          : Row(
              children: [
                // Desktop Drawer Sidebar navigation panel
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
                      Container(
                        padding: const EdgeInsets.all(24),
                        color: const Color(0xFF8B5CF6).withOpacity(0.04),
                        child: const Row(
                          children: [
                            CircleAvatar(
                              backgroundColor: Color(0xFF8B5CF6),
                              child: Icon(Icons.shield, color: Colors.white),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Admin Sekolah',
                                    style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                                  ),
                                  Text(
                                    'SekolahPRO Superuser',
                                    style: TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Divider(height: 1),
                      // Nav links
                      Expanded(
                        child: ListView(
                          padding: const EdgeInsets.all(12),
                          children: [
                            _buildSideNavItem(0, 'Beranda Admin', Icons.dashboard),
                            _buildSideNavItem(1, 'Manajemen Merchant', Icons.storefront),
                            _buildSideNavItem(2, 'Manajemen Siswa', Icons.people),
                            _buildSideNavItem(3, 'Top Up Manual', Icons.add_circle),
                            _buildSideNavItem(4, 'Manajemen Voucher', Icons.confirmation_num),
                            _buildSideNavItem(5, 'Laporan Finansial', Icons.analytics),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          children: [
                            const Text(
                              'SekolahPRO Admin v1.0',
                              style: TextStyle(fontSize: 10, color: Color(0xFF94A3B8)),
                            ),
                            const SizedBox(height: 8),
                            SizedBox(
                              width: double.infinity,
                              child: OutlinedButton.icon(
                                icon: const Icon(Icons.arrow_back, size: 14),
                                label: const Text('Keluar Dashboard'),
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
                // Main Content Pane
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
              selectedItemColor: const Color(0xFF8B5CF6),
              unselectedItemColor: const Color(0xFF64748B),
              showUnselectedLabels: true,
              type: BottomNavigationBarType.fixed,
              items: const [
                BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Admin'),
                BottomNavigationBarItem(icon: Icon(Icons.storefront), label: 'Merchant'),
                BottomNavigationBarItem(icon: Icon(Icons.people), label: 'Siswa'),
                BottomNavigationBarItem(icon: Icon(Icons.add_circle), label: 'Top Up'),
                BottomNavigationBarItem(icon: Icon(Icons.confirmation_num), label: 'Voucher'),
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
        selectedTileColor: const Color(0xFF8B5CF6).withOpacity(0.08),
        selectedColor: const Color(0xFF8B5CF6),
        leading: Icon(icon, color: isSelected ? const Color(0xFF8B5CF6) : const Color(0xFF64748B)),
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

  // --- TAB 1: ADMIN HOME VIEW ---
  Widget _buildHome(BuildContext context, double totalDeposits, int linkedStudentsCount, AppState appState) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Analitik Dompet & Merchant Terpusat',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
          ),
          const SizedBox(height: 16),
          // Admin Stats row
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'Akumulasi Deposit Sekolah',
                  'Rp ${totalDeposits.toInt().toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}',
                  Icons.account_balance,
                  const Color(0xFF8B5CF6),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatCard(
                  'Merchant & Kantin Aktif',
                  '${appState.merchants.length} Toko',
                  Icons.storefront,
                  const Color(0xFFF59E0B),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatCard(
                  'Siswa Terhubung Ortu',
                  '$linkedStudentsCount / ${appState.students.length} Siswa',
                  Icons.link,
                  const Color(0xFF10B981),
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
          // Info box about bulk actions
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
                const Text(
                  'Pemberitahuan Sistem Keamanan',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF1E293B)),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Sebagai administrator SekolahPRO, Anda memiliki kewenangan penuh untuk menyetel batas alergen siswa, mengatur linking code orang tua, melakukan top up saldo manual, menyetujui voucher subsidi gratis bantuan sekolah, dan memblokir sementara akun yang bermasalah.',
                  style: TextStyle(fontSize: 12, color: Color(0xFF64748B), height: 1.5),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String label, String val, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(fontSize: 11, color: Color(0xFF64748B))),
                const SizedBox(height: 2),
                Text(val, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF0F172A))),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- TAB 2: MERCHANTS ADMIN MANAGER ---
  Widget _buildMerchantAdminPage(BuildContext context, AppState appState) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Registrasi Merchant Baru', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ElevatedButton.icon(
                icon: const Icon(Icons.add),
                label: const Text('Daftarkan Toko Baru'),
                onPressed: () => _showAddMerchantDialog(context, appState),
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF8B5CF6), foregroundColor: Colors.white),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: appState.merchants.length,
            itemBuilder: (context, idx) {
              final merchant = appState.merchants[idx];
              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.grey.shade100)),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(merchant.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                        Text('Kategori: ${merchant.category} • Akun Kasir: ${merchant.username}', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                        Text('Jam Operasional: ${merchant.startTime} - ${merchant.endTime}', style: const TextStyle(fontSize: 11, color: Colors.grey)),
                      ],
                    ),
                    Row(
                      children: [
                        // Toggle temp close spec
                        Text(
                          merchant.isTempClosed ? 'TUTUP SEMENTARA' : 'AKTIF',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: merchant.isTempClosed ? Colors.amber.shade700 : Colors.green,
                          ),
                        ),
                        Switch(
                          value: !merchant.isTempClosed,
                          activeColor: Colors.green,
                          onChanged: (val) {
                            appState.toggleMerchantTempClosed(merchant.id, !val);
                            _showSnackBar('Status operasional ${merchant.name} berhasil diubah!', Colors.green);
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  void _showAddMerchantDialog(BuildContext context, AppState appState) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('Daftarkan Merchant Sekolah baru'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Nama Merchant / Kantin', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                TextField(controller: _merchantNameController, decoration: const InputDecoration(border: OutlineInputBorder())),
                const SizedBox(height: 12),
                
                const Text('Kategori Merchant', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(border: Border.all(color: Colors.grey), borderRadius: BorderRadius.circular(4)),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      isExpanded: true,
                      value: _merchantCategory,
                      items: const [
                        DropdownMenuItem(value: 'Makanan & Minuman', child: Text('Makanan & Minuman (Kantin)')),
                        DropdownMenuItem(value: 'ATK & Perlengkapan', child: Text('ATK & Perlengkapan (Koperasi)')),
                      ],
                      onChanged: (val) {
                        if (val != null) {
                          setState(() {
                            _merchantCategory = val;
                          });
                        }
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                const Text('Username Login Kasir', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                TextField(controller: _merchantUsernameController, decoration: const InputDecoration(border: OutlineInputBorder())),
                const SizedBox(height: 12),

                const Text('Password Kasir', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                TextField(controller: _merchantPasswordController, decoration: const InputDecoration(border: OutlineInputBorder())),
                const SizedBox(height: 12),

                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Jam Buka', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 4),
                          TextField(controller: _merchantHoursStart, decoration: const InputDecoration(border: OutlineInputBorder())),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Jam Tutup', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 4),
                          TextField(controller: _merchantHoursEnd, decoration: const InputDecoration(border: OutlineInputBorder())),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal')),
            ElevatedButton(
              onPressed: () {
                if (_merchantNameController.text.isEmpty ||
                    _merchantUsernameController.text.isEmpty ||
                    _merchantPasswordController.text.isEmpty) {
                  return;
                }
                
                appState.addOrUpdateMerchantAdmin(
                  name: _merchantNameController.text,
                  category: _merchantCategory,
                  username: _merchantUsernameController.text,
                  password: _merchantPasswordController.text,
                  startTime: _merchantHoursStart.text,
                  endTime: _merchantHoursEnd.text,
                );

                _merchantNameController.clear();
                _merchantUsernameController.clear();
                _merchantPasswordController.clear();
                Navigator.pop(context);
                _showSnackBar('Merchant baru berhasil didaftarkan!', Colors.green);
              },
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF8B5CF6), foregroundColor: Colors.white),
              child: const Text('Daftarkan Toko'),
            ),
          ],
        );
      },
    );
  }

  // --- TAB 3: SISWA ADMIN MANAGER (CSV BULK SIMULATOR, RESET PIN, LINK CODE REGEN) ---
  Widget _buildSiswaAdminPage(BuildContext context, AppState appState) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Bulk import panel simulator
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.grey.shade100)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.publish, color: Color(0xFF8B5CF6)),
                    SizedBox(width: 8),
                    Text('Import Bulk Siswa Baru (Simulasi CSV)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  ],
                ),
                const SizedBox(height: 8),
                const Text(
                  'Format: NIS, Nama Siswa, Kelas, Saldo Awal. Baris baru untuk memisahkan data.',
                  style: TextStyle(fontSize: 11, color: Colors.grey),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _bulkImportController,
                  maxLines: 4,
                  decoration: const InputDecoration(border: OutlineInputBorder(), hintText: 'NIS,Nama,Kelas,Saldo'),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      final count = appState.simulateBulkImport(_bulkImportController.text);
                      _showSnackBar('$count siswa berhasil diimport secara bulk!', Colors.green);
                    },
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF8B5CF6), foregroundColor: Colors.white),
                    child: const Text('Proses Bulk Import Siswa', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Student accounts list
          const Text('Kelola Akun Siswa Terdaftar', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 12),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: appState.students.length,
            itemBuilder: (context, idx) {
              final student = appState.students[idx];
              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.grey.shade100)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(student.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                            Text('NIS: ${student.nis} • Kelas: ${student.className} • Saldo: Rp ${student.balance.toInt()}', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                            Text('Link Ortu: ${student.isLinked ? "Terhubung" : "Belum terhubung"} (Kode: ${student.linkingCode})', style: const TextStyle(fontSize: 11, color: Colors.grey)),
                          ],
                        ),
                        // Reset PIN & Regen Linking Code Buttons
                        Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.lock_reset, color: Colors.amber, size: 22),
                              tooltip: 'Reset PIN Siswa',
                              onPressed: () {
                                appState.resetStudentPinByAdmin(student.nis, '123456');
                                _showSnackBar('PIN ${student.name} berhasil di-reset ke default 123456!', Colors.green);
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.autorenew, color: Colors.blue, size: 22),
                              tooltip: 'Regenerate Linking Code',
                              onPressed: () {
                                final newCode = appState.regenerateStudentLinkingCode(student.nis);
                                _showSnackBar('Kode linking ${student.name} baru: $newCode!', Colors.green);
                              },
                            ),
                            IconButton(
                              icon: Icon(
                                student.isBlocked ? Icons.block : Icons.check_circle_outline,
                                color: student.isBlocked ? Colors.red : Colors.green,
                                size: 22,
                              ),
                              tooltip: student.isBlocked ? 'Aktifkan Akun' : 'Nonaktifkan Akun',
                              onPressed: () {
                                appState.toggleStudentAccountStatus(student.nis, !student.isBlocked);
                                _showSnackBar(
                                  student.isBlocked
                                      ? 'Akun ${student.name} berhasil diaktifkan!'
                                      : 'Akun ${student.name} berhasil dinonaktifkan!',
                                  Colors.green,
                                );
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  // --- TAB 4: TOP UP MANUAL SALDO SISWA ---
  Widget _buildTopUpManualPage(BuildContext context, AppState appState) {
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
                      Icon(Icons.add_circle, color: Color(0xFF8B5CF6), size: 28),
                      SizedBox(width: 12),
                      Text('Top Up Saldo E-Wallet Manual', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Text('Gunakan halaman ini untuk melakukan pengisian saldo manual bagi siswa yang membayar tunai ke koperasi/sekolah.', style: TextStyle(fontSize: 13, color: Colors.grey, height: 1.4)),
                  const SizedBox(height: 24),
                  
                  const Text('Nomor Induk Siswa (NIS)', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 6),
                  TextField(controller: _topUpNisController, keyboardType: TextInputType.number, decoration: const InputDecoration(border: OutlineInputBorder(), hintText: 'Contoh: 123456')),
                  const SizedBox(height: 16),

                  const Text('Nominal Pengisian Saldo (Rp)', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 6),
                  TextField(controller: _topUpAmountController, keyboardType: TextInputType.number, decoration: const InputDecoration(border: OutlineInputBorder(), hintText: 'Contoh: 20000')),
                  const SizedBox(height: 24),

                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () {
                        if (_topUpNisController.text.isEmpty || _topUpAmountController.text.isEmpty) return;
                        
                        final double? amount = double.tryParse(_topUpAmountController.text);
                        if (amount == null) return;

                        try {
                          appState.topUpWallet(
                            studentNis: _topUpNisController.text.trim(),
                            amount: amount,
                            method: 'Manual',
                          );

                          _topUpNisController.clear();
                          _topUpAmountController.clear();
                          _showSnackBar('Top up manual berhasil dilakukan!', Colors.green);
                        } catch (e) {
                          _showSnackBar(e.toString().replaceFirst('Exception: ', ''), Colors.red);
                        }
                      },
                      style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF8B5CF6), foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                      child: const Text('Proses Top Up Saldo', style: TextStyle(fontWeight: FontWeight.bold)),
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

  // --- TAB 5: PUBLISH VOUCHERS ---
  Widget _buildVoucherAdminPage(BuildContext context, AppState appState) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Buat & Terbitkan Voucher Baru', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.grey.shade100)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Kode Voucher (KAPITAL)', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 4),
                          TextField(controller: _voucherCodeController, decoration: const InputDecoration(border: OutlineInputBorder(), hintText: 'Contoh: DISKON25')),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Tipe Voucher', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            decoration: BoxDecoration(border: Border.all(color: Colors.grey), borderRadius: BorderRadius.circular(4)),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                isExpanded: true,
                                value: _voucherType,
                                items: const [
                                  DropdownMenuItem(value: 'Subsidi', child: Text('Subsidi (Nominal Rp)')),
                                  DropdownMenuItem(value: 'Diskon', child: Text('Diskon (Potongan %)')),
                                  DropdownMenuItem(value: 'Hadiah', child: Text('Hadiah (Nominal Rp)')),
                                ],
                                onChanged: (val) {
                                  if (val != null) setState(() => _voucherType = val);
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Nilai (Nominal / Persentase)', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 4),
                          TextField(controller: _voucherValueController, keyboardType: TextInputType.number, decoration: const InputDecoration(border: OutlineInputBorder(), hintText: 'Contoh: 10000 atau 10')),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Deskripsi Voucher', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 4),
                          TextField(controller: _voucherDescController, decoration: const InputDecoration(border: OutlineInputBorder(), hintText: 'Contoh: Subsidi bantuan sekolah Rp 10.000')),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      if (_voucherCodeController.text.isEmpty ||
                          _voucherValueController.text.isEmpty ||
                          _voucherDescController.text.isEmpty) {
                        return;
                      }

                      final val = double.tryParse(_voucherValueController.text);
                      if (val == null) return;

                      appState.addVoucherAdmin(
                        code: _voucherCodeController.text.trim().toUpperCase(),
                        type: _voucherType,
                        value: val,
                        description: _voucherDescController.text,
                        expiryDays: 14, // default 2 weeks expiry
                      );

                      _voucherCodeController.clear();
                      _voucherValueController.clear();
                      _voucherDescController.clear();
                      _showSnackBar('Voucher baru berhasil diterbitkan!', Colors.green);
                    },
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF8B5CF6), foregroundColor: Colors.white),
                    child: const Text('Terbitkan Voucher & Bagikan ke Siswa', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Active vouchers listing
          const Text('Voucher Aktif Terdaftar', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 12),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: appState.vouchers.length,
            itemBuilder: (context, idx) {
              final v = appState.vouchers[idx];
              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.grey.shade100)),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('${v.code} (${v.type})', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                          Text(v.description, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                          Text('Berlaku Hingga: ${v.expiryDate.day}/${v.expiryDate.month}/${v.expiryDate.year}', style: const TextStyle(fontSize: 11, color: Colors.grey)),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () {
                        appState.toggleVoucherAdmin(v.code);
                        _showSnackBar('Voucher ${v.code} berhasil ditarik!', Colors.green);
                      },
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  // --- TAB 6: FINANCE TRANS TRANSACTION REPORT LIST ---
  Widget _buildLaporanFinansialPage(BuildContext context, AppState appState) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Seluruh Riwayat Transaksi Finansial', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              // Simulated reports exporter buttons
              Row(
                children: [
                  OutlinedButton.icon(
                    icon: const Icon(Icons.download, size: 14),
                    label: const Text('Export Excel/CSV', style: TextStyle(fontSize: 11)),
                    onPressed: () => _simulateExcelDownload(context),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.picture_as_pdf, size: 14),
                    label: const Text('Unduh Rekap PDF', style: TextStyle(fontSize: 11)),
                    onPressed: () => _simulatePdfReportDownload(context),
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF8B5CF6), foregroundColor: Colors.white),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: appState.transactions.isEmpty
                ? const Center(child: Text('Tidak ada logs transaksi terdaftar.'))
                : ListView.builder(
                    itemCount: appState.transactions.length,
                    itemBuilder: (context, index) {
                      final tx = appState.transactions[index];
                      final formattedDate = "${tx.timestamp.day}/${tx.timestamp.month}/${tx.timestamp.year} ${tx.timestamp.hour.toString().padLeft(2, '0')}:${tx.timestamp.minute.toString().padLeft(2, '0')}";
                      
                      Color typeColor = Colors.green;
                      if (tx.type == 'Pembelian') typeColor = Colors.red;

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
                                  Row(
                                    children: [
                                      Text('[${tx.type}] ', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: typeColor)),
                                      Text(tx.merchantName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                                    ],
                                  ),
                                  const SizedBox(height: 2),
                                  Text('Siswa: ${tx.studentName} (${tx.studentNis}) • ${tx.itemsSummary}', style: const TextStyle(fontSize: 11, color: Colors.grey)),
                                  const SizedBox(height: 2),
                                  Text('Status: ${tx.status} • $formattedDate', style: const TextStyle(fontSize: 10, color: Colors.grey)),
                                ],
                              ),
                            ),
                            Text(
                              tx.type == 'Pembelian' ? '- Rp ${tx.amount.toInt()}' : '+ Rp ${tx.amount.toInt()}',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: typeColor),
                            ),
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

  void _simulateExcelDownload(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const AlertDialog(
        content: Row(
          children: [
            CircularProgressIndicator(),
            SizedBox(width: 20),
            Text('Mengekspor rekap transaksi ke CSV...'),
          ],
        ),
      ),
    );
    Timer(const Duration(seconds: 1), () {
      Navigator.pop(context);
      _showSnackBar('File Laporan_Keuangan_Sekolah.csv berhasil diunduh!', Colors.green);
    });
  }

  void _simulatePdfReportDownload(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const AlertDialog(
        content: Row(
          children: [
            CircularProgressIndicator(),
            SizedBox(width: 20),
            Text('Mengekspor rekap finansial ke PDF...'),
          ],
        ),
      ),
    );
    Timer(const Duration(seconds: 1), () {
      Navigator.pop(context);
      _showSnackBar('Laporan_Tahunan_SekolahPRO.pdf berhasil diunduh!', Colors.green);
    });
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
