// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:dio/dio.dart' as _i361;
import 'package:get_it/get_it.dart' as _i174;
import 'package:injectable/injectable.dart' as _i526;
import 'package:internet_connection_checker/internet_connection_checker.dart'
    as _i973;
import 'package:shared_preferences/shared_preferences.dart' as _i460;

import '../../features/auth/data/datasources/auth_data_source.dart' as _i970;
import '../../features/auth/data/repositories/auth_repository.dart' as _i573;
import '../../features/auth/presentation/blocs/auth_bloc/auth_bloc.dart'
    as _i661;
import '../../features/exams/domain/repositories/exam_repository.dart' as _i254;
import '../../features/exams/domain/repositories/subject_repository.dart'
    as _i634;
import '../../features/payment/data/datasources/subscription_data_source.dart'
    as _i900;
import '../../features/payment/data/datasources/subscription_local_data_source.dart'
    as _i622;
import '../../features/payment/domain/repositories/subscription_repository.dart'
    as _i611;
import '../../features/payment/presentation/bloc/subscription_bloc.dart'
    as _i383;
import '../../features/quiz/domain/repositories/question_repository.dart'
    as _i837;
import '../../features/quiz/presentation/bloc/exam_bloc/exam_bloc.dart'
    as _i1020;
import '../../features/quiz/presentation/bloc/subject_bloc/subject_bloc.dart'
    as _i354;
import '../../features/splash/data/datasources/user_preferences_local_datasource.dart'
    as _i293;
import '../../features/splash/data/datasources/user_preferences_local_datasource_impl.dart'
    as _i424;
import '../../features/splash/data/repositories/user_preferences_repository_impl.dart'
    as _i429;
import '../../features/splash/domain/repositories/user_preferences_repository.dart'
    as _i421;
import '../../features/splash/presentation/cubit/splash_cubit.dart' as _i125;
import '../network/network_info.dart' as _i932;
import '../services/hive_service.dart' as _i1047;
import 'injectable_module.dart' as _i109;
import 'modules/auth_module.dart' as _i4;
import 'modules/exam_module.dart' as _i486;
import 'modules/hive_module.dart' as _i31;
import 'modules/network_module.dart' as _i851;
import 'modules/payment_module.dart' as _i81;
import 'modules/quiz_module.dart' as _i697;
import 'modules/subject_module.dart' as _i143;

// initializes the registration of main-scope dependencies inside of GetIt
Future<_i174.GetIt> init(
  _i174.GetIt getIt, {
  String? environment,
  _i526.EnvironmentFilter? environmentFilter,
}) async {
  final gh = _i526.GetItHelper(
    getIt,
    environment,
    environmentFilter,
  );
  final injectableModule = _$InjectableModule();
  final examModule = _$ExamModule();
  final subjectModule = _$SubjectModule();
  final hiveModule = _$HiveModule();
  final quizModule = _$QuizModule();
  final paymentModule = _$PaymentModule();
  final authModule = _$AuthModule();
  final networkModule = _$NetworkModule();
  await gh.factoryAsync<_i460.SharedPreferences>(
    () => injectableModule.prefs,
    preResolve: true,
  );
  gh.singleton<_i254.ExamRepository>(() => examModule.examRepository());
  gh.singleton<_i634.SubjectRepository>(
      () => subjectModule.subjectRepository());
  await gh.singletonAsync<_i1047.HiveService>(
    () => hiveModule.hiveService,
    preResolve: true,
  );
  gh.singleton<_i837.QuestionRepository>(() => quizModule.questionRepository());
  gh.lazySingleton<_i973.InternetConnectionChecker>(
      () => paymentModule.internetConnectionChecker());
  gh.lazySingleton<_i970.LocalAuthDataSource>(
      () => authModule.localAuthDataSource(gh<_i460.SharedPreferences>()));
  gh.lazySingleton<_i293.UserPreferencesLocalDataSource>(() =>
      _i424.UserPreferencesLocalDataSourceImpl(gh<_i460.SharedPreferences>()));
  gh.factory<_i354.SubjectBloc>(
      () => subjectModule.subjectBloc(gh<_i634.SubjectRepository>()));
  gh.singleton<_i361.Dio>(() => networkModule.dio(gh<_i1047.HiveService>()));
  gh.lazySingleton<_i900.SubscriptionDataSource>(
      () => paymentModule.subscriptionDataSource(gh<_i361.Dio>()));
  gh.lazySingleton<_i970.AuthDataSource>(
      () => authModule.remoteAuthDataSource(gh<_i361.Dio>()));
  gh.factory<_i1020.ExamBloc>(
      () => examModule.examBloc(gh<_i254.ExamRepository>()));
  gh.lazySingleton<_i622.SubscriptionLocalDataSource>(() =>
      paymentModule.subscriptionLocalDataSource(gh<_i460.SharedPreferences>()));
  gh.lazySingleton<_i932.NetworkInfo>(
      () => paymentModule.networkInfo(gh<_i973.InternetConnectionChecker>()));
  gh.lazySingleton<_i421.UserPreferencesRepository>(
      () => _i429.UserPreferencesRepositoryImpl(
            gh<_i293.UserPreferencesLocalDataSource>(),
            gh<_i970.LocalAuthDataSource>(),
          ));
  gh.lazySingleton<_i573.AuthRepository>(() => authModule.authRepository(
        gh<_i970.AuthDataSource>(),
        gh<_i970.LocalAuthDataSource>(),
      ));
  gh.lazySingleton<_i611.SubscriptionRepository>(
      () => paymentModule.subscriptionRepository(
            gh<_i900.SubscriptionDataSource>(),
            gh<_i622.SubscriptionLocalDataSource>(),
            gh<_i970.LocalAuthDataSource>(),
            gh<_i932.NetworkInfo>(),
          ));
  gh.factory<_i125.SplashCubit>(
      () => _i125.SplashCubit(gh<_i421.UserPreferencesRepository>()));
  gh.lazySingleton<_i661.AuthBloc>(
      () => authModule.authBloc(gh<_i573.AuthRepository>()));
  gh.factory<_i383.SubscriptionBloc>(
      () => paymentModule.subscriptionBloc(gh<_i611.SubscriptionRepository>()));
  return getIt;
}

class _$InjectableModule extends _i109.InjectableModule {}

class _$ExamModule extends _i486.ExamModule {}

class _$SubjectModule extends _i143.SubjectModule {}

class _$HiveModule extends _i31.HiveModule {}

class _$QuizModule extends _i697.QuizModule {}

class _$PaymentModule extends _i81.PaymentModule {}

class _$AuthModule extends _i4.AuthModule {}

class _$NetworkModule extends _i851.NetworkModule {}
