import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class SplashAnimation extends StatelessWidget {
  final VoidCallback onAnimationComplete;

  const SplashAnimation({
    Key? key,
    required this.onAnimationComplete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // App Logo Animation
          Lottie.asset(
            'assets/animations/splash_logo.json',
            width: 200,
            height: 200,
            fit: BoxFit.contain,
            animate: true,
            repeat: false,
            onLoaded: (composition) {
              // When the animation composition is loaded, set a listener for completion
              Future.delayed(
                  Duration(milliseconds: composition.duration.inMilliseconds),
                  () {
                onAnimationComplete();
              });
            },
          ),
          const SizedBox(height: 24),
          // App Name with animated text appearance
          TweenAnimationBuilder<double>(
            tween: Tween<double>(begin: 0, end: 1),
            duration: const Duration(milliseconds: 800),
            curve: Curves.easeOutCubic,
            builder: (context, value, child) {
              return Opacity(
                opacity: value,
                child: Transform.translate(
                  offset: Offset(0, 20 * (1 - value)),
                  child: Text(
                    'EthioExamHub',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 16),
          // Tagline with delayed appearance - using Future.delayed to start this animation
          FutureBuilder(
              future: Future.delayed(const Duration(milliseconds: 300)),
              builder: (context, snapshot) {
                return TweenAnimationBuilder<double>(
                  tween: Tween<double>(
                      begin: 0,
                      end: snapshot.connectionState == ConnectionState.done
                          ? 1
                          : 0),
                  duration: const Duration(milliseconds: 800),
                  curve: Curves.easeOutCubic,
                  builder: (context, value, child) {
                    return Opacity(
                      opacity: value,
                      child: Transform.translate(
                        offset: Offset(0, 20 * (1 - value)),
                        child: Text(
                          'Your Path to Exam Success',
                          style: Theme.of(context)
                              .textTheme
                              .bodyLarge
                              ?.copyWith(
                                color: Theme.of(context).colorScheme.secondary,
                              ),
                        ),
                      ),
                    );
                  },
                );
              }),
        ],
      ),
    );
  }
}
