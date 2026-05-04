import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/settings_repository.dart';
import '../theme/accent_colors.dart';
import 'repository_providers.dart';

final accentProvider = StateNotifierProvider<AccentNotifier, AccentOption>((ref) {
  final repo = ref.watch(settingsRepositoryProvider);
  return AccentNotifier(repo);
});

class AccentNotifier extends StateNotifier<AccentOption> {
  final SettingsRepository _repo;

  AccentNotifier(this._repo) : super(AccentColors.options.first) {
    _loadAccent();
  }

  Future<void> _loadAccent() async {
    final id = await _repo.getAccentColorId();
    state = AccentColors.fromId(id);
  }

  Future<void> setAccent(AccentOption option) async {
    state = option;
    await _repo.setAccentColorId(option.id);
  }
}
