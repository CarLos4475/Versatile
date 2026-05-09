import 'dart:ui';
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
    final saved = await _repo.get('language_code');
    if (saved != null) {
      state = Locale(saved);
    } else {
      final deviceCode = PlatformDispatcher.instance.locale.languageCode;
      final resolved = deviceCode == 'es' ? 'es' : 'en';
      state = Locale(resolved);
      await _repo.setLanguageCode(resolved);
    }
  }

  Future<void> setLocale(Locale locale) async {
    state = locale;
    await _repo.setLanguageCode(locale.languageCode);
  }
}
