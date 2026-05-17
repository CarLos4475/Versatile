import '../../../domain/entities/monthly_recap.dart';

/// Hardcoded MonthlyRecap used only by the debug preview button. Lets us
/// validate visuals (aurora background, slide composition, dots) without
/// having to change the device date or seed real session data.
MonthlyRecap buildSampleRecap() {
  return const MonthlyRecap(
    year: 2026,
    month: 4,
    sessionsCount: 14,
    totalDurationMin: 870,
    totalVolumeKg: 28450.0,
    workoutDays: {
      '2026-04-01',
      '2026-04-03',
      '2026-04-05',
      '2026-04-07',
      '2026-04-09',
      '2026-04-10',
      '2026-04-12',
      '2026-04-14',
      '2026-04-16',
      '2026-04-19',
      '2026-04-21',
      '2026-04-23',
      '2026-04-26',
      '2026-04-28',
    },
    topRoutine: RecapTopRoutine(
      routineId: 'sample-upper',
      name: 'Upper',
      colorValue: 0xFFD97757,
      iconCode: 58713,
      sessionsCount: 6,
    ),
    topExercise: RecapTopExercise(
      exerciseId: 'ex-1',
      name: 'Bench Press',
      muscle: 'Chest',
      setsCount: 24,
      totalVolumeKg: 7820.0,
    ),
    newPR: RecapPersonalRecord(
      exerciseId: 'ex-7',
      exerciseName: 'Squat',
      weightKg: 140.0,
      reps: 5,
      estimatedOneRm: 163.3,
      date: '2026-04-19',
    ),
    volumeDeltaPctVsPrev: 18.4,
    prevMonthLabel: 'March 2026',
    volumeByCategory: {
      'push': 10800.0,
      'pull': 9200.0,
      'legs': 7400.0,
      'other': 1050.0,
    },
  );
}
