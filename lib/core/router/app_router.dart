import 'package:exam_app/features/auth/presentation/screens/home_screen.dart';
import 'package:exam_app/features/auth/presentation/screens/registration_screen.dart';
import 'package:exam_app/features/payment/presentation/screens/transaction_verification_screen.dart';
import 'package:exam_app/features/quiz/presentation/bloc/question_state.dart';
import 'package:exam_app/features/quiz/presentation/screens/question_screen.dart';
import 'package:exam_app/features/quiz/presentation/screens/subject_selection_screen.dart';
import 'package:exam_app/features/quiz/presentation/screens/year_selection_screen.dart';
import 'package:exam_app/features/faq/presentation/screens/faq_screen.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';

class RoutePaths {
  static const String login = '/login';
  static const String signUp = '/signup';
  static const String home = '/home';
  static const String subjects = '/subjects';
  static const String years = '/years';
  static const String questions = '/questions';
  static const String profile = '/profile';
  static const String faq = '/faq';
  static const String contact = '/contact';
  static const String about = '/about';
  static const String settings = '/settings';
  static const String transactionVerification = '/transaction-verification';
  
  // Deep link paths
  static const String deepLinkQuestions = '/questions/:questionId';
}

class AppRouter {
  static final GoRouter router = GoRouter(
    routes: [
      GoRoute(
        path: '/',
        redirect: (context, state) => RoutePaths.login,
      ),
      GoRoute(
        path: RoutePaths.signUp,
        name: 'SignUp',
        builder: (context, state) => const RegistrationScreen(),
      ),
      GoRoute(
        path: RoutePaths.home,
        name: 'Home',
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: RoutePaths.subjects,
        name: 'Subjects',
        builder: (context, state) => SubjectSelectionScreen(),
      ),
      GoRoute(
        path: RoutePaths.years,
        name: 'Years',
        builder: (context, state) => YearSelectionScreen(),
      ),
      GoRoute(
        path: RoutePaths.questions,
        name: 'Questions',
        builder: (context, state) {
          final chapter = state.pathParameters['chapter'] ?? '';
          final year = int.tryParse(state.pathParameters['year'] ?? '');
          final mode = state.pathParameters['mode'] == 'practice' 
              ? QuestionMode.practice 
              : QuestionMode.quiz;
          return QuestionScreen(
            chapter: chapter.isNotEmpty ? chapter : null,
            year: year,
            isQuizMode: mode == QuestionMode.quiz,
          );
        },
      ),
      GoRoute(
        path: RoutePaths.profile,
        name: 'Profile',
        builder: (context, state) => const Scaffold(
          body: Center(child: Text('Profile Screen - Coming Soon')),
        ),
      ),
      GoRoute(
        path: RoutePaths.faq,
        name: 'FAQ',
        builder: (context, state) => const FAQScreen(),
      ),
      GoRoute(
        path: RoutePaths.contact,
        name: 'Contact',
        builder: (context, state) => const Scaffold(
          body: Center(child: Text('Contact Screen - Coming Soon')),
        ),
      ),
      GoRoute(
        path: RoutePaths.about,
        name: 'About',
        builder: (context, state) => const Scaffold(
          body: Center(child: Text('About Screen - Coming Soon')),
        ),
      ),
      GoRoute(
        path: RoutePaths.settings,
        name: 'Settings',
        builder: (context, state) => const Scaffold(
          body: Center(child: Text('Settings Screen - Coming Soon')),
        ),
      ),
      GoRoute(
        path: RoutePaths.transactionVerification,
        name: 'TransactionVerification',
        builder: (context, state) => TransactionVerificationScreen.withBloc(),
      ),
    ],
    initialLocation: RoutePaths.home,
    debugLogDiagnostics: true,
    errorPageBuilder: (context, state) => MaterialPage<void>(
      key: state.pageKey,
      child: ErrorScreen(error: state.error),
    ),
    redirect: (context, state) {
      // Add authentication redirect logic here
      return null;
    },
  );
}

class ErrorScreen extends StatelessWidget {
  final Exception? error;
  
  const ErrorScreen({super.key, this.error});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Error')),
      body: Center(
        child: Text(error?.toString() ?? 'Page not found'),
      ),
    );
  }
}