class WorkoutSet {
  final double kg;
  final int reps;
  final double? leftKg;
  final int? leftReps;

  const WorkoutSet({
    required this.kg,
    required this.reps,
    this.leftKg,
    this.leftReps,
  });

  bool get isSplit => leftKg != null;
  double get volume => isSplit ? kg * reps + leftKg! * leftReps! : kg * reps;

  WorkoutSet copyWith({
    double? kg,
    int? reps,
    double? leftKg,
    int? leftReps,
    bool clearLeft = false,
  }) {
    return WorkoutSet(
      kg: kg ?? this.kg,
      reps: reps ?? this.reps,
      leftKg: clearLeft ? null : (leftKg ?? this.leftKg),
      leftReps: clearLeft ? null : (leftReps ?? this.leftReps),
    );
  }
}
