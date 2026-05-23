import '../../domain/entities/workout_set.dart';

class OverloadSuggestion {
  final double suggestedKg;
  final double previousKg;
  final double increment;

  const OverloadSuggestion({
    required this.suggestedKg,
    required this.previousKg,
    required this.increment,
  });
}

OverloadSuggestion? computeOverloadSuggestion({
  required List<WorkoutSet> prevSets,
  required String muscle,
  required String equipment,
  required bool isSplitMode,
  required double currentInputKg,
}) {
  if (equipment == 'Bodyweight' || muscle == 'Core') return null;
  if (prevSets.isEmpty) return null;

  final modeWeight = _modeWeight(prevSets.map((s) => s.kg));
  if (modeWeight == null || modeWeight <= 0) return null;

  final setsAtMode = prevSets.where((s) => s.kg == modeWeight).toList();
  final qualifying = setsAtMode.where((s) => s.reps >= 13).length;
  if (qualifying < (setsAtMode.length / 2).ceil()) return null;

  if (isSplitMode) {
    final leftWeights = prevSets
        .where((s) => s.leftKg != null && s.leftKg! > 0)
        .map((s) => s.leftKg!);
    if (leftWeights.isEmpty) return null;
    final leftMode = _modeWeight(leftWeights);
    if (leftMode == null) return null;
    final leftAtMode = prevSets.where((s) => s.leftKg == leftMode).toList();
    final leftQ =
        leftAtMode.where((s) => (s.leftReps ?? 0) >= 13).length;
    if (leftQ < (leftAtMode.length / 2).ceil()) return null;
  }

  final increment = _incrementFor(muscle, equipment);
  final suggested = modeWeight + increment;

  if (currentInputKg > modeWeight) return null;

  return OverloadSuggestion(
    suggestedKg: suggested,
    previousKg: modeWeight,
    increment: increment,
  );
}

double? _modeWeight(Iterable<double> weights) {
  final counts = <double, int>{};
  for (final w in weights) {
    if (w > 0) counts[w] = (counts[w] ?? 0) + 1;
  }
  if (counts.isEmpty) return null;
  return counts.entries.reduce((a, b) => a.value >= b.value ? a : b).key;
}

double _incrementFor(String muscle, String equipment) {
  if (const {'Quadriceps', 'Hamstrings', 'Glutes', 'Legs'}.contains(muscle)) {
    return switch (equipment) {
      'Dumbbell' => 4,
      _ => 5,
    };
  }

  if (muscle == 'Back' || muscle == 'Chest') {
    return switch (equipment) {
      'Dumbbell' => 2,
      _ => 5,
    };
  }

  if (const {'Calves', 'Abductors', 'Adductors'}.contains(muscle)) {
    return 5;
  }

  // Shoulders, Biceps, Triceps, Forearms, Arms (compound fallback)
  return switch (equipment) {
    'Dumbbell' => 2,
    _ => 2.5,
  };
}
