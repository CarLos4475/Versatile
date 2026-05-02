import 'dart:convert';
import 'package:sqflite/sqflite.dart';
import '../../data/database/database_helper.dart';

class DataService {
  static Future<String> exportJson() async {
    final db = await DatabaseHelper.instance.database;

    final settingRows = await db.query('settings');
    final userName = settingRows
        .where((r) => r['key'] == 'user_name')
        .map((r) => r['value'] as String)
        .firstOrNull ?? 'there';

    final exerciseRows = await db.query(
      'exercises',
      where: 'is_custom = ?',
      whereArgs: [1],
    );

    final routineRows = await db.query('routines');
    final routines = <Map<String, dynamic>>[];
    for (final r in routineRows) {
      final rId = r['id'] as String;
      final reRows = await db.query(
        'routine_exercises',
        where: 'routine_id = ?',
        whereArgs: [rId],
        orderBy: 'sort_order ASC',
      );
      routines.add({
        'id': rId,
        'name': r['name'],
        'colorValue': r['color_value'],
        'exercises': reRows.map((re) => {
          'exerciseId': re['exercise_id'],
          'targetSets': re['target_sets'],
          'targetReps': re['target_reps'],
          'restSeconds': re['rest_seconds'],
        }).toList(),
      });
    }

    final sessionRows = await db.query('sessions', orderBy: 'date DESC');
    final sessions = <Map<String, dynamic>>[];
    for (final s in sessionRows) {
      final sId = s['id'] as String;
      final seRows = await db.query(
        'session_exercises',
        where: 'session_id = ?',
        whereArgs: [sId],
        orderBy: 'sort_order ASC',
      );
      final exercises = <Map<String, dynamic>>[];
      for (final se in seRows) {
        final seId = se['id'] as int;
        final setRows = await db.query(
          'session_sets',
          where: 'session_exercise_id = ?',
          whereArgs: [seId],
          orderBy: 'set_index ASC',
        );
        exercises.add({
          'exerciseId': se['exercise_id'],
          'name': se['exercise_name'],
          'sets': setRows.map((ss) => {
            'kg': ss['kg'],
            'reps': ss['reps'],
            'leftKg': ss['left_kg'],
            'leftReps': ss['left_reps'],
          }).toList(),
        });
      }
      sessions.add({
        'id': s['id'],
        'routineId': s['routine_id'],
        'routineName': s['routine_name'],
        'colorValue': s['color_value'],
        'date': s['date'],
        'durationMin': s['duration_min'],
        'volumeKg': s['volume_kg'],
        'exercises': exercises,
      });
    }

    final logRows = await db.query('workout_log');

    return jsonEncode({
      'version': '1.0',
      'exportedAt': DateTime.now().toIso8601String(),
      'settings': {'userName': userName},
      'exercises': exerciseRows.map((e) => {
        'id': e['id'],
        'name': e['name'],
        'muscle': e['muscle'],
        'equipment': e['equipment'],
        'isUnilateral': e['is_unilateral'] == 1,
      }).toList(),
      'routines': routines,
      'sessions': sessions,
      'workoutLog': logRows.map((r) => r['date']).toList(),
    });
  }

  static Future<void> importJson(String jsonStr) async {
    final data = jsonDecode(jsonStr) as Map<String, dynamic>;
    final db = await DatabaseHelper.instance.database;

    await db.transaction((txn) async {
      // Settings
      final settings = data['settings'] as Map<String, dynamic>?;
      final name = settings?['userName'] as String?;
      if (name != null && name.isNotEmpty) {
        await txn.insert(
          'settings',
          {'key': 'user_name', 'value': name},
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }

      // Custom exercises
      final exercises = data['exercises'] as List<dynamic>? ?? [];
      for (final e in exercises) {
        await txn.insert(
          'exercises',
          {
            'id': e['id'],
            'name': e['name'],
            'muscle': e['muscle'],
            'equipment': e['equipment'],
            'is_custom': 1,
            'is_unilateral': (e['isUnilateral'] as bool? ?? false) ? 1 : 0,
          },
          conflictAlgorithm: ConflictAlgorithm.ignore,
        );
      }

      // Routines
      final routines = data['routines'] as List<dynamic>? ?? [];
      for (final r in routines) {
        final inserted = await txn.insert(
          'routines',
          {
            'id': r['id'],
            'name': r['name'],
            'color_value': r['colorValue'],
          },
          conflictAlgorithm: ConflictAlgorithm.ignore,
        );
        if (inserted == 0) continue; // already exists
        final rExercises = r['exercises'] as List<dynamic>? ?? [];
        for (var i = 0; i < rExercises.length; i++) {
          final re = rExercises[i];
          await txn.insert('routine_exercises', {
            'routine_id': r['id'],
            'exercise_id': re['exerciseId'],
            'sort_order': i,
            'target_sets': re['targetSets'],
            'target_reps': re['targetReps'],
            'rest_seconds': re['restSeconds'],
          });
        }
      }

      // Sessions
      final sessions = data['sessions'] as List<dynamic>? ?? [];
      for (final s in sessions) {
        final inserted = await txn.insert(
          'sessions',
          {
            'id': s['id'],
            'routine_id': s['routineId'],
            'routine_name': s['routineName'],
            'color_value': s['colorValue'] ?? 0xFFD97757,
            'date': s['date'],
            'duration_min': s['durationMin'],
            'volume_kg': s['volumeKg'],
          },
          conflictAlgorithm: ConflictAlgorithm.ignore,
        );
        if (inserted == 0) continue;
        final sExercises = s['exercises'] as List<dynamic>? ?? [];
        for (var i = 0; i < sExercises.length; i++) {
          final se = sExercises[i];
          final seId = await txn.insert('session_exercises', {
            'session_id': s['id'],
            'exercise_id': se['exerciseId'],
            'exercise_name': se['name'],
            'sort_order': i,
          });
          final sets = se['sets'] as List<dynamic>? ?? [];
          for (var j = 0; j < sets.length; j++) {
            final ws = sets[j];
            await txn.insert('session_sets', {
              'session_exercise_id': seId,
              'set_index': j,
              'kg': ws['kg'],
              'reps': ws['reps'],
              'left_kg': ws['leftKg'],
              'left_reps': ws['leftReps'],
            });
          }
        }
      }

      // Workout log
      final workoutLog = data['workoutLog'] as List<dynamic>? ?? [];
      for (final day in workoutLog) {
        await txn.insert(
          'workout_log',
          {'date': day},
          conflictAlgorithm: ConflictAlgorithm.ignore,
        );
      }
    });
  }
}
