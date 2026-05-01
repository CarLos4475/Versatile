class RoutineExercise {
  final int? dbId;
  final String exerciseId;
  final int targetSets;
  final String targetReps;
  final int restSeconds;

  const RoutineExercise({
    this.dbId,
    required this.exerciseId,
    required this.targetSets,
    required this.targetReps,
    required this.restSeconds,
  });
}

class Routine {
  final String id;
  final String name;
  final int colorValue;
  final List<RoutineExercise> exercises;

  const Routine({
    required this.id,
    required this.name,
    required this.colorValue,
    required this.exercises,
  });

  int get estimatedMinutes => exercises.fold(
        0,
        (sum, e) => sum + ((e.targetSets * (e.restSeconds + 30)) ~/ 60),
      );
}