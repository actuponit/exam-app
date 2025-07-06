import 'package:exam_app/core/presentation/utils/dialog_utils.dart';
import 'package:exam_app/core/theme.dart';
import 'package:exam_app/features/exams/domain/entities/exam.dart';
import 'package:exam_app/features/quiz/presentation/bloc/exam_bloc/exam_bloc.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class YearSelectionScreen extends StatelessWidget {
  final String subjectId;
  final int duration;
  final String? region;

  const YearSelectionScreen({
    super.key,
    required this.subjectId,
    required this.duration,
    this.region,
  });

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ExamBloc>().add(LoadExams(subjectId, region: region));
    });

    return Scaffold(
        appBar: AppBar(
          title: Text('Select Year and Chapter',
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
                if (region != null) ...[
                  Text(
                    'Region: $region',
                    style: bodyStyle.copyWith(color: textLight),
                  ),
                ],
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    boxShadow: [
                      BoxShadow(
                        color: Theme.of(context).shadowColor.withOpacity(0.05),
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
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontSize: 16,
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurface
                                  .withOpacity(0.7),
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
                              labelStyle: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(
                                    color: selected
                                        ? Theme.of(context)
                                            .colorScheme
                                            .onPrimary
                                        : Theme.of(context)
                                            .colorScheme
                                            .onSurface,
                                    fontSize: 14,
                                  ),
                              backgroundColor:
                                  Theme.of(context).colorScheme.surface,
                              selectedColor:
                                  Theme.of(context).colorScheme.primary,
                              checkmarkColor:
                                  Theme.of(context).colorScheme.onPrimary,
                              onSelected: (selected) {
                                context
                                    .read<ExamBloc>()
                                    .add(FilterExamsByChapter(
                                      chapter.id,
                                    ));
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
        selectedChapter: state.filteredChapter != null
            ? state.exams[index].chapters.firstWhere(
                (chapter) => chapter.id == state.filteredChapter?.id,
              )
            : null,
        duration: duration,
        region: region,
      ),
    );
  }
}

class YearListItem extends StatelessWidget {
  final Exam exam;
  final ExamChapter? selectedChapter;
  final int duration;
  final String? region;

  const YearListItem({
    super.key,
    required this.exam,
    this.selectedChapter,
    required this.duration,
    this.region,
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
          color: Theme.of(context).colorScheme.surface,
          border: Border.all(
            color: Theme.of(context).dividerColor,
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
              color: Theme.of(context).colorScheme.secondary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  exam.year.toString(),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                        fontSize: 18,
                      ),
                ),
                if (selectedChapter != null)
                  Text(
                    'Unit',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withOpacity(0.7),
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
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
          ),
          subtitle: Text(
            selectedChapter == null
                ? '${exam.totalQuestions} Questions • ${duration * exam.totalQuestions} mins'
                : '${selectedChapter?.questionCount} Questions • ${duration * (selectedChapter?.questionCount ?? 0)} mins',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color:
                      Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                ),
          ),
          trailing: Icon(
            Icons.chevron_right,
            color: Theme.of(context).iconTheme.color?.withOpacity(0.7),
          ),
          onTap: () => DialogUtils.showModeSelectionDialog(
            context,
            year: exam.year.toString(),
            subjectId: exam.subjectId,
            chapterId: selectedChapter?.id,
            region: region,
            onCancel: () {
              // Handle cancel if needed
            },
          ),
        ),
      ),
    );
  }
}
