import 'package:flutter/material.dart';
import '../../domain/services/score_calculator.dart';

class ResultDialog extends StatelessWidget {
  final ScoreResult scoreResult;
  final VoidCallback onClose;

  const ResultDialog({
    super.key,
    required this.scoreResult,
    required this.onClose,
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
            scoreResult.grade,
            style: theme.textTheme.displayMedium?.copyWith(
              color: colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${scoreResult.percentage.toStringAsFixed(1)}%',
            style: theme.textTheme.titleLarge?.copyWith(
              color: colorScheme.secondary,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Correct Answers: ${scoreResult.correctAnswers}/${scoreResult.totalQuestions}',
            style: theme.textTheme.titleMedium,
          ),
          
          const SizedBox(height: 24),
          Text(
            scoreResult.message,
            style: theme.textTheme.bodyLarge?.copyWith(
              fontStyle: FontStyle.italic,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
      actions: [
        FilledButton(
          onPressed: onClose,
          child: const Text('Close'),
        ),
      ],
    );
  }
} 