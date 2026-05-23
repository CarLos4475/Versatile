import 'dart:math' as math;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/repository_providers.dart';
import '../../../core/utils/exercise_category.dart';
import '../../../core/utils/format_utils.dart';
import '../../../domain/entities/monthly_recap.dart';
import '../../../domain/entities/session.dart';
import '../../../domain/entities/workout_set.dart';
import '../../home/view_models/home_view_model.dart';

typedef MonthKey = ({int year, int month});

bool _sessionInMonth(Session s, int year, int month) {
  if (s.date.length < 7) return false;
  final y = int.tryParse(s.date.substring(0, 4));
  final m = int.tryParse(s.date.substring(5, 7));
  return y == year && m == month;
}

/// Epley one-rep-max estimator. Public so callers outside the recap module
/// (active workout PR detection, share card) can reuse the exact formula.
double epleyOneRm(double kg, int reps) => kg * (1 + reps / 30);

String _firstDayKey(int year, int month) =>
    '${year.toString().padLeft(4, '0')}-${month.toString().padLeft(2, '0')}-01';

MonthlyRecap? _computeRecap(List<Session> sessions, int year, int month) {
  final monthSessions =
      sessions.where((s) => _sessionInMonth(s, year, month)).toList();
  if (monthSessions.isEmpty) return null;

  final totalDur = monthSessions.fold<int>(0, (s, x) => s + x.durationMin);
  final totalVol = monthSessions.fold<double>(0.0, (s, x) => s + x.volumeKg);
  final workoutDays = monthSessions.map((s) => s.date).toSet();

  final routineGroups = <String, List<Session>>{};
  for (final s in monthSessions) {
    (routineGroups[s.routineId] ??= []).add(s);
  }
  RecapTopRoutine? topRoutine;
  if (routineGroups.isNotEmpty) {
    final entries = routineGroups.entries.toList()
      ..sort((a, b) => b.value.length.compareTo(a.value.length));
    final top = entries.first;
    final snapshot = top.value.first;
    topRoutine = RecapTopRoutine(
      routineId: top.key,
      name: snapshot.routineName,
      colorValue: snapshot.colorValue,
      iconCode: snapshot.iconCode,
      sessionsCount: top.value.length,
    );
  }

  final exGroups =
      <String, ({String name, String muscle, int sets, double vol})>{};
  for (final s in monthSessions) {
    final exercises = s.exercises ?? const <SessionExercise>[];
    for (final e in exercises) {
      var setsCount = 0;
      var volSum = 0.0;
      for (final set in e.sets) {
        setsCount += 1;
        volSum += set.volume;
      }
      final prev = exGroups[e.exerciseId];
      if (prev == null) {
        exGroups[e.exerciseId] = (
          name: e.name,
          muscle: e.muscle,
          sets: setsCount,
          vol: volSum,
        );
      } else {
        exGroups[e.exerciseId] = (
          name: prev.name,
          muscle: prev.muscle,
          sets: prev.sets + setsCount,
          vol: prev.vol + volSum,
        );
      }
    }
  }
  RecapTopExercise? topExercise;
  if (exGroups.isNotEmpty) {
    final entries = exGroups.entries.toList()
      ..sort((a, b) => b.value.vol.compareTo(a.value.vol));
    final top = entries.first;
    topExercise = RecapTopExercise(
      exerciseId: top.key,
      name: top.value.name,
      muscle: top.value.muscle,
      setsCount: top.value.sets,
      totalVolumeKg: top.value.vol,
    );
  }

  final firstDay = _firstDayKey(year, month);
  final prevBest1Rm = <String, double>{};
  final thisMonthBest1Rm =
      <String, ({double orm, double kg, int reps, String date})>{};

  void considerSet(
    String exId,
    double kg,
    int reps,
    String date,
    bool isThisMonth,
    bool isBeforeMonth,
  ) {
    if (kg <= 0 || reps <= 0) return;
    final orm = epleyOneRm(kg, reps);
    if (isThisMonth) {
      final cur = thisMonthBest1Rm[exId];
      if (cur == null || orm > cur.orm) {
        thisMonthBest1Rm[exId] = (orm: orm, kg: kg, reps: reps, date: date);
      }
    } else if (isBeforeMonth) {
      final prev = prevBest1Rm[exId] ?? 0;
      if (orm > prev) prevBest1Rm[exId] = orm;
    }
  }

  for (final s in sessions) {
    final isThisMonth = _sessionInMonth(s, year, month);
    final isBeforeMonth = s.date.compareTo(firstDay) < 0;
    if (!isThisMonth && !isBeforeMonth) continue;
    final exercises = s.exercises ?? const <SessionExercise>[];
    for (final e in exercises) {
      for (final set in e.sets) {
        considerSet(e.exerciseId, set.kg, set.reps, s.date,
            isThisMonth, isBeforeMonth);
        if (set.leftKg != null && set.leftReps != null) {
          considerSet(e.exerciseId, set.leftKg!, set.leftReps!, s.date,
              isThisMonth, isBeforeMonth);
        }
      }
    }
  }

  RecapPersonalRecord? newPR;
  for (final entry in thisMonthBest1Rm.entries) {
    final prev = prevBest1Rm[entry.key] ?? 0;
    if (entry.value.orm > prev) {
      final exName = exGroups[entry.key]?.name ?? '';
      if (newPR == null || entry.value.orm > newPR.estimatedOneRm) {
        newPR = RecapPersonalRecord(
          exerciseId: entry.key,
          exerciseName: exName,
          weightKg: entry.value.kg,
          reps: entry.value.reps,
          estimatedOneRm: entry.value.orm,
          date: entry.value.date,
        );
      }
    }
  }

  final prevMonth = month == 1
      ? (year: year - 1, month: 12)
      : (year: year, month: month - 1);
  var prevVol = 0.0;
  var prevHasData = false;
  var prevMonthSessionsCount = 0;
  for (final s in sessions) {
    if (_sessionInMonth(s, prevMonth.year, prevMonth.month)) {
      prevVol += s.volumeKg;
      prevHasData = true;
      prevMonthSessionsCount += 1;
    }
  }
  double? volumeDeltaPct;
  String? prevLabel;
  if (prevHasData && prevVol > 0) {
    volumeDeltaPct = ((totalVol - prevVol) / prevVol) * 100;
    prevLabel = FormatUtils.monthYear(
      _firstDayKey(prevMonth.year, prevMonth.month),
    );
  }

  // Movement-pattern split derived from each exercise's muscle. Keys are
  // ExerciseCategory.name so the entity doesn't depend on the enum.
  final volumeByCategory = <String, double>{};
  for (final s in monthSessions) {
    for (final e in s.exercises ?? const <SessionExercise>[]) {
      final cat = categoryForMuscle(e.muscle).name;
      volumeByCategory[cat] = (volumeByCategory[cat] ?? 0) + e.volume;
    }
  }

  // Volume grouped into the 6 high-level buckets the Muscle Balance slide
  // displays. Arms collapses Biceps/Triceps/Forearms, Legs collapses Quads
  // /Hamstrings/Glutes/Calves; everything else stays as-is.
  final volumeByMuscle = <String, double>{};
  for (final s in monthSessions) {
    for (final e in s.exercises ?? const <SessionExercise>[]) {
      final bucket = _muscleBucket(e.muscle);
      if (bucket == null) continue;
      volumeByMuscle[bucket] = (volumeByMuscle[bucket] ?? 0) + e.volume;
    }
  }

  // Week-of-month bucketing for the volume bar chart + best-week badge.
  // Week 0 = days 1-7, week 1 = 8-14, etc. Last bucket may be partial.
  final weeksInMonth = ((_daysInMonth(year, month) + 6) / 7).ceil();
  final weeklyVolume = List<double>.filled(weeksInMonth, 0);
  final weeklySessionCount = List<int>.filled(weeksInMonth, 0);
  for (final s in monthSessions) {
    final day = int.tryParse(s.date.substring(8, 10));
    if (day == null) continue;
    final w = ((day - 1) ~/ 7).clamp(0, weeksInMonth - 1);
    weeklyVolume[w] += s.volumeKg;
    weeklySessionCount[w] += 1;
  }
  final bestWeekSessions =
      weeklySessionCount.isEmpty ? 0 : weeklySessionCount.reduce(math.max);

  // newPRsCount: count distinct exercises whose best in-month e1RM beat
  // their pre-month historical best. Reuses the maps we already built.
  var newPRsCount = 0;
  for (final entry in thisMonthBest1Rm.entries) {
    final prev = prevBest1Rm[entry.key] ?? 0;
    if (entry.value.orm > prev) newPRsCount += 1;
  }

  // Top lift: exercise with the highest single-set e1RM during the month.
  // Pulls weekly bests over the last 7 weeks (calendar-anchored Mon→Sun)
  // for the sparkline. deltaKgVsPrevMonth = bestKg this month minus the
  // best raw kg of the same exercise in the previous calendar month.
  RecapTopLift? topLift;
  if (thisMonthBest1Rm.isNotEmpty) {
    final topId = thisMonthBest1Rm.entries
        .reduce((a, b) => a.value.orm >= b.value.orm ? a : b)
        .key;
    final best = thisMonthBest1Rm[topId]!;
    final name = exGroups[topId]?.name ?? '';
    final muscle = _muscleForExercise(monthSessions, topId);

    // Previous-month best raw kg for the same exercise (used for delta).
    double prevMonthBestKg = 0;
    for (final s in sessions) {
      if (!_sessionInMonth(s, prevMonth.year, prevMonth.month)) continue;
      for (final e in s.exercises ?? const <SessionExercise>[]) {
        if (e.exerciseId != topId) continue;
        for (final set in e.sets) {
          if (set.kg > prevMonthBestKg) prevMonthBestKg = set.kg;
          if (set.leftKg != null && set.leftKg! > prevMonthBestKg) {
            prevMonthBestKg = set.leftKg!;
          }
        }
      }
    }
    final deltaKg = prevMonthBestKg > 0 ? (best.kg - prevMonthBestKg) : 0.0;

    // 7-week sparkline ending in the last day of the analysed month. Each
    // bucket holds the best e1RM seen for this exercise in that ISO week.
    final lastDay = DateTime(year, month, _daysInMonth(year, month));
    final weeklyBests = List<double>.filled(7, 0);
    for (final s in sessions) {
      final d = DateTime.tryParse('${s.date}T00:00:00');
      if (d == null) continue;
      final diff = lastDay.difference(d).inDays;
      if (diff < 0 || diff >= 49) continue;
      final bucket = 6 - (diff ~/ 7);
      if (bucket < 0 || bucket > 6) continue;
      for (final e in s.exercises ?? const <SessionExercise>[]) {
        if (e.exerciseId != topId) continue;
        for (final set in e.sets) {
          if (set.kg > 0 && set.reps > 0) {
            final orm = epleyOneRm(set.kg, set.reps);
            if (orm > weeklyBests[bucket]) weeklyBests[bucket] = orm;
          }
          if (set.leftKg != null &&
              set.leftReps != null &&
              set.leftKg! > 0 &&
              set.leftReps! > 0) {
            final orm = epleyOneRm(set.leftKg!, set.leftReps!);
            if (orm > weeklyBests[bucket]) weeklyBests[bucket] = orm;
          }
        }
      }
    }
    topLift = RecapTopLift(
      exerciseId: topId,
      name: name,
      muscle: muscle,
      bestKg: best.kg,
      bestReps: best.reps,
      estimatedOneRm: best.orm,
      deltaKgVsPrevMonth: deltaKg,
      weeklyBests: weeklyBests,
    );
  }

  return MonthlyRecap(
    year: year,
    month: month,
    sessionsCount: monthSessions.length,
    totalDurationMin: totalDur,
    totalVolumeKg: totalVol,
    workoutDays: workoutDays,
    topRoutine: topRoutine,
    topExercise: topExercise,
    newPR: newPR,
    volumeDeltaPctVsPrev: volumeDeltaPct,
    prevMonthLabel: prevLabel,
    volumeByCategory: volumeByCategory,
    prevSessionsCount: prevMonthSessionsCount,
    bestWeekSessions: bestWeekSessions,
    newPRsCount: newPRsCount,
    weeklyVolumeKg: weeklyVolume,
    volumeByMuscle: volumeByMuscle,
    topLift: topLift,
  );
}

