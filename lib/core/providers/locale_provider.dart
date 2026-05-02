import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/settings_repository.dart';
import 'repository_providers.dart';

final localeProvider = StateNotifierProvider<LocaleNotifier, Locale>((ref) {
  final repo = ref.watch(settingsRepositoryProvider);
  return LocaleNotifier(repo);
});

class LocaleNotifier extends StateNotifier<Locale> {
  final SettingsRepository _repo;

  LocaleNotifier(this._repo) : super(const Locale('en')) {
    _loadLocale();
  }

  Future<void> _loadLocale() async {
    final code = await _repo.getLanguageCode();
    state = Locale(code);
  }

  Future<void> setLocale(Locale locale) async {
    state = locale;
    await _repo.setLanguageCode(locale.languageCode);
  }
}
