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
            return const _LoadingScreen(label: 'Loading exams...');
          }

          if (state is ExamError) {
            return _ErrorCard(
              message: state.message,
              onRetry: () => context
                  .read<ExamBloc>()
                  .add(LoadExams(subjectId, region: region)),
            );
          }

          if (state is ExamLoaded) {
            final isChaptter = state.chapters.isNotEmpty &&
                state.chapters.first.name.startsWith("Ch-");
            return Column(
              children: [
                if (region != null) ...[
                  Text(
                    'Region: $region',
                    style: bodyStyle.copyWith(color: textLight),
                  ),
                ],
                _ChapterFilterBar(
                  label: isChaptter ? 'Filter by Chapter' : 'Filter by year',
                  chapters: state.chapters,
                  selectedChapterId: state.filteredChapter?.id,
                  onSelected: (chapterId) => context
                      .read<ExamBloc>()
                      .add(FilterExamsByChapter(chapterId)),
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
      return const _EmptyState(
        message: 'No questions available for this chapter',
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

class _LoadingScreen extends StatelessWidget {
  final String label;

  const _LoadingScreen({required this.label});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: theme.primaryColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(theme.primaryColor),
              strokeWidth: 3,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            label,
            style: theme.textTheme.titleLarge?.copyWith(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: theme.colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}

class _ErrorCard extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorCard({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(cardRadius),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.error_outline_rounded,
                  size: 64,
                  color: theme.colorScheme.error,
                ),
                const SizedBox(height: 20),
                SelectableText.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: 'Something went wrong\n',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                      TextSpan(
                        text: message,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.error,
                        ),
                      ),
                    ],
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: onRetry,
                  icon: const Icon(Icons.refresh, color: Colors.white),
                  label: const Text(
                    'Try Again',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
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

class _EmptyState extends StatelessWidget {
  final String message;

  const _EmptyState({required this.message});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.quiz_outlined,
              size: 80,
              color: theme.colorScheme.onSurface.withOpacity(0.3),
            ),
            const SizedBox(height: 16),
            Text(
              message,
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.6),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _ChapterFilterBar extends StatelessWidget {
  final String label;
  final List<Chapter> chapters;
  final String? selectedChapterId;
  final ValueChanged<String> onSelected;

  const _ChapterFilterBar({
    required this.label,
    required this.chapters,
    required this.selectedChapterId,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            colorScheme.primaryContainer.withOpacity(0.15),
            colorScheme.secondaryContainer.withOpacity(0.10),
          ],
        ),
        borderRadius: BorderRadius.circular(cardRadius),
        border: Border.all(color: colorScheme.outline.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: theme.textTheme.titleSmall?.copyWith(
              fontSize: 16,
              color: colorScheme.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 40,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: chapters.length + 1,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final isAll = index == 0;
                final chapter =
                    isAll ? Chapter(id: "all", name: "All") : chapters[index - 1];
                final selected = selectedChapterId == chapter.id ||
                    (isAll && selectedChapterId == null);

                return FilterChip(
                  selected: selected,
                  label: Text(chapter.name),
                  labelStyle: theme.textTheme.bodySmall?.copyWith(
                    color: selected
                        ? colorScheme.onPrimary
                        : colorScheme.primary,
                    fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                    fontSize: 13,
                  ),
                  backgroundColor: colorScheme.surface,
                  selectedColor: colorScheme.primary,
                  checkmarkColor: colorScheme.onPrimary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                    side: BorderSide(
                      color: selected
                          ? colorScheme.primary
                          : colorScheme.outline.withOpacity(0.5),
                      width: 1.5,
                    ),
                  ),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  elevation: selected ? 2 : 0,
                  shadowColor: colorScheme.primary.withOpacity(0.3),
                  onSelected: (_) => onSelected(chapter.id),
                );
              },
            ),
          ),
        ],
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
    final validYear = int.tryParse(exam.year) != null;
    final colorScheme = Theme.of(context).colorScheme;
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(cardRadius),
        side: BorderSide(color: Theme.of(context).dividerColor, width: 1),
      ),
      child: ListTile(
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        leading: validYear
            ? Container(
                width: 60,
                height: 60,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: colorScheme.primaryContainer,
                  shape: BoxShape.circle,
                ),
                child: Text(
                  exam.year.toString(),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: colorScheme.primary,
                        fontSize: 18,
                      ),
                ),
              )
            : null,
        title: Text(
          selectedChapter == null || !validYear
              ? '${exam.title} (${exam.year})'
              : '${selectedChapter?.name} (${exam.year})',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurface,
              ),
        ),
        subtitle: Text(
          selectedChapter == null
              ? '${exam.totalQuestions} Questions • ${duration * exam.totalQuestions} mins'
              : '${selectedChapter?.questionCount} Questions • ${duration * (selectedChapter?.questionCount ?? 0)} mins',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurface.withOpacity(0.7),
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
          onCancel: () {},
        ),
      ),
    );
  }
}
