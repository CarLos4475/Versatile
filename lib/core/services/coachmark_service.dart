import '../../data/repositories/settings_repository.dart';

class CoachmarkService {
  CoachmarkService(this._settings);
  final SettingsRepository _settings;

  Future<bool> shouldShow(String id) async {
    return (await _settings.get('coachmark_v1_$id')) == null;
  }

  Future<void> markSeen(String id) => _settings.set('coachmark_v1_$id', '1');
}
