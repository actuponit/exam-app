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
  final VoidCallback? onCancel;

  const ModeSelectionDialog({
    super.key,
    required this.year,
    required this.subjectId,
    this.chapterId,
    this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return BackdropFilter(
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
