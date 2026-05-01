import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/seed_data.dart';
import '../../../domain/entities/exercise.dart';

enum ExercisesTab { all, mine }

class ExercisesState {
  final String query;
  final String selectedMuscle;
  final ExercisesTab tab;

  const ExercisesState({
    this.query = '',
    this.selectedMuscle = 'All',
    this.tab = ExercisesTab.all,
  });

  ExercisesState copyWith({
    String? query,
    String? selectedMuscle,
    ExercisesTab? tab,
  }) {
    return ExercisesState(
      query: query ?? this.query,
      selectedMuscle: selectedMuscle ?? this.selectedMuscle,
      tab: tab ?? this.tab,
    );
  }
}

class ExercisesNotifier extends StateNotifier<ExercisesState> {
  ExercisesNotifier() : super(const ExercisesState());

  void setQuery(String q) => state = state.copyWith(query: q);
  void setMuscle(String m) => state = state.copyWith(selectedMuscle: m);
  void setTab(ExercisesTab t) => state = state.copyWith(tab: t);
}

final exercisesProvider =
    StateNotifierProvider<ExercisesNotifier, ExercisesState>(
  (_) => ExercisesNotifier(),
);

final filteredExercisesProvider = Provider<List<Exercise>>((ref) {
  final state = ref.watch(exercisesProvider);
  return SeedData.exercises.where((e) {
    if (state.tab == ExercisesTab.mine && !e.isCustom) return false;
    if (state.selectedMuscle != 'All' && e.muscle != state.selectedMuscle) {
      return false;
    }
    if (state.query.isNotEmpty &&
        !e.name.toLowerCase().contains(state.query.toLowerCase())) {
      return false;
    }
    return true;
  }).toList();
});
