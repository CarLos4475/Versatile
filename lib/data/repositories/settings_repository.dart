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
}
