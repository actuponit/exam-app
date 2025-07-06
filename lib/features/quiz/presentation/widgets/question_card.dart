import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import '../../domain/models/question.dart';
import 'markdown_latex.dart';
import 'option_card.dart';
import 'package:exam_app/features/quiz/presentation/widgets/explanation_display.dart';

class QuestionCard extends StatefulWidget {
  final Question question;
  final String? selectedAnswer;
  final bool showAnswer;
  final Function(String) onAnswerSelected;
  final bool celebrate;
  final int index;

  const QuestionCard({
    super.key,
    required this.question,
    this.selectedAnswer,
    required this.showAnswer,
    this.celebrate = false,
    required this.onAnswerSelected,
    required this.index,
  });

  @override
  State<QuestionCard> createState() => _QuestionCardState();
}

class _QuestionCardState extends State<QuestionCard> {
  late ConfettiController _confettiController;
  final Map<String, GlobalKey> _optionKeys = {};

  @override
  void initState() {
    super.initState();
    _confettiController =
        ConfettiController(duration: const Duration(seconds: 1));

    // Create keys for each option
    for (var option in widget.question.options) {
      _optionKeys[option.id] = GlobalKey();
    }
  }

  @override
  void didUpdateWidget(QuestionCard oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Play confetti when answer is shown and correct
    if (widget.celebrate &&
        oldWidget.selectedAnswer == null &&
        widget.selectedAnswer == widget.question.correctOption) {
      _confettiController.play();
    }
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final question = widget.question;
    final questionIndex = widget.index + 1;
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 10),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'Q$questionIndex',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Divider(
                    color: theme.colorScheme.primary.withOpacity(0.2),
                    thickness: 1.2,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            MarkdownLatexWidget(
              data: question.text,
              shrinkWrap: true,
              textStyle: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 18),
            ...question.options.map((option) {
              final isSelected = widget.selectedAnswer == option.id;
              final isCorrect =
                  widget.showAnswer && widget.selectedAnswer != null
                      ? question.correctOption == option.id
                      : null;
              return OptionCard(
                option: option.text,
                isSelected: isSelected,
                isCorrect: isCorrect,
                onTap: () => widget.onAnswerSelected(option.id),
              );
            }),
            if (widget.showAnswer && widget.selectedAnswer != null) ...[
              const SizedBox(height: 10),
              ExplanationDisplay(
                explanation: question.explanation ?? 'No explanation available',
              ),
            ],
          ],
        ),
      ),
    );
  }
}
