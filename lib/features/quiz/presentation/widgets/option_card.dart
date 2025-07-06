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
    final isAnswered = isCorrect != null;

    Color backgroundColor;
    Color textColor;
    Widget? leadingIcon;
    Widget? trailingIcon;

    if (!isAnswered) {
      backgroundColor = isSelected
          ? theme.colorScheme.primaryContainer
          : theme.colorScheme.surface;
      textColor = isSelected
          ? theme.colorScheme.onPrimaryContainer
          : theme.colorScheme.onSurface;
      leadingIcon = Container(
        width: 22,
        height: 22,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: isSelected
                ? theme.colorScheme.primary
                : theme.colorScheme.outline,
            width: 2,
          ),
          color: isSelected
              ? theme.colorScheme.primary.withAlpha(38)
              : Colors.transparent,
        ),
        child: isSelected
            ? Center(
                child: Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary,
                    shape: BoxShape.circle,
                  ),
                ),
              )
            : null,
      );
    } else if (isCorrect == true) {
      backgroundColor = theme.colorScheme.primary.withAlpha(38);
      textColor = theme.colorScheme.primary;
      leadingIcon = Container(
        width: 22,
        height: 22,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: theme.colorScheme.primary,
        ),
        child: const Icon(Icons.check, color: Colors.white, size: 16),
      );
      trailingIcon =
          const Icon(Icons.check_circle, color: Colors.green, size: 20);
    } else {
      backgroundColor =
          isSelected ? Colors.red.withAlpha(30) : theme.colorScheme.surface;
      textColor =
          isSelected ? Colors.red.shade800 : theme.colorScheme.onSurface;
      leadingIcon = Container(
        width: 22,
        height: 22,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isSelected ? Colors.red : Colors.transparent,
          border: Border.all(
            color: isSelected ? Colors.red : theme.colorScheme.outline,
            width: 2,
          ),
        ),
        child: isSelected
            ? const Icon(Icons.close, color: Colors.white, size: 16)
            : null,
      );
      if (isSelected) {
        trailingIcon = const Icon(Icons.cancel, color: Colors.red, size: 20);
      }
    }

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(14),
          // border: Border.all(color: borderColor, width: 1.5),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            leadingIcon,
            const SizedBox(width: 14),
            Expanded(
              child: MarkdownLatexWidget(
                data: option,
                shrinkWrap: true,
                textStyle: TextStyle(
                  color: textColor,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  fontSize: 16,
                ),
              ),
            ),
            if (trailingIcon != null) ...[
              const SizedBox(width: 10),
              trailingIcon,
            ],
          ],
        ),
      ),
    );
  }
}
