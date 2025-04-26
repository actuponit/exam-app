import 'package:exam_app/core/router/app_router.dart';
import 'package:exam_app/features/splash/presentation/cubit/splash_cubit.dart';
import 'package:exam_app/features/splash/presentation/screens/onboarding_screen.dart';
import 'package:exam_app/features/splash/presentation/widgets/splash_animation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  bool _showOnboarding = false;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

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
      context.go(RoutePaths.home);
    } else if (!state.isComplete) {
      // Otherwise show onboarding screens
      setState(() {
        _showOnboarding = true;
      });
      _fadeController.forward();
    } else {
      // If onboarding was completed before, navigate to home
      context.go(RoutePaths.signUp);
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
        ],
      ),
    );
  }
}

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
