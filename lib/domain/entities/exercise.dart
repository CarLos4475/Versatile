class Exercise {
  final String id;
  final String name;
  final String muscle;
  final String equipment;
  final bool isCustom;
  final bool isUnilateral;

  const Exercise({
    required this.id,
    required this.name,
    required this.muscle,
    required this.equipment,
    this.isCustom = false,
    this.isUnilateral = false,
  });
}