/// Maps an exercise's raw `muscle` field to one of the six recap buckets,
/// or null when it should be excluded from the Muscle Balance slide.
String? _muscleBucket(String muscle) {
  switch (muscle) {
    case 'Chest':
      return 'Chest';
    case 'Back':
      return 'Back';
    case 'Shoulders':
      return 'Shoulders';
    case 'Biceps':
    case 'Triceps':
    case 'Forearms':
    case 'Arms':
      return 'Arms';
    case 'Quadriceps':
    case 'Hamstrings':
    case 'Glutes':
    case 'Calves':
    case 'Legs':
      return 'Legs';
    case 'Core':
      return 'Core';
  }
  return null;
}

int _daysInMonth(int year, int month) {
  final firstNext = month == 12
      ? DateTime(year + 1, 1, 1)
      : DateTime(year, month + 1, 1);
  return firstNext.subtract(const Duration(days: 1)).day;
}

String _muscleForExercise(List<Session> monthSessions, String exerciseId) {
  for (final s in monthSessions) {
    for (final e in s.exercises ?? const <SessionExercise>[]) {
      if (e.exerciseId == exerciseId) return e.muscle;
    }
  }
  return 'Other';
}

final monthlyRecapProvider =
    Provider.family<MonthlyRecap?, MonthKey>((ref, key) {
  final sessions =
      ref.watch(sessionsAsyncProvider).value ?? const <Session>[];
  return _computeRecap(sessions, key.year, key.month);
});

