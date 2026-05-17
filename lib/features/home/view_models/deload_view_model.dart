import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/repository_providers.dart';
import '../../../domain/entities/session.dart';
import '../../../domain/entities/workout_set.dart';
import '../../programs/view_models/programs_view_model.dart';
import '../../recap/view_models/recap_view_model.dart';
import 'home_view_model.dart';

/// Output of the deload suggestion analysis. Carries which signals fired so
/// the banner can pick the right copy.
class DeloadSuggestion {
  /// Several lifts' best e1RM hasn't moved up in 3+ weeks.
  final bool stagnation;
  /// Weekly volume in the last 2 weeks dropped vs the preceding 4 weeks.
  final bool volumeDrop;

  const DeloadSuggestion({
    required this.stagnation,
    required this.volumeDrop,
  });
}

/// Hard floors below which the heuristic doesn't have enough data to be
/// trustworthy. Suggestion is suppressed entirely under these thresholds.
const _minTotalSessions = 12;
const _minSessionsInWindow = 4;

/// Days of recent inactivity that already count as a natural deload.
const _restGracePeriodDays = 14;

/// Stagnation fires when this many tracked lifts haven't progressed in 3+
/// weeks. Tracked lifts need at least 3 sessions in the analysis window.
const _stagnationMinExercises = 2;
const _stagnationMinSessions = 3;
const _stagnationWeeksWindow = 6;
const _stagnationStaleWeeks = 3;

/// Volume drop fires when last-2-weeks avg < (prev-4-weeks avg × this).
const _volumeDropRatio = 0.85;

/// Whole-number ISO week for [date] anchored at Monday. Returned as days
/// since epoch divided by 7 with a shift so the boundary lands on Monday —
/// gives a monotonically increasing integer that's easy to compare.
int _weekStamp(DateTime date) {
  // 1970-01-01 was a Thursday. Shift so Monday becomes 0.
  final shifted = date.toUtc().millisecondsSinceEpoch ~/ 86400000 - 3;
  return shifted ~/ 7;
}

