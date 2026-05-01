import 'workout_set.dart';

class SessionExercise {
  final String exerciseId;
  final String name;
  final List<WorkoutSet> sets;

  const SessionExercise({
    required this.exerciseId,
    required this.name,
    required this.sets,
  });

  double get volume => sets.fold(0.0, (s, set) => s + set.volume);
}

class Session {
  final String id;
  final String routineId;
  final String routineName;
  final String date; // 'YYYY-MM-DD'
  final int durationMin;
  final double volumeKg;
  final List<SessionExercise>? exercises;

  const Session({
    required this.id,
    required this.routineId,
    required this.routineName,
    required this.date,
    required this.durationMin,
    required this.volumeKg,
    this.exercises,
  });
}