final availableRecapsProvider = Provider<List<MonthKey>>((ref) {
  final sessions =
      ref.watch(sessionsAsyncProvider).value ?? const <Session>[];
  final now = DateTime.now();
  final keys = <MonthKey>{};
  for (final s in sessions) {
    if (s.date.length < 7) continue;
    final y = int.tryParse(s.date.substring(0, 4));
    final m = int.tryParse(s.date.substring(5, 7));
    if (y == null || m == null) continue;
    if (y == now.year && m == now.month) continue;
    keys.add((year: y, month: m));
  }
  final sorted = keys.toList()
    ..sort((a, b) {
      final ad = a.year * 12 + a.month;
      final bd = b.year * 12 + b.month;
      return bd.compareTo(ad);
    });
  return sorted;
});

/// (year, month) key for the calendar month immediately before today.
MonthKey lastFinishedMonth(DateTime now) {
  if (now.month == 1) return (year: now.year - 1, month: 12);
  return (year: now.year, month: now.month - 1);
}

/// Real-time PR detection used during the active workout. Given a set the
/// user just closed, returns a [RecapPersonalRecord] if its weight beats
/// every prior result for that exercise — both historical sessions strictly
/// before [today] and sets already completed earlier in the current session.
/// Returns null if there's no PR.
///
/// Callers for unilateral exercises should invoke this twice (main side and
/// `leftKg`/`leftReps`) and keep the higher PR, mirroring the behaviour of
/// [_computeAllSessionPRs] which considers each side independently.
RecapPersonalRecord? detectRealtimePR({
  required List<Session> previousSessions,
  required List<WorkoutSet> currentSessionSetsForExercise,
  required String exerciseId,
  required String exerciseName,
  required double kg,
  required int reps,
  required String today,
}) {
  if (kg <= 0 || reps <= 0) return null;

  double bestWeight = 0;
  for (final s in previousSessions) {
    if (s.date.compareTo(today) >= 0) continue;
    for (final e in s.exercises ?? const <SessionExercise>[]) {
      if (e.exerciseId != exerciseId) continue;
      for (final set in e.sets) {
        if (set.kg > bestWeight) bestWeight = set.kg;
        if (set.leftKg != null && set.leftKg! > bestWeight) {
          bestWeight = set.leftKg!;
        }
      }
    }
  }
  for (final set in currentSessionSetsForExercise) {
    if (set.kg > bestWeight) bestWeight = set.kg;
    if (set.leftKg != null && set.leftKg! > bestWeight) {
      bestWeight = set.leftKg!;
    }
  }

  if (kg <= bestWeight) return null;
  return RecapPersonalRecord(
    exerciseId: exerciseId,
    exerciseName: exerciseName,
    weightKg: kg,
    reps: reps,
    estimatedOneRm: epleyOneRm(kg, reps),
    date: today,
  );
}

