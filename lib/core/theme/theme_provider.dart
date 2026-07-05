import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'app_colors.dart';

class ThemeState {
  final ThemeMode themeMode;
  final Color primaryColor;

  const ThemeState({
    required this.themeMode,
    required this.primaryColor,
  });

  ThemeState copyWith({
    ThemeMode? themeMode,
    Color? primaryColor,
  }) {
    return ThemeState(
      themeMode: themeMode ?? this.themeMode,
      primaryColor: primaryColor ?? this.primaryColor,
    );
  }
}

class ThemeNotifier extends StateNotifier<ThemeState> {
  static const _themeModeKey = 'theme_mode';
  static const _primaryColorKey = 'primary_color';

  ThemeNotifier() : super(const ThemeState(
    themeMode: ThemeMode.dark, 
    primaryColor: AppColors.primary,
  )) {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    
    // Load Theme Mode
    final modeStr = prefs.getString(_themeModeKey);
    ThemeMode mode = ThemeMode.dark;
    if (modeStr == 'light') mode = ThemeMode.light;
    else if (modeStr == 'system') mode = ThemeMode.system;

    // Load Primary Color
    final colorValue = prefs.getInt(_primaryColorKey);
    Color color = AppColors.primary;
    if (colorValue != null) {
      color = Color(colorValue);
    }

    state = ThemeState(themeMode: mode, primaryColor: color);
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_themeModeKey, mode.name);
    state = state.copyWith(themeMode: mode);
  }

  Future<void> setPrimaryColor(Color color) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_primaryColorKey, color.value);
    state = state.copyWith(primaryColor: color);
  }
}

final themeProvider = StateNotifierProvider<ThemeNotifier, ThemeState>((ref) {
  return ThemeNotifier();
});
