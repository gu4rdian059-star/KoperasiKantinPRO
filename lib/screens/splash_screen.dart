import 'package:flutter/material.dart';
import 'onboarding_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnim;
  late Animation<double> _fadeAnim;
  late Animation<double> _taglineAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );

    _scaleAnim = Tween<double>(begin: 0.72, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.0, 0.65, curve: Curves.easeOutBack)),
    );
    _fadeAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.0, 0.55, curve: Curves.easeIn)),
    );
    _taglineAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.55, 1.0, curve: Curves.easeIn)),
    );

    _controller.forward();

    // After 2.8s, navigate to onboarding
    Future.delayed(const Duration(milliseconds: 2800), () {
      if (mounted) {
        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            pageBuilder: (_, __, ___) => const OnboardingScreen(),
            transitionsBuilder: (_, anim, __, child) =>
                FadeTransition(opacity: anim, child: child),
            transitionDuration: const Duration(milliseconds: 500),
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF6C63FF),
              Color(0xFF4A5AF0),
              Color(0xFF3B82F6),
            ],
          ),
        ),
        child: Stack(
          children: [
            // Background decorative circles
            Positioned(
              top: -80,
              right: -80,
              child: Container(
                width: 280,
                height: 280,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.06),
                ),
              ),
            ),
            Positioned(
              bottom: -120,
              left: -60,
              child: Container(
                width: 320,
                height: 320,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.05),
                ),
              ),
            ),
            Positioned(
              top: 140,
              left: -40,
              child: Container(
                width: 160,
                height: 160,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.04),
                ),
              ),
            ),

            // Center Logo
            Center(
              child: AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  return FadeTransition(
                    opacity: _fadeAnim,
                    child: Transform.scale(
                      scale: _scaleAnim.value,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Logo Icon
                          Container(
                            width: 88,
                            height: 88,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.18),
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.35),
                                width: 1.5,
                              ),
                            ),
                            child: Center(
                              child: Container(
                                width: 52,
                                height: 52,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFF6B8A),
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: const Icon(
                                  Icons.account_balance_wallet_rounded,
                                  color: Colors.white,
                                  size: 28,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 22),
                          // Brand Name
                          RichText(
                            text: const TextSpan(
                              children: [
                                TextSpan(
                                  text: 'Sekolah',
                                  style: TextStyle(
                                    fontSize: 36,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.white,
                                    letterSpacing: 0.5,
                                    fontFamily: 'Outfit',
                                  ),
                                ),
                                TextSpan(
                                  text: 'PRO',
                                  style: TextStyle(
                                    fontSize: 36,
                                    fontWeight: FontWeight.w800,
                                    color: Color(0xFFFF6B8A),
                                    letterSpacing: 0.5,
                                    fontFamily: 'Outfit',
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),
                          // Tagline fades in after logo
                          FadeTransition(
                            opacity: _taglineAnim,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 6),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: const Text(
                                'Digital Payment & School Monitoring',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w500,
                                  letterSpacing: 0.3,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

            // Bottom loading dots
            Positioned(
              bottom: 52,
              left: 0,
              right: 0,
              child: AnimatedBuilder(
                animation: _taglineAnim,
                builder: (_, __) => FadeTransition(
                  opacity: _taglineAnim,
                  child: Column(
                    children: [
                      SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: Colors.white.withOpacity(0.7),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Memuat aplikasi...',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.6),
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
