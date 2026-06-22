import 'package:flutter/material.dart';
import '../state/app_state_provider.dart';
import 'login_screen.dart';

class RoleSelectionScreen extends StatefulWidget {
  const RoleSelectionScreen({super.key});

  @override
  State<RoleSelectionScreen> createState() => _RoleSelectionScreenState();
}

class _RoleSelectionScreenState extends State<RoleSelectionScreen> {
  @override
  Widget build(BuildContext context) {
    final appState = AppStateProvider.of(context);
    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isMobile = screenWidth < 768;

    // Show loading spinner while Supabase initializes
    if (appState.isLoading) {
      return Scaffold(
        body: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFFEEF2F6), Color(0xFFE2E8F0)],
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFF1A56DB),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(Icons.account_balance_wallet, color: Colors.white, size: 32),
              ),
              const SizedBox(height: 32),
              const CircularProgressIndicator(
                color: Color(0xFF1A56DB),
                strokeWidth: 3,
              ),
              const SizedBox(height: 24),
              const Text(
                'SekolahPRO',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Menghubungkan ke server...',
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF475569),
                ),
              ),
              if (appState.loadingError != null) ...[
                const SizedBox(height: 16),
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 32),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEF3C7),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFFF59E0B)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.wifi_off, color: Color(0xFFF59E0B), size: 16),
                      const SizedBox(width: 8),
                      Text(
                        appState.loadingError!,
                        style: const TextStyle(
                          color: Color(0xFF92400E),
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      );
    }


    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFEEF2F6),
              Color(0xFFE2E8F0),
            ],
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 48.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 40),
              // Brand Logo
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1A56DB),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF1A56DB).withOpacity(0.3),
                          blurRadius: 15,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.account_balance_wallet,
                      color: Colors.white,
                      size: 32,
                    ),
                  ),
                  const SizedBox(width: 16),
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'SekolahPRO',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1E293B),
                          letterSpacing: 0.5,
                        ),
                      ),
                      Text(
                        'Digital Payment & Monitoring',
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(0xFF64748B),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 48),
              const Text(
                'Selamat Datang',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Silakan pilih tipe akun Anda untuk melanjutkan masuk ke sistem',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Color(0xFF475569),
                ),
              ),
              const SizedBox(height: 48),
              // Grid of roles
              isMobile
                  ? Column(
                      children: _buildRoleCards(context),
                    )
                  : SizedBox(
                      width: 1000,
                      child: GridView.count(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisCount: 2,
                        crossAxisSpacing: 24,
                        mainAxisSpacing: 24,
                        childAspectRatio: 2.2,
                        children: _buildRoleCards(context),
                      ),
                    ),
              const SizedBox(height: 60),
              // Footer
              const Text(
                'SekolahPRO © 2026. All Rights Reserved.',
                style: TextStyle(
                  fontSize: 12,
                  color: Color(0xFF94A3B8),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildRoleCards(BuildContext context) {
    return [
      _RoleCard(
        title: 'Siswa / Pelajar',
        description: 'Beli makanan kantin, ATK koperasi dengan saldo SekolahPRO & cek voucher diskon.',
        icon: Icons.school,
        color: const Color(0xFF1A56DB),
        onTap: () => _navigateToLogin(context, 'siswa'),
      ),
      _RoleCard(
        title: 'Orang Tua Wali',
        description: 'Pantau pengeluaran anak, isi saldo e-wallet anak, & kelola batas pengeluaran alergi.',
        icon: Icons.family_restroom,
        color: const Color(0xFF10B981),
        onTap: () => _navigateToLogin(context, 'ortu'),
      ),
      _RoleCard(
        title: 'Merchant / Kasir',
        description: 'Dashboard penjualan kantin/koperasi, update stok produk realtime, & scan token transaksi.',
        icon: Icons.storefront,
        color: const Color(0xFFF59E0B),
        onTap: () => _navigateToLogin(context, 'merchant'),
      ),
      _RoleCard(
        title: 'Admin Sekolah',
        description: 'Kelola pendaftaran merchant, voucher subsidi, export laporan, & manajemen PIN siswa.',
        icon: Icons.admin_panel_settings,
        color: const Color(0xFF8B5CF6),
        onTap: () => _navigateToLogin(context, 'admin'),
      ),
    ];
  }

  void _navigateToLogin(BuildContext context, String role) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => LoginScreen(role: role),
      ),
    );
  }
}

class _RoleCard extends StatefulWidget {
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _RoleCard({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  State<_RoleCard> createState() => _RoleCardState();
}

class _RoleCardState extends State<_RoleCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.only(bottom: 16.0),
          padding: const EdgeInsets.all(24.0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: _isHovered ? widget.color.withOpacity(0.5) : Colors.transparent,
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: _isHovered
                    ? widget.color.withOpacity(0.15)
                    : Colors.black.withOpacity(0.04),
                blurRadius: _isHovered ? 20 : 10,
                offset: _isHovered ? const Offset(0, 10) : const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Icon Container
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: widget.color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  widget.icon,
                  color: widget.color,
                  size: 32,
                ),
              ),
              const SizedBox(width: 20),
              // Text Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      widget.title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      widget.description,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF64748B),
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                Icons.arrow_forward_ios,
                color: widget.color.withOpacity(0.8),
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
