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

  const HomeState({
    required this.sessions,
    required this.routines,
    this.weekSessions = 0,
    this.weekVolume = 0,
    this.avgTimeMins = 0,
    this.userName = 'there',
    this.workoutDays = const {},
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

  return HomeState(
    sessions: sessions,
    routines: routines,
    weekSessions: weekSessions.length,
    weekVolume: weekSessions.fold(0.0, (s, x) => s + x.volumeKg),
    avgTimeMins: avgTimeMins,
    userName: userName,
    workoutDays: allWorkoutDays,
  );
});
