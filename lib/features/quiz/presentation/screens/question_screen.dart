import 'package:exam_app/core/di/injection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/question_repository.dart';
import '../bloc/question_bloc.dart';
import '../bloc/question_event.dart';
import '../bloc/question_state.dart';
import '../widgets/question_card.dart';
import '../widgets/quiz_result_dialog.dart';

class QuestionScreen extends StatelessWidget {
  final String subjectId;
  final String? chapterId;
  final int year;
  final bool isQuizMode;

  const QuestionScreen({
    super.key,
    required this.subjectId,
    required this.year,
    this.chapterId,
    this.isQuizMode = false,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => QuestionBloc(
        repository: getIt<QuestionRepository>(),
      )..add(QuestionStarted(
          subjectId: subjectId,
          chapterId: chapterId,
          year: year,
          isQuizMode: isQuizMode,
        )),
      child: const QuestionScreenContent(),
    );
  }
}

class QuestionScreenContent extends StatefulWidget {
  const QuestionScreenContent({super.key});

  @override
  State<QuestionScreenContent> createState() => _QuestionScreenContentState();
}

class _QuestionScreenContentState extends State<QuestionScreenContent> {
  final _pageController = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: BlocBuilder<QuestionBloc, QuestionState>(
          builder: (context, state) {
            if (!state.isQuizMode) return const Text('Practice Mode');
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Quiz Mode'),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    state.formattedTimeRemaining,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            );
          },
        ),
        actions: [
          BlocBuilder<QuestionBloc, QuestionState>(
            builder: (context, state) {
              if (!state.isQuizMode) return const SizedBox();
              return TextButton.icon(
                onPressed: state.canSubmit
                    ? () =>
                        context.read<QuestionBloc>().add(const QuizSubmitted())
                    : null,
                icon: const Icon(Icons.check_circle_outline),
                label: const Text('Submit'),
              );
            },
          ),
        ],
      ),
      body: BlocConsumer<QuestionBloc, QuestionState>(
        listener: (context, state) {
          if (state.status == QuestionStatus.success &&
              state.currentPage != _currentPage) {
            _pageController.animateToPage(
              state.currentPage,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
            );
          }

          // Show result dialog when quiz is submitted
          if (state.status == QuestionStatus.submitted &&
              state.isQuizMode &&
              state.scoreResult != null) {
            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (context) => ResultDialog(
                scoreResult: state.scoreResult!,
                onClose: () => Navigator.of(context).pop(),
              ),
            );
          }
        },
        builder: (context, state) {
          if (state.status == QuestionStatus.loading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.status == QuestionStatus.error) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Error loading questions'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      context.read<QuestionBloc>().add(
                            QuestionStarted(
                              subjectId: state.subjectId,
                              chapterId: state.chapterId,
                              year: state.year,
                              isQuizMode: state.isQuizMode,
                            ),
                          );
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          return Column(
            children: [
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  onPageChanged: (page) {
                    setState(() => _currentPage = page);
                    context.read<QuestionBloc>().add(QuestionPageChanged(page));
                  },
                  itemCount: state.totalPages,
                  itemBuilder: (context, pageIndex) {
                    final pageQuestions =
                        state.questions.skip(pageIndex * 3).take(3).toList();

                    return ListView.builder(
                      padding: const EdgeInsets.only(bottom: 16),
                      itemCount: pageQuestions.length,
                      itemBuilder: (context, index) {
                        final question = pageQuestions[index];
                        return QuestionCard(
                          question: question,
                          selectedAnswer: state.answers[question.id],
                          showAnswer: !state.isQuizMode || state.isSubmitted,
                          onAnswerSelected: (answer) {
                            context.read<QuestionBloc>().add(
                                  QuestionAnswered(
                                    questionId: question.id,
                                    selectedOption: answer,
                                  ),
                                );
                          },
                        );
                      },
                    );
                  },
                ),
              ),
              if (state.totalPages > 1)
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      state.totalPages,
                      (index) => Container(
                        width: 8,
                        height: 8,
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: index == _currentPage
                              ? Theme.of(context).primaryColor
                              : Colors.grey[300],
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
