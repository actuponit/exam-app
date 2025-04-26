import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class OnboardingPage extends StatelessWidget {
  final String title;
  final String description;
  final String animationPath;

  const OnboardingPage({
    Key? key,
    required this.title,
    required this.description,
    required this.animationPath,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Animation with Lottie
          Expanded(
            flex: 3,
            child: Lottie.asset(
              animationPath,
              fit: BoxFit.contain,
              repeat: true,
              animate: true,
            ),
          ),
          const SizedBox(height: 32),
          // Title
          Text(
            title,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
          ),
          const SizedBox(height: 16),
          // Description
          Text(
            description,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color:
                      Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                ),
          ),
          // Additional space at the bottom for the page controls
          const SizedBox(height: 72),
        ],
      ),
    );
  }
}
