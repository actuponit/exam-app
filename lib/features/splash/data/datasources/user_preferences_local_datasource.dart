abstract class UserPreferencesLocalDataSource {
  /// Gets whether onboarding is completed
  Future<bool> getOnboardingCompleted();

  /// Sets onboarding as completed
  Future<void> setOnboardingCompleted(bool completed);
}
