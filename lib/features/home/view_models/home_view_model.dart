import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/repository_providers.dart';
import '../../../domain/entities/program.dart';
import '../../../domain/entities/session.dart';
import '../../../domain/entities/routine.dart';
import '../../programs/view_models/programs_view_model.dart';
import '../../routines/view_models/routines_view_model.dart';

class SessionsAsyncNotifier extends AsyncNotifier<List<Session>> {
  @override
  Future<List<Session>> build() async {
    return ref.read(sessionRepositoryProvider).getAll();
  }
}

final sessionsAsyncProvider =
    AsyncNotifierProvider<SessionsAsyncNotifier, List<Session>>(
      SessionsAsyncNotifier.new,
    );

class HomeState {
  final List<Session> sessions;
  final List<Routine> routines;
  final int weekSessions;
  final double weekVolume;
  final int avgTimeMins;
  final String userName;
  final Set<String> workoutDays;
  final Routine? nextRoutine;
  final int? nextRoutineDaysAgo; // null = never done
  // When the active program assigns a non-routine label to today (Rest,
  // Cardio, etc.), this carries it. Mutually exclusive with [nextRoutine]
  // being a program-sourced routine — but a label still leaves [nextRoutine]
  // null so the hero card switches to label mode.
  final String? todayLabel;
  // True when today's hero card came from the active program (either a
  // routine slot or a label slot), so the UI can show a "planned" badge.
  final bool plannedFromProgram;
  // True when today falls inside a deload week of the active program.
  final bool isDeloadWeek;
  // True when an active program is running but today has no explicit slot,
  // so we treat it as a rest day by default.
  final bool isAutoRestDay;

  const HomeState({
    required this.sessions,
    required this.routines,
    this.weekSessions = 0,
    this.weekVolume = 0,
    this.avgTimeMins = 0,
    this.userName = 'there',
    this.workoutDays = const {},
    this.nextRoutine,
    this.nextRoutineDaysAgo,
    this.todayLabel,
    this.plannedFromProgram = false,
    this.isDeloadWeek = false,
    this.isAutoRestDay = false,
  });
}

final workoutLogDaysProvider = FutureProvider<Set<String>>((ref) async {
  ref.watch(sessionsAsyncProvider);
  return ref.read(workoutLogRepositoryProvider).getDays(84);
});

final homeProvider = Provider<HomeState>((ref) {
  final sessions = ref.watch(sessionsAsyncProvider).value ?? [];
  final routines = ref.watch(routinesProvider).value ?? [];
  final userName = ref.watch(userNameProvider).value ?? 'there';
  final loggedDays = ref.watch(workoutLogDaysProvider).value ?? {};

  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final weekStart = today.subtract(Duration(days: today.weekday - 1));

  final weekSessions = sessions.where((s) {
    final d = DateTime.parse('${s.date}T00:00:00');
    return !d.isBefore(weekStart);
  }).toList();

  final avgTimeMins = weekSessions.isEmpty
      ? 0
      : (weekSessions.fold(0, (s, x) => s + x.durationMin) /
                weekSessions.length)
            .round();

  // combine workout_log dates with recent session dates for full coverage
  final sessionDates = sessions.map((s) => s.date).toSet();
  final allWorkoutDays = {...loggedDays, ...sessionDates};

  // Build last done date per routine from session history (last 30 days)
  final lastDoneMap = <String, String>{};
  for (final s in sessions) {
    final existing = lastDoneMap[s.routineId];
    if (existing == null || s.date.compareTo(existing) > 0) {
      lastDoneMap[s.routineId] = s.date;
    }
  }

  // Pick the routine done least recently (never-done routines rank highest)
  Routine? nextRoutine;
  int? nextRoutineDaysAgo;
  if (routines.isNotEmpty) {
    int maxScore = -1;
    for (final routine in routines) {
      final lastDate = lastDoneMap[routine.id];
      final score = lastDate == null
          ? 999999
          : today.difference(DateTime.parse('${lastDate}T00:00:00')).inDays;
      if (score > maxScore) {
        maxScore = score;
        nextRoutine = routine;
        nextRoutineDaysAgo = lastDate == null ? null : score;
      }
    }
  }

  // If a program is active and configures today, override the LRU suggestion.
  // Days inside an active program with no explicit slot fall back to rest.
  String? todayLabel;
  bool plannedFromProgram = false;
  bool isDeloadWeek = false;
  bool isAutoRestDay = false;
  final planned = ref.watch(todaysPlannedSlotProvider).value;
  if (planned != null) {
    isDeloadWeek = planned.isDeloadWeek;
    if (planned.slot.kind == SlotKind.routine) {
      Routine? programRoutine;
      for (final r in routines) {
        if (r.id == planned.slot.routineId) {
          programRoutine = r;
          break;
        }
      }
      // If the referenced routine was deleted, fall back to LRU silently.
      if (programRoutine != null) {
        nextRoutine = programRoutine;
        final lastDate = lastDoneMap[programRoutine.id];
        nextRoutineDaysAgo = lastDate == null
            ? null
            : today.difference(DateTime.parse('${lastDate}T00:00:00')).inDays;
        plannedFromProgram = true;
      }
    } else {
      todayLabel = planned.slot.labelText;
      nextRoutine = null;
      nextRoutineDaysAgo = null;
      plannedFromProgram = true;
    }
  } else {
    final active = ref.watch(activeProgramProvider).value;
    if (active != null) {
      final start = DateTime(
        active.startDate.year,
        active.startDate.month,
        active.startDate.day,
      );
      if (!today.isBefore(start)) {
        final daysSinceStart = today.difference(start).inDays;
        final weekIndex =
            (daysSinceStart ~/ 7) % active.program.weeksCount;
        isDeloadWeek = active.program.deloadWeeks.contains(weekIndex);
        isAutoRestDay = true;
        nextRoutine = null;
        nextRoutineDaysAgo = null;
      }
    }
  }

  return HomeState(
    sessions: sessions,
    routines: routines,
    weekSessions: weekSessions.length,
    weekVolume: weekSessions.fold(0.0, (s, x) => s + x.volumeKg),
    avgTimeMins: avgTimeMins,
    userName: userName,
    workoutDays: allWorkoutDays,
    nextRoutine: nextRoutine,
    nextRoutineDaysAgo: nextRoutineDaysAgo,
    todayLabel: todayLabel,
    plannedFromProgram: plannedFromProgram,
    isDeloadWeek: isDeloadWeek,
    isAutoRestDay: isAutoRestDay,
  );
});

// Fetches the main exercise name and PR for the hero card's suggested routine.
final heroCardInfoProvider =
    FutureProvider<({String? id, String? exerciseName, double? pr})>((ref) async {
  final state = ref.watch(homeProvider);
  final nextRoutine = state.nextRoutine;
  if (nextRoutine == null || nextRoutine.exercises.isEmpty) {
    return (id: null, exerciseName: null, pr: null);
  }

  final firstExercise = nextRoutine.exercises.first;
  final exercise = await ref
      .read(exerciseRepositoryProvider)
      .findById(firstExercise.exerciseId);

  // Compute PR from sessions in memory (covers the last 30 days)
  double? pr;
  for (final session in state.sessions) {
    for (final se in (session.exercises ?? [])) {
      if (se.exerciseId == firstExercise.exerciseId) {
        for (final set in se.sets) {
          if (set.kg > (pr ?? 0)) pr = set.kg;
          if (set.leftKg != null && set.leftKg! > (pr ?? 0)) {
            pr = set.leftKg!;
          }
        }
      }
    }
  }

  return (id: exercise?.id, exerciseName: exercise?.name, pr: pr);
});
