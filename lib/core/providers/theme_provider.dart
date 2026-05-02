import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/settings_repository.dart';
import 'repository_providers.dart';

final themeModeProvider = StateNotifierProvider<ThemeModeNotifier, ThemeMode>((ref) {
  final repo = ref.watch(settingsRepositoryProvider);
  return ThemeModeNotifier(repo);
});

class ThemeModeNotifier extends StateNotifier<ThemeMode> {
  final SettingsRepository _repo;

  ThemeModeNotifier(this._repo) : super(ThemeMode.system) {
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    final themeString = await _repo.getThemeMode();
    state = _fromString(themeString);
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    state = mode;
    await _repo.setThemeMode(_toString(mode));
  }

  ThemeMode _fromString(String val) {
    switch (val) {
      case 'light': return ThemeMode.light;
      case 'dark': return ThemeMode.dark;
      default: return ThemeMode.system;
    }
  }

  String _toString(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light: return 'light';
      case ThemeMode.dark: return 'dark';
      case ThemeMode.system: return 'system';
    }
  }
}
