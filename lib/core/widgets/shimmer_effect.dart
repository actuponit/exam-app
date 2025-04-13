import 'package:flutter/material.dart';

class ShimmerEffect extends StatelessWidget {
  final double width;
  final double height;
  final double radius;
  final EdgeInsets? margin;

  const ShimmerEffect({
    super.key,
    required this.width,
    required this.height,
    this.radius = 0,
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant,
        borderRadius: BorderRadius.circular(radius),
      ),
      child: ShaderMask(
        shaderCallback: (bounds) {
          return LinearGradient(
            colors: [
              Theme.of(context).colorScheme.surfaceVariant,
              Theme.of(context).colorScheme.surface,
              Theme.of(context).colorScheme.surfaceVariant,
            ],
            stops: const [0.0, 0.5, 1.0],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ).createShader(bounds);
        },
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(radius),
          ),
        ),
      ),
    );
  }
} 