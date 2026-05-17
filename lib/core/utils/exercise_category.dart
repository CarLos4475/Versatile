/// Movement-pattern category derived from an exercise's `muscle` field.
/// Lets us filter exercises by push/pull/legs without persisting any new
/// data — every category is a pure mapping over existing muscle strings.
enum ExerciseCategory { push, pull, legs, other }

/// Maps a muscle string (as stored in `Exercise.muscle`) to its movement
/// category. Unrecognised muscles fall through to [ExerciseCategory.other].
///
/// Conventions (matches the seeded muscle set in the catalogue):
/// - **push**: Chest, Shoulders, Triceps
/// - **pull**: Back, Biceps
/// - **legs**: Quadriceps, Hamstrings, Glutes, Calves
/// - **other**: Core, Forearms, Arms (compound label), Legs (compound label),
///   any custom or unknown muscle.
ExerciseCategory categoryForMuscle(String muscle) {
  switch (muscle) {
    case 'Chest':
    case 'Shoulders':
    case 'Triceps':
      return ExerciseCategory.push;
    case 'Back':
    case 'Biceps':
      return ExerciseCategory.pull;
    case 'Quadriceps':
    case 'Hamstrings':
    case 'Glutes':
    case 'Calves':
      return ExerciseCategory.legs;
    default:
      return ExerciseCategory.other;
  }
}
