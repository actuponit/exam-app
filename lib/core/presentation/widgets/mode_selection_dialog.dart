import 'dart:ui';
import 'package:exam_app/core/router/app_router.dart';
import 'package:exam_app/core/theme.dart';
import 'package:exam_app/features/quiz/presentation/bloc/question_state.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ModeSelectionDialog extends StatelessWidget {
  final String year;
  final String subjectId;
  final String? chapterId;
  final String? region;
  final VoidCallback? onCancel;

  const ModeSelectionDialog({
    super.key,
    required this.year,
    required this.subjectId,
    this.chapterId,
    this.region,
    this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
      child: Dialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: BorderRadius.circular(cardRadius),
            boxShadow: [
              BoxShadow(
                color: colorScheme.shadow.withOpacity(0.1),
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
                style: textTheme.titleLarge?.copyWith(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: colorScheme.onSurface,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Choose how you want to take this exam',
                style: textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurface.withOpacity(0.7),
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
                      'region': region,
                    },
                  );
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
                    },
                  );
                },
              ),
              const SizedBox(height: 24),
              TextButton(
                onPressed: () {
                  context.pop();
                  onCancel?.call();
                },
                child: Text(
                  'Cancel',
                  style: textTheme.titleMedium?.copyWith(
                    color: colorScheme.onSurface.withOpacity(0.7),
                    fontSize: 16,
                  ),
                ),
              ),
            ],
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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(cardRadius),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border.all(
              color: colorScheme.outline.withOpacity(0.15),
              width: 1.5,
            ),
            borderRadius: BorderRadius.circular(cardRadius),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: colorScheme.primary.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  color: colorScheme.primary,
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
                      style: textTheme.titleMedium?.copyWith(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurface.withOpacity(0.7),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: colorScheme.onSurface.withOpacity(0.7),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
