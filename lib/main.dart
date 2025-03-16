import 'package:exam_app/core/router/app_router.dart';
import 'package:exam_app/core/theme.dart';
import 'package:exam_app/features/auth/blocs/registration_form_bloc/registration_form_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'core/di.dart';

void main() {
  setupDependencies();
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => RegistrationBloc(),
        ),
      ],
      child: MaterialApp.router(
        routerConfig: AppRouter.router,
        theme: getAppTheme(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
