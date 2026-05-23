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
        'iconCode': r['icon_code'],
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
          'muscle': se['muscle'],
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
        'iconCode': s['icon_code'],
        'date': s['date'],
        'durationMin': s['duration_min'],
        'volumeKg': s['volume_kg'],
        'exercises': exercises,
      });
    }

    final logRows = await db.query('workout_log');

    final programRows = await db.query('programs');
    final programs = <Map<String, dynamic>>[];
    for (final p in programRows) {
      final pId = p['id'] as String;
      final slotRows = await db.query(
        'program_slots',
        where: 'program_id = ?',
        whereArgs: [pId],
      );
      programs.add({
        'id': pId,
        'name': p['name'],
        'colorValue': p['color_value'],
        'iconCode': p['icon_code'],
        'weeksCount': p['weeks_count'],
        'deloadWeeks': p['deload_weeks'],
        'createdAt': p['created_at'],
        'slots': slotRows.map((s) => {
          'id': s['id'],
          'weekIndex': s['week_index'],
          'weekday': s['weekday'],
          'slotKind': s['slot_kind'],
          'routineId': s['routine_id'],
          'labelText': s['label_text'],
        }).toList(),
      });
    }

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
      'programs': programs,
    });
  }

  static Future<void> importJson(String jsonStr) async {
    final Map<String, dynamic> data;
    try {
      data = jsonDecode(jsonStr) as Map<String, dynamic>;
    } catch (_) {
      throw const FormatException('Invalid JSON format');
    }

    // Sanity check: make sure this looks like a Versatile backup
    if (!data.containsKey('routines') && !data.containsKey('sessions')) {
      throw const FormatException('File does not appear to be a Versatile backup');
    }

    final db = await DatabaseHelper.instance.database;

    await db.transaction((txn) async {
      // Wipe all user data
      await txn.delete('session_sets');
      await txn.delete('session_exercises');
      await txn.delete('sessions');
      await txn.delete('routine_exercises');
      await txn.delete('routines');
      await txn.delete('program_slots');
      await txn.delete('programs');
      await txn.delete('workout_log');
      await txn.delete('exercises', where: 'is_custom = ?', whereArgs: [1]);
      await txn.delete('settings');

      // Settings
      final settings = data['settings'] as Map<String, dynamic>?;
      final name = settings?['userName'] as String?;
      if (name != null && name.isNotEmpty) {
        await txn.insert('settings', {'key': 'user_name', 'value': name});
      }

      // Custom exercises
      final exercises = data['exercises'] as List<dynamic>? ?? [];
      for (final e in exercises) {
        await txn.insert('exercises', {
          'id': e['id'],
          'name': e['name'],
          'muscle': e['muscle'],
          'equipment': e['equipment'],
          'is_custom': 1,
          'is_unilateral': (e['isUnilateral'] as bool? ?? false) ? 1 : 0,
        });
      }

      // Routines
      final routines = data['routines'] as List<dynamic>? ?? [];
      for (final r in routines) {
        await txn.insert('routines', {
          'id': r['id'],
          'name': r['name'],
          'color_value': r['colorValue'],
          'icon_code': r['iconCode'] ?? 58713,
        });
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
        await txn.insert('sessions', {
          'id': s['id'],
          'routine_id': s['routineId'],
          'routine_name': s['routineName'],
          'color_value': s['colorValue'] ?? 0xFFD97757,
          'icon_code': s['iconCode'] ?? 58713,
          'date': s['date'],
          'duration_min': s['durationMin'],
          'volume_kg': s['volumeKg'],
        });
        final sExercises = s['exercises'] as List<dynamic>? ?? [];
        for (var i = 0; i < sExercises.length; i++) {
          final se = sExercises[i];
          final seId = await txn.insert('session_exercises', {
            'session_id': s['id'],
            'exercise_id': se['exerciseId'],
            'exercise_name': se['name'],
            'muscle': se['muscle'] ?? 'Other',
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
        await txn.insert('workout_log', {'date': day});
      }

      // Programs
      final programs = data['programs'] as List<dynamic>? ?? [];
      for (final p in programs) {
        await txn.insert('programs', {
          'id': p['id'],
          'name': p['name'],
          'color_value': p['colorValue'],
          'icon_code': p['iconCode'] ?? 58713,
          'weeks_count': p['weeksCount'],
          'deload_weeks': p['deloadWeeks'] ?? '',
          'created_at': p['createdAt'],
        });
        final slots = p['slots'] as List<dynamic>? ?? [];
        for (final s in slots) {
          await txn.insert('program_slots', {
            'id': s['id'],
            'program_id': p['id'],
            'week_index': s['weekIndex'],
            'weekday': s['weekday'],
            'slot_kind': s['slotKind'],
            'routine_id': s['routineId'],
            'label_text': s['labelText'],
          });
        }
      }
    });
  }
}
