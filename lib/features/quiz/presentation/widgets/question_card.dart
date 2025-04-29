import 'package:flutter/material.dart';
import '../../domain/models/question.dart';
import 'markdown_latex.dart';
import 'option_card.dart';

class QuestionCard extends StatelessWidget {
  final Question question;
  final String? selectedAnswer;
  final bool showAnswer;
  final Function(String) onAnswerSelected;

  const QuestionCard({
    super.key,
    required this.question,
    this.selectedAnswer,
    required this.showAnswer,
    required this.onAnswerSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            MarkdownLatex(
              data: question.text,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            ...question.options.map((option) {
              final isSelected = selectedAnswer == option;
              final isCorrect = question.correctOption == option;

              return OptionCard(
                option: option,
                isSelected: isSelected,
                isCorrect:
                    showAnswer && selectedAnswer != null ? isCorrect : null,
                onTap: () => onAnswerSelected(option),
              );
            }).toList(),
            if (showAnswer && selectedAnswer != null)
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Divider(),
                    const SizedBox(height: 8),
                    Text(
                      'Explanation:',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 8),
                    MarkdownLatex(
                      data: question.explanation ?? 'No explanation available',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
