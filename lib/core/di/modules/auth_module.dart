import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:exam_app/features/auth/data/repositories/auth_repository.dart';
import 'package:exam_app/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:exam_app/features/auth/presentation/blocs/auth_bloc/auth_bloc.dart';

@module
abstract class AuthModule {
  @lazySingleton
  AuthRepository authRepository(Dio dio) => AuthRepositoryImpl(dio);

  @lazySingleton
  AuthBloc authBloc(AuthRepository authRepository) => AuthBloc(authRepository);
} 