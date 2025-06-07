import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';
import 'package:exam_app/core/theme.dart';
import 'package:exam_app/core/router/app_router.dart';

class WelcomeScreen extends StatefulWidget {
  static const String routeName = '/welcome';

  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _startAnimations();
  }

  void _initializeAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _slideController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));
  }

  void _startAnimations() {
    Future.delayed(const Duration(milliseconds: 300), () {
      _fadeController.forward();
    });

    Future.delayed(const Duration(milliseconds: 600), () {
      _slideController.forward();
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final theme = Theme.of(context);

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              primaryColor.withOpacity(0.1),
              Colors.white,
              secondaryColor.withOpacity(0.05),
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                children: [
                  const SizedBox(height: 40),

                  // Header Animation
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: Column(
                      children: [
                        Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            color: primaryColor,
                            borderRadius: BorderRadius.circular(25),
                            boxShadow: [
                              BoxShadow(
                                color: primaryColor.withOpacity(0.3),
                                blurRadius: 15,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.school_rounded,
                            size: 50,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          'ExamHub',
                          style: theme.textTheme.displayMedium?.copyWith(
                            color: primaryColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Master Your National Exams',
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: textLight,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 40),

                  // Main Illustration
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: SizedBox(
                      height: size.height * 0.3,
                      child: Lottie.asset(
                        'assets/animations/exam_practice.json',
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),

                  const SizedBox(height: 40),

                  // Content Section
                  SlideTransition(
                    position: _slideAnimation,
                    child: FadeTransition(
                      opacity: _fadeAnimation,
                      child: Column(
                        children: [
                          Text(
                            'Prepare with Confidence',
                            style: theme.textTheme.headlineSmall?.copyWith(
                              color: textDark,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Practice with thousands of questions, track your progress, and ace your exams with our comprehensive study platform.',
                            style: theme.textTheme.bodyLarge?.copyWith(
                              color: textLight,
                              height: 1.6,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 32),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 48),

                  // Action Buttons
                  SlideTransition(
                    position: _slideAnimation,
                    child: FadeTransition(
                      opacity: _fadeAnimation,
                      child: Column(
                        children: [
                          _buildPrimaryButton(
                            context: context,
                            text: 'Register',
                            onPressed: () => context.push(RoutePaths.signUp),
                          ),
                          const SizedBox(height: 16),
                          _buildSecondaryButton(
                            context: context,
                            text: 'Already have an account? Login',
                            onPressed: () => context.push(RoutePaths.login),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),
                  _buildPrivacyPolicyButton(),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPrimaryButton({
    required BuildContext context,
    required String text,
    required VoidCallback onPressed,
  }) {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [primaryColor, secondaryColor],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(buttonRadius),
        boxShadow: [
          BoxShadow(
            color: primaryColor.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(buttonRadius),
          ),
        ),
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildSecondaryButton({
    required BuildContext context,
    required String text,
    required VoidCallback onPressed,
  }) {
    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
      ),
      child: Text(
        text,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: primaryColor,
              fontWeight: FontWeight.w500,
            ),
      ),
    );
  }

  Widget _buildPrivacyPolicyButton() {
    return Center(
      child: TextButton.icon(
        onPressed: () => context.push(RoutePaths.privacyPolicy),
        icon: Icon(
          Icons.privacy_tip_outlined,
          size: 16,
          color: primaryColor.withOpacity(0.7),
        ),
        label: Text(
          'Privacy Policy & Terms of Service',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: primaryColor.withOpacity(0.8),
                fontWeight: FontWeight.w500,
                decoration: TextDecoration.underline,
                decorationColor: primaryColor.withOpacity(0.3),
              ),
        ),
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
    );
  }
}
