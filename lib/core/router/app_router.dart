import 'package:exam_app/features/auth/presentation/screens/home_screen.dart';
import 'package:exam_app/features/auth/presentation/screens/registration_screen.dart';
import 'package:exam_app/features/payment/presentation/screens/transaction_verification_screen.dart';
import 'package:exam_app/features/profile/presentation/screens/profile_screen.dart';
import 'package:exam_app/features/quiz/presentation/bloc/question_state.dart';
import 'package:exam_app/features/quiz/presentation/screens/question_screen.dart';
import 'package:exam_app/features/quiz/presentation/screens/subject_selection_screen.dart';
import 'package:exam_app/features/quiz/presentation/screens/year_selection_screen.dart';
import 'package:exam_app/features/faq/presentation/screens/faq_screen.dart';
import 'package:exam_app/features/splash/presentation/screens/splash_screen.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';

class RoutePaths {
  static const String splash = '/splash';
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
        redirect: (context, state) => RoutePaths.splash,
      ),
      GoRoute(
        path: RoutePaths.splash,
        name: 'Splash',
        builder: (context, state) => const SplashScreen(),
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
        builder: (context, state) => SubjectSelectionScreen.route,
      ),
      GoRoute(
        path: '${RoutePaths.years}/:subjectId',
        name: 'Years',
        builder: (context, state) {
          final subjectId = state.pathParameters['subjectId'] ?? '';
          final duration = state.extra as int? ?? 2;
          return YearSelectionScreen(
            subjectId: subjectId,
            duration: duration,
          );
        },
      ),
      GoRoute(
        path: '${RoutePaths.years}/:subjectId/:year${RoutePaths.questions}',
        name: 'Questions',
        builder: (context, state) {
          final subjectId = state.pathParameters['subjectId'] ?? '';
          final year = int.tryParse(state.pathParameters['year'] ?? '') ?? 0;

          final extra = state.extra as Map<String, dynamic>? ?? {};
          final chapterId = extra['chapterId'];
          final mode = extra['mode'] ?? QuestionMode.practice;

          return QuestionScreen(
            subjectId: subjectId,
            chapterId: chapterId,
            year: year,
            isQuizMode: mode == QuestionMode.quiz,
          );
        },
      ),
      GoRoute(
        path: RoutePaths.profile,
        name: 'Profile',
        builder: (context, state) => ProfileScreen.route,
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
        builder: (context, state) => const TransactionVerificationScreen(),
      ),
    ],
    initialLocation: RoutePaths.splash,
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
