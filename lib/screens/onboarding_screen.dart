import 'package:flutter/material.dart';
import 'role_selection_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with TickerProviderStateMixin {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  late AnimationController _illustrationController;

  @override
  void initState() {
    super.initState();
    _illustrationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..forward();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _illustrationController.dispose();
    super.dispose();
  }

  void _goToNextPage() {
    if (_currentPage < 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    } else {
      _finishOnboarding();
    }
  }

  void _finishOnboarding() {
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => const RoleSelectionScreen(),
        transitionsBuilder: (_, anim, __, child) =>
            FadeTransition(opacity: anim, child: child),
        transitionDuration: const Duration(milliseconds: 400),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isMobile = size.width < 768;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          PageView(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                _currentPage = index;
                _illustrationController.reset();
                _illustrationController.forward();
              });
            },
            children: [
              _OnboardingPage1(
                isMobile: isMobile,
                animController: _illustrationController,
              ),
              _OnboardingPage2(
                isMobile: isMobile,
                animController: _illustrationController,
              ),
            ],
          ),

          // Bottom controls bar
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: EdgeInsets.fromLTRB(
                  isMobile ? 28 : 48, 20, isMobile ? 28 : 48, isMobile ? 40 : 32),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Page dots
                  Row(
                    children: List.generate(2, (index) {
                      final isActive = index == _currentPage;
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.only(right: 6),
                        width: isActive ? 28 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(4),
                          color: isActive
                              ? const Color(0xFF4A5AF0)
                              : const Color(0xFFCBD5E1),
                        ),
                      );
                    }),
                  ),

                  // Navigation button
                  GestureDetector(
                    onTap: _goToNextPage,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 28, vertical: 14),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF6C63FF), Color(0xFF4A5AF0)],
                        ),
                        borderRadius: BorderRadius.circular(50),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF6C63FF).withOpacity(0.35),
                            blurRadius: 16,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            _currentPage == 0 ? 'Lanjut' : 'Mulai Sekarang',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Icon(Icons.arrow_forward_rounded,
                              color: Colors.white, size: 18),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Skip button top-right
          Positioned(
            top: MediaQuery.of(context).padding.top + 12,
            right: isMobile ? 20 : 40,
            child: TextButton(
              onPressed: _finishOnboarding,
              child: const Text(
                'Lewati',
                style: TextStyle(
                  color: Color(0xFF94A3B8),
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Onboarding Page 1 ────────────────────────────────────────────────────────

class _OnboardingPage1 extends StatelessWidget {
  final bool isMobile;
  final AnimationController animController;

  const _OnboardingPage1({
    required this.isMobile,
    required this.animController,
  });

  @override
  Widget build(BuildContext context) {
    final slideAnim = Tween<Offset>(
      begin: const Offset(0.15, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: animController, curve: Curves.easeOutCubic));

    final fadeAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: animController, curve: Curves.easeIn),
    );

    return Padding(
      padding: EdgeInsets.only(
          left: isMobile ? 28 : 64,
          right: isMobile ? 28 : 64,
          top: isMobile ? 60 : 50,
          bottom: 120),
      child: isMobile
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: _Illustration1()),
                const SizedBox(height: 32),
                FadeTransition(
                  opacity: fadeAnim,
                  child: SlideTransition(
                      position: slideAnim, child: _Page1Text()),
                ),
              ],
            )
          : Row(
              children: [
                Expanded(child: _Illustration1()),
                const SizedBox(width: 60),
                Expanded(
                  child: FadeTransition(
                    opacity: fadeAnim,
                    child: SlideTransition(
                        position: slideAnim, child: _Page1Text()),
                  ),
                ),
              ],
            ),
    );
  }
}

