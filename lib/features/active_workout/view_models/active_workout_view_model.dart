import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/seed_data.dart';
import '../../../domain/entities/exercise.dart';
import '../../../domain/entities/routine.dart';
import '../../../domain/entities/workout_set.dart';

class ExerciseWorkoutState {
  final String exerciseId;
  final int targetSets;
  final String targetReps;
  final int restSec;
  final bool isExpanded;
  final List<WorkoutSet> completedSets;
  final WorkoutSet? currentInput;

  const ExerciseWorkoutState({
    required this.exerciseId,
    required this.targetSets,
    required this.targetReps,
    required this.restSec,
    this.isExpanded = false,
    this.completedSets = const [],
    this.currentInput,
  });

  bool get isDone => completedSets.length >= targetSets;
  int get nextSetIndex => completedSets.length;

  ExerciseWorkoutState copyWith({
    bool? isExpanded,
    List<WorkoutSet>? completedSets,
    WorkoutSet? currentInput,
    bool clearCurrentInput = false,
  }) {
    return ExerciseWorkoutState(
      exerciseId: exerciseId,
      targetSets: targetSets,
      targetReps: targetReps,
      restSec: restSec,
      isExpanded: isExpanded ?? this.isExpanded,
      completedSets: completedSets ?? this.completedSets,
      currentInput:
          clearCurrentInput ? null : (currentInput ?? this.currentInput),
    );
  }
}

class RestTimerState {
  final int total;
  final int remaining;
  final String exerciseName;

  const RestTimerState({
    required this.total,
    required this.remaining,
    required this.exerciseName,
  });

  double get progress => total > 0 ? remaining / total : 0.0;

  RestTimerState copyWith({int? remaining, int? total}) {
    return RestTimerState(
      total: total ?? this.total,
      remaining: remaining ?? this.remaining,
      exerciseName: exerciseName,
    );
  }
}

class ActiveWorkoutState {
  final Routine routine;
  final List<Exercise> exercises;
  final int elapsedSeconds;
  final bool isRunning;
  final List<ExerciseWorkoutState> exerciseStates;
  final RestTimerState? restTimer;

  const ActiveWorkoutState({
    required this.routine,
    required this.exercises,
    required this.elapsedSeconds,
    required this.isRunning,
    required this.exerciseStates,
    this.restTimer,
  });

  int get totalSets =>
      exerciseStates.fold(0, (s, e) => s + e.targetSets);
  int get completedSets =>
      exerciseStates.fold(0, (s, e) => s + e.completedSets.length);
  double get totalVolume => exerciseStates.fold(
        0.0,
        (s, e) => s + e.completedSets.fold(0.0, (vs, set) => vs + set.volume),
      );

  Exercise? findExercise(String id) {
    try {
      return exercises.firstWhere((e) => e.id == id);
    } catch (_) {
      return null;
    }
  }

  ActiveWorkoutState copyWith({
    int? elapsedSeconds,
    bool? isRunning,
    List<ExerciseWorkoutState>? exerciseStates,
    RestTimerState? restTimer,
    bool clearRestTimer = false,
  }) {
    return ActiveWorkoutState(
      routine: routine,
      exercises: exercises,
      elapsedSeconds: elapsedSeconds ?? this.elapsedSeconds,
      isRunning: isRunning ?? this.isRunning,
      exerciseStates: exerciseStates ?? this.exerciseStates,
      restTimer: clearRestTimer ? null : (restTimer ?? this.restTimer),
    );
  }
}

class ActiveWorkoutNotifier extends StateNotifier<ActiveWorkoutState> {
  ActiveWorkoutNotifier(String routineId)
      : super(_buildInitial(routineId)) {
    _startSessionTimer();
  }

  Timer? _sessionTimer;
  Timer? _restTicker;

