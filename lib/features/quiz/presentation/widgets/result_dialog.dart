import 'package:flutter/material.dart';
import '../../domain/services/score_calculator.dart';

class ResultDialog extends StatelessWidget {
  final ScoreResult result;
  final VoidCallback onRetry;
  final VoidCallback onBackToSelection;

  const ResultDialog({
    super.key,
    required this.result,
    required this.onRetry,
    required this.onBackToSelection,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return AlertDialog(
      title: Text(
        'Quiz Results',
        style: theme.textTheme.headlineSmall,
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            result.grade,
            style: theme.textTheme.displayMedium?.copyWith(
              color: colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${(result.percentage * 100).toStringAsFixed(1)}%',
            style: theme.textTheme.titleLarge?.copyWith(
              color: colorScheme.secondary,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Correct Answers: ${result.correctAnswers}/${result.totalQuestions}',
            style: theme.textTheme.titleMedium,
          ),
          if (result.timeSpent != null) ...[
            const SizedBox(height: 8),
            Text(
              'Time Spent: ${result.timeSpent!.inMinutes} minutes',
              style: theme.textTheme.titleMedium,
            ),
          ],
          const SizedBox(height: 24),
          Text(
            result.message,
            style: theme.textTheme.bodyLarge?.copyWith(
              fontStyle: FontStyle.italic,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: onBackToSelection,
          child: const Text('Back to Selection'),
        ),
        FilledButton(
          onPressed: onRetry,
          child: const Text('Try Again'),
        ),
      ],
    );
  }
}