class _Illustration1 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF4DB6AC), Color(0xFF26A69A)],
        ),
        borderRadius: BorderRadius.circular(28),
      ),
      child: Stack(
        children: [
          // Decorative circles
          Positioned(
            top: -20,
            right: -20,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.1),
              ),
            ),
          ),
          Positioned(
            bottom: -30,
            left: -30,
            child: Container(
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.08),
              ),
            ),
          ),
          // Content
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Notification badge
                Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 12,
                          offset: const Offset(0, 4))
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: Color(0xFF10B981),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      const Text(
                        'Transaksi Berhasil ✓',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                    ],
                  ),
                ),
                // School illustration using icons
                Container(
                  width: 140,
                  height: 140,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.school_rounded,
                    size: 72,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 20),
                // Students row
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(3, (i) {
                    final colors = [
                      const Color(0xFFFF6B8A),
                      const Color(0xFFFBBF24),
                      const Color(0xFF60A5FA)
                    ];
                    return Container(
                      margin: const EdgeInsets.symmetric(horizontal: 6),
                      child: CircleAvatar(
                        backgroundColor: colors[i],
                        radius: 20,
                        child: Icon(
                          i == 0
                              ? Icons.person
                              : i == 1
                                  ? Icons.person_2
                                  : Icons.person_3,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 16),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'Rp 1.200+ — siswa di seluruh Indonesia',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Page1Text extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
          decoration: BoxDecoration(
            color: const Color(0xFF6C63FF).withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Text(
            'ONBOARDING AWAL',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: Color(0xFF6C63FF),
              letterSpacing: 1.2,
            ),
          ),
        ),
        const SizedBox(height: 20),
        RichText(
          text: const TextSpan(
            style: TextStyle(fontFamily: 'Outfit'),
            children: [
              TextSpan(
                text: 'Selamat Datang di\n',
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF0F172A),
                  height: 1.25,
                ),
              ),
              TextSpan(
                text: 'Sekolah',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF0F172A),
                  height: 1.25,
                ),
              ),
              TextSpan(
                text: 'PRO',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF6C63FF),
                  height: 1.25,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        const Text(
          'Solusi ekosistem digital sekolah yang aman dan praktis. Kelola keuangan dan administrasi pendidikan dalam satu genggaman Anda.',
          style: TextStyle(
            fontSize: 15,
            color: Color(0xFF64748B),
            height: 1.6,
          ),
        ),
        const SizedBox(height: 28),
        // Feature chips
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            _FeatureChip(icon: Icons.account_balance_wallet_rounded, label: 'E-Wallet'),
            _FeatureChip(icon: Icons.qr_code_rounded, label: 'Token QR'),
            _FeatureChip(icon: Icons.storefront_rounded, label: 'Kantin & ATK'),
            _FeatureChip(icon: Icons.notifications_rounded, label: 'Notifikasi Real-time'),
          ],
        ),
      ],
    );
  }
}

// ─── Onboarding Page 2 ────────────────────────────────────────────────────────

class _OnboardingPage2 extends StatelessWidget {
  final bool isMobile;
  final AnimationController animController;

  const _OnboardingPage2({
    required this.isMobile,
    required this.animController,
  });

  @override
  Widget build(BuildContext context) {
    final slideAnim = Tween<Offset>(
      begin: const Offset(0.15, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: animController, curve: Curves.easeOutCubic));

    final fadeAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: animController, curve: Curves.easeIn),
    );

    return Padding(
      padding: EdgeInsets.only(
          left: isMobile ? 28 : 64,
          right: isMobile ? 28 : 64,
          top: isMobile ? 60 : 50,
          bottom: 120),
      child: isMobile
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FadeTransition(
                    opacity: fadeAnim,
                    child: SlideTransition(
                        position: slideAnim, child: _Page2Text())),
                const SizedBox(height: 28),
                Expanded(child: _Illustration2()),
              ],
            )
          : Row(
              children: [
                Expanded(
                  child: FadeTransition(
                    opacity: fadeAnim,
                    child: SlideTransition(
                        position: slideAnim, child: _Page2Text()),
                  ),
                ),
                const SizedBox(width: 60),
                Expanded(child: _Illustration2()),
              ],
            ),
    );
  }
}

