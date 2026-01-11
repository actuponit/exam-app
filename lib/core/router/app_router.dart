import 'package:exam_app/core/di/injection.dart';
import 'package:exam_app/features/about/presentation/screens/about_us_screen.dart';
import 'package:exam_app/features/auth/data/repositories/auth_repository.dart';
import 'package:exam_app/features/auth/presentation/blocs/password_reset/password_reset_bloc.dart';
import 'package:exam_app/features/auth/presentation/screens/home_screen.dart';
import 'package:exam_app/features/auth/presentation/screens/login_screen.dart';
import 'package:exam_app/features/auth/presentation/screens/registration_screen.dart';
import 'package:exam_app/features/auth/presentation/screens/reset_password_screen.dart';
import 'package:exam_app/features/auth/presentation/screens/video_walkthrough_screen.dart';
import 'package:exam_app/features/auth/presentation/screens/forget_password_email_screen.dart';
import 'package:exam_app/features/auth/presentation/screens/forget_password_otp_screen.dart';
import 'package:exam_app/features/auth/presentation/screens/welcome_screen.dart';
import 'package:exam_app/features/contacts/presentation/screens/contacts_screen.dart';
import 'package:exam_app/features/notes/presentation/screens/note_detail_screen.dart';
import 'package:exam_app/features/payment/presentation/screens/transaction_verification_screen.dart';
import 'package:exam_app/features/profile/presentation/screens/profile_screen.dart';
import 'package:exam_app/features/quiz/presentation/bloc/question_state.dart';
import 'package:exam_app/features/quiz/presentation/screens/question_screen.dart';
import 'package:exam_app/features/quiz/presentation/screens/subject_selection_screen.dart';
import 'package:exam_app/features/quiz/presentation/screens/year_chapter_selection_screen.dart';
import 'package:exam_app/features/faq/presentation/screens/faq_screen.dart';
import 'package:exam_app/features/splash/presentation/screens/splash_screen.dart';
import 'package:exam_app/features/settings/presentation/settings_screen.dart';
import 'package:exam_app/features/notifications/presentation/pages/notification_page.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';

class RoutePaths {
  static const String splash = '/splash';
  static const String welcome = '/welcome';
  static const String videoWalkthrough = '/video-walkthrough';
  static const String login = '/login';
  static const String signUp = '/signup';
  static const String forgetPassword = '/forget-password';
  static const String forgetPasswordOtp = '/forget-password/otp';
  static const String forgetPasswordReset = '/forget-password/reset';
  static const String home = '/home';
  static const String subjects = '/subjects';
  static const String years = '/years';
  static const String questions = '/questions';
  static const String profile = '/profile';
  static const String faq = '/faq';
  static const String contact = '/contact';
  static const String about = '/about';
  static const String settings = '/settings';
  static const String notes = '/notes';
  static const String noteDetail = '/notes/detail';
  static const String transactionVerification = '/transaction-verification';

  // Deep link paths
  static const String deepLinkQuestions = '/questions/:questionId';
  static const String notifications = '/notifications';
}

class AppRouter {
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  static final GoRouter router = GoRouter(
    navigatorKey: navigatorKey,
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
        path: RoutePaths.welcome,
        name: 'Welcome',
        builder: (context, state) => const WelcomeScreen(),
      ),
      GoRoute(
        path: RoutePaths.videoWalkthrough,
        name: 'VideoWalkthrough',
        builder: (context, state) => const VideoWalkthroughScreen(),
      ),
      GoRoute(
        path: RoutePaths.login,
        name: 'Login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: RoutePaths.forgetPassword,
        name: 'ForgetPassword',
        builder: (context, state) => BlocProvider(
          create: (context) => PasswordResetBloc(getIt<AuthRepository>()),
          child: const ForgetPasswordEmailScreen(),
        ),
      ),
      GoRoute(
        path: RoutePaths.forgetPasswordReset,
        name: 'ForgetPasswordReset',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          final email = extra != null ? extra['email'] as String? : null;
          final resetToken =
              extra != null ? extra['resetToken'] as String? : null;
          return BlocProvider(
            create: (_) => PasswordResetBloc(getIt<AuthRepository>()),
            child: ResetPasswordScreen(email: email, resetToken: resetToken),
          );
        },
      ),
      GoRoute(
        path: RoutePaths.signUp,
        name: 'SignUp',
        builder: (context, state) => const RegistrationScreen(),
      ),
      GoRoute(
        path: RoutePaths.forgetPasswordOtp,
        name: 'ForgetPasswordOtp',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          final email = extra != null ? extra['email'] as String? : null;
          return BlocProvider(
            create: (context) => PasswordResetBloc(getIt<AuthRepository>()),
            child: ForgetPasswordOtpScreen(email: email),
          );
        },
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
          final extra = state.extra as Map<String, dynamic>? ?? {};
          final duration = extra['duration'] as int? ?? 2;
          final region = extra['region'] as String?;
          final subjectName = extra['subjectName'] as String? ?? 'Subject';
          return YearChapterSelectionScreen(
            subjectId: subjectId,
            subjectName: subjectName,
            duration: duration,
            region: region,
          );
        },
      ),
      GoRoute(
        path: '${RoutePaths.years}/:subjectId/:year${RoutePaths.questions}',
        name: 'Questions',
        builder: (context, state) {
          final subjectId = state.pathParameters['subjectId'] ?? '';
          final year = state.pathParameters['year'] ?? '';

          final extra = state.extra as Map<String, dynamic>? ?? {};
          final chapterId = extra['chapterId'];
          final mode = extra['mode'] ?? QuestionMode.practice;
          final region = extra['region'];

          return QuestionScreen(
            subjectId: subjectId,
            chapterId: chapterId,
            year: year,
            isQuizMode: mode == QuestionMode.quiz,
            region: region,
          );
        },
      ),
      GoRoute(
        path: RoutePaths.profile,
        name: 'Profile',
        builder: (context, state) => ProfileScreen(),
      ),
      GoRoute(
        path: RoutePaths.faq,
        name: 'FAQ',
        builder: (context, state) => const FAQScreen(),
      ),
      GoRoute(
        path: RoutePaths.contact,
        name: 'Contact',
        builder: (context, state) => ContactsScreen(),
      ),
      GoRoute(
        path: RoutePaths.about,
        name: 'About',
        builder: (context, state) => AboutUsScreen(),
      ),
      GoRoute(
        path: RoutePaths.settings,
        name: 'Settings',
        builder: (context, state) => const SettingsScreen(),
      ),
      // GoRoute(
      //   path: RoutePaths.notes,
      //   name: 'Notes',
      //   builder: (context, state) => const NotesScreen(),
      // ),
      GoRoute(
        path: '${RoutePaths.noteDetail}/:noteId',
        name: 'NoteDetail',
        builder: (context, state) {
          final noteId = state.pathParameters['noteId'] ?? '';
          return NoteDetailScreen(noteId: noteId);
        },
      ),
      GoRoute(
        path: RoutePaths.transactionVerification,
        name: 'TransactionVerification',
        builder: (context, state) => const TransactionVerificationScreen(),
      ),
      GoRoute(
        path: RoutePaths.notifications,
        name: 'Notifications',
        builder: (context, state) => const NotificationPage(),
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
