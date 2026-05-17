import '../database/database_helper.dart';
import '../../domain/entities/program.dart';

class ProgramRepository {
  Future<List<Program>> getAll() async {
    final db = await DatabaseHelper.instance.database;
    final rows = await db.query('programs', orderBy: 'created_at DESC');
    final result = <Program>[];
    for (final r in rows) {
      result.add(await _hydrate(r));
    }
    return result;
  }

  Future<Program?> findById(String id) async {
    final db = await DatabaseHelper.instance.database;
    final rows = await db.query(
      'programs',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return _hydrate(rows.first);
  }

  Future<Program> _hydrate(Map<String, Object?> row) async {
    final id = row['id'] as String;
    final slots = await _loadSlots(id);
    final deloadCsv = (row['deload_weeks'] as String?) ?? '';
    final deloadSet = deloadCsv.isEmpty
        ? <int>{}
        : deloadCsv.split(',').map(int.parse).toSet();
    return Program(
      id: id,
      name: row['name'] as String,
      colorValue: row['color_value'] as int,
      iconCode: (row['icon_code'] as int?) ?? 58713,
      weeksCount: row['weeks_count'] as int,
      deloadWeeks: deloadSet,
      createdAt: DateTime.parse(row['created_at'] as String),
      slots: slots,
    );
  }

  Future<List<ProgramSlot>> _loadSlots(String programId) async {
    final db = await DatabaseHelper.instance.database;
    final rows = await db.query(
      'program_slots',
      where: 'program_id = ?',
      whereArgs: [programId],
    );
    return rows.map(_slotFromRow).toList();
  }

  ProgramSlot _slotFromRow(Map<String, Object?> r) {
    return ProgramSlot(
      id: r['id'] as String,
      programId: r['program_id'] as String,
      weekIndex: r['week_index'] as int,
      weekday: r['weekday'] as int,
      kind: (r['slot_kind'] as String) == 'routine'
          ? SlotKind.routine
          : SlotKind.label,
      routineId: r['routine_id'] as String?,
      labelText: r['label_text'] as String?,
    );
  }

  Future<void> insert(Program program) async {
    final db = await DatabaseHelper.instance.database;
    await db.transaction((txn) async {
      await txn.insert('programs', {
        'id': program.id,
        'name': program.name,
        'color_value': program.colorValue,
        'icon_code': program.iconCode,
        'weeks_count': program.weeksCount,
        'deload_weeks': program.deloadWeeks.toList().join(','),
        'created_at': program.createdAt.toIso8601String(),
      });
      for (final s in program.slots) {
        await txn.insert('program_slots', _slotToRow(s));
      }
    });
  }

  Map<String, Object?> _slotToRow(ProgramSlot s) => {
    'id': s.id,
    'program_id': s.programId,
    'week_index': s.weekIndex,
    'weekday': s.weekday,
    'slot_kind': s.kind == SlotKind.routine ? 'routine' : 'label',
    'routine_id': s.routineId,
    'label_text': s.labelText,
  };

  Future<void> updateMeta(
    String id, {
    required String name,
    required int colorValue,
    required int iconCode,
    required int weeksCount,
    required Set<int> deloadWeeks,
  }) async {
    final db = await DatabaseHelper.instance.database;
    await db.update(
      'programs',
      {
        'name': name,
        'color_value': colorValue,
        'icon_code': iconCode,
        'weeks_count': weeksCount,
        'deload_weeks': deloadWeeks.toList().join(','),
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Replaces all slots for a program in one transaction.
  Future<void> replaceSlots(String programId, List<ProgramSlot> slots) async {
    final db = await DatabaseHelper.instance.database;
    await db.transaction((txn) async {
      await txn.delete(
        'program_slots',
        where: 'program_id = ?',
        whereArgs: [programId],
      );
      for (final s in slots) {
        await txn.insert('program_slots', _slotToRow(s));
      }
    });
  }

  Future<void> delete(String id) async {
    final db = await DatabaseHelper.instance.database;
    await db.delete('programs', where: 'id = ?', whereArgs: [id]);
  }

  /// Returns the slot for a specific (program, weekIndex, weekday) cell, or
  /// null if no slot is configured. Used by the home view to decide what to
  /// show as today's planned workout.
  Future<ProgramSlot?> getSlot(
    String programId,
    int weekIndex,
    int weekday,
  ) async {
    final db = await DatabaseHelper.instance.database;
    final rows = await db.query(
      'program_slots',
      where: 'program_id = ? AND week_index = ? AND weekday = ?',
      whereArgs: [programId, weekIndex, weekday],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return _slotFromRow(rows.first);
  }
}
