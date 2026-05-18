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
  /// Push / Pull / Legs / Other volume in kg for the month. Used by the
  /// exercises-list category filter, not the recap slides anymore.
  final Map<String, double> volumeByCategory;
  /// Sessions count for the previous calendar month. Drives the Sessions
  /// slide delta pill ("3 more than March").
  final int prevSessionsCount;
  /// Most sessions in a single week-of-month bucket. Footer of CalendarSlide.
  final int bestWeekSessions;
  /// Count of exercises whose best e1RM this month beat their pre-month
  /// historical max. Shown in the Outro stats trio.
  final int newPRsCount;
  /// Volume per week-of-month bucket, in order from week 0 to last week.
  /// Powers the bar chart in the Volume slide.
  final List<double> weeklyVolumeKg;
  /// Volume grouped into the 6 high-level muscle buckets the Muscle Balance
  /// slide displays: Chest / Back / Legs / Shoulders / Arms / Core. Keys are
  /// the canonical English muscle names; the slide localises at render time.
  final Map<String, double> volumeByMuscle;
  /// Top lift of the month: exercise with the highest single-set e1RM and
  /// its weekly progression. Null when there's no qualifying set.
  final RecapTopLift? topLift;

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
    this.prevSessionsCount = 0,
    this.bestWeekSessions = 0,
    this.newPRsCount = 0,
    this.weeklyVolumeKg = const [],
    this.volumeByMuscle = const {},
    this.topLift,
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

/// Top lift of the month — the single exercise/set combo with the highest
/// estimated 1RM in the calendar month, plus its weekly progression so the
/// recap can draw a sparkline.
class RecapTopLift {
  final String exerciseId;
  final String name;
  final String muscle;
  final double bestKg;
  final int bestReps;
  final double estimatedOneRm;
  /// Delta in kg vs the best lift of the same exercise in the previous
  /// month. 0 when there's no comparable prior month data.
  final double deltaKgVsPrevMonth;
  /// Best estimated 1RM per week for this exercise across the last 7 weeks
  /// (oldest first). Used by the recap sparkline. Empty when there isn't
  /// enough data to draw at least two points.
  final List<double> weeklyBests;

  const RecapTopLift({
    required this.exerciseId,
    required this.name,
    required this.muscle,
    required this.bestKg,
    required this.bestReps,
    required this.estimatedOneRm,
    this.deltaKgVsPrevMonth = 0,
    this.weeklyBests = const [],
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
