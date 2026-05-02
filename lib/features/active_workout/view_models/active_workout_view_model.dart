import 'dart:async';
import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../../core/providers/repository_providers.dart';
import '../../../core/services/workout_notification_service.dart';
import '../../../domain/entities/exercise.dart';
import '../../../domain/entities/routine.dart';
import '../../../domain/entities/session.dart';
import '../../../domain/entities/workout_set.dart';
import '../../home/view_models/home_view_model.dart';

class ExerciseWorkoutState {
  final String exerciseId;
  final int targetSets;
  final String targetReps;
  final int restSec;
  final bool isExpanded;
  final List<WorkoutSet> completedSets;
  final WorkoutSet? currentInput;
  final List<WorkoutSet> prevSets;
  final bool isUnilateral;
  final bool isSplitMode;

  const ExerciseWorkoutState({
    required this.exerciseId,
    required this.targetSets,
    required this.targetReps,
    required this.restSec,
    this.isExpanded = false,
    this.completedSets = const [],
    this.currentInput,
    this.prevSets = const [],
    this.isUnilateral = false,
    this.isSplitMode = false,
  });

  bool get isDone => completedSets.length >= targetSets;
  int get nextSetIndex => completedSets.length;

  ExerciseWorkoutState copyWith({
    bool? isExpanded,
    List<WorkoutSet>? completedSets,
    WorkoutSet? currentInput,
    bool clearCurrentInput = false,
    bool? isSplitMode,
  }) {
    return ExerciseWorkoutState(
      exerciseId: exerciseId,
      targetSets: targetSets,
      targetReps: targetReps,
      restSec: restSec,
      isExpanded: isExpanded ?? this.isExpanded,
      completedSets: completedSets ?? this.completedSets,
      currentInput: clearCurrentInput
          ? null
          : (currentInput ?? this.currentInput),
      prevSets: prevSets,
      isUnilateral: isUnilateral,
      isSplitMode: isSplitMode ?? this.isSplitMode,
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

  int get totalSets => exerciseStates.fold(0, (s, e) => s + e.targetSets);
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

class _WorkoutInit {
  final Routine routine;
  final List<Exercise> exercises;
  final Map<String, List<WorkoutSet>> previousPerformance;
  const _WorkoutInit({
    required this.routine,
    required this.exercises,
    required this.previousPerformance,
  });
}

final workoutInitProvider = FutureProvider.autoDispose
    .family<_WorkoutInit, String>((ref, routineId) async {
      final routineRepo = ref.read(routineRepositoryProvider);
      final exerciseRepo = ref.read(exerciseRepositoryProvider);
      final sessionRepo = ref.read(sessionRepositoryProvider);

      final routine = await routineRepo.findById(routineId);
      if (routine == null) throw Exception('Routine not found: $routineId');
      final exercises = await exerciseRepo.getAll();
      final prev = await sessionRepo.getPreviousPerformance(routineId);

      return _WorkoutInit(
        routine: routine,
        exercises: exercises,
        previousPerformance: prev,
      );
    });

class ActiveWorkoutNotifier extends StateNotifier<ActiveWorkoutState> {
  final Ref _ref;

  ActiveWorkoutNotifier(String routineId, this._ref)
    : super(_buildInitial(routineId, _ref)) {
    _startSessionTimer();
  }

  Timer? _sessionTimer;
  Timer? _restTicker;

  DateTime _workoutStartedAt = DateTime.now();
  DateTime _startedAt = DateTime.now();
  int _accumulatedSeconds = 0;
  DateTime? _restEndAt;

  DateTime get workoutStartedAt => _workoutStartedAt;

  void restoreStartTime(DateTime originalStartedAt) {
    _workoutStartedAt = originalStartedAt;
    _startedAt = originalStartedAt;
    _accumulatedSeconds = 0;
    final elapsed = DateTime.now().difference(originalStartedAt).inSeconds;
    state = state.copyWith(elapsedSeconds: elapsed.clamp(0, 86400));
  }

  void restoreProgress(String jsonStr) {
    try {
      final data = jsonDecode(jsonStr) as Map<String, dynamic>;
      final exData = data['exercises'] as List<dynamic>;
      if (exData.length != state.exerciseStates.length) return;

      final restored = state.exerciseStates.asMap().entries.map((entry) {
        final i = entry.key;
        final e = entry.value;
        final d = exData[i] as Map<String, dynamic>;

        final completedSets = (d['completedSets'] as List<dynamic>).map((s) {
          final m = s as Map<String, dynamic>;
          return WorkoutSet(
            kg: (m['kg'] as num).toDouble(),
            reps: (m['reps'] as num).toInt(),
            leftKg: m['leftKg'] != null ? (m['leftKg'] as num).toDouble() : null,
            leftReps: m['leftReps'] != null ? (m['leftReps'] as num).toInt() : null,
          );
        }).toList();

        final ck = d['currentKg'];
        final cr = d['currentReps'];
        final currentInput = (ck != null && cr != null && completedSets.length < e.targetSets)
            ? WorkoutSet(
                kg: (ck as num).toDouble(),
                reps: (cr as num).toInt(),
                leftKg: d['currentLeftKg'] != null ? (d['currentLeftKg'] as num).toDouble() : null,
                leftReps: d['currentLeftReps'] != null ? (d['currentLeftReps'] as num).toInt() : null,
              )
            : e.currentInput;

        return ExerciseWorkoutState(
          exerciseId: e.exerciseId,
          targetSets: e.targetSets,
          targetReps: e.targetReps,
          restSec: e.restSec,
          isExpanded: e.isExpanded,
          completedSets: completedSets,
          currentInput: completedSets.length >= e.targetSets ? null : currentInput,
          prevSets: e.prevSets,
          isUnilateral: e.isUnilateral,
          isSplitMode: d['isSplitMode'] as bool? ?? false,
        );
      }).toList();

      // Restore rest timer
      final restEndAtMs = data['restEndAtMs'];
      final restName = data['restExerciseName'] as String?;
      final restTotal = data['restTotal'];

      RestTimerState? restTimer;
      if (restEndAtMs != null && restName != null && restTotal != null) {
        _restEndAt = DateTime.fromMillisecondsSinceEpoch((restEndAtMs as num).toInt());
        final remaining = _restEndAt!.difference(DateTime.now()).inSeconds;
        if (remaining > 0) {
          restTimer = RestTimerState(
            total: (restTotal as num).toInt(),
            remaining: remaining,
            exerciseName: restName,
          );
        } else {
          _restEndAt = null;
        }
      }

      state = state.copyWith(
        exerciseStates: restored,
        restTimer: restTimer,
        clearRestTimer: restTimer == null,
      );

      if (restTimer != null) _resumeRestTimer();
    } catch (_) {}
  }

  void _saveProgress() {
    final exercises = state.exerciseStates.map((e) => {
      'completedSets': e.completedSets.map((s) => {
        'kg': s.kg,
        'reps': s.reps,
        'leftKg': s.leftKg,
        'leftReps': s.leftReps,
      }).toList(),
      'currentKg': e.currentInput?.kg,
      'currentReps': e.currentInput?.reps,
      'currentLeftKg': e.currentInput?.leftKg,
      'currentLeftReps': e.currentInput?.leftReps,
      'isSplitMode': e.isSplitMode,
    }).toList();

    final json = jsonEncode({
      'exercises': exercises,
      'restEndAtMs': _restEndAt?.millisecondsSinceEpoch,
      'restExerciseName': state.restTimer?.exerciseName,
      'restTotal': state.restTimer?.total,
    });
    WorkoutNotificationService.saveProgress(json);
  }

  static ActiveWorkoutState _buildInitial(String routineId, Ref ref) {
    final init = ref.read(workoutInitProvider(routineId)).requireValue;
    final prev = init.previousPerformance;

    return ActiveWorkoutState(
      routine: init.routine,
      exercises: init.exercises,
      elapsedSeconds: 0,
      isRunning: true,
      exerciseStates: init.routine.exercises.asMap().entries.map((entry) {
        final i = entry.key;
        final re = entry.value;
        final prevSets = prev[re.exerciseId] ?? [];
        final firstPrev = prevSets.isNotEmpty
            ? prevSets.first
            : const WorkoutSet(kg: 0, reps: 8);
        final isUnilateral = init.exercises.any(
          (e) => e.id == re.exerciseId && e.isUnilateral,
        );
        return ExerciseWorkoutState(
          exerciseId: re.exerciseId,
          targetSets: re.targetSets,
          targetReps: re.targetReps,
          restSec: re.restSeconds,
          isExpanded: i == 0,
          currentInput: WorkoutSet(kg: firstPrev.kg, reps: firstPrev.reps),
          prevSets: prevSets,
          isUnilateral: isUnilateral,
        );
      }).toList(),
    );
  }

  void _startSessionTimer() {
    _startedAt = DateTime.now();
    _sessionTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (state.isRunning) {
        final elapsed = _accumulatedSeconds +
            DateTime.now().difference(_startedAt).inSeconds;
        state = state.copyWith(elapsedSeconds: elapsed);
      }
    });
  }

  void togglePause() {
    if (state.isRunning) {
      _accumulatedSeconds +=
          DateTime.now().difference(_startedAt).inSeconds;
    } else {
      _startedAt = DateTime.now();
    }
    state = state.copyWith(isRunning: !state.isRunning);
  }

  void toggleExpand(int index) {
    final list = [...state.exerciseStates];
    list[index] = list[index].copyWith(isExpanded: !list[index].isExpanded);
    state = state.copyWith(exerciseStates: list);
  }

  void toggleSplitMode(int index) {
    final list = [...state.exerciseStates];
    final e = list[index];
    final newSplit = !e.isSplitMode;
    WorkoutSet? newInput = e.currentInput;
    if (newInput != null) {
      if (newSplit) {
        newInput = WorkoutSet(
          kg: newInput.kg,
          reps: newInput.reps,
          leftKg: newInput.kg,
          leftReps: newInput.reps,
        );
      } else {
        newInput = WorkoutSet(kg: newInput.kg, reps: newInput.reps);
      }
    }
    list[index] = ExerciseWorkoutState(
      exerciseId: e.exerciseId,
      targetSets: e.targetSets,
      targetReps: e.targetReps,
      restSec: e.restSec,
      isExpanded: e.isExpanded,
      completedSets: e.completedSets,
      currentInput: newInput,
      prevSets: e.prevSets,
      isUnilateral: e.isUnilateral,
      isSplitMode: newSplit,
    );
    state = state.copyWith(exerciseStates: list);
  }

  void finishSet(int index) {
    final list = [...state.exerciseStates];
    final e = list[index];
    if (e.currentInput == null) return;

    // Mirror right to left for unilateral in symmetric mode
    var setToSave = e.currentInput!;
    if (e.isUnilateral && !e.isSplitMode) {
      setToSave = setToSave.copyWith(
        leftKg: setToSave.kg,
        leftReps: setToSave.reps,
      );
    }

    final newCompleted = [...e.completedSets, setToSave];
    final isDone = newCompleted.length >= e.targetSets;
    final prev = e.prevSets;
    final nextIdx = newCompleted.length;
    final nextPrev = nextIdx < prev.length
        ? prev[nextIdx]
        : prev.isNotEmpty
        ? prev.last
        : const WorkoutSet(kg: 0, reps: 8);

    if (isDone) {
      list[index] = e.copyWith(
        completedSets: newCompleted,
        clearCurrentInput: true,
      );
    } else {
      list[index] = e.copyWith(
        completedSets: newCompleted,
        currentInput: WorkoutSet(
          kg: nextPrev.kg,
          reps: nextPrev.reps,
          leftKg: e.isSplitMode ? (nextPrev.leftKg ?? nextPrev.kg) : null,
          leftReps: e.isSplitMode ? (nextPrev.leftReps ?? nextPrev.reps) : null,
        ),
      );
    }

    final exerciseName = state.findExercise(e.exerciseId)?.name ?? 'Exercise';

    state = state.copyWith(
      exerciseStates: list,
      restTimer: RestTimerState(
        total: e.restSec,
        remaining: e.restSec,
        exerciseName: exerciseName,
      ),
    );
    _startRestTimer();
    _saveProgress();
  }

  void _startRestTimer() {
    _restTicker?.cancel();
    final rt = state.restTimer;
    if (rt == null) return;
    _restEndAt = DateTime.now().add(Duration(seconds: rt.total));
    _resumeRestTimer();
  }

  void _resumeRestTimer() {
    _restTicker?.cancel();
    _restTicker = Timer.periodic(const Duration(seconds: 1), (_) {
      final endAt = _restEndAt;
      final currentRt = state.restTimer;
      if (endAt == null || currentRt == null) {
        _restTicker?.cancel();
        return;
      }
      final remaining = endAt.difference(DateTime.now()).inSeconds;
      if (remaining <= 0) {
        state = state.copyWith(clearRestTimer: true);
        _restEndAt = null;
        _restTicker?.cancel();
        return;
      }
      state = state.copyWith(
        restTimer: currentRt.copyWith(remaining: remaining),
      );
    });
  }

  void skipRest() {
    _restTicker?.cancel();
    _restEndAt = null;
    state = state.copyWith(clearRestTimer: true);
    _saveProgress();
  }

  void addRestTime(int seconds) {
    final rt = state.restTimer;
    if (rt == null) return;
    _restEndAt = (_restEndAt ?? DateTime.now()).add(Duration(seconds: seconds));
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
    list[index] = e.copyWith(
      currentInput: e.currentInput!.copyWith(reps: reps),
    );
    state = state.copyWith(exerciseStates: list);
  }

  void updateLeftWeight(int index, double kg) {
    final list = [...state.exerciseStates];
    final e = list[index];
    if (e.currentInput == null) return;
    list[index] = e.copyWith(
      currentInput: e.currentInput!.copyWith(leftKg: kg),
    );
    state = state.copyWith(exerciseStates: list);
  }

  void updateLeftReps(int index, int reps) {
    final list = [...state.exerciseStates];
    final e = list[index];
    if (e.currentInput == null) return;
    list[index] = e.copyWith(
      currentInput: e.currentInput!.copyWith(leftReps: reps),
    );
    state = state.copyWith(exerciseStates: list);
  }

  Future<void> finishWorkout() async {
    _sessionTimer?.cancel();
    _restTicker?.cancel();

    final exerciseStates = state.exerciseStates
        .where((e) => e.completedSets.isNotEmpty)
        .toList();
    if (exerciseStates.isEmpty) return;

    final sessionExercises = exerciseStates.map((e) {
      final ex = state.findExercise(e.exerciseId);
      return SessionExercise(
        exerciseId: e.exerciseId,
        name: ex?.name ?? '',
        sets: e.completedSets,
      );
    }).toList();

    final totalVolume = sessionExercises.fold(0.0, (s, e) => s + e.volume);

    final session = Session(
      id: const Uuid().v4(),
      routineId: state.routine.id,
      routineName: state.routine.name,
      colorValue: state.routine.colorValue,
      date: _todayString(),
      durationMin: (state.elapsedSeconds / 60).ceil(),
      volumeKg: totalVolume,
      exercises: sessionExercises,
    );

    await _ref.read(sessionRepositoryProvider).insert(session);
    await _ref.read(workoutLogRepositoryProvider).logDay(_todayString());
    _ref.invalidate(sessionsAsyncProvider);
  }

  String _todayString() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    _sessionTimer?.cancel();
    _restTicker?.cancel();
    super.dispose();
  }
}

final activeWorkoutRoutineIdProvider = StateProvider<String?>((ref) => null);

final activeWorkoutProvider = StateNotifierProvider.autoDispose
    .family<ActiveWorkoutNotifier, ActiveWorkoutState, String>(
      (ref, routineId) => ActiveWorkoutNotifier(routineId, ref),
    );
