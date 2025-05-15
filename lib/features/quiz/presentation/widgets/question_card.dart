import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import '../../domain/models/question.dart';
import 'markdown_latex.dart';
import 'option_card.dart';

class QuestionCard extends StatefulWidget {
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
  State<QuestionCard> createState() => _QuestionCardState();
}

class _QuestionCardState extends State<QuestionCard> {
  late ConfettiController _confettiController;
  final Map<String, GlobalKey> _optionKeys = {};

  @override
  void initState() {
    super.initState();
    _confettiController =
        ConfettiController(duration: const Duration(seconds: 3));

    // Create keys for each option
    for (var option in widget.question.options) {
      _optionKeys[option.id] = GlobalKey();
    }
  }

  @override
  void didUpdateWidget(QuestionCard oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Play confetti when answer is shown and correct
    if (widget.showAnswer &&
        !oldWidget.showAnswer &&
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
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            MarkdownLatex(
              data: widget.question.text,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            ...widget.question.options.map((option) {
              final isSelected = widget.selectedAnswer == option.id;
              final isCorrect = widget.question.correctOption == option.id;

              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Stack(
                  key: _optionKeys[option.id],
                  children: [
                    OptionCard(
                      option: option.text,
                      isSelected: isSelected,
                      isCorrect:
                          widget.showAnswer && widget.selectedAnswer != null
                              ? isCorrect
                              : null,
                      onTap: () => widget.onAnswerSelected(option.id),
                    ),
                    if (widget.showAnswer &&
                        isCorrect &&
                        widget.selectedAnswer == widget.question.correctOption)
                      Positioned.fill(
                        child: Align(
                          alignment: Alignment.center,
                          child: ConfettiWidget(
                            confettiController: _confettiController,
                            blastDirectionality: BlastDirectionality.explosive,
                            particleDrag: 0.05,
                            emissionFrequency: 0.05,
                            numberOfParticles: 30,
                            maxBlastForce: 20,
                            minBlastForce: 10,
                            gravity: 0.1,
                            shouldLoop: false,
                            colors: const [
                              Colors.green,
                              Colors.blue,
                              Colors.pink,
                              Colors.orange,
                              Colors.purple,
                              Colors.yellow,
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              );
            }).toList(),
            if (widget.showAnswer && widget.selectedAnswer != null)
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
                      data: widget.question.explanation ??
                          'No explanation available',
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
