import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/repository_providers.dart';
import '../../../domain/entities/exercise.dart';

enum ExercisesTab { all, mine }

enum ExerciseLaterality { all, bilateral, unilateral }

class ExercisesState {
  final String query;
  final String selectedMuscle;
  final ExercisesTab tab;
  final ExerciseLaterality laterality;

  const ExercisesState({
    this.query = '',
    this.selectedMuscle = 'All',
    this.tab = ExercisesTab.all,
    this.laterality = ExerciseLaterality.all,
  });

  ExercisesState copyWith({
    String? query,
    String? selectedMuscle,
    ExercisesTab? tab,
    ExerciseLaterality? laterality,
  }) {
    return ExercisesState(
      query: query ?? this.query,
      selectedMuscle: selectedMuscle ?? this.selectedMuscle,
      tab: tab ?? this.tab,
      laterality: laterality ?? this.laterality,
    );
  }
}

class ExercisesNotifier extends StateNotifier<ExercisesState> {
  ExercisesNotifier() : super(const ExercisesState());

  void setQuery(String q) => state = state.copyWith(query: q);
  void setMuscle(String m) => state = state.copyWith(selectedMuscle: m);
  void setTab(ExercisesTab t) => state = state.copyWith(tab: t);
  void setLaterality(ExerciseLaterality l) =>
      state = state.copyWith(laterality: l);
}

final exercisesProvider =
    StateNotifierProvider<ExercisesNotifier, ExercisesState>(
  (_) => ExercisesNotifier(),
);

class ExercisesAsyncNotifier extends AsyncNotifier<List<Exercise>> {
  @override
  Future<List<Exercise>> build() async {
    return ref.read(exerciseRepositoryProvider).getAll();
  }

  Future<void> addExercise(Exercise exercise) async {
    await ref.read(exerciseRepositoryProvider).insert(exercise);
    ref.invalidateSelf();
  }
}

final exercisesAsyncProvider =
    AsyncNotifierProvider<ExercisesAsyncNotifier, List<Exercise>>(
  ExercisesAsyncNotifier.new,
);

final filteredExercisesProvider = Provider<List<Exercise>>((ref) {
  final allExercises = ref.watch(exercisesAsyncProvider).value ?? [];
  final state = ref.watch(exercisesProvider);
  return allExercises.where((e) {
    if (state.tab == ExercisesTab.mine && !e.isCustom) return false;
    if (state.selectedMuscle != 'All' && e.muscle != state.selectedMuscle) {
      return false;
    }
    if (state.laterality == ExerciseLaterality.unilateral && !e.isUnilateral) {
      return false;
    }
    if (state.laterality == ExerciseLaterality.bilateral && e.isUnilateral) {
      return false;
    }
    if (state.query.isNotEmpty &&
        !e.name.toLowerCase().contains(state.query.toLowerCase())) {
      return false;
    }
    return true;
  }).toList();
});
