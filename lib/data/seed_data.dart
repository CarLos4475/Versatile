import '../domain/entities/exercise.dart';
import '../domain/entities/routine.dart';
import '../domain/entities/session.dart';
import '../domain/entities/workout_set.dart';

class SeedData {
  SeedData._();

  static const List<Exercise> exercises = [
    Exercise(id: 'ex-1',  name: 'Bench Press',           muscle: 'Chest',     equipment: 'Barbell'),
    Exercise(id: 'ex-2',  name: 'Incline Dumbbell Press', muscle: 'Chest',     equipment: 'Dumbbell'),
    Exercise(id: 'ex-3',  name: 'Cable Fly',              muscle: 'Chest',     equipment: 'Cable'),
    Exercise(id: 'ex-4',  name: 'Pull-Up',                muscle: 'Back',      equipment: 'Bodyweight'),
    Exercise(id: 'ex-5',  name: 'Barbell Row',            muscle: 'Back',      equipment: 'Barbell'),
    Exercise(id: 'ex-6',  name: 'Lat Pulldown',           muscle: 'Back',      equipment: 'Cable'),
    Exercise(id: 'ex-7',  name: 'Squat',                  muscle: 'Legs',      equipment: 'Barbell'),
    Exercise(id: 'ex-8',  name: 'Romanian Deadlift',      muscle: 'Legs',      equipment: 'Barbell'),
    Exercise(id: 'ex-9',  name: 'Leg Press',              muscle: 'Legs',      equipment: 'Machine'),
    Exercise(id: 'ex-10', name: 'Overhead Press',         muscle: 'Shoulders', equipment: 'Barbell'),
    Exercise(id: 'ex-11', name: 'Lateral Raise',          muscle: 'Shoulders', equipment: 'Dumbbell'),
    Exercise(id: 'ex-12', name: 'Face Pull',              muscle: 'Shoulders', equipment: 'Cable'),
    Exercise(id: 'ex-13', name: 'Bicep Curl',             muscle: 'Arms',      equipment: 'Dumbbell'),
    Exercise(id: 'ex-14', name: 'Tricep Pushdown',        muscle: 'Arms',      equipment: 'Cable'),
    Exercise(id: 'ex-15', name: 'Hammer Curl',            muscle: 'Arms',      equipment: 'Dumbbell'),
    Exercise(id: 'ex-16', name: 'Plank',                  muscle: 'Core',      equipment: 'Bodyweight'),
    Exercise(id: 'ex-17', name: 'Hanging Leg Raise',      muscle: 'Core',      equipment: 'Bodyweight'),
    Exercise(id: 'ex-c1', name: 'Landmine Press',         muscle: 'Shoulders', equipment: 'Barbell', isCustom: true),
    Exercise(id: 'ex-c2', name: 'Pendlay Row',            muscle: 'Back',      equipment: 'Barbell', isCustom: true),
  ];

  static const List<Routine> routines = [
    Routine(
      id: 'r-1',
      name: 'Push Day',
      colorValue: 0xFFD97757,
      exercises: [
        RoutineExercise(exerciseId: 'ex-1',  targetSets: 4, targetReps: '6-8',   restSeconds: 120),
        RoutineExercise(exerciseId: 'ex-2',  targetSets: 3, targetReps: '8-10',  restSeconds: 90),
        RoutineExercise(exerciseId: 'ex-10', targetSets: 3, targetReps: '8-10',  restSeconds: 90),
        RoutineExercise(exerciseId: 'ex-11', targetSets: 3, targetReps: '12-15', restSeconds: 60),
        RoutineExercise(exerciseId: 'ex-14', targetSets: 3, targetReps: '10-12', restSeconds: 60),
      ],
    ),
    Routine(
      id: 'r-2',
      name: 'Pull Day',
      colorValue: 0xFFB85432,
      exercises: [
        RoutineExercise(exerciseId: 'ex-4',  targetSets: 4, targetReps: '6-10',  restSeconds: 120),
        RoutineExercise(exerciseId: 'ex-5',  targetSets: 4, targetReps: '8-10',  restSeconds: 90),
        RoutineExercise(exerciseId: 'ex-6',  targetSets: 3, targetReps: '10-12', restSeconds: 75),
        RoutineExercise(exerciseId: 'ex-13', targetSets: 3, targetReps: '10-12', restSeconds: 60),
        RoutineExercise(exerciseId: 'ex-12', targetSets: 3, targetReps: '12-15', restSeconds: 60),
      ],
    ),
    Routine(
      id: 'r-3',
      name: 'Legs',
      colorValue: 0xFFE89A7E,
      exercises: [
        RoutineExercise(exerciseId: 'ex-7',  targetSets: 5, targetReps: '5',     restSeconds: 180),
        RoutineExercise(exerciseId: 'ex-8',  targetSets: 3, targetReps: '8-10',  restSeconds: 120),
        RoutineExercise(exerciseId: 'ex-9',  targetSets: 3, targetReps: '10-12', restSeconds: 90),
        RoutineExercise(exerciseId: 'ex-17', targetSets: 3, targetReps: '12',    restSeconds: 60),
      ],
    ),
  ];

