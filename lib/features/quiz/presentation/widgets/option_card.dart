import 'package:flutter/material.dart';
import '../widgets/markdown_latex.dart';

class OptionCard extends StatelessWidget {
  final String option;
  final bool isSelected;
  final bool? isCorrect;
  final VoidCallback? onTap;

  const OptionCard({
    super.key,
    required this.option,
    required this.isSelected,
    this.isCorrect,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    // Determine colors based on selection and correctness
    Color backgroundColor;
    Color borderColor;
    Color textColor;
    
    if (isCorrect == null) {
      // Not showing correctness yet
      backgroundColor = isSelected 
          ? theme.colorScheme.primaryContainer 
          : theme.colorScheme.surface;
      borderColor = isSelected 
          ? theme.colorScheme.primary 
          : theme.colorScheme.outline;
      textColor = isSelected 
          ? theme.colorScheme.onPrimaryContainer 
          : theme.colorScheme.onSurface;
    } else if (isCorrect == true) {
      // Correct answer
      backgroundColor = Colors.green.withOpacity(0.2);
      borderColor = Colors.green;
      textColor = Colors.green.shade800;
    } else {
      // Incorrect answer
      backgroundColor = isSelected 
          ? Colors.red.withOpacity(0.2) 
          : theme.colorScheme.surface;
      borderColor = isSelected ? Colors.red : theme.colorScheme.outline;
      textColor = isSelected ? Colors.red.shade800 : theme.colorScheme.onSurface;
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: borderColor),
          ),
          child: MarkdownLatex(
            data: option,
            style: TextStyle(
              color: textColor,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }
} 