import 'package:flutter/material.dart';
import '../../state/app_state_provider.dart';
import '../../models/student.dart';

class SiswaSettingsPage extends StatefulWidget {
  const SiswaSettingsPage({super.key});

  @override
  State<SiswaSettingsPage> createState() => _SiswaSettingsPageState();
}

class _SiswaSettingsPageState extends State<SiswaSettingsPage> {
  final _formKey = GlobalKey<FormState>();
  final _oldPinController = TextEditingController();
  final _newPinController = TextEditingController();
  final _confirmPinController = TextEditingController();
  
  bool _obscureOld = true;
  bool _obscureNew = true;
  bool _obscureConfirm = true;

  @override
  void dispose() {
    _oldPinController.dispose();
    _newPinController.dispose();
    _confirmPinController.dispose();
    super.dispose();
  }

  void _handleChangePin() {
    if (!_formKey.currentState!.validate()) return;

    final appState = AppStateProvider.of(context);
    final Student student = appState.currentUser as Student;

    if (_oldPinController.text != student.pin) {
      _showSnackBar('PIN lama Anda salah!', Colors.red);
      return;
    }

    try {
      appState.changeStudentPin(student.nis, _newPinController.text);
      _showSnackBar('PIN Transaksi berhasil diperbarui!', Colors.green);
      _oldPinController.clear();
      _newPinController.clear();
      _confirmPinController.clear();
      setState(() {});
    } catch (e) {
      _showSnackBar('Gagal memperbarui PIN: $e', Colors.red);
    }
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
    final Student student = appState.currentUser as Student;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Security header card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF1E293B), Color(0xFF334155)],
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Row(
              children: [
                Icon(Icons.security, color: Color(0xFFF59E0B), size: 36),
                SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Keamanan Akun Anda',
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Jaga keamanan akun Anda dengan rutin mengubah PIN Transaksi 6-digit.',
                        style: TextStyle(color: Color(0xFFCBD5E1), fontSize: 11),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Child profile overview
          Card(
            color: Colors.white,
            elevation: 2,
            shadowColor: Colors.black.withOpacity(0.02),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Detail Profil Siswa', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  const SizedBox(height: 16),
                  _buildProfileRow('Nama Lengkap', student.name),
                  _buildProfileRow('NIS', student.nis),
                  _buildProfileRow('Kelas', student.className),
                  _buildProfileRow('Kode Linking Orang Tua', student.linkingCode),
                  _buildProfileRow('Linked Orang Tua', student.isLinked ? 'Terhubung' : 'Belum Terhubung', isLink: true),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Change PIN Form
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey.shade100),
            ),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Ubah PIN Transaksi',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF0F172A)),
                  ),
                  const SizedBox(height: 16),

                  // Old PIN
                  const Text('PIN Lama (6 digit)', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: _oldPinController,
                    obscureText: _obscureOld,
                    maxLength: 6,
                    keyboardType: TextInputType.number,
                    validator: (val) {
                      if (val == null || val.length != 6) return 'Masukkan 6 digit PIN';
                      return null;
                    },
                    decoration: InputDecoration(
                      counterText: '',
                      hintText: 'PIN lama',
                      prefixIcon: const Icon(Icons.lock_outline, size: 18),
                      suffixIcon: IconButton(
                        icon: Icon(_obscureOld ? Icons.visibility_off : Icons.visibility, size: 16),
                        onPressed: () => setState(() => _obscureOld = !_obscureOld),
                      ),
                      contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // New PIN
                  const Text('PIN Baru (6 digit)', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: _newPinController,
                    obscureText: _obscureNew,
                    maxLength: 6,
                    keyboardType: TextInputType.number,
                    validator: (val) {
                      if (val == null || val.length != 6) return 'PIN baru harus 6 digit';
                      if (val == _oldPinController.text && val.isNotEmpty) return 'PIN baru harus berbeda dengan PIN lama';
                      return null;
                    },
                    decoration: InputDecoration(
                      counterText: '',
                      hintText: 'PIN baru',
                      prefixIcon: const Icon(Icons.lock, size: 18),
                      suffixIcon: IconButton(
                        icon: Icon(_obscureNew ? Icons.visibility_off : Icons.visibility, size: 16),
                        onPressed: () => setState(() => _obscureNew = !_obscureNew),
                      ),
                      contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Confirm PIN
                  const Text('Konfirmasi PIN Baru', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: _confirmPinController,
                    obscureText: _obscureConfirm,
                    maxLength: 6,
                    keyboardType: TextInputType.number,
                    validator: (val) {
                      if (val == null || val.length != 6) return 'Konfirmasi PIN harus 6 digit';
                      if (val != _newPinController.text) return 'Konfirmasi PIN tidak cocok dengan PIN baru';
                      return null;
                    },
                    decoration: InputDecoration(
                      counterText: '',
                      hintText: 'Ketik ulang PIN baru',
                      prefixIcon: const Icon(Icons.lock, size: 18),
                      suffixIcon: IconButton(
                        icon: Icon(_obscureConfirm ? Icons.visibility_off : Icons.visibility, size: 16),
                        onPressed: () => setState(() => _obscureConfirm = !_obscureConfirm),
                      ),
                      contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Submit button
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: _handleChangePin,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1A56DB),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      child: const Text('Simpan Perubahan PIN', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileRow(String label, String val, {bool isLink = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 12, color: Color(0xFF64748B))),
          Text(
            val,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: isLink
                  ? (val == 'Terhubung' ? const Color(0xFF10B981) : const Color(0xFFEF4444))
                  : const Color(0xFF1E293B),
            ),
          ),
        ],
      ),
    );
  }
}
