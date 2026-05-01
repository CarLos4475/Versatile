import 'package:sqflite/sqflite.dart';
import '../database/database_helper.dart';

class WorkoutLogRepository {
  Future<void> logDay(String date) async {
    final db = await DatabaseHelper.instance.database;
    await db.insert(
      'workout_log',
      {'date': date},
      conflictAlgorithm: ConflictAlgorithm.ignore,
    );
  }

  Future<Set<String>> getDays(int lastDays) async {
    final db = await DatabaseHelper.instance.database;
    final cutoff = DateTime.now().subtract(Duration(days: lastDays));
    final cutoffStr =
        '${cutoff.year}-${cutoff.month.toString().padLeft(2, '0')}-${cutoff.day.toString().padLeft(2, '0')}';
    final rows = await db.query(
      'workout_log',
      where: 'date >= ?',
      whereArgs: [cutoffStr],
    );
    return rows.map((r) => r['date'] as String).toSet();
  }
}