import '../../data/database/database_helper.dart';
import '../../domain/entities/exercise_progress.dart';
import '../../domain/entities/session.dart';
import '../../domain/entities/workout_set.dart';

class SessionRepository {
  Future<List<Session>> getAll() async {
    final db = await DatabaseHelper.instance.database;
    final rows = await db.query('sessions', orderBy: 'date DESC, rowid DESC');
    final result = <Session>[];
    for (final r in rows) {
      final sessionId = r['id'] as String;
      result.add(Session(
        id: sessionId,
        routineId: r['routine_id'] as String,
        routineName: r['routine_name'] as String,
        colorValue: r['color_value'] as int,
        iconCode: r['icon_code'] as int? ?? 58713,
        date: r['date'] as String,
        durationMin: r['duration_min'] as int,
        volumeKg: (r['volume_kg'] as num).toDouble(),
        exercises: await _loadExercises(sessionId),
      ));
    }
    return result;
  }

  Future<void> insert(Session session) async {
    final db = await DatabaseHelper.instance.database;
    await db.insert('sessions', {
      'id': session.id,
      'routine_id': session.routineId,
      'routine_name': session.routineName,
      'color_value': session.colorValue,
      'icon_code': session.iconCode,
      'date': session.date,
      'duration_min': session.durationMin,
      'volume_kg': session.volumeKg,
    });
    final exercises = session.exercises ?? [];
    for (var i = 0; i < exercises.length; i++) {
      final se = exercises[i];
      final seId = await db.insert('session_exercises', {
        'session_id': session.id,
        'exercise_id': se.exerciseId,
        'exercise_name': se.name,
        'muscle': se.muscle,
        'sort_order': i,
      });
      for (var j = 0; j < se.sets.length; j++) {
        final s = se.sets[j];
        await db.insert('session_sets', {
          'session_exercise_id': seId,
          'set_index': j,
          'kg': s.kg,
          'reps': s.reps,
          'left_kg': s.leftKg,
          'left_reps': s.leftReps,
        });
      }
    }
  }

  Future<Map<String, List<WorkoutSet>>> getPreviousPerformance(
      String routineId) async {
    final db = await DatabaseHelper.instance.database;
    final lastRows = await db.query(
      'sessions',
      where: 'routine_id = ?',
      whereArgs: [routineId],
      orderBy: 'date DESC, rowid DESC',
      limit: 1,
    );
    if (lastRows.isEmpty) return {};
    final sessionId = lastRows.first['id'] as String;

    final seRows = await db.query(
      'session_exercises',
      where: 'session_id = ?',
      whereArgs: [sessionId],
      orderBy: 'sort_order ASC',
    );

    final result = <String, List<WorkoutSet>>{};
    for (final se in seRows) {
      final seId = se['id'] as int;
      final exerciseId = se['exercise_id'] as String;
      final setRows = await db.query(
        'session_sets',
        where: 'session_exercise_id = ?',
        whereArgs: [seId],
        orderBy: 'set_index ASC',
      );
      result[exerciseId] = setRows
          .map((s) => WorkoutSet(
                kg: (s['kg'] as num).toDouble(),
                reps: s['reps'] as int,
                leftKg: s['left_kg'] != null
                    ? (s['left_kg'] as num).toDouble()
                    : null,
                leftReps: s['left_reps'] as int?,
              ))
          .toList();
    }
    return result;
  }

  Future<List<ExerciseProgressPoint>> getExerciseProgress(
    String exerciseId,
  ) async {
    final db = await DatabaseHelper.instance.database;
    final rows = await db.rawQuery('''
      SELECT se.id AS se_id, s.date
      FROM session_exercises se
      JOIN sessions s ON s.id = se.session_id
      WHERE se.exercise_id = ?
      ORDER BY s.date ASC
    ''', [exerciseId]);

    final result = <ExerciseProgressPoint>[];
    for (final row in rows) {
      final seId = row['se_id'] as int;
      final date = row['date'] as String;
      final setRows = await db.query(
        'session_sets',
        where: 'session_exercise_id = ?',
        whereArgs: [seId],
      );
      if (setRows.isEmpty) continue;

      double bestOneRm = 0;
      double totalVolume = 0;
      for (final s in setRows) {
        final kg = (s['kg'] as num).toDouble();
        final reps = s['reps'] as int;
        final leftKg =
            s['left_kg'] != null ? (s['left_kg'] as num).toDouble() : null;
        final leftReps = s['left_reps'] as int?;

        final orm = kg * (1 + reps / 30);
        if (orm > bestOneRm) bestOneRm = orm;
        totalVolume += kg * reps;

        if (leftKg != null && leftReps != null) {
          final leftOrm = leftKg * (1 + leftReps / 30);
          if (leftOrm > bestOneRm) bestOneRm = leftOrm;
          totalVolume += leftKg * leftReps;
        }
      }

      result.add(ExerciseProgressPoint(
        date: date,
        estimatedOneRm: bestOneRm,
        volume: totalVolume,
      ));
    }
    return result;
  }

  Future<List<SessionExercise>> _loadExercises(String sessionId) async {
    final db = await DatabaseHelper.instance.database;
    final seRows = await db.query(
      'session_exercises',
      where: 'session_id = ?',
      whereArgs: [sessionId],
      orderBy: 'sort_order ASC',
    );
    final result = <SessionExercise>[];
    for (final se in seRows) {
      final seId = se['id'] as int;
      final setRows = await db.query(
        'session_sets',
        where: 'session_exercise_id = ?',
        whereArgs: [seId],
        orderBy: 'set_index ASC',
      );
      result.add(SessionExercise(
        exerciseId: se['exercise_id'] as String,
        name: se['exercise_name'] as String,
        muscle: se['muscle'] as String? ?? 'Other',
        sets: setRows
            .map((s) => WorkoutSet(
                  kg: (s['kg'] as num).toDouble(),
                  reps: s['reps'] as int,
                  leftKg: s['left_kg'] != null
                      ? (s['left_kg'] as num).toDouble()
                      : null,
                  leftReps: s['left_reps'] as int?,
                ))
            .toList(),
      ));
    }
    return result;
  }
}
