import '../../data/database/database_helper.dart';
import '../../domain/entities/session.dart';
import '../../domain/entities/workout_set.dart';

class SessionRepository {
  Future<List<Session>> getAll() async {
    final db = await DatabaseHelper.instance.database;
    final rows = await db.query('sessions', orderBy: 'date DESC');
    final result = <Session>[];
    for (final r in rows) {
      final sessionId = r['id'] as String;
      result.add(Session(
        id: sessionId,
        routineId: r['routine_id'] as String,
        routineName: r['routine_name'] as String,
        colorValue: r['color_value'] as int,
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
        'sort_order': i,
      });
      for (var j = 0; j < se.sets.length; j++) {
        final s = se.sets[j];
        await db.insert('session_sets', {
          'session_exercise_id': seId,
          'set_index': j,
          'kg': s.kg,
          'reps': s.reps,
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
      orderBy: 'date DESC',
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
              ))
          .toList();
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
        sets: setRows
            .map((s) => WorkoutSet(
                  kg: (s['kg'] as num).toDouble(),
                  reps: s['reps'] as int,
                ))
            .toList(),
      ));
    }
    return result;
  }
}
