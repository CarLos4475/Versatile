import 'package:sqflite/sqflite.dart';
import '../database/database_helper.dart';

class SettingsRepository {
  Future<String?> get(String key) async {
    final db = await DatabaseHelper.instance.database;
    final rows = await db.query('settings', where: 'key = ?', whereArgs: [key]);
    if (rows.isEmpty) return null;
    return rows.first['value'] as String;
  }

  Future<void> set(String key, String value) async {
    final db = await DatabaseHelper.instance.database;
    await db.insert(
      'settings',
      {'key': key, 'value': value},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<String> getUserName() async => (await get('user_name')) ?? 'there';
  Future<void> setUserName(String name) => set('user_name', name);
  Future<bool> isOnboarded() async => (await get('onboarded')) == '1';
  Future<void> setOnboarded() => set('onboarded', '1');
  Future<String> getThemeMode() async => (await get('theme_mode')) ?? 'system';
  Future<void> setThemeMode(String mode) => set('theme_mode', mode);
  Future<String> getLanguageCode() async => (await get('language_code')) ?? 'en';
  Future<void> setLanguageCode(String code) => set('language_code', code);
  Future<String> getAccentColorId() async => (await get('accent_color')) ?? 'orange';
  Future<void> setAccentColorId(String id) => set('accent_color', id);

  Future<String?> getActiveProgramId() => get('active_program_id');
  Future<void> setActiveProgramId(String id) => set('active_program_id', id);
  Future<void> clearActiveProgram() async {
    final db = await DatabaseHelper.instance.database;
    await db.delete(
      'settings',
      where: 'key IN (?, ?)',
      whereArgs: ['active_program_id', 'active_program_start_date'],
    );
  }

  Future<DateTime?> getActiveProgramStartDate() async {
    final s = await get('active_program_start_date');
    if (s == null || s.isEmpty) return null;
    return DateTime.tryParse(s);
  }

  Future<void> setActiveProgramStartDate(DateTime date) =>
      set('active_program_start_date', date.toIso8601String().substring(0, 10));

  Future<bool> isRecapSeen(String monthKey) async =>
      (await get('recap_seen_$monthKey')) == '1';
  Future<void> setRecapSeen(String monthKey) =>
      set('recap_seen_$monthKey', '1');

  /// ISO date (YYYY-MM-DD) until which the deload suggestion banner stays
  /// hidden. Null when the user has never dismissed.
  Future<DateTime?> getDeloadDismissedUntil() async {
    final s = await get('deload_dismissed_until');
    if (s == null || s.isEmpty) return null;
    return DateTime.tryParse(s);
  }

  Future<void> setDeloadDismissedUntil(DateTime date) =>
      set('deload_dismissed_until', date.toIso8601String().substring(0, 10));

  Future<bool> getEditorialPhotosEnabled() async =>
      (await get('editorial_photos_enabled')) == '1';
  Future<void> setEditorialPhotosEnabled(bool enabled) =>
      set('editorial_photos_enabled', enabled ? '1' : '0');

  Future<String?> getEditorialPhotoMoodboardPath() =>
      get('editorial_photo_moodboard_path');
  Future<void> setEditorialPhotoMoodboardPath(String? path) =>
      set('editorial_photo_moodboard_path', path ?? '');

  Future<String?> getEditorialPhotoBackCoverPath() =>
      get('editorial_photo_back_cover_path');
  Future<void> setEditorialPhotoBackCoverPath(String? path) =>
      set('editorial_photo_back_cover_path', path ?? '');

  Future<String?> getEditorialQuoteMoodboard() =>
      get('editorial_quote_moodboard');
  Future<void> setEditorialQuoteMoodboard(String quote) =>
      set('editorial_quote_moodboard', quote);

  Future<String?> getEditorialQuoteBackCover() =>
      get('editorial_quote_back_cover');
  Future<void> setEditorialQuoteBackCover(String quote) =>
      set('editorial_quote_back_cover', quote);

  Future<double> getEditorialMoodboardAlignX() async =>
      double.tryParse(await get('editorial_moodboard_align_x') ?? '0.0') ?? 0.0;
  Future<void> setEditorialMoodboardAlignX(double val) =>
      set('editorial_moodboard_align_x', val.toString());

  Future<double> getEditorialMoodboardAlignY() async =>
      double.tryParse(await get('editorial_moodboard_align_y') ?? '0.0') ?? 0.0;
  Future<void> setEditorialMoodboardAlignY(double val) =>
      set('editorial_moodboard_align_y', val.toString());

  Future<double> getEditorialBackCoverAlignX() async =>
      double.tryParse(await get('editorial_back_cover_align_x') ?? '0.0') ?? 0.0;
  Future<void> setEditorialBackCoverAlignX(double val) =>
      set('editorial_back_cover_align_x', val.toString());

  Future<double> getEditorialBackCoverAlignY() async =>
      double.tryParse(await get('editorial_back_cover_align_y') ?? '0.0') ?? 0.0;
  Future<void> setEditorialBackCoverAlignY(double val) =>
      set('editorial_back_cover_align_y', val.toString());

  Future<double> getEditorialMoodboardScale() async =>
      double.tryParse(await get('editorial_moodboard_scale') ?? '1.0') ?? 1.0;
  Future<void> setEditorialMoodboardScale(double val) =>
      set('editorial_moodboard_scale', val.toString());

  Future<double> getEditorialBackCoverScale() async =>
      double.tryParse(await get('editorial_back_cover_scale') ?? '1.0') ?? 1.0;
  Future<void> setEditorialBackCoverScale(double val) =>
      set('editorial_back_cover_scale', val.toString());
}