import 'package:exam_app/core/di/injection.dart';
import 'package:exam_app/core/router/app_router.dart';
import 'package:exam_app/core/theme.dart';
import 'package:exam_app/features/auth/presentation/blocs/auth_bloc/auth_bloc.dart';
import 'package:exam_app/features/auth/presentation/blocs/registration_form_bloc/registration_form_bloc.dart';
import 'package:exam_app/features/exams/domain/repositories/exam_repository.dart';
import 'package:exam_app/features/exams/domain/repositories/subject_repository.dart';
import 'package:exam_app/features/quiz/presentation/bloc/exam_bloc/exam_bloc.dart';
import 'package:exam_app/features/quiz/presentation/bloc/subject_bloc/subject_bloc.dart';
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
        BlocProvider(
          create: (context) => getIt<AuthBloc>(),
        ),
        BlocProvider(
          create: (context) => RegistrationBloc(),
        ),
        BlocProvider(
            create: (context) => SubjectBloc(getIt<SubjectRepository>())),
        BlocProvider(create: (context) => ExamBloc(getIt<ExamRepository>()))
      ],
      child: MaterialApp.router(
        routerConfig: AppRouter.router,
        theme: getAppTheme(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
