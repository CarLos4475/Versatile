import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/seed_data.dart';
import '../../../domain/entities/session.dart';
import '../../../domain/entities/routine.dart';

class HomeState {
  final List<Session> sessions;
  final List<Routine> routines;

  const HomeState({required this.sessions, required this.routines});

  int get weekSessions => sessions.length > 4 ? 4 : sessions.length;
  double get weekVolume => sessions
      .take(4)
      .fold(0.0, (s, x) => s + x.volumeKg);
}

final homeProvider = Provider<HomeState>((ref) {
  return HomeState(
    sessions: SeedData.sessions,
    routines: SeedData.routines,
  );
});
