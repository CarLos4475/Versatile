import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/utils/format_utils.dart';
import '../../../data/seed_data.dart';
import '../../../domain/entities/session.dart';

class HistoryState {
  final List<Session> sessions;
  final Map<String, List<Session>> grouped;

  const HistoryState({required this.sessions, required this.grouped});
}

final historyProvider = Provider<HistoryState>((ref) {
  final sessions = SeedData.sessions;
  final Map<String, List<Session>> grouped = {};
  for (final s in sessions) {
    final key = FormatUtils.monthYear(s.date);
    (grouped[key] ??= []).add(s);
  }
  return HistoryState(sessions: sessions, grouped: grouped);
});
