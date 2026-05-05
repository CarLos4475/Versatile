import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/services.dart';
import '../../data/repositories/settings_repository.dart';

class SoundService {
  static const _channel = MethodChannel('com.example.versatile/workout');

  final SettingsRepository _settings;
  AudioPlayer? _player;

  SoundService(this._settings);

  Future<bool> get isAlertEnabled async {
    final v = await _settings.get('rest_alert_enabled');
    return v != 'false';
  }

  Future<String> get soundType async {
    return await _settings.get('rest_alert_sound_type') ?? 'default';
  }

  Future<String?> get customPath async {
    return await _settings.get('rest_alert_custom_path');
  }

  Future<void> setAlertEnabled(bool enabled) =>
      _settings.set('rest_alert_enabled', enabled ? 'true' : 'false');

  Future<void> setSoundType(String type) =>
      _settings.set('rest_alert_sound_type', type);

  Future<void> setCustomPath(String path) =>
      _settings.set('rest_alert_custom_path', path);

  Future<void> playAlertSound({required String exerciseName}) async {
    final enabled = await isAlertEnabled;
    if (!enabled) return;

    final type = await soundType;

    HapticFeedback.heavyImpact();

    try {
      await _channel.invokeMethod('showRestAlert', {
        'exerciseName': exerciseName,
      });
    } catch (_) {}

    if (type == 'custom') {
      final path = await customPath;
      if (path != null && path.isNotEmpty) {
        _player ??= AudioPlayer();
        await _player!.setVolume(1.0);
        await _player!.play(DeviceFileSource(path));
      }
    }
  }

  void dispose() {
    _player?.dispose();
    _player = null;
  }
}
