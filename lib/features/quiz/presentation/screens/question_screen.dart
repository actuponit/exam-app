import 'package:exam_app/core/di/injection.dart';
import 'package:exam_app/core/presentation/widgets/app_snackbar.dart';
import 'package:exam_app/features/exams/presentation/bloc/recent_exam_bloc/recent_exam_cubit.dart';
import 'package:exam_app/features/quiz/presentation/bloc/subject_bloc/subject_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:no_screenshot/no_screenshot.dart';
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
    context.read<RecentExamCubit>().saveRecentExam(
          subjectId,
          year,
          chapterId,
        );
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

  final _noScreenshot = NoScreenshot.instance;

  void stopScreenshotListening() async {
    await _noScreenshot.stopScreenshotListening();
  }

  void startScreenshot() async {
    await _noScreenshot.screenshotOn();
  }

  Future<void> startScreenshotListening() async {
    await _noScreenshot.startScreenshotListening();
  }

  void listenForScreenshot() {
    _noScreenshot.screenshotStream.listen((value) {
      if (value.wasScreenshotTaken && mounted) {
        AppSnackBar.warning(
          context: context,
          message: 'Screenshots are not allowed on this page',
        );
      }
    });
  }

  void _startScreenshotListening() async {
    await _noScreenshot.screenshotOff();
    await startScreenshotListening();
    listenForScreenshot();
  }

  @override
  void initState() {
    _startScreenshotListening();
    super.initState();
  }

  @override
  void dispose() {
    _pageController.dispose();
    stopScreenshotListening();
    startScreenshot();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(
          onPressed: () {
            context.read<SubjectBloc>().add(LoadSubjects());
            context.pop();
          },
        ),
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
              return AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                child: ElevatedButton.icon(
                  onPressed: state.canSubmit
                      ? () => context
                          .read<QuestionBloc>()
                          .add(const QuizSubmitted())
                      : null,
                  style: ElevatedButton.styleFrom(
                    disabledBackgroundColor: Colors.grey.shade200,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 12),
                    backgroundColor: state.canSubmit
                        ? Theme.of(context).colorScheme.primary
                        : Colors.grey.shade200,
                    foregroundColor:
                        state.canSubmit ? Colors.white : Colors.grey.shade700,
                    elevation: state.canSubmit ? 4 : 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                      side: BorderSide(
                        color: state.canSubmit
                            ? Theme.of(context).colorScheme.primary
                            : Colors.grey.shade400,
                        width: 1.5,
                      ),
                    ),
                  ),
                  icon: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: Icon(
                      state.canSubmit
                          ? Icons.check_circle
                          : Icons.radio_button_unchecked,
                      key: ValueKey<bool>(state.canSubmit),
                      size: 24,
                    ),
                  ),
                  label: const Text(
                    'Submit',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
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
                          celebrate: !state.isQuizMode,
                          onAnswerSelected: (answer) {
                            context.read<QuestionBloc>().add(
                                  QuestionAnswered(
                                    question: question,
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
              if (state.totalPages > 1) ...[
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ElevatedButton.icon(
                        onPressed: _currentPage > 0
                            ? () {
                                _pageController.previousPage(
                                  duration: const Duration(milliseconds: 300),
                                  curve: Curves.easeInOut,
                                );
                              }
                            : null,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        icon: const Icon(Icons.arrow_back_ios_new, size: 18),
                        label: const Text('Previous'),
                      ),
                      ElevatedButton.icon(
                        onPressed: _currentPage < state.totalPages - 1
                            ? () {
                                _pageController.nextPage(
                                  duration: const Duration(milliseconds: 300),
                                  curve: Curves.easeInOut,
                                );
                              }
                            : null,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        icon: const Icon(Icons.arrow_forward_ios, size: 18),
                        label: const Text('Next'),
                      ),
                    ],
                  ),
                ),
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
            ],
          );
        },
      ),
    );
  }
}
