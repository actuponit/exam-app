import 'package:exam_app/features/auth/data/datasources/auth_data_source.dart';
import 'package:exam_app/features/splash/data/datasources/user_preferences_local_datasource.dart';
import 'package:exam_app/features/splash/domain/repositories/user_preferences_repository.dart';
import 'package:injectable/injectable.dart';

@LazySingleton(as: UserPreferencesRepository)
class UserPreferencesRepositoryImpl implements UserPreferencesRepository {
  final UserPreferencesLocalDataSource _localDataSource;
  final LocalAuthDataSource _localAuthDataSource;

  UserPreferencesRepositoryImpl(
      this._localDataSource, this._localAuthDataSource);

  @override
  Future<bool> hasCompletedOnboarding() async {
    return _localDataSource.getOnboardingCompleted();
  }

  @override
  Future<void> completeOnboarding() async {
    await _localDataSource.setOnboardingCompleted(true);
  }

  @override
  Future<bool> isUserLoggedIn() async {
    final userId = await _localAuthDataSource.getUserId();
    return userId != null;
  }
}