  static const List<Session> sessions = [
    Session(
      id: 's-7', routineId: 'r-1', routineName: 'Push Day',
      date: '2026-04-29', durationMin: 58, volumeKg: 4280,
      exercises: [
        SessionExercise(exerciseId: 'ex-1', name: 'Bench Press', sets: [
          WorkoutSet(kg: 80, reps: 8), WorkoutSet(kg: 82.5, reps: 7),
          WorkoutSet(kg: 82.5, reps: 6), WorkoutSet(kg: 80, reps: 6),
        ]),
        SessionExercise(exerciseId: 'ex-2', name: 'Incline Dumbbell Press', sets: [
          WorkoutSet(kg: 28, reps: 10), WorkoutSet(kg: 28, reps: 9), WorkoutSet(kg: 26, reps: 9),
        ]),
        SessionExercise(exerciseId: 'ex-10', name: 'Overhead Press', sets: [
          WorkoutSet(kg: 50, reps: 8), WorkoutSet(kg: 50, reps: 7), WorkoutSet(kg: 47.5, reps: 8),
        ]),
        SessionExercise(exerciseId: 'ex-11', name: 'Lateral Raise', sets: [
          WorkoutSet(kg: 12, reps: 14), WorkoutSet(kg: 12, reps: 12), WorkoutSet(kg: 10, reps: 14),
        ]),
        SessionExercise(exerciseId: 'ex-14', name: 'Tricep Pushdown', sets: [
          WorkoutSet(kg: 30, reps: 12), WorkoutSet(kg: 32.5, reps: 10), WorkoutSet(kg: 30, reps: 10),
        ]),
      ],
    ),
    Session(id: 's-6', routineId: 'r-2', routineName: 'Pull Day', date: '2026-04-27', durationMin: 62, volumeKg: 3940),
    Session(id: 's-5', routineId: 'r-3', routineName: 'Legs',     date: '2026-04-25', durationMin: 71, volumeKg: 6120),
    Session(id: 's-4', routineId: 'r-1', routineName: 'Push Day', date: '2026-04-22', durationMin: 55, volumeKg: 4150),
    Session(id: 's-3', routineId: 'r-2', routineName: 'Pull Day', date: '2026-04-20', durationMin: 60, volumeKg: 3820),
    Session(id: 's-2', routineId: 'r-3', routineName: 'Legs',     date: '2026-04-18', durationMin: 68, volumeKg: 5980),
    Session(id: 's-1', routineId: 'r-1', routineName: 'Push Day', date: '2026-04-15', durationMin: 56, volumeKg: 4020),
  ];

  static const Map<String, List<WorkoutSet>> previousPerformance = {
    'ex-1':  [WorkoutSet(kg: 80, reps: 8), WorkoutSet(kg: 82.5, reps: 7), WorkoutSet(kg: 82.5, reps: 6), WorkoutSet(kg: 80, reps: 6)],
    'ex-2':  [WorkoutSet(kg: 28, reps: 10), WorkoutSet(kg: 28, reps: 9), WorkoutSet(kg: 26, reps: 9)],
    'ex-10': [WorkoutSet(kg: 50, reps: 8), WorkoutSet(kg: 50, reps: 7), WorkoutSet(kg: 47.5, reps: 8)],
    'ex-11': [WorkoutSet(kg: 12, reps: 14), WorkoutSet(kg: 12, reps: 12), WorkoutSet(kg: 10, reps: 14)],
    'ex-14': [WorkoutSet(kg: 30, reps: 12), WorkoutSet(kg: 32.5, reps: 10), WorkoutSet(kg: 30, reps: 10)],
    'ex-4':  [WorkoutSet(kg: 0, reps: 10), WorkoutSet(kg: 0, reps: 8), WorkoutSet(kg: 0, reps: 7), WorkoutSet(kg: 0, reps: 6)],
    'ex-5':  [WorkoutSet(kg: 70, reps: 10), WorkoutSet(kg: 70, reps: 9), WorkoutSet(kg: 70, reps: 8), WorkoutSet(kg: 67.5, reps: 8)],
    'ex-7':  [WorkoutSet(kg: 100, reps: 5), WorkoutSet(kg: 100, reps: 5), WorkoutSet(kg: 100, reps: 5), WorkoutSet(kg: 95, reps: 5), WorkoutSet(kg: 95, reps: 5)],
  };

  static const List<String> muscleGroups = ['All', 'Chest', 'Back', 'Legs', 'Shoulders', 'Arms', 'Core'];

  static Exercise? findExercise(String id) {
    try {
      return exercises.firstWhere((e) => e.id == id);
    } catch (_) {
      return null;
    }
  }

  static Routine? findRoutine(String id) {
    try {
      return routines.firstWhere((r) => r.id == id);
    } catch (_) {
      return null;
    }
  }
}
