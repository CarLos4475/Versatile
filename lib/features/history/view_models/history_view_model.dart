import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/utils/format_utils.dart';
import '../../../domain/entities/session.dart';
import '../../home/view_models/home_view_model.dart';

class HistoryState {
  final List<Session> sessions;
  final Map<String, List<Session>> grouped;
  final double totalVolume;
  final int avgDuration;

  const HistoryState({
    required this.sessions,
    required this.grouped,
    required this.totalVolume,
    required this.avgDuration,
  });
}

final historyProvider = Provider<HistoryState>((ref) {
  final sessions = ref.watch(sessionsAsyncProvider).value ?? [];

  final grouped = <String, List<Session>>{};
  for (final s in sessions) {
    final key = FormatUtils.monthYear(s.date);
    (grouped[key] ??= []).add(s);
  }

  final totalVolume = sessions.fold(0.0, (s, x) => s + x.volumeKg);
  final avgDuration = sessions.isEmpty
      ? 0
      : (sessions.fold(0, (s, x) => s + x.durationMin) ~/ sessions.length);

  return HistoryState(
    sessions: sessions,
    grouped: grouped,
    totalVolume: totalVolume,
    avgDuration: avgDuration,
  );
});
