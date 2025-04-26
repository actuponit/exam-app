abstract class UserPreferencesRepository {
  /// Checks if the user has completed onboarding
  Future<bool> hasCompletedOnboarding();

  /// Marks onboarding as completed
  Future<void> completeOnboarding();

  /// Checks if the user is logged in based on stored user ID
  Future<bool> isUserLoggedIn();
}