  static ActiveWorkoutState _buildInitial(String routineId) {
    final routine = SeedData.findRoutine(routineId) ??
        SeedData.routines.first;
    final exercises = SeedData.exercises;
    final prev = SeedData.previousPerformance;

    return ActiveWorkoutState(
      routine: routine,
      exercises: exercises,
      elapsedSeconds: 0,
      isRunning: true,
      exerciseStates: routine.exercises.asMap().entries.map((entry) {
        final i = entry.key;
        final re = entry.value;
        final prevSets = prev[re.exerciseId] ?? [];
        final firstPrev =
            prevSets.isNotEmpty ? prevSets.first : const WorkoutSet(kg: 0, reps: 8);
        return ExerciseWorkoutState(
          exerciseId: re.exerciseId,
          targetSets: re.targetSets,
          targetReps: re.targetReps,
          restSec: re.restSeconds,
          isExpanded: i == 0,
          currentInput: WorkoutSet(kg: firstPrev.kg, reps: firstPrev.reps),
        );
      }).toList(),
    );
  }

  void _startSessionTimer() {
    _sessionTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (state.isRunning) {
        state = state.copyWith(elapsedSeconds: state.elapsedSeconds + 1);
      }
    });
  }

  void togglePause() {
    state = state.copyWith(isRunning: !state.isRunning);
  }

  void toggleExpand(int index) {
    final list = [...state.exerciseStates];
    list[index] = list[index].copyWith(isExpanded: !list[index].isExpanded);
    state = state.copyWith(exerciseStates: list);
  }

  void finishSet(int index) {
    final list = [...state.exerciseStates];
    final e = list[index];
    if (e.currentInput == null) return;

    final newCompleted = [...e.completedSets, e.currentInput!];
    final isDone = newCompleted.length >= e.targetSets;
    final prev = SeedData.previousPerformance[e.exerciseId] ?? [];
    final nextIdx = newCompleted.length;
    final nextPrev = nextIdx < prev.length
        ? prev[nextIdx]
        : prev.isNotEmpty
            ? prev.last
            : const WorkoutSet(kg: 0, reps: 8);

    list[index] = e.copyWith(
      completedSets: newCompleted,
      currentInput: isDone ? null : WorkoutSet(kg: nextPrev.kg, reps: nextPrev.reps),
      clearCurrentInput: isDone,
    );

    final exerciseName =
        state.findExercise(e.exerciseId)?.name ?? 'Exercise';

    state = state.copyWith(
      exerciseStates: list,
      restTimer: RestTimerState(
        total: e.restSec,
        remaining: e.restSec,
        exerciseName: exerciseName,
      ),
    );

    _startRestTimer();
  }

  void _startRestTimer() {
    _restTicker?.cancel();
    _restTicker = Timer.periodic(const Duration(seconds: 1), (_) {
      final rt = state.restTimer;
      if (rt == null) {
        _restTicker?.cancel();
        return;
      }
      if (rt.remaining <= 0) {
        state = state.copyWith(clearRestTimer: true);
        _restTicker?.cancel();
        return;
      }
      state = state.copyWith(restTimer: rt.copyWith(remaining: rt.remaining - 1));
    });
  }

  void skipRest() {
    _restTicker?.cancel();
    state = state.copyWith(clearRestTimer: true);
  }

  void addRestTime(int seconds) {
    final rt = state.restTimer;
    if (rt == null) return;
    state = state.copyWith(
      restTimer: rt.copyWith(
        remaining: rt.remaining + seconds,
        total: rt.total + seconds,
      ),
    );
  }

  void updateWeight(int index, double kg) {
    final list = [...state.exerciseStates];
    final e = list[index];
    if (e.currentInput == null) return;
    list[index] = e.copyWith(currentInput: e.currentInput!.copyWith(kg: kg));
    state = state.copyWith(exerciseStates: list);
  }

  void updateReps(int index, int reps) {
    final list = [...state.exerciseStates];
    final e = list[index];
    if (e.currentInput == null) return;
    list[index] = e.copyWith(currentInput: e.currentInput!.copyWith(reps: reps));
    state = state.copyWith(exerciseStates: list);
  }

  @override
  void dispose() {
    _sessionTimer?.cancel();
    _restTicker?.cancel();
    super.dispose();
  }
}

final activeWorkoutProvider = StateNotifierProvider.autoDispose
    .family<ActiveWorkoutNotifier, ActiveWorkoutState, String>(
  (ref, routineId) => ActiveWorkoutNotifier(routineId),
);
