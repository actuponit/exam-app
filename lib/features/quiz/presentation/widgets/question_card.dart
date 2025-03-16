import 'package:flutter/material.dart';
import '../../../../core/theme.dart';
import '../../domain/models/question.dart';
import 'markdown_latex.dart';
import 'option_card.dart';

class QuestionCard extends StatefulWidget {
  final Question question;
  final String? selectedAnswer;
  final Function(String) onAnswerSelected;
  final bool showAnswer;

  const QuestionCard({
    super.key,
    required this.question,
    this.selectedAnswer,
    required this.onAnswerSelected,
    this.showAnswer = false,
  });

  @override
  State<QuestionCard> createState() => _QuestionCardState();
}

class _QuestionCardState extends State<QuestionCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Card(
        margin: const EdgeInsets.all(16),
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildQuestionText(),
              const SizedBox(height: 24),
              _buildOptions(),
              if (widget.showAnswer && widget.selectedAnswer != null)
                _buildExplanation(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuestionText() {
    return MarkdownLatex(
      data: widget.question.text,
      selectable: true,
      style: titleStyle.copyWith(fontSize: 18),
    );
  }

  Widget _buildOptions() {
    return Column(
      children: widget.question.options.map((option) {
        final isSelected = widget.selectedAnswer == option;
        final isCorrect = option == widget.question.correctOption;
        final showCorrectness = widget.showAnswer && widget.selectedAnswer != null;

        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: OptionCard(
            option: option,
            isSelected: isSelected,
            isCorrect: isCorrect,
            showCorrect: showCorrectness,
            onTap: widget.selectedAnswer == null
                ? () => widget.onAnswerSelected(option)
                : null,
          ),
        );
      }).toList(),
    );
  }

  Widget _buildExplanation() {
    return AnimatedSize(
      duration: const Duration(milliseconds: 300),
      child: Container(
        margin: const EdgeInsets.only(top: 24),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[300]!),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Explanation',
              style: titleStyle.copyWith(
                fontSize: 16,
                color: primaryColor,
              ),
            ),
            const SizedBox(height: 8),
            MarkdownLatex(
              data: widget.question.explanation ?? '',
              selectable: true,
              style: bodyStyle.copyWith(height: 1.5),
            ),
          ],
        ),
      ),
    );
  }
} 