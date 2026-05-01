import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as p;

class DatabaseHelper {
  DatabaseHelper._();
  static final DatabaseHelper instance = DatabaseHelper._();

  Database? _db;

  Future<Database> get database async {
    _db ??= await _open();
    return _db!;
  }

  Future<Database> _open() async {
    final dbPath = await getDatabasesPath();
    final filePath = p.join(dbPath, 'versatile.db');
    return openDatabase(
      filePath,
      version: 4,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
      onConfigure: (db) async => db.execute('PRAGMA foreign_keys = ON'),
    );
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute(
        'ALTER TABLE exercises ADD COLUMN is_unilateral INTEGER NOT NULL DEFAULT 0',
      );
      await db.execute('ALTER TABLE session_sets ADD COLUMN left_kg REAL');
      await db.execute('ALTER TABLE session_sets ADD COLUMN left_reps INTEGER');
      await db.execute('''
        CREATE TABLE settings (
          key TEXT PRIMARY KEY,
          value TEXT NOT NULL
        )
      ''');
    }
    if (oldVersion < 3) {
      await db.execute("UPDATE exercises SET muscle='Quadriceps' WHERE id='ex-7'");
      await db.execute("UPDATE exercises SET muscle='Hamstrings' WHERE id='ex-8'");
      await db.execute("UPDATE exercises SET muscle='Quadriceps' WHERE id='ex-9'");
      await db.execute("UPDATE exercises SET muscle='Biceps' WHERE id='ex-13'");
      await db.execute("UPDATE exercises SET muscle='Triceps' WHERE id='ex-14'");
      await db.execute("UPDATE exercises SET muscle='Biceps' WHERE id='ex-15'");
      await db.execute("UPDATE exercises SET muscle='Other' WHERE muscle='Arms'");
      await db.execute("UPDATE exercises SET muscle='Other' WHERE muscle='Legs'");
    }
    if (oldVersion < 4) {
      await db.execute(
        'CREATE TABLE IF NOT EXISTS workout_log (date TEXT PRIMARY KEY)',
      );
    }
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE exercises (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        muscle TEXT NOT NULL,
        equipment TEXT NOT NULL,
        is_custom INTEGER NOT NULL DEFAULT 0,
        is_unilateral INTEGER NOT NULL DEFAULT 0
      )
    ''');

    await db.execute('''
      CREATE TABLE routines (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        color_value INTEGER NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE routine_exercises (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        routine_id TEXT NOT NULL,
        exercise_id TEXT NOT NULL,
        sort_order INTEGER NOT NULL DEFAULT 0,
        target_sets INTEGER NOT NULL,
        target_reps TEXT NOT NULL,
        rest_seconds INTEGER NOT NULL,
        FOREIGN KEY (routine_id) REFERENCES routines(id) ON DELETE CASCADE,
        FOREIGN KEY (exercise_id) REFERENCES exercises(id)
      )
    ''');

    await db.execute('''
      CREATE TABLE sessions (
        id TEXT PRIMARY KEY,
        routine_id TEXT NOT NULL,
        routine_name TEXT NOT NULL,
        color_value INTEGER NOT NULL DEFAULT 0xFFD97757,
        date TEXT NOT NULL,
        duration_min INTEGER NOT NULL,
        volume_kg REAL NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE session_exercises (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        session_id TEXT NOT NULL,
        exercise_id TEXT NOT NULL,
        exercise_name TEXT NOT NULL,
        sort_order INTEGER NOT NULL DEFAULT 0,
        FOREIGN KEY (session_id) REFERENCES sessions(id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE session_sets (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        session_exercise_id INTEGER NOT NULL,
        set_index INTEGER NOT NULL,
        kg REAL NOT NULL,
        reps INTEGER NOT NULL,
        left_kg REAL,
        left_reps INTEGER,
        FOREIGN KEY (session_exercise_id) REFERENCES session_exercises(id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE settings (
        key TEXT PRIMARY KEY,
        value TEXT NOT NULL
      )
    ''');

    await db.execute(
      'CREATE TABLE workout_log (date TEXT PRIMARY KEY)',
    );

    await _seed(db);
  }

  Future<void> _seed(Database db) async {
    final exercises = [
      {'id': 'ex-1',  'name': 'Bench Press',           'muscle': 'Chest',     'equipment': 'Barbell',    'is_custom': 0, 'is_unilateral': 0},
      {'id': 'ex-2',  'name': 'Incline Dumbbell Press', 'muscle': 'Chest',     'equipment': 'Dumbbell',   'is_custom': 0, 'is_unilateral': 0},
      {'id': 'ex-3',  'name': 'Cable Fly',              'muscle': 'Chest',     'equipment': 'Cable',      'is_custom': 0, 'is_unilateral': 0},
      {'id': 'ex-4',  'name': 'Pull-Up',                'muscle': 'Back',      'equipment': 'Bodyweight', 'is_custom': 0, 'is_unilateral': 0},
      {'id': 'ex-5',  'name': 'Barbell Row',            'muscle': 'Back',      'equipment': 'Barbell',    'is_custom': 0, 'is_unilateral': 0},
      {'id': 'ex-6',  'name': 'Lat Pulldown',           'muscle': 'Back',      'equipment': 'Cable',      'is_custom': 0, 'is_unilateral': 0},
      {'id': 'ex-7',  'name': 'Squat',                  'muscle': 'Quadriceps', 'equipment': 'Barbell',    'is_custom': 0, 'is_unilateral': 0},
      {'id': 'ex-8',  'name': 'Romanian Deadlift',      'muscle': 'Hamstrings', 'equipment': 'Barbell',    'is_custom': 0, 'is_unilateral': 0},
      {'id': 'ex-9',  'name': 'Leg Press',              'muscle': 'Quadriceps', 'equipment': 'Machine',    'is_custom': 0, 'is_unilateral': 0},
      {'id': 'ex-10', 'name': 'Overhead Press',         'muscle': 'Shoulders',  'equipment': 'Barbell',    'is_custom': 0, 'is_unilateral': 0},
      {'id': 'ex-11', 'name': 'Lateral Raise',          'muscle': 'Shoulders',  'equipment': 'Dumbbell',   'is_custom': 0, 'is_unilateral': 1},
      {'id': 'ex-12', 'name': 'Face Pull',              'muscle': 'Shoulders',  'equipment': 'Cable',      'is_custom': 0, 'is_unilateral': 0},
      {'id': 'ex-13', 'name': 'Bicep Curl',             'muscle': 'Biceps',     'equipment': 'Dumbbell',   'is_custom': 0, 'is_unilateral': 1},
      {'id': 'ex-14', 'name': 'Tricep Pushdown',        'muscle': 'Triceps',    'equipment': 'Cable',      'is_custom': 0, 'is_unilateral': 0},
      {'id': 'ex-15', 'name': 'Hammer Curl',            'muscle': 'Biceps',     'equipment': 'Dumbbell',   'is_custom': 0, 'is_unilateral': 1},
      {'id': 'ex-16', 'name': 'Plank',                  'muscle': 'Core',      'equipment': 'Bodyweight', 'is_custom': 0, 'is_unilateral': 0},
      {'id': 'ex-17', 'name': 'Hanging Leg Raise',      'muscle': 'Core',      'equipment': 'Bodyweight', 'is_custom': 0, 'is_unilateral': 0},
      {'id': 'ex-c1', 'name': 'Landmine Press',         'muscle': 'Shoulders', 'equipment': 'Barbell',    'is_custom': 1, 'is_unilateral': 0},
      {'id': 'ex-c2', 'name': 'Pendlay Row',            'muscle': 'Back',      'equipment': 'Barbell',    'is_custom': 1, 'is_unilateral': 0},
    ];
    for (final e in exercises) {
      await db.insert('exercises', e);
    }

    final routines = [
      {
        'id': 'r-1', 'name': 'Push Day', 'color_value': 0xFFD97757,
        'exercises': [
          {'exercise_id': 'ex-1',  'sort_order': 0, 'target_sets': 4, 'target_reps': '6-8',   'rest_seconds': 120},
          {'exercise_id': 'ex-2',  'sort_order': 1, 'target_sets': 3, 'target_reps': '8-10',  'rest_seconds': 90},
          {'exercise_id': 'ex-10', 'sort_order': 2, 'target_sets': 3, 'target_reps': '8-10',  'rest_seconds': 90},
          {'exercise_id': 'ex-11', 'sort_order': 3, 'target_sets': 3, 'target_reps': '12-15', 'rest_seconds': 60},
          {'exercise_id': 'ex-14', 'sort_order': 4, 'target_sets': 3, 'target_reps': '10-12', 'rest_seconds': 60},
        ],
      },
      {
        'id': 'r-2', 'name': 'Pull Day', 'color_value': 0xFFB85432,
        'exercises': [
          {'exercise_id': 'ex-4',  'sort_order': 0, 'target_sets': 4, 'target_reps': '6-10',  'rest_seconds': 120},
          {'exercise_id': 'ex-5',  'sort_order': 1, 'target_sets': 4, 'target_reps': '8-10',  'rest_seconds': 90},
          {'exercise_id': 'ex-6',  'sort_order': 2, 'target_sets': 3, 'target_reps': '10-12', 'rest_seconds': 75},
          {'exercise_id': 'ex-13', 'sort_order': 3, 'target_sets': 3, 'target_reps': '10-12', 'rest_seconds': 60},
          {'exercise_id': 'ex-12', 'sort_order': 4, 'target_sets': 3, 'target_reps': '12-15', 'rest_seconds': 60},
        ],
      },
      {
        'id': 'r-3', 'name': 'Legs', 'color_value': 0xFFE89A7E,
        'exercises': [
          {'exercise_id': 'ex-7',  'sort_order': 0, 'target_sets': 5, 'target_reps': '5',     'rest_seconds': 180},
          {'exercise_id': 'ex-8',  'sort_order': 1, 'target_sets': 3, 'target_reps': '8-10',  'rest_seconds': 120},
          {'exercise_id': 'ex-9',  'sort_order': 2, 'target_sets': 3, 'target_reps': '10-12', 'rest_seconds': 90},
          {'exercise_id': 'ex-17', 'sort_order': 3, 'target_sets': 3, 'target_reps': '12',    'rest_seconds': 60},
        ],
      },
    ];

    for (final r in routines) {
      await db.insert('routines', {
        'id': r['id'],
        'name': r['name'],
        'color_value': r['color_value'],
      });
      final exList = r['exercises'] as List<Map<String, Object>>;
      for (final e in exList) {
        await db.insert('routine_exercises', {
          'routine_id': r['id'],
          ...e,
        });
      }
    }
  }
}
