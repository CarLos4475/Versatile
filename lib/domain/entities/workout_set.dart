class WorkoutSet {
  final double kg;
  final int reps;

  const WorkoutSet({required this.kg, required this.reps});

  double get volume => kg * reps;

  WorkoutSet copyWith({double? kg, int? reps}) {
    return WorkoutSet(kg: kg ?? this.kg, reps: reps ?? this.reps);
  }
}
