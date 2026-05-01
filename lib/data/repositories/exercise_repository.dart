import '../../data/database/database_helper.dart';
import '../../domain/entities/exercise.dart';

class ExerciseRepository {
  Future<List<Exercise>> getAll() async {
    final db = await DatabaseHelper.instance.database;
    final rows = await db.query('exercises', orderBy: 'name ASC');
    return rows.map(_fromRow).toList();
  }

  Future<Exercise?> findById(String id) async {
    final db = await DatabaseHelper.instance.database;
    final rows = await db.query('exercises', where: 'id = ?', whereArgs: [id]);
    if (rows.isEmpty) return null;
    return _fromRow(rows.first);
  }

  Future<void> insert(Exercise exercise) async {
    final db = await DatabaseHelper.instance.database;
    await db.insert('exercises', {
      'id': exercise.id,
      'name': exercise.name,
      'muscle': exercise.muscle,
      'equipment': exercise.equipment,
      'is_custom': exercise.isCustom ? 1 : 0,
      'is_unilateral': exercise.isUnilateral ? 1 : 0,
    });
  }

  Future<void> delete(String id) async {
    final db = await DatabaseHelper.instance.database;
    await db.delete('exercises', where: 'id = ?', whereArgs: [id]);
  }

  Exercise _fromRow(Map<String, Object?> row) {
    return Exercise(
      id: row['id'] as String,
      name: row['name'] as String,
      muscle: row['muscle'] as String,
      equipment: row['equipment'] as String,
      isCustom: (row['is_custom'] as int) == 1,
      isUnilateral: (row['is_unilateral'] as int? ?? 0) == 1,
    );
  }
}
