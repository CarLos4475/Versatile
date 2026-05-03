import '../../data/database/database_helper.dart';
import '../../domain/entities/routine.dart';

class RoutineRepository {
  Future<List<Routine>> getAll() async {
    final db = await DatabaseHelper.instance.database;
    final routineRows = await db.query('routines');
    final result = <Routine>[];
    for (final r in routineRows) {
      final id = r['id'] as String;
      result.add(
        Routine(
          id: id,
          name: r['name'] as String,
          colorValue: r['color_value'] as int,
          iconCode: r['icon_code'] as int? ?? 58713,
          exercises: await _loadExercises(id),
        ),
      );
    }
    return result;
  }

  Future<Routine?> findById(String id) async {
    final db = await DatabaseHelper.instance.database;
    final rows = await db.query('routines', where: 'id = ?', whereArgs: [id]);
    if (rows.isEmpty) return null;
    final r = rows.first;
    return Routine(
      id: id,
      name: r['name'] as String,
      colorValue: r['color_value'] as int,
      iconCode: r['icon_code'] as int? ?? 58713,
      exercises: await _loadExercises(id),
    );
  }

  Future<void> insert(Routine routine) async {
    final db = await DatabaseHelper.instance.database;
    await db.insert('routines', {
      'id': routine.id,
      'name': routine.name,
      'color_value': routine.colorValue,
      'icon_code': routine.iconCode,
    });
    for (var i = 0; i < routine.exercises.length; i++) {
      final re = routine.exercises[i];
      await db.insert('routine_exercises', {
        'routine_id': routine.id,
        'exercise_id': re.exerciseId,
        'sort_order': i,
        'target_sets': re.targetSets,
        'target_reps': re.targetReps,
        'rest_seconds': re.restSeconds,
      });
    }
  }

  Future<void> updateName(String id, String name) async {
    final db = await DatabaseHelper.instance.database;
    await db.update(
      'routines',
      {'name': name},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> updateMeta(String id, int colorValue, int iconCode) async {
    final db = await DatabaseHelper.instance.database;
    await db.update(
      'routines',
      {'color_value': colorValue, 'icon_code': iconCode},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> delete(String id) async {
    final db = await DatabaseHelper.instance.database;
    await db.delete('routines', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> addExercise(String routineId, RoutineExercise re) async {
    final db = await DatabaseHelper.instance.database;
    final countResult = await db.rawQuery(
      'SELECT COUNT(*) as c FROM routine_exercises WHERE routine_id = ?',
      [routineId],
    );
    final sortOrder = (countResult.first['c'] as int?) ?? 0;
    await db.insert('routine_exercises', {
      'routine_id': routineId,
      'exercise_id': re.exerciseId,
      'sort_order': sortOrder,
      'target_sets': re.targetSets,
      'target_reps': re.targetReps,
      'rest_seconds': re.restSeconds,
    });
  }

  Future<void> removeExercise(String routineId, int dbId) async {
    final db = await DatabaseHelper.instance.database;
    await db.delete('routine_exercises', where: 'id = ?', whereArgs: [dbId]);
  }

  Future<void> deleteReferencesToExercise(String exerciseId) async {
    final db = await DatabaseHelper.instance.database;
    await db.delete(
      'routine_exercises',
      where: 'exercise_id = ?',
      whereArgs: [exerciseId],
    );
  }

  Future<void> reorderExercises(
    String routineId,
    List<RoutineExercise> exercises,
  ) async {
    final db = await DatabaseHelper.instance.database;
    await db.transaction((txn) async {
      for (var i = 0; i < exercises.length; i++) {
        final re = exercises[i];
        if (re.dbId != null) {
          await txn.update(
            'routine_exercises',
            {'sort_order': i},
            where: 'id = ?',
            whereArgs: [re.dbId],
          );
        }
      }
    });
  }

  Future<List<RoutineExercise>> _loadExercises(String routineId) async {
    final db = await DatabaseHelper.instance.database;
    final rows = await db.query(
      'routine_exercises',
      where: 'routine_id = ?',
      whereArgs: [routineId],
      orderBy: 'sort_order ASC',
    );
    return rows
        .map(
          (r) => RoutineExercise(
            dbId: r['id'] as int,
            exerciseId: r['exercise_id'] as String,
            targetSets: r['target_sets'] as int,
            targetReps: r['target_reps'] as String,
            restSeconds: r['rest_seconds'] as int,
          ),
        )
        .toList();
  }
}
