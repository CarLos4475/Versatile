import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/repository_providers.dart';
import '../../../domain/entities/program.dart';

/// All programs (templates) sorted by created_at DESC.
final programsListProvider = FutureProvider<List<Program>>((ref) async {
  return ref.read(programRepositoryProvider).getAll();
});

/// Lookup a single program by id.
final programByIdProvider = FutureProvider.autoDispose
    .family<Program?, String>((ref, id) async {
      return ref.read(programRepositoryProvider).findById(id);
    });

/// Active program info read from settings. Returns (id, startDate, program).
/// All three are null if no program is active. Program is null if the
/// active_program_id setting points to a deleted program — in that case the
/// caller should call clearActiveProgram() to clean up.
class ActiveProgramInfo {
  final String id;
  final DateTime startDate;
  final Program program;
  const ActiveProgramInfo({
    required this.id,
    required this.startDate,
    required this.program,
  });
}

final activeProgramProvider = FutureProvider<ActiveProgramInfo?>((ref) async {
  final settings = ref.read(settingsRepositoryProvider);
  final id = await settings.getActiveProgramId();
  if (id == null || id.isEmpty) return null;
  final startDate = await settings.getActiveProgramStartDate();
  if (startDate == null) return null;
  final program = await ref.read(programRepositoryProvider).findById(id);
  if (program == null) {
    // Stale pointer to a deleted program: clean up silently and fall back.
    await settings.clearActiveProgram();
    return null;
  }
  return ActiveProgramInfo(
    id: id,
    startDate: startDate,
    program: program,
  );
});

/// Today's planned slot from the active program, if any. Null when:
/// - No active program
/// - The active program's cell for today is unconfigured
class TodaysPlannedSlot {
  final Program program;
  final int weekIndex;
  final int weekday;
  final bool isDeloadWeek;
  final ProgramSlot slot;
  const TodaysPlannedSlot({
    required this.program,
    required this.weekIndex,
    required this.weekday,
    required this.isDeloadWeek,
    required this.slot,
  });
}

final todaysPlannedSlotProvider = FutureProvider<TodaysPlannedSlot?>((
  ref,
) async {
  final active = await ref.watch(activeProgramProvider.future);
  if (active == null) return null;

  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final start = DateTime(
    active.startDate.year,
    active.startDate.month,
    active.startDate.day,
  );

  // If the user picked a future start date, the program hasn't begun yet.
  if (today.isBefore(start)) return null;

  final daysSinceStart = today.difference(start).inDays;
  final weeksElapsed = daysSinceStart ~/ 7;
  final weekIndex = weeksElapsed % active.program.weeksCount;
  final weekday = today.weekday; // 1..7

  final slot = active.program.slotAt(weekIndex, weekday);
  if (slot == null) return null;

  return TodaysPlannedSlot(
    program: active.program,
    weekIndex: weekIndex,
    weekday: weekday,
    isDeloadWeek: active.program.deloadWeeks.contains(weekIndex),
    slot: slot,
  );
});
