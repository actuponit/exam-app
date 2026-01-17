import 'package:exam_app/core/router/app_router.dart';
import 'package:exam_app/features/splash/presentation/cubit/splash_cubit.dart';
import 'package:exam_app/features/splash/presentation/screens/onboarding_screen.dart';
import 'package:exam_app/features/splash/presentation/widgets/splash_animation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:package_info_plus/package_info_plus.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  bool _showOnboarding = false;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  String _appVersion = '';

  @override
  void initState() {
    super.initState();

    // Initialize the animation controller for fade transition
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    );

    // Check if onboarding should be shown
    _checkOnboardingStatus();
    _loadPackageInfo();
  }

  Future<void> _loadPackageInfo() async {
    try {
      final info = await PackageInfo.fromPlatform();
      setState(() {
        _appVersion = info.version;
      });
    } catch (_) {
      // ignore errors and keep version empty
    }
  }

  Future<void> _checkOnboardingStatus() async {
    // Check if onboarding was completed before
    await context.read<SplashCubit>().checkAppInitialState();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  void _onSplashAnimationComplete() {
    final state = context.read<SplashCubit>().state;

    if (state.isLoggedIn) {
      // If onboarding was completed before, navigate to home
      // context.go(RoutePaths.home);
    } else if (!state.isComplete) {
      // Otherwise show onboarding screens
      setState(() {
        _showOnboarding = true;
      });
      _fadeController.forward();
    } else {
      // If onboarding was completed before, navigate to home
      context.go(RoutePaths.welcome);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: Stack(
        children: [
          if (!_showOnboarding)
            Positioned.fill(
              child: CustomPaint(
                painter: ParticlesPainter(),
              ),
            ),
          // Initial Splash Animation
          if (!_showOnboarding)
            SplashAnimation(
              onAnimationComplete: _onSplashAnimationComplete,
            ),

          // Onboarding Screens with Fade In Animation
          if (_showOnboarding)
            FadeTransition(
              opacity: _fadeAnimation,
              child: const OnboardingScreen(),
            ),

          // Particles overlay animation (optional)
          // Version label (fetched from package_info_plus)
          Positioned(
            left: 0,
            right: 0,
            bottom: 24,
            child: SafeArea(
              top: false,
              child: Center(
                child: AnimatedOpacity(
                  opacity: _appVersion.isEmpty ? 0 : 1,
                  duration: const Duration(milliseconds: 350),
                  child: Text(
                    _appVersion.isEmpty ? '' : 'v$_appVersion',
                    style: Theme.of(context).textTheme.bodySmall ??
                        const TextStyle(fontSize: 12, color: Colors.black),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Add version display in bottom area

// Custom painter for animated particles in the background
class ParticlesPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.purple.withOpacity(0.3)
      ..style = PaintingStyle.fill;

    // Draw some particles (can be enhanced with animated positions)
    for (int i = 0; i < 70; i++) {
      // These would normally be animated with a value from an Animation<double>
      final x = (i * 17) % size.width;
      final y = (i * 23) % size.height;
      final radius = (i % 5 + 2).toDouble();

      canvas.drawCircle(Offset(x, y), radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
