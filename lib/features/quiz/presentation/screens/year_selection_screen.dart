import 'dart:ui';
import 'package:exam_app/core/router/app_router.dart';
import 'package:exam_app/core/theme.dart';
import 'package:exam_app/features/exams/domain/entities/exam.dart';
import 'package:exam_app/features/quiz/presentation/bloc/exam_bloc/exam_bloc.dart';
import 'package:exam_app/features/quiz/presentation/bloc/question_state.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class YearSelectionScreen extends StatelessWidget {
  final String subjectId;
  final int duration;

  const YearSelectionScreen({
    super.key,
    required this.subjectId,
    required this.duration,
  });

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ExamBloc>().add(LoadExams(subjectId));
    });

    return Scaffold(
        appBar: AppBar(
          title: Text('Select Chapter',
              style: displayStyle.copyWith(color: Colors.white)),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.pop(),
          ),
        ),
        body: BlocBuilder<ExamBloc, ExamState>(builder: (context, state) {
          if (state is ExamLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is ExamError) {
            return Center(
              child: Text(
                'Error: ${state.message}',
                style: bodyStyle.copyWith(color: textLight),
              ),
            );
          }

          if (state is ExamLoaded) {
            return Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey[200]!,
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Filter by Chapter',
                        style: titleStyle.copyWith(
                          fontSize: 16,
                          color: textLight,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(cardRadius),
                        ),
                        height: 40,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: state.chapters.length + 1,
                          separatorBuilder: (_, __) => const SizedBox(width: 8),
                          itemBuilder: (context, index) {
                            final isAll = index == 0;
                            final chapter = isAll
                                ? Chapter(id: "all", name: "All")
                                : state.chapters[index - 1];
                            final selected =
                                state.filteredChapter?.id == chapter.id ||
                                    (isAll && state.filteredChapter == null);

                            return FilterChip(
                              selected: selected,
                              label: Text(chapter.name),
                              labelStyle: bodyStyle.copyWith(
                                color: selected ? Colors.white : textDark,
                                fontSize: 14,
                              ),
                              backgroundColor: Colors.grey[100],
                              selectedColor: primaryColor,
                              checkmarkColor: Colors.white,
                              onSelected: (selected) {
                                context
                                    .read<ExamBloc>()
                                    .add(FilterExamsByChapter(chapter.id));
                              },
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 8),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: _buildYearList(state),
                ),
              ],
            );
          }

          return Container();
        }));
  }

  Widget _buildYearList(ExamLoaded state) {
    if (state.exams.isEmpty) {
      return Center(
        child: Text(
          'No questions available for this chapter',
          style: bodyStyle.copyWith(color: textLight),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: state.exams.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) => YearListItem(
        exam: state.exams[index],
        selectedChapter: state.filteredChapter,
        duration: duration,
      ),
    );
  }
}

class YearListItem extends StatelessWidget {
  final Exam exam;
  final ExamChapter? selectedChapter;
  final int duration;

  const YearListItem({
    super.key,
    required this.exam,
    this.selectedChapter,
    required this.duration,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(cardRadius),
      ),
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(cardRadius),
          color: Colors.white,
          border: Border.all(
            color: Colors.grey[200]!,
            width: 1.5,
          ),
        ),
        child: ListTile(
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          leading: Container(
            width: 60,
            height: 60,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: secondaryColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  exam.year.toString(),
                  style: titleStyle.copyWith(
                    color: primaryColor,
                    fontSize: 18,
                  ),
                ),
                if (selectedChapter != null)
                  Text(
                    'Unit',
                    style: bodyStyle.copyWith(
                      color: textLight,
                      fontSize: 12,
                    ),
                  ),
              ],
            ),
          ),
          title: Text(
            selectedChapter == null
                ? '${exam.title} (${exam.year})'
                : '${selectedChapter?.name} (${exam.year})',
            style: titleStyle.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          subtitle: Text(
            selectedChapter == null
                ? '${exam.totalQuestions} Questions • ${duration * exam.totalQuestions} mins'
                : '${selectedChapter?.questionCount} Questions • ${duration * (selectedChapter?.questionCount ?? 0)} mins',
            style: bodyStyle.copyWith(
              color: textLight,
            ),
          ),
          trailing: const Icon(
            Icons.chevron_right,
            color: textLight,
          ),
          onTap: () => _showModeSelectionDialog(
            context,
            year: exam.year.toString(),
            subjectId: exam.subjectId,
            chapterId: selectedChapter?.id,
          ),
        ),
      ),
    );
  }

  Future<void> _showModeSelectionDialog(
    BuildContext context, {
    required String year,
    required String subjectId,
    String? chapterId,
  }) async {
    return showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.5),
      builder: (context) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: Dialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(cardRadius),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Select Mode',
                  style: displayStyle.copyWith(
                    fontSize: 24,
                    color: textDark,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Choose how you want to take this exam',
                  style: bodyStyle.copyWith(
                    color: textLight,
                  ),
                ),
                const SizedBox(height: 24),
                _ModeButton(
                  icon: Icons.book_outlined,
                  title: 'Practice Mode',
                  description: 'Review answers as you go',
                  onTap: () {
                    context.pop();
                    context.push(
                        '${RoutePaths.years}/$subjectId/$year${RoutePaths.questions}',
                        extra: {
                          'mode': QuestionMode.practice,
                          'chapterId': chapterId,
                        });
                  },
                ),
                const SizedBox(height: 16),
                _ModeButton(
                  icon: Icons.timer_outlined,
                  title: 'Quiz Mode',
                  description: 'Timed exam with final review',
                  onTap: () {
                    context.pop();
                    context.push(
                        '${RoutePaths.years}/$subjectId/$year${RoutePaths.questions}',
                        extra: {
                          'mode': QuestionMode.quiz,
                          'chapterId': chapterId,
                        });
                  },
                ),
                const SizedBox(height: 24),
                TextButton(
                  onPressed: () => context.pop(),
                  child: Text(
                    'Cancel',
                    style: titleStyle.copyWith(
                      color: textLight,
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ModeButton extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final VoidCallback onTap;

  const _ModeButton({
    required this.icon,
    required this.title,
    required this.description,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(cardRadius),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border.all(
              color: Colors.grey[200]!,
              width: 1.5,
            ),
            borderRadius: BorderRadius.circular(cardRadius),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: primaryColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  color: primaryColor,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: titleStyle.copyWith(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: bodyStyle.copyWith(
                        color: textLight,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right,
                color: textLight,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
