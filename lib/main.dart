import 'package:exam_app/core/di/injection.dart';
import 'package:exam_app/core/router/app_router.dart';
import 'package:exam_app/core/theme.dart';
import 'package:exam_app/core/theme_cubit.dart';
import 'package:exam_app/features/auth/data/repositories/auth_repository.dart';
import 'package:exam_app/features/auth/presentation/blocs/auth_bloc/auth_bloc.dart';
import 'package:exam_app/features/auth/presentation/blocs/registration_form_bloc/registration_form_bloc.dart';
import 'package:exam_app/features/exams/presentation/bloc/recent_exam_bloc/recent_exam_cubit.dart';
import 'package:exam_app/features/payment/presentation/bloc/subscription_bloc.dart';
import 'package:exam_app/features/profile/presentation/bloc/profile_cubit.dart';
import 'package:exam_app/features/quiz/domain/repositories/question_repository.dart';
import 'package:exam_app/features/quiz/presentation/bloc/exam_bloc/exam_bloc.dart';
import 'package:exam_app/features/quiz/presentation/bloc/question_bloc.dart';
import 'package:exam_app/features/quiz/presentation/bloc/subject_bloc/subject_bloc.dart';
import 'package:exam_app/features/splash/presentation/cubit/splash_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await configureDependencies();
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        // ...existing BlocProviders...
        BlocProvider(
          create: (context) => getIt<AuthBloc>(),
        ),
        BlocProvider(
          create: (context) => RegistrationBloc(),
        ),
        BlocProvider(
          create: (context) => getIt<SubscriptionBloc>(),
        ),
        BlocProvider(
          create: (context) => getIt<SplashCubit>(),
        ),
        BlocProvider(
          create: (context) => getIt<ExamBloc>(),
        ),
        BlocProvider(
          create: (context) => QuestionBloc(
            repository: getIt<QuestionRepository>(),
          ),
        ),
        BlocProvider(
          create: (context) => getIt<SubjectBloc>(),
        ),
        BlocProvider(
          create: (context) => getIt<RecentExamCubit>()..loadRecentExam(),
        ),
        BlocProvider(
          create: (context) =>
              ProfileCubit(authRepository: getIt<AuthRepository>()),
        ),
        BlocProvider(
          create: (context) => ThemeCubit(),
        ),
      ],
      child: BlocBuilder<ThemeCubit, ThemeState>(
        builder: (context, state) {
          return MaterialApp.router(
            routerConfig: AppRouter.router,
            theme: getAppTheme(),
            darkTheme: getDarkAppTheme(),
            themeMode: state.themeMode,
            debugShowCheckedModeBanner: false,
          );
        },
      ),
    );
  }
}
