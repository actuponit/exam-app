import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../features/quiz/presentation/screens/question_screen.dart';
import '../features/quiz/presentation/screens/year_chapter_selection_screen.dart';
import '../features/quiz/presentation/bloc/question_state.dart';

final router = GoRouter(
  routes: [
    // Selection screen
    GoRoute(
      path: '/select/:mode',
      builder: (context, state) => YearChapterSelectionScreen(
        mode: state.pathParameters['mode'] == 'practice'
            ? QuestionMode.practice
            : QuestionMode.quiz,
      ),
    ),

    // Questions screen - handles both filter types
    GoRoute(
      path: '/questions/:filter/:value/:mode',
      builder: (context, state) {
        final filterValue = state.pathParameters['value'] ?? '';
        final isYear = int.tryParse(filterValue) != null;

        return QuestionScreen(
          chapter: isYear ? '' : filterValue,
          year: isYear ? int.parse(filterValue) : 0,
          mode: state.pathParameters['mode'] == 'practice'
              ? QuestionMode.practice
              : QuestionMode.quiz,
        );
      },
    ),
  ],
); 