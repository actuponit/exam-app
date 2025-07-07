import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'services/theme_persistence_service.dart';
import 'theme.dart';

part 'theme_state.dart';

class ThemeCubit extends Cubit<ThemeState> {
  ThemeCubit()
      : super(ThemeState(
          themeMode: ThemeMode.system,
          themeData: getAppTheme(),
        ));

  /// Initialize the theme by loading saved preference
  Future<void> initializeTheme() async {
    final savedThemeMode = await ThemePersistenceService.loadThemeMode();
    final themeData = _getThemeData(savedThemeMode);

    emit(ThemeState(
      themeMode: savedThemeMode,
      themeData: themeData,
    ));
  }

  /// Toggle between light and dark themes
  Future<void> toggleTheme() async {
    final newThemeMode =
        state.themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;

    await _updateTheme(newThemeMode);
  }

  /// Set specific theme mode
  Future<void> setTheme(ThemeMode mode) async {
    await _updateTheme(mode);
  }

  /// Private method to update theme and save preference
  Future<void> _updateTheme(ThemeMode mode) async {
    final themeData = _getThemeData(mode);

    emit(ThemeState(
      themeMode: mode,
      themeData: themeData,
    ));

    // Save the preference
    await ThemePersistenceService.saveThemeMode(mode);
  }

  /// Get theme data based on mode
  ThemeData _getThemeData(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.dark:
        return getDarkAppTheme();
      case ThemeMode.light:
        return getAppTheme();
      case ThemeMode.system:
        // For system mode, we'll default to light
        // The MaterialApp will handle system theme switching
        return getAppTheme();
    }
  }
}
