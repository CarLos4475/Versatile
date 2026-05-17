class MonthlyRecap {
  final int year;
  final int month;
  final int sessionsCount;
  final int totalDurationMin;
  final double totalVolumeKg;
  final Set<String> workoutDays;
  final RecapTopRoutine? topRoutine;
  final RecapTopExercise? topExercise;
  final RecapPersonalRecord? newPR;
  final double? volumeDeltaPctVsPrev;
  final String? prevMonthLabel;
  /// Push / Pull / Legs / Other volume in kg for the month. Drives the
  /// "Movement balance" slide and is derived from the muscle of each
  /// exercise via `categoryForMuscle` (no schema change).
  final Map<String, double> volumeByCategory;

  const MonthlyRecap({
    required this.year,
    required this.month,
    required this.sessionsCount,
    required this.totalDurationMin,
    required this.totalVolumeKg,
    required this.workoutDays,
    this.topRoutine,
    this.topExercise,
    this.newPR,
    this.volumeDeltaPctVsPrev,
    this.prevMonthLabel,
    this.volumeByCategory = const {},
  });

  String get monthKey =>
      '${year.toString().padLeft(4, '0')}-${month.toString().padLeft(2, '0')}';
}

class RecapTopRoutine {
  final String routineId;
  final String name;
  final int colorValue;
  final int iconCode;
  final int sessionsCount;

  const RecapTopRoutine({
    required this.routineId,
    required this.name,
    required this.colorValue,
    required this.iconCode,
    required this.sessionsCount,
  });
}

class RecapTopExercise {
  final String exerciseId;
  final String name;
  final String muscle;
  final int setsCount;
  final double totalVolumeKg;

  const RecapTopExercise({
    required this.exerciseId,
    required this.name,
    required this.muscle,
    required this.setsCount,
    required this.totalVolumeKg,
  });
}

class RecapPersonalRecord {
  final String exerciseId;
  final String exerciseName;
  final double weightKg;
  final int reps;
  final double estimatedOneRm;
  final String date;

  const RecapPersonalRecord({
    required this.exerciseId,
    required this.exerciseName,
    required this.weightKg,
    required this.reps,
    required this.estimatedOneRm,
    required this.date,
  });
}
