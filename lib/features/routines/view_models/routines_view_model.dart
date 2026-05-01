import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/repository_providers.dart';
import '../../../domain/entities/routine.dart';

class RoutinesNotifier extends AsyncNotifier<List<Routine>> {
  @override
  Future<List<Routine>> build() async {
    return ref.read(routineRepositoryProvider).getAll();
  }

  Future<void> addRoutine(Routine routine) async {
    await ref.read(routineRepositoryProvider).insert(routine);
    ref.invalidateSelf();
  }

  Future<void> deleteRoutine(String id) async {
    await ref.read(routineRepositoryProvider).delete(id);
    ref.invalidateSelf();
  }

  Future<void> addExercise(String routineId, RoutineExercise re) async {
    await ref.read(routineRepositoryProvider).addExercise(routineId, re);
    ref.invalidateSelf();
  }

  Future<void> removeExercise(String routineId, int dbId) async {
    await ref.read(routineRepositoryProvider).removeExercise(routineId, dbId);
    ref.invalidateSelf();
  }

  Future<void> reorderExercises(
      String routineId, List<RoutineExercise> exercises) async {
    await ref
        .read(routineRepositoryProvider)
        .reorderExercises(routineId, exercises);
    ref.invalidateSelf();
  }
}

final routinesProvider =
    AsyncNotifierProvider<RoutinesNotifier, List<Routine>>(
  RoutinesNotifier.new,
);