DeloadSuggestion? _analyse(
  List<Session> sessions,
  DateTime today,
  bool dismissed,
  bool todayIsDeloadWeek,
) {
  if (dismissed) return null;
  if (todayIsDeloadWeek) return null;
  if (sessions.length < _minTotalSessions) return null;

  final todayStamp = _weekStamp(today);
  final windowStart = today.subtract(Duration(days: 7 * _stagnationWeeksWindow));

  // Most recent session date — if user already hasn't trained for a while,
  // a deload "suggestion" is moot.
  DateTime? lastTraining;
  for (final s in sessions) {
    final d = DateTime.tryParse('${s.date}T00:00:00');
    if (d == null) continue;
    if (lastTraining == null || d.isAfter(lastTraining)) {
      lastTraining = d;
    }
  }
  if (lastTraining == null) return null;
  if (today.difference(lastTraining).inDays > _restGracePeriodDays) {
    return null;
  }

  // Sessions inside the analysis window.
  final windowSessions = <Session>[];
  for (final s in sessions) {
    final d = DateTime.tryParse('${s.date}T00:00:00');
    if (d == null) continue;
    if (d.isBefore(windowStart)) continue;
    windowSessions.add(s);
  }
  if (windowSessions.length < _minSessionsInWindow) return null;

  // ── Stagnation ───────────────────────────────────────────────────────────
  // For each exercise with enough sessions, find the week of its best e1RM.
  // If the best was 3+ weeks ago, the lift is considered stagnant.
  final perExerciseBestStamp = <String, int>{};
  final perExerciseBestOrm = <String, double>{};
  final perExerciseSessionCount = <String, int>{};
  for (final s in windowSessions) {
    final d = DateTime.tryParse('${s.date}T00:00:00');
    if (d == null) continue;
    final stamp = _weekStamp(d);
    final seen = <String>{};
    for (final e in s.exercises ?? const <SessionExercise>[]) {
      if (seen.add(e.exerciseId)) {
        perExerciseSessionCount[e.exerciseId] =
            (perExerciseSessionCount[e.exerciseId] ?? 0) + 1;
      }
      double bestInSession = perExerciseBestOrm[e.exerciseId] ?? 0;
      var beat = false;
      for (final set in e.sets) {
        final orm = _setOrmOrZero(set);
        if (orm > bestInSession) {
          bestInSession = orm;
          beat = true;
        }
      }
      if (beat) {
        perExerciseBestOrm[e.exerciseId] = bestInSession;
        perExerciseBestStamp[e.exerciseId] = stamp;
      }
    }
  }
  var stagnantCount = 0;
  for (final entry in perExerciseSessionCount.entries) {
    if (entry.value < _stagnationMinSessions) continue;
    final bestStamp = perExerciseBestStamp[entry.key];
    if (bestStamp == null) continue;
    if (todayStamp - bestStamp >= _stagnationStaleWeeks) {
      stagnantCount += 1;
    }
  }
  final stagnation = stagnantCount >= _stagnationMinExercises;

  // ── Volume drop ──────────────────────────────────────────────────────────
  // Sum volume by week stamp, compare last 2 weeks vs preceding 4.
  final volumeByWeek = <int, double>{};
  for (final s in windowSessions) {
    final d = DateTime.tryParse('${s.date}T00:00:00');
    if (d == null) continue;
    final stamp = _weekStamp(d);
    volumeByWeek[stamp] = (volumeByWeek[stamp] ?? 0) + s.volumeKg;
  }
  double avgFor(Iterable<int> stamps) {
    var sum = 0.0;
    var n = 0;
    for (final st in stamps) {
      sum += volumeByWeek[st] ?? 0;
      n += 1;
    }
    return n == 0 ? 0 : sum / n;
  }
  final last2 = [todayStamp, todayStamp - 1];
  final prev4 = [
    todayStamp - 2,
    todayStamp - 3,
    todayStamp - 4,
    todayStamp - 5,
  ];
  final last2Avg = avgFor(last2);
  final prev4Avg = avgFor(prev4);
  final volumeDrop = prev4Avg > 0 && last2Avg < prev4Avg * _volumeDropRatio;

  if (!stagnation && !volumeDrop) return null;
  return DeloadSuggestion(
    stagnation: stagnation,
    volumeDrop: volumeDrop,
  );
}

double _setOrmOrZero(WorkoutSet set) {
  double best = 0;
  if (set.kg > 0 && set.reps > 0) {
    final orm = epleyOneRm(set.kg, set.reps);
    if (orm > best) best = orm;
  }
  if (set.leftKg != null && set.leftReps != null &&
      set.leftKg! > 0 && set.leftReps! > 0) {
    final orm = epleyOneRm(set.leftKg!, set.leftReps!);
    if (orm > best) best = orm;
  }
  return best;
}

/// Dismissal flag — true means the banner is hidden for the current grace
/// period. Reads `deload_dismissed_until` from settings.
final deloadDismissedProvider = FutureProvider<bool>((ref) async {
  final until = await ref.read(settingsRepositoryProvider)
      .getDeloadDismissedUntil();
  if (until == null) return false;
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  return !today.isAfter(until);
});

/// Whether today falls inside a deload week of the active program. If so,
/// the user is already deloading and the banner should stay hidden.
final isTodayInDeloadWeekProvider = FutureProvider<bool>((ref) async {
  final active = await ref.watch(activeProgramProvider.future);
  if (active == null) return false;
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final start = DateTime(
    active.startDate.year,
    active.startDate.month,
    active.startDate.day,
  );
  if (today.isBefore(start)) return false;
  final weeksElapsed = today.difference(start).inDays ~/ 7;
  final weekIndex = weeksElapsed % active.program.weeksCount;
  return active.program.deloadWeeks.contains(weekIndex);
});

final deloadSuggestionProvider = Provider<DeloadSuggestion?>((ref) {
  final sessions = ref.watch(sessionsAsyncProvider).value ?? const <Session>[];
  final dismissed = ref.watch(deloadDismissedProvider).value ?? false;
  final inDeloadWeek =
      ref.watch(isTodayInDeloadWeekProvider).value ?? false;
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  return _analyse(sessions, today, dismissed, inDeloadWeek);
});
