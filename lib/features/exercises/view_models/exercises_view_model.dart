import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/repository_providers.dart';
import '../../../core/providers/locale_provider.dart';
import '../../../core/utils/l10n_utils.dart';
import '../../../domain/entities/exercise.dart';
import '../../routines/view_models/routines_view_model.dart';

const kArmsSubMuscles = ['Biceps', 'Triceps', 'Forearms'];
const kLegsSubMuscles = ['Quadriceps', 'Hamstrings', 'Glutes', 'Calves'];

const kArmsSet = {'Biceps', 'Triceps', 'Forearms'};
const kLegsSet = {'Quadriceps', 'Hamstrings', 'Glutes', 'Calves'};

enum ExercisesTab { all, mine }

enum ExerciseLaterality { all, bilateral, unilateral }

class ExercisesState {
  final String query;
  final String selectedMuscle;
  final String? selectedSubMuscle;
  final ExercisesTab tab;
  final ExerciseLaterality laterality;
  final bool isEditMode;
  final Set<String> selectedIds;

  const ExercisesState({
    this.query = '',
    this.selectedMuscle = 'All',
    this.selectedSubMuscle,
    this.tab = ExercisesTab.all,
    this.laterality = ExerciseLaterality.all,
    this.isEditMode = false,
    this.selectedIds = const {},
  });

  ExercisesState copyWith({
    String? query,
    String? selectedMuscle,
    String? selectedSubMuscle,
    bool clearSubMuscle = false,
    ExercisesTab? tab,
    ExerciseLaterality? laterality,
    bool? isEditMode,
    Set<String>? selectedIds,
  }) {
    return ExercisesState(
      query: query ?? this.query,
      selectedMuscle: selectedMuscle ?? this.selectedMuscle,
      selectedSubMuscle: clearSubMuscle
          ? null
          : (selectedSubMuscle ?? this.selectedSubMuscle),
      tab: tab ?? this.tab,
      laterality: laterality ?? this.laterality,
      isEditMode: isEditMode ?? this.isEditMode,
      selectedIds: selectedIds ?? this.selectedIds,
    );
  }
}

class ExercisesNotifier extends StateNotifier<ExercisesState> {
  ExercisesNotifier() : super(const ExercisesState());

  void setQuery(String q) => state = state.copyWith(query: q);

  void setMuscle(String m) =>
      state = state.copyWith(selectedMuscle: m, clearSubMuscle: true);

  void setSubMuscle(String? m) {
    if (state.selectedSubMuscle == m) {
      state = state.copyWith(clearSubMuscle: true);
    } else {
      state = state.copyWith(selectedSubMuscle: m);
    }
  }

  void setTab(ExercisesTab t) {
    if (t != state.tab) {
      state = state.copyWith(tab: t, isEditMode: false, selectedIds: {});
    }
  }

  void setLaterality(ExerciseLaterality l) =>
      state = state.copyWith(laterality: l);

  void toggleEditMode() {
    state = state.copyWith(
      isEditMode: !state.isEditMode,
      selectedIds: {},
    );
  }

  void toggleSelection(String id) {
    final next = Set<String>.from(state.selectedIds);
    if (next.contains(id)) {
      next.remove(id);
    } else {
      next.add(id);
    }
    state = state.copyWith(selectedIds: next);
  }

  void clearSelection() {
    state = state.copyWith(selectedIds: {});
  }
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

  Future<void> deleteExercises(Set<String> ids) async {
    final repo = ref.read(exerciseRepositoryProvider);
    final routineRepo = ref.read(routineRepositoryProvider);
    
    for (final id in ids) {
      // 1. Remove from all routines first
      await routineRepo.deleteReferencesToExercise(id);
      // 2. Remove the exercise definition
      await repo.delete(id);
    }
    
    // Invalidate both so routines and exercises refresh
    ref.invalidateSelf();
    ref.invalidate(routinesProvider);
  }
}

final exercisesAsyncProvider =
    AsyncNotifierProvider<ExercisesAsyncNotifier, List<Exercise>>(
  ExercisesAsyncNotifier.new,
);

final filteredExercisesProvider = Provider<List<Exercise>>((ref) {
  final allExercises = ref.watch(exercisesAsyncProvider).value ?? [];
  final state = ref.watch(exercisesProvider);
  final locale = ref.watch(localeProvider).languageCode;

  return allExercises.where((e) {
    if (state.tab == ExercisesTab.mine && !e.isCustom) return false;

    if (state.selectedMuscle != 'All') {
      if (state.selectedMuscle == 'Arms') {
        if (state.selectedSubMuscle != null) {
          if (e.muscle != state.selectedSubMuscle) return false;
        } else {
          if (!kArmsSet.contains(e.muscle)) return false;
        }
      } else if (state.selectedMuscle == 'Legs') {
        if (state.selectedSubMuscle != null) {
          if (e.muscle != state.selectedSubMuscle) return false;
        } else {
          if (!kLegsSet.contains(e.muscle)) return false;
        }
      } else {
        if (e.muscle != state.selectedMuscle) return false;
      }
    }

    if (state.laterality == ExerciseLaterality.unilateral && !e.isUnilateral) {
      return false;
    }
    if (state.laterality == ExerciseLaterality.bilateral && e.isUnilateral) {
      return false;
    }
    if (state.query.isNotEmpty) {
      final name = e.getLocalizedNameNonContext(locale).toLowerCase();
      if (!name.contains(state.query.toLowerCase())) return false;
    }
    return true;
  }).toList();
});
