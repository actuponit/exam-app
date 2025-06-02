import 'package:exam_app/core/router/app_router.dart';
import 'package:exam_app/features/splash/presentation/constants/onboarding_data.dart';
import 'package:exam_app/features/splash/presentation/cubit/splash_cubit.dart';
import 'package:exam_app/features/splash/presentation/widgets/onboarding_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with SingleTickerProviderStateMixin {
  final PageController _pageController = PageController();
  late AnimationController _animationController;
  late Animation<double> _buttonAnimation;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _buttonAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    );

    // Start the animation after a short delay
    Future.delayed(const Duration(milliseconds: 500), () {
      _animationController.forward();
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: BlocConsumer<SplashCubit, SplashState>(
        listener: (context, state) {
          if (state.isComplete) {
            // Navigate to home when onboarding is complete
            if (state.isLoggedIn) {
              context.go(RoutePaths.home);
            } else {
              context.go(RoutePaths.welcome);
            }
          }
        },
        builder: (context, state) {
          return SafeArea(
            child: Column(
              children: [
                // Page View of Onboarding Pages
                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    itemCount: OnboardingData.pages.length,
                    onPageChanged: (index) {
                      context.read<SplashCubit>().updatePageIndex(index);
                    },
                    itemBuilder: (context, index) {
                      final pageData = OnboardingData.pages[index];
                      return OnboardingPage(
                        title: pageData['title']!,
                        description: pageData['description']!,
                        animationPath: pageData['animationPath']!,
                      );
                    },
                  ),
                ),

                // Bottom Controls
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 24.0, vertical: 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Skip Button
                      TextButton(
                        onPressed: () => _completeOnboarding(context),
                        child: Text(
                          'Skip',
                          style: Theme.of(context)
                              .textTheme
                              .labelLarge
                              ?.copyWith(
                                color: Theme.of(context).colorScheme.secondary,
                              ),
                        ),
                      ),

                      // Page Indicator
                      SmoothPageIndicator(
                        controller: _pageController,
                        count: OnboardingData.pages.length,
                        effect: ExpandingDotsEffect(
                          activeDotColor: Theme.of(context).colorScheme.primary,
                          dotColor: Theme.of(context)
                              .colorScheme
                              .primary
                              .withOpacity(0.3),
                          dotHeight: 8,
                          dotWidth: 8,
                          expansionFactor: 3,
                        ),
                      ),

                      // Next/Get Started Button with Animation
                      ScaleTransition(
                        scale: _buttonAnimation,
                        child: ElevatedButton(
                          onPressed: () {
                            if (state.currentPageIndex ==
                                OnboardingData.pages.length - 1) {
                              _completeOnboarding(context);
                            } else {
                              _pageController.nextPage(
                                duration: const Duration(milliseconds: 500),
                                curve: Curves.easeInOut,
                              );
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 24, vertical: 12),
                          ),
                          child: Text(
                            state.currentPageIndex ==
                                    OnboardingData.pages.length - 1
                                ? 'Get Started'
                                : 'Next',
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _completeOnboarding(BuildContext context) {
    context.read<SplashCubit>().completeOnboarding();
  }
}
