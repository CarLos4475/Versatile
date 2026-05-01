import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/repository_providers.dart';
import '../../../domain/entities/session.dart';
import '../../../domain/entities/routine.dart';
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
  final int streak;

  const HomeState({
    required this.sessions,
    required this.routines,
    this.weekSessions = 0,
    this.weekVolume = 0,
    this.streak = 0,
  });
}

final homeProvider = Provider<HomeState>((ref) {
  final sessions = ref.watch(sessionsAsyncProvider).value ?? [];
  final routines = ref.watch(routinesProvider).value ?? [];

  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final weekStart = today.subtract(Duration(days: today.weekday - 1));

  final weekSessions = sessions.where((s) {
    final d = DateTime.parse('${s.date}T00:00:00');
    return !d.isBefore(weekStart);
  }).toList();

  int streak = 0;
  for (int i = 0; i < 365; i++) {
    final check = today.subtract(Duration(days: i));
    final dateStr =
        '${check.year}-${check.month.toString().padLeft(2, '0')}-${check.day.toString().padLeft(2, '0')}';
    if (sessions.any((s) => s.date == dateStr)) {
      streak++;
    } else if (i > 0) {
      break;
    }
  }

  return HomeState(
    sessions: sessions,
    routines: routines,
    weekSessions: weekSessions.length,
    weekVolume: weekSessions.fold(0.0, (s, x) => s + x.volumeKg),
    streak: streak,
  );
});
