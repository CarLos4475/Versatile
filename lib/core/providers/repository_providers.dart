import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/exercise_repository.dart';
import '../../data/repositories/routine_repository.dart';
import '../../data/repositories/session_repository.dart';

final exerciseRepositoryProvider = Provider<ExerciseRepository>(
  (_) => ExerciseRepository(),
);

final routineRepositoryProvider = Provider<RoutineRepository>(
  (_) => RoutineRepository(),
);

final sessionRepositoryProvider = Provider<SessionRepository>(
  (_) => SessionRepository(),
);
