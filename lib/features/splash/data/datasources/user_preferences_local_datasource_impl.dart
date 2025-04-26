import 'package:exam_app/features/splash/data/datasources/user_preferences_local_datasource.dart';
import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';

@LazySingleton(as: UserPreferencesLocalDataSource)
class UserPreferencesLocalDataSourceImpl
    implements UserPreferencesLocalDataSource {
  final SharedPreferences _sharedPreferences;

  // Keys for SharedPreferences
  static const String _onboardingCompletedKey = 'onboarding_completed';

  UserPreferencesLocalDataSourceImpl(this._sharedPreferences);

  @override
  Future<bool> getOnboardingCompleted() async {
    return _sharedPreferences.getBool(_onboardingCompletedKey) ?? false;
  }

  @override
  Future<void> setOnboardingCompleted(bool completed) async {
    await _sharedPreferences.setBool(_onboardingCompletedKey, completed);
  }
}
