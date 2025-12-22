import 'package:exam_app/core/di/injection.dart';
import 'package:exam_app/core/presentation/widgets/app_snackbar.dart';
import 'package:exam_app/core/theme_cubit.dart';
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
  final String? region;
  const QuestionScreen({
    super.key,
    required this.subjectId,
    required this.year,
    this.chapterId,
    this.isQuizMode = false,
    this.region,
  });

  @override
  Widget build(BuildContext context) {
    context.read<RecentExamCubit>().saveRecentExam(
          subjectId,
          year,
          chapterId,
          region,
        );
    return BlocProvider(
      create: (context) => QuestionBloc(
        repository: getIt<QuestionRepository>(),
      )..add(QuestionStarted(
          subjectId: subjectId,
          chapterId: chapterId,
          year: year,
          isQuizMode: isQuizMode,
          region: region,
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
          BlocBuilder<ThemeCubit, ThemeState>(
            builder: (context, state) {
              final brightness = Theme.of(context).brightness;
              final isDarkMode = state.themeMode == ThemeMode.dark ||
                  (state.themeMode == ThemeMode.system &&
                      brightness == Brightness.dark);

              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () {
                    context.read<ThemeCubit>().toggleTheme();
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 220),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      gradient: LinearGradient(
                        colors: isDarkMode
                            ? [
                                Theme.of(context).colorScheme.secondary,
                                Theme.of(
                                  context,
                                ).colorScheme.secondary.withOpacity(0.8),
                              ]
                            : [
                                Theme.of(context).primaryColor,
                                Theme.of(
                                  context,
                                ).primaryColor.withOpacity(0.85),
                              ],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.12),
                          blurRadius: 10,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 220),
                      child: Icon(
                        isDarkMode
                            ? Icons.wb_sunny_rounded
                            : Icons.nights_stay_rounded,
                        key: ValueKey(isDarkMode),
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
          BlocBuilder<QuestionBloc, QuestionState>(
            builder: (context, state) {
              if (!state.isQuizMode) return const SizedBox();
              return AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                child: Container(
                  decoration: BoxDecoration(
                    color: state.canSubmit
                        ? Theme.of(context).colorScheme.secondary
                        : Theme.of(context).colorScheme.surfaceVariant,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      if (state.canSubmit)
                        BoxShadow(
                          color: Theme.of(context)
                              .colorScheme
                              .secondary
                              .withOpacity(0.25),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                    ],
                    border: Border.all(
                      color: state.canSubmit
                          ? Theme.of(context).colorScheme.secondary
                          : Theme.of(context).colorScheme.outline,
                      width: 1.5,
                    ),
                  ),
                  child: IconButton(
                    icon: Icon(
                      state.canSubmit
                          ? Icons.check_circle
                          : Icons.radio_button_unchecked,
                      color: state.canSubmit
                          ? Theme.of(context).colorScheme.onSecondary
                          : Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                    onPressed: state.canSubmit
                        ? () => context
                            .read<QuestionBloc>()
                            .add(const QuizSubmitted())
                        : null,
                    tooltip: 'Submit',
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: BlocListener<QuestionBloc, QuestionState>(
        listenWhen: (previous, current) =>
            previous.status != current.status &&
            current.isQuizMode &&
            previous.scoreResult != current.scoreResult,
        listener: (context, state) {
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
        child: BlocConsumer<QuestionBloc, QuestionState>(
          listener: (context, state) {
            if (state.status == QuestionStatus.success &&
                state.currentPage != _currentPage) {
              _pageController.animateToPage(
                state.currentPage,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
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
                      context
                          .read<QuestionBloc>()
                          .add(QuestionPageChanged(page));
                    },
                    itemCount: state.totalPages,
                    itemBuilder: (context, pageIndex) {
                      final pageQuestions =
                          state.questions.skip(pageIndex * 6).take(6).toList();

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
                            index: (state.currentPage * 6) + index,
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
                        ElevatedButton(
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
                              horizontal: 18,
                              vertical: 10,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            backgroundColor:
                                Theme.of(context).colorScheme.primary,
                            foregroundColor: Colors.white,
                            elevation: 0,
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.arrow_back_ios_new, size: 18),
                              SizedBox(width: 6),
                              Text('Previous'),
                            ],
                          ),
                        ),
                        ElevatedButton(
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
                              horizontal: 18,
                              vertical: 10,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            backgroundColor:
                                Theme.of(context).colorScheme.primary,
                            foregroundColor: Colors.white,
                            elevation: 0,
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text('Next'),
                              SizedBox(width: 6),
                              Icon(Icons.arrow_forward_ios, size: 18),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
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
                                ? Theme.of(context).colorScheme.primary
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
      ),
    );
  }
}
