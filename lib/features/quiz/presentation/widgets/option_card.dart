import 'package:flutter/material.dart';
import '../widgets/markdown_latex.dart';

class OptionCard extends StatelessWidget {
  final String option;
  final bool isSelected;
  final bool isCorrect;
  final bool showCorrect;
  final VoidCallback? onTap;

  const OptionCard({
    super.key,
    required this.option,
    required this.isSelected,
    required this.isCorrect,
    required this.showCorrect,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    Color getBackgroundColor() {
      if (!isSelected && !showCorrect) return theme.cardColor;
      if (showCorrect && isCorrect) return colorScheme.primary.withOpacity(0.15);
      if (isSelected && !isCorrect) return colorScheme.error.withOpacity(0.15);
      return theme.cardColor;
    }

    Color getBorderColor() {
      if (!isSelected && !showCorrect) return theme.dividerColor;
      if (showCorrect && isCorrect) return colorScheme.primary;
      if (isSelected && !isCorrect) return colorScheme.error;
      return theme.dividerColor;
    }

    Widget? getTrailingIcon() {
      if (!showCorrect && !isSelected) return null;
      if (showCorrect && isCorrect) {
        return Icon(
          Icons.check_circle,
          color: colorScheme.primary,
        );
      }
      if (isSelected && !isCorrect) {
        return Icon(
          Icons.cancel,
          color: colorScheme.error,
        );
      }
      return null;
    }

    return Card(
      elevation: isSelected ? 2 : 1,
      color: getBackgroundColor(),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: getBorderColor(),
          width: isSelected || (showCorrect && isCorrect) ? 2 : 1,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Expanded(
                child: MarkdownLatex(
                  data: option,
                  selectable: true,
                ),
              ),
              if (getTrailingIcon() != null) ...[
                const SizedBox(width: 12),
                getTrailingIcon()!,
              ],
            ],
          ),
        ),
      ),
    );
  }
} 