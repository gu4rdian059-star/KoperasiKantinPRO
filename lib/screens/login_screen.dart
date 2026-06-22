import 'package:flutter/material.dart';
import '../../state/app_state_provider.dart';
import 'siswa/siswa_dashboard.dart';
import 'ortu/ortu_dashboard.dart';
import 'merchant/merchant_dashboard.dart';
import 'admin/admin_dashboard.dart';

class LoginScreen extends StatefulWidget {
  final String role;

  const LoginScreen({super.key, required this.role});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // Common Form controllers
  final _formKey = GlobalKey<FormState>();
  final _field1Controller = TextEditingController(); // NIS / Phone / Username / Admin Username
  final _field2Controller = TextEditingController(); // PIN / Password / Password / Admin Password
  
  // Parent Registration specific
  bool _isParentRegister = false;
  final _nameController = TextEditingController();
  final _linkingCodeController = TextEditingController();

  bool _obscureText = true;
  String? _errorMessage;
  bool _isLoading = false;

  @override
  void dispose() {
    _field1Controller.dispose();
    _field2Controller.dispose();
    _nameController.dispose();
    _linkingCodeController.dispose();
    super.dispose();
  }

  void _clearError() {
    if (_errorMessage != null) {
      setState(() {
        _errorMessage = null;
      });
    }
  }

