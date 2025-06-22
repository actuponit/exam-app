import 'package:dio/dio.dart';
import 'package:exam_app/features/exams/data/datasource/recent_exam_local_datasource.dart';
import 'package:exam_app/features/quiz/data/datasource/questions_local_datasource.dart';
import 'package:injectable/injectable.dart';
import 'package:exam_app/features/auth/data/datasources/auth_data_source.dart';
import 'package:exam_app/features/auth/data/datasources/local_auth_data_source.dart';
import 'package:exam_app/features/auth/data/datasources/remote_auth_data_source.dart';
import 'package:exam_app/features/auth/data/repositories/auth_repository.dart';
import 'package:exam_app/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:exam_app/features/auth/presentation/blocs/auth_bloc/auth_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

@module
abstract class AuthModule {
  @lazySingleton
  AuthDataSource remoteAuthDataSource(Dio dio) => RemoteAuthDataSource(dio);

  @lazySingleton
  LocalAuthDataSource localAuthDataSource(SharedPreferences prefs) =>
      LocalAuthDataSourceImpl(prefs);

  @lazySingleton
  AuthRepository authRepository(
    AuthDataSource remoteDataSource,
    LocalAuthDataSource localDataSource,
    IQuestionsLocalDatasource questionsLocalDatasource,
    IRecentExamLocalDatasource recentExamLocalDatasource,
  ) =>
      AuthRepositoryImpl(
        remoteDataSource,
        localDataSource,
        questionsLocalDatasource,
        recentExamLocalDatasource,
      );

  @lazySingleton
  AuthBloc authBloc(AuthRepository authRepository) => AuthBloc(authRepository);
}
