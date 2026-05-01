import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/exercise_repository.dart';
import '../../data/repositories/routine_repository.dart';
import '../../data/repositories/session_repository.dart';
import '../../data/repositories/settings_repository.dart';
import '../../data/repositories/workout_log_repository.dart';

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

final userNameProvider = FutureProvider<String>((ref) async {
  return ref.read(settingsRepositoryProvider).getUserName();
});
