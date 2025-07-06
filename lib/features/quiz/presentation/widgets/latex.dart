import 'package:flutter/material.dart';
import 'package:flutter_math_fork/flutter_math.dart';

/// Simple LaTeX renderer widget
class LatexWidget extends StatelessWidget {
  final String latex;
  final bool isBlock;
  final TextStyle? textStyle;

  const LatexWidget({
    super.key,
    required this.latex,
    this.isBlock = false,
    this.textStyle,
  });

  @override
  Widget build(BuildContext context) {
    try {
      return Math.tex(
        latex,
        textStyle:
            textStyle ?? const TextStyle(fontSize: 16, color: Colors.black87),
        options: MathOptions(
          fontSize: isBlock ? 18 : 16,
          color: textStyle?.color ?? Colors.black87,
        ),
      );
    } catch (e) {
      // Fallback if LaTeX parsing fails
      return Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: Colors.red[100],
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(
          isBlock ? '\$\$$latex\$\$' : '\$$latex\$',
          style: const TextStyle(
            fontFamily: 'monospace',
            color: Colors.red,
            fontSize: 12,
          ),
        ),
      );
    }
  }
}