/// PR detection for a single session: returns every exercise in `target`
/// whose heaviest weight beat its previous best across all sessions strictly
/// before its date. Sorted by weight descending.
List<RecapPersonalRecord> _computeAllSessionPRs(
    List<Session> sessions, Session target) {
  final targetExercises = target.exercises ?? const <SessionExercise>[];
  if (targetExercises.isEmpty) return const [];

  final targetMax =
      <String, ({double kg, int reps, String name})>{};
  for (final e in targetExercises) {
    for (final set in e.sets) {
      void consider(double kg, int reps) {
        if (kg <= 0 || reps <= 0) return;
        final cur = targetMax[e.exerciseId];
        if (cur == null || kg > cur.kg) {
          targetMax[e.exerciseId] = (kg: kg, reps: reps, name: e.name);
        }
      }

      consider(set.kg, set.reps);
      if (set.leftKg != null && set.leftReps != null) {
        consider(set.leftKg!, set.leftReps!);
      }
    }
  }
  if (targetMax.isEmpty) return const [];

  final prevMax = <String, double>{};
  for (final s in sessions) {
    if (s.id == target.id) continue;
    if (s.date.compareTo(target.date) >= 0) continue;
    for (final e in s.exercises ?? const <SessionExercise>[]) {
      for (final set in e.sets) {
        final cur = prevMax[e.exerciseId] ?? 0;
        if (set.kg > cur) prevMax[e.exerciseId] = set.kg;
        if (set.leftKg != null && set.leftKg! > cur) {
          prevMax[e.exerciseId] = set.leftKg!;
        }
      }
    }
  }

  final results = <RecapPersonalRecord>[];
  for (final entry in targetMax.entries) {
    final prev = prevMax[entry.key] ?? 0;
    if (entry.value.kg > prev) {
      results.add(RecapPersonalRecord(
        exerciseId: entry.key,
        exerciseName: entry.value.name,
        weightKg: entry.value.kg,
        reps: entry.value.reps,
        estimatedOneRm: epleyOneRm(entry.value.kg, entry.value.reps),
        date: target.date,
      ));
    }
  }
  results.sort((a, b) => b.weightKg.compareTo(a.weightKg));
  return results;
}

