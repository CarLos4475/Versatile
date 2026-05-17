import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/repository_providers.dart';
import '../../../core/utils/format_utils.dart';
import '../../../domain/entities/monthly_recap.dart';
import '../../../domain/entities/session.dart';
import '../../home/view_models/home_view_model.dart';

typedef MonthKey = ({int year, int month});

bool _sessionInMonth(Session s, int year, int month) {
  if (s.date.length < 7) return false;
  final y = int.tryParse(s.date.substring(0, 4));
  final m = int.tryParse(s.date.substring(5, 7));
  return y == year && m == month;
}

double _setOneRm(double kg, int reps) => kg * (1 + reps / 30);

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
    final orm = _setOneRm(kg, reps);
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
  for (final s in sessions) {
    if (_sessionInMonth(s, prevMonth.year, prevMonth.month)) {
      prevVol += s.volumeKg;
      prevHasData = true;
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
  );
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

/// PR detection for a single session: returns the most impressive new 1RM
/// achieved in `target` compared to all sessions strictly before its date.
/// Returns null if no exercise in this session beat its previous best.
RecapPersonalRecord? _computeSessionPR(List<Session> sessions, Session target) {
  final targetExercises = target.exercises ?? const <SessionExercise>[];
  if (targetExercises.isEmpty) return null;

  final targetMax =
      <String, ({double orm, double kg, int reps, String name})>{};
  for (final e in targetExercises) {
    for (final set in e.sets) {
      void consider(double kg, int reps) {
        if (kg <= 0 || reps <= 0) return;
        final orm = _setOneRm(kg, reps);
        final cur = targetMax[e.exerciseId];
        if (cur == null || orm > cur.orm) {
          targetMax[e.exerciseId] =
              (orm: orm, kg: kg, reps: reps, name: e.name);
        }
      }

      consider(set.kg, set.reps);
      if (set.leftKg != null && set.leftReps != null) {
        consider(set.leftKg!, set.leftReps!);
      }
    }
  }
  if (targetMax.isEmpty) return null;

  final prevMax = <String, double>{};
  for (final s in sessions) {
    if (s.id == target.id) continue;
    if (s.date.compareTo(target.date) >= 0) continue;
    for (final e in s.exercises ?? const <SessionExercise>[]) {
      for (final set in e.sets) {
        void consider(double kg, int reps) {
          if (kg <= 0 || reps <= 0) return;
          final orm = _setOneRm(kg, reps);
          final cur = prevMax[e.exerciseId] ?? 0;
          if (orm > cur) prevMax[e.exerciseId] = orm;
        }

        consider(set.kg, set.reps);
        if (set.leftKg != null && set.leftReps != null) {
          consider(set.leftKg!, set.leftReps!);
        }
      }
    }
  }

  RecapPersonalRecord? best;
  for (final entry in targetMax.entries) {
    final prev = prevMax[entry.key] ?? 0;
    if (entry.value.orm > prev) {
      if (best == null || entry.value.orm > best.estimatedOneRm) {
        best = RecapPersonalRecord(
          exerciseId: entry.key,
          exerciseName: entry.value.name,
          weightKg: entry.value.kg,
          reps: entry.value.reps,
          estimatedOneRm: entry.value.orm,
          date: target.date,
        );
      }
    }
  }
  return best;
}

/// PR (if any) achieved by the session identified by `sessionId`. Returns
/// null if the session isn't found or no exercise beat its previous best.
final sessionPRProvider =
    Provider.family<RecapPersonalRecord?, String>((ref, sessionId) {
  final sessions =
      ref.watch(sessionsAsyncProvider).value ?? const <Session>[];
  Session? target;
  for (final s in sessions) {
    if (s.id == sessionId) {
      target = s;
      break;
    }
  }
  if (target == null) return null;
  return _computeSessionPR(sessions, target);
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
