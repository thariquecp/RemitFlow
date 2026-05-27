import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeState extends Equatable {
  final ThemeMode themeMode;
  
  const ThemeState({required this.themeMode});

  @override
  List<Object?> get props => [themeMode];
}

class ThemeCubit extends Cubit<ThemeState> {
  static const _key = 'theme_mode_enum';
  final SharedPreferences _prefs;

  ThemeCubit(this._prefs) : super(ThemeState(themeMode: _parseThemeMode(_prefs.getString(_key))));

  static ThemeMode _parseThemeMode(String? value) {
    switch (value) {
      case 'light': return ThemeMode.light;
      case 'dark': return ThemeMode.dark;
      default: return ThemeMode.system;
    }
  }

  void setThemeMode(ThemeMode mode) {
    _prefs.setString(_key, mode.name);
    emit(ThemeState(themeMode: mode));
  }
}
