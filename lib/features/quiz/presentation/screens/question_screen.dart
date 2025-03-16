import 'package:exam_app/features/quiz/data/repositories/question_repository_impl.dart';
import 'package:exam_app/features/quiz/domain/repositories/question_repository.dart';
import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../bloc/question_bloc.dart';
import '../bloc/question_event.dart';
import '../bloc/question_state.dart';
import '../widgets/markdown_latex.dart';
import '../widgets/option_card.dart';
import '../widgets/result_dialog.dart';

class QuestionScreen extends StatelessWidget {
  final String? chapter;
  final int? year;
  final QuestionMode mode;

  const QuestionScreen({
    super.key,
    this.chapter,
    this.year,
    required this.mode,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => QuestionBloc(
        repository: QuestionRepositoryImpl(),
      )..add(
          QuestionStarted(
            chapter: chapter,
            year: year,
            mode: mode,
          ),
        ),
      child: const QuestionView(),
    );
  }
}

class QuestionView extends StatefulWidget {
  const QuestionView({super.key});

  @override
  State<QuestionView> createState() => _QuestionViewState();
}

class _QuestionViewState extends State<QuestionView> {
  late final ConfettiController _confettiController;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 1));
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  void _showResultDialog(BuildContext context, QuestionState state) {
    if (state.scoreResult == null) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => ResultDialog(
        result: state.scoreResult!,
        onRetry: () {
          context.read<QuestionBloc>().add(
                QuestionStarted(
                  chapter: state.chapter,
                  year: state.year,
                  mode: state.mode,
                ),
              );
          Navigator.pop(context);
        },
        onBackToSelection: () {
          context.go('/select/${state.mode == QuestionMode.practice ? "practice" : "quiz"}');
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<QuestionBloc, QuestionState>(
      listener: (context, state) {
        // Show confetti in practice mode when answer is correct
        if (state.mode == QuestionMode.practice &&
            state.answers.isNotEmpty) {
          final lastAnswer = state.answers.values.last;
          final question = state.questions.firstWhere(
            (q) => q.id == lastAnswer.questionId,
          );
          if (lastAnswer.selectedOption == question.correctOption) {
            _confettiController.play();
          }
        }

        // Show result dialog when quiz is submitted
        if (state.status == QuestionStatus.submitted) {
          _showResultDialog(context, state);
        }
      },
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            title: Text(
              state.mode == QuestionMode.practice
                  ? 'Practice Mode'
                  : 'Quiz Mode',
            ),
            actions: [
              if (state.mode == QuestionMode.quiz)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Center(
                    child: Text(
                      'Time: ${state.timeRemaining ?? 0} min',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                ),
            ],
          ),
          body: Stack(
            children: [
              switch (state.status) {
                QuestionStatus.loading => const Center(
                    child: CircularProgressIndicator(),
                  ),
                QuestionStatus.error => Center(
                    child: SelectableText.rich(
                      TextSpan(
                        text: 'Error: ',
                        style: const TextStyle(color: Colors.red),
                        children: [
                          TextSpan(
                            text: state.error ?? 'Unknown error occurred',
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                        ],
                      ),
                    ),
                  ),
                _ => const QuestionContent(),
              },
              Align(
                alignment: Alignment.topCenter,
                child: ConfettiWidget(
                  confettiController: _confettiController,
                  blastDirectionality: BlastDirectionality.explosive,
                  particleDrag: 0.05,
                  emissionFrequency: 0.05,
                  numberOfParticles: 20,
                  gravity: 0.1,
                  shouldLoop: false,
                  colors: [
                    Theme.of(context).colorScheme.primary,
                    Theme.of(context).colorScheme.secondary,
                    Theme.of(context).colorScheme.tertiary,
                    Colors.pink,
                    Colors.orange,
                    Colors.purple,
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class QuestionContent extends StatelessWidget {
  const QuestionContent({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<QuestionBloc, QuestionState>(
      builder: (context, state) {
        if (state.questions.isEmpty) {
          return Center(
            child: Text(
              'No questions available${state.year != null ? " for year ${state.year}" : ""}${state.chapter != null ? " in chapter ${state.chapter}" : ""}',
              style: Theme.of(context).textTheme.titleLarge,
            ),
          );
        }

        return Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: state.pageController,
                onPageChanged: (index) {
                  context.read<QuestionBloc>().add(
                        QuestionPageChanged(index),
                      );
                },
                itemCount: state.questions.length,
                itemBuilder: (context, index) {
                  final question = state.questions[index];
                  final isAnswered = state.answers.containsKey(question.id);
                  final selectedOption = state.answers[question.id]?.selectedOption;
                  final showCorrect = state.mode == QuestionMode.practice && isAnswered;

                  return SingleChildScrollView(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Question ${index + 1} of ${state.questions.length}',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 16.0),
                        MarkdownLatex(
                          data: question.text,
                          selectable: true,
                        ),
                        const SizedBox(height: 24.0),
                        ...question.options.map((option) {
                          final isSelected = selectedOption == option;
                          final isCorrect = showCorrect && option == question.correctOption;

                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12.0),
                            child: OptionCard(
                              option: option,
                              isSelected: isSelected,
                              isCorrect: isCorrect,
                              showCorrect: showCorrect,
                              onTap: isAnswered
                                  ? null
                                  : () {
                                      context.read<QuestionBloc>().add(
                                            QuestionAnswered(
                                              questionId: question.id,
                                              selectedOption: option,
                                            ),
                                          );
                                    },
                            ),
                          );
                        }).toList(),
                        if (showCorrect && question.explanation != null) ...[
                          const SizedBox(height: 24.0),
                          Text(
                            'Explanation:',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 8.0),
                          MarkdownLatex(
                            data: question.explanation!,
                            selectable: true,
                          ),
                        ],
                      ],
                    ),
                  );
                },
              ),
            ),
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    if (state.currentPage > 0)
                      ElevatedButton(
                        onPressed: () {
                          state.pageController?.previousPage(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          );
                        },
                        child: const Text('Previous'),
                      )
                    else
                      const SizedBox.shrink(),
                    if (state.mode == QuestionMode.quiz &&
                        state.currentPage == state.questions.length - 1)
                      ElevatedButton(
                        onPressed: () {
                          context.read<QuestionBloc>().add(
                                const QuizSubmitted(),
                              );
                        },
                        child: const Text('Submit'),
                      )
                    else if (state.currentPage < state.questions.length - 1)
                      ElevatedButton(
                        onPressed: () {
                          state.pageController?.nextPage(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          );
                        },
                        child: const Text('Next'),
                      ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
} 