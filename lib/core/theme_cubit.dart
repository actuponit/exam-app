import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'theme.dart';

part 'theme_state.dart';

class ThemeCubit extends Cubit<ThemeState> {
  ThemeCubit()
      : super(ThemeState(
          themeMode: ThemeMode.light,
          themeData: getAppTheme(),
        ));

  void toggleTheme() {
    if (state.themeMode == ThemeMode.light) {
      emit(ThemeState(
        themeMode: ThemeMode.dark,
        themeData: getDarkAppTheme(),
      ));
    } else {
      emit(ThemeState(
        themeMode: ThemeMode.light,
        themeData: getAppTheme(),
      ));
    }
  }

  void setTheme(ThemeMode mode) {
    if (mode == ThemeMode.dark) {
      emit(ThemeState(
        themeMode: ThemeMode.dark,
        themeData: getDarkAppTheme(),
      ));
    } else {
      emit(ThemeState(
        themeMode: ThemeMode.light,
        themeData: getAppTheme(),
      ));
    }
  }
}
