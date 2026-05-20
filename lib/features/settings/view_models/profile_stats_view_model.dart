import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/repository_providers.dart';

class ProfileStats {
  final int sessionCount;
  final int totalMinutes;
  final int prCount;

  const ProfileStats({
    required this.sessionCount,
    required this.totalMinutes,
    required this.prCount,
  });

  int get totalHours => (totalMinutes / 60).floor();
}

final profileStatsProvider = FutureProvider<ProfileStats>((ref) async {
  final repo = ref.watch(sessionRepositoryProvider);
  final aggregates = await repo.getSessionAggregates();
  final prs = await repo.getPrCount();
  return ProfileStats(
    sessionCount: aggregates.sessionCount,
    totalMinutes: aggregates.totalMinutes,
    prCount: prs,
  );
});