class _Page2Text extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
          decoration: BoxDecoration(
            color: const Color(0xFF10B981).withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Text(
            'ONBOARDING AKHIR',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: Color(0xFF10B981),
              letterSpacing: 1.2,
            ),
          ),
        ),
        const SizedBox(height: 20),
        RichText(
          text: const TextSpan(
            style: TextStyle(fontFamily: 'Outfit'),
            children: [
              TextSpan(
                text: 'Kelola dengan\n',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF0F172A),
                  height: 1.25,
                ),
              ),
              TextSpan(
                text: 'Mudah ',
                style: TextStyle(
                  fontSize: 34,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF4A5AF0),
                  height: 1.25,
                ),
              ),
              TextSpan(
                text: '✨',
                style: TextStyle(
                  fontSize: 28,
                  height: 1.25,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        const Text(
          'Pantau transaksi dan top up saldo kapan saja di mana saja. Semua kebutuhan administrasi sekolah anak dalam genggaman Anda.',
          style: TextStyle(
            fontSize: 15,
            color: Color(0xFF64748B),
            height: 1.6,
          ),
        ),
        const SizedBox(height: 28),
        // Benefit list
        ...[
          ('🔒', 'Saldo aman & terenkripsi 100%'),
          ('📲', 'Notifikasi ke orang tua < 5 detik'),
          ('🏪', 'Dukung kantin & koperasi ATK'),
          ('📊', 'Laporan harian & bulanan otomatis'),
        ].map((item) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                children: [
                  Text(item.$1, style: const TextStyle(fontSize: 18)),
                  const SizedBox(width: 12),
                  Text(
                    item.$2,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF374151),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            )),
      ],
    );
  }
}

class _Illustration2 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [Color(0xFFF0F4FF), Color(0xFFE8EEFF)],
        ),
        borderRadius: BorderRadius.circular(28),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Wallet Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF6C63FF), Color(0xFF4A5AF0)],
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF6C63FF).withOpacity(0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
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
                        'Saldo E-Wallet',
                        style: TextStyle(
                            color: Colors.white70, fontSize: 12),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text('Siswa',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.w600)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Rp 750.000',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Budi Setyawan · X-IPA 1',
                    style: TextStyle(color: Colors.white70, fontSize: 11),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // Transaction list
            ...[
              ('Budi Setyawan', 'Nasi Ayam Geprek', '-Rp 15.000', const Color(0xFFEF4444)),
              ('Siti Aminah', 'Top Up BCA VA', '+Rp 100.000', const Color(0xFF10B981)),
              ('Andi Pratama', 'Buku Tulis ATK', '-Rp 8.000', const Color(0xFFEF4444)),
            ].map((item) => Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.black.withOpacity(0.04),
                          blurRadius: 8,
                          offset: const Offset(0, 2))
                    ],
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 16,
                        backgroundColor: const Color(0xFF6C63FF).withOpacity(0.1),
                        child: Text(
                          item.$1[0],
                          style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF6C63FF)),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(item.$1,
                                style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF0F172A))),
                            Text(item.$2,
                                style: const TextStyle(
                                    fontSize: 10, color: Color(0xFF94A3B8))),
                          ],
                        ),
                      ),
                      Text(
                        item.$3,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: item.$4,
                        ),
                      ),
                    ],
                  ),
                )),
          ],
        ),
      ),
    );
  }
}

// ─── Feature Chip Widget ──────────────────────────────────────────────────────

class _FeatureChip extends StatelessWidget {
  final IconData icon;
  final String label;
  const _FeatureChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: const Color(0xFF6C63FF).withOpacity(0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF6C63FF).withOpacity(0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: const Color(0xFF6C63FF)),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Color(0xFF4A5AF0),
            ),
          ),
        ],
      ),
    );
  }
}
