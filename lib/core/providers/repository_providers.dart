import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/exercise_repository.dart';
import '../../data/repositories/program_repository.dart';
import '../../data/repositories/routine_repository.dart';
import '../../data/repositories/session_repository.dart';
import '../../data/repositories/settings_repository.dart';
import '../../data/repositories/workout_log_repository.dart';
import '../../domain/entities/exercise_progress.dart';
import '../services/coachmark_service.dart';

final exerciseRepositoryProvider = Provider<ExerciseRepository>(
  (_) => ExerciseRepository(),
);

final routineRepositoryProvider = Provider<RoutineRepository>(
  (_) => RoutineRepository(),
);

final sessionRepositoryProvider = Provider<SessionRepository>(
  (_) => SessionRepository(),
);

final settingsRepositoryProvider = Provider<SettingsRepository>(
  (_) => SettingsRepository(),
);

final workoutLogRepositoryProvider = Provider<WorkoutLogRepository>(
  (_) => WorkoutLogRepository(),
);

final programRepositoryProvider = Provider<ProgramRepository>(
  (_) => ProgramRepository(),
);

final userNameProvider = FutureProvider<String>((ref) async {
  return ref.read(settingsRepositoryProvider).getUserName();
});

final exerciseProgressProvider = FutureProvider.autoDispose
    .family<List<ExerciseProgressPoint>, String>(
      (ref, exerciseId) =>
          ref.read(sessionRepositoryProvider).getExerciseProgress(exerciseId),
    );

final coachmarkServiceProvider = Provider<CoachmarkService>(
  (ref) => CoachmarkService(ref.read(settingsRepositoryProvider)),
);

final historyNavKeyProvider = StateProvider<GlobalKey?>((ref) => null);
final routinesNavKeyProvider = StateProvider<GlobalKey?>((ref) => null);
final routinesAddKeyProvider = StateProvider<GlobalKey?>((ref) => null);
final exercisesNavKeyProvider = StateProvider<GlobalKey?>((ref) => null);
final exercisesSearchKeyProvider = StateProvider<GlobalKey?>((ref) => null);
final exercisesAddKeyProvider = StateProvider<GlobalKey?>((ref) => null);
final historyFirstCardKeyProvider = StateProvider<GlobalKey?>((ref) => null);
