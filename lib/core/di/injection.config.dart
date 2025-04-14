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
import 'package:shared_preferences/shared_preferences.dart' as _i460;

import '../../features/auth/data/datasources/auth_data_source.dart' as _i970;
import '../../features/auth/data/repositories/auth_repository.dart' as _i573;
import '../../features/auth/presentation/blocs/auth_bloc/auth_bloc.dart'
    as _i661;
import '../../features/quiz/domain/repositories/question_repository.dart'
    as _i837;
import '../services/hive_service.dart' as _i1047;
import 'injectable_module.dart' as _i109;
import 'modules/auth_module.dart' as _i4;
import 'modules/network_module.dart' as _i851;
import 'modules/quiz_module.dart' as _i697;

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
  final quizModule = _$QuizModule();
  final networkModule = _$NetworkModule();
  final authModule = _$AuthModule();
  await gh.factoryAsync<_i460.SharedPreferences>(
    () => injectableModule.prefs,
    preResolve: true,
  );
  gh.singleton<_i837.QuestionRepository>(() => quizModule.questionRepository());
  gh.singleton<_i361.Dio>(() => networkModule.dio);
  gh.singleton<_i1047.HiveService>(() => _i1047.HiveService());
  gh.lazySingleton<_i970.LocalAuthDataSource>(
      () => authModule.localAuthDataSource(gh<_i460.SharedPreferences>()));
  gh.lazySingleton<_i970.AuthDataSource>(
      () => authModule.remoteAuthDataSource(gh<_i361.Dio>()));
  gh.lazySingleton<_i573.AuthRepository>(() => authModule.authRepository(
        gh<_i970.AuthDataSource>(),
        gh<_i970.LocalAuthDataSource>(),
      ));
  gh.lazySingleton<_i661.AuthBloc>(
      () => authModule.authBloc(gh<_i573.AuthRepository>()));
  return getIt;
}

class _$InjectableModule extends _i109.InjectableModule {}

class _$QuizModule extends _i697.QuizModule {}

class _$NetworkModule extends _i851.NetworkModule {}

class _$AuthModule extends _i4.AuthModule {}