/// All PRs achieved by the session identified by `sessionId`. Returns an
/// empty list if the session isn't found or no exercise beat its previous best.
final sessionPRsProvider =
    Provider.family<List<RecapPersonalRecord>, String>((ref, sessionId) {
  final sessions =
      ref.watch(sessionsAsyncProvider).value ?? const <Session>[];
  Session? target;
  for (final s in sessions) {
    if (s.id == sessionId) {
      target = s;
      break;
    }
  }
  if (target == null) return const [];
  return _computeAllSessionPRs(sessions, target);
});

/// Returns the MonthKey of last finished month if its recap is unseen and has
/// data, else null. Drives the History tab banner.
final unseenLastRecapProvider = FutureProvider<MonthKey?>((ref) async {
  final sessions =
      ref.watch(sessionsAsyncProvider).value ?? const <Session>[];
  if (sessions.isEmpty) return null;
  final lastKey = lastFinishedMonth(DateTime.now());
  final recap = ref.watch(monthlyRecapProvider(lastKey));
  if (recap == null) return null;
  final keyStr =
      '${lastKey.year.toString().padLeft(4, '0')}-'
      '${lastKey.month.toString().padLeft(2, '0')}';
  final seen = await ref.read(settingsRepositoryProvider).isRecapSeen(keyStr);
  if (seen) return null;
  return lastKey;
});