  bool _isSubmitButtonActive() {
    if (_isParentRegister) {
      return _field1Controller.text.isNotEmpty &&
          _field2Controller.text.isNotEmpty &&
          _nameController.text.isNotEmpty &&
          _linkingCodeController.text.isNotEmpty;
    }
    return _field1Controller.text.isNotEmpty && _field2Controller.text.isNotEmpty;
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    // Short simulated delay to simulate 100% responsiveness and backend call
    await Future.delayed(const Duration(milliseconds: 600));

    final appState = AppStateProvider.of(context);

    try {
      if (widget.role == 'siswa') {
        await appState.loginSiswa(_field1Controller.text, _field2Controller.text);
        if (mounted) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const SiswaDashboard()),
            (route) => false,
          );
        }
      } else if (widget.role == 'ortu') {
        if (_isParentRegister) {
          appState.registerParent(
            _field1Controller.text,
            _nameController.text,
            _field2Controller.text,
            _linkingCodeController.text,
          );
          if (mounted) {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => const OrtuDashboard()),
              (route) => false,
            );
          }
        } else {
          await appState.loginParent(_field1Controller.text, _field2Controller.text);
          if (mounted) {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => const OrtuDashboard()),
              (route) => false,
            );
          }
        }
      } else if (widget.role == 'merchant') {
        await appState.loginMerchant(_field1Controller.text, _field2Controller.text);
        if (mounted) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const MerchantDashboard()),
            (route) => false,
          );
        }
      } else if (widget.role == 'admin') {
        appState.loginAdmin(_field1Controller.text, _field2Controller.text);
        if (mounted) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const AdminDashboard()),
            (route) => false,
          );
        }
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().replaceFirst('Exception: ', '');
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isMobile = screenWidth < 768;

    String titleText = 'Selamat Datang';
    String subtitleText = 'Masuk ke Portal SekolahPRO';
    IconData headerIcon = Icons.lock_open;
    Color primaryColor = const Color(0xFF1A56DB);

    if (widget.role == 'siswa') {
      titleText = 'Portal Siswa';
      subtitleText = 'Masuk dengan NIS & PIN Anda';
      headerIcon = Icons.school;
      primaryColor = const Color(0xFF1A56DB);
    } else if (widget.role == 'ortu') {
      primaryColor = const Color(0xFF10B981);
      if (_isParentRegister) {
        titleText = 'Registrasi Orang Tua';
        subtitleText = 'Hubungkan akun dengan profil anak';
        headerIcon = Icons.person_add;
      } else {
        titleText = 'Portal Orang Tua';
        subtitleText = 'Masuk dengan Nomor HP & Kata Sandi';
        headerIcon = Icons.family_restroom;
      }
    } else if (widget.role == 'merchant') {
      titleText = 'Portal Kasir Merchant';
      subtitleText = 'Kelola produk & scan token belanja';
      headerIcon = Icons.storefront;
      primaryColor = const Color(0xFFF59E0B);
    } else if (widget.role == 'admin') {
      titleText = 'Portal Administrator';
      subtitleText = 'Akses kontrol penuh SekolahPRO';
      headerIcon = Icons.admin_panel_settings;
      primaryColor = const Color(0xFF8B5CF6);
    }

    Widget loginCardContent = Form(
      key: _formKey,
      onChanged: () => setState(() {}),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header Logo and Titles
          Center(
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: primaryColor.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    headerIcon,
                    color: primaryColor,
                    size: 40,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  titleText,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  subtitleText,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Custom High-Fidelity Error Box (Red alerts, warning icons as in Figma Login Error Merchant)
          if (_errorMessage != null) ...[
            Container(
              padding: const EdgeInsets.all(16),
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: const Color(0xFFFEF2F2),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFFCA5A5), width: 1),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.error_outline,
                    color: Color(0xFFEF4444),
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Login Gagal',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF991B1B),
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _errorMessage!,
                          style: const TextStyle(
                            color: Color(0xFFB91C1C),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, size: 16, color: Color(0xFF991B1B)),
                    onPressed: _clearError,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
            ),
          ],

          // Parent Register Extra Fields: Full Name
          if (widget.role == 'ortu' && _isParentRegister) ...[
            const Text(
              'Nama Lengkap',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF334155),
              ),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _nameController,
              decoration: InputDecoration(
                hintText: 'Masukkan nama lengkap Anda',
                prefixIcon: const Icon(Icons.person, size: 20),
                contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],

          // Field 1: NIS / Phone / Username
          Text(
            widget.role == 'siswa'
                ? 'Nomor Induk Siswa (NIS)'
                : widget.role == 'ortu'
                    ? 'Nomor WhatsApp / HP'
                    : 'Nama Pengguna (Username)',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF334155),
            ),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: _field1Controller,
            keyboardType: (widget.role == 'siswa' || widget.role == 'ortu')
                ? TextInputType.number
                : TextInputType.text,
            decoration: InputDecoration(
              hintText: widget.role == 'siswa'
                  ? 'Contoh: 123456'
                  : widget.role == 'ortu'
                      ? 'Contoh: 08123456789'
                      : 'Masukkan username',
              prefixIcon: Icon(
                widget.role == 'siswa'
                    ? Icons.badge
                    : widget.role == 'ortu'
                        ? Icons.phone
                        : Icons.account_circle,
                size: 20,
              ),
              contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Field 2: PIN / Password
          Text(
            widget.role == 'siswa' ? 'PIN Transaksi (6 digit)' : 'Kata Sandi (Password)',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF334155),
            ),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: _field2Controller,
            obscureText: _obscureText,
            keyboardType: widget.role == 'siswa' ? TextInputType.number : TextInputType.text,
            maxLength: widget.role == 'siswa' ? 6 : null,
            decoration: InputDecoration(
              counterText: '',
              hintText: widget.role == 'siswa' ? 'Masukkan 6 digit PIN' : 'Masukkan password',
              prefixIcon: const Icon(Icons.lock, size: 20),
              suffixIcon: IconButton(
                icon: Icon(
                  _obscureText ? Icons.visibility_off : Icons.visibility,
                  size: 20,
                  color: const Color(0xFF64748B),
                ),
                onPressed: () => setState(() => _obscureText = !_obscureText),
              ),
              contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Parent Register Extra Fields: Link Child Code
          if (widget.role == 'ortu' && _isParentRegister) ...[
            const Text(
              'Kode Linking Anak',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF334155),
              ),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _linkingCodeController,
              decoration: InputDecoration(
                hintText: 'Contoh: BUDI123 (Minta ke anak/admin)',
                prefixIcon: const Icon(Icons.link, size: 20),
                contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],

          // Login/Submit button: triggers active only if valid
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: (_isSubmitButtonActive() && !_isLoading) ? _handleLogin : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                disabledBackgroundColor: const Color(0xFFE2E8F0),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: _isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                    )
                  : Text(
                      _isParentRegister ? 'Daftar Sekarang' : 'Masuk Sekarang',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: _isSubmitButtonActive() ? Colors.white : const Color(0xFF94A3B8),
                      ),
                    ),
            ),
          ),
          const SizedBox(height: 16),

          // Toggle Parent Registration or Role selection return
          if (widget.role == 'ortu') ...[
            Center(
              child: TextButton(
                onPressed: () {
                  setState(() {
                    _isParentRegister = !_isParentRegister;
                    _errorMessage = null;
                    _field1Controller.clear();
                    _field2Controller.clear();
                    _nameController.clear();
                    _linkingCodeController.clear();
                  });
                },
                child: Text(
                  _isParentRegister
                      ? 'Sudah punya akun? Masuk di sini'
                      : 'Belum terdaftar? Registrasi Orang Tua Baru',
                  style: TextStyle(
                    color: primaryColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
          Center(
            child: TextButton.icon(
              icon: const Icon(Icons.arrow_back, size: 16),
              label: const Text('Kembali ke Pilih Role'),
              onPressed: () => Navigator.pop(context),
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFF64748B),
              ),
            ),
          ),
        ],
      ),
    );

    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: isMobile
              ? Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 15,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: loginCardContent,
                )
              : SizedBox(
                  width: 500,
                  child: Card(
                    elevation: 8,
                    shadowColor: Colors.black.withOpacity(0.1),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                    color: Colors.white,
                    child: Padding(
                      padding: const EdgeInsets.all(40.0),
                      child: loginCardContent,
                    ),
                  ),
                ),
        ),
      ),
    );
  }
}
