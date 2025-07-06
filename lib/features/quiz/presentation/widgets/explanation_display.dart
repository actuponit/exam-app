import 'package:exam_app/features/quiz/presentation/widgets/markdown_latex.dart';
import 'package:flutter/material.dart';

class ExplanationDisplay extends StatefulWidget {
  final String explanation;
  final bool isVisible;
  final VoidCallback? onExpand;
  final VoidCallback? onCollapse;

  const ExplanationDisplay({
    super.key,
    required this.explanation,
    this.isVisible = false,
    this.onExpand,
    this.onCollapse,
  });

  @override
  State<ExplanationDisplay> createState() => _ExplanationDisplayState();
}

class _ExplanationDisplayState extends State<ExplanationDisplay> {
  bool _expanded = false;

  void _toggle() {
    setState(() => _expanded = !_expanded);
    if (_expanded) {
      widget.onExpand?.call();
    } else {
      widget.onCollapse?.call();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AnimatedCrossFade(
      crossFadeState:
          _expanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
      duration: const Duration(milliseconds: 300),
      firstChild: InkWell(
        onTap: _toggle,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: theme.colorScheme.primary.withOpacity(0.07),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            children: [
              Icon(Icons.lightbulb_outline,
                  color: theme.colorScheme.primary, size: 20),
              const SizedBox(width: 10),
              Text(
                'Explanation',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              Icon(Icons.expand_more, color: theme.colorScheme.primary),
            ],
          ),
        ),
      ),
      secondChild: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: theme.colorScheme.primary.withOpacity(0.07),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.lightbulb,
                    color: theme.colorScheme.primary, size: 20),
                const SizedBox(width: 10),
                Text(
                  'Explanation',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.expand_less),
                  color: theme.colorScheme.primary,
                  onPressed: _toggle,
                  splashRadius: 18,
                ),
              ],
            ),
            const SizedBox(height: 8),
            MarkdownLatexWidget(
              data: widget.explanation,
              shrinkWrap: true,
              textStyle: theme.textTheme.bodyMedium?.copyWith(
                fontSize: 15,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
