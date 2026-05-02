import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/repository_providers.dart';
import '../../../domain/entities/session.dart';
import '../../../domain/entities/routine.dart';
import '../../routines/view_models/routines_view_model.dart';

class SessionsAsyncNotifier extends AsyncNotifier<List<Session>> {
  @override
  Future<List<Session>> build() async {
    await ref.read(sessionRepositoryProvider).deleteOldSessions();
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
