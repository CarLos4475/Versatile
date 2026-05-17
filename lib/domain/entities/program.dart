enum SlotKind { routine, label }

class ProgramSlot {
  final String id;
  final String programId;
  final int weekIndex;
  final int weekday;
  final SlotKind kind;
  final String? routineId;
  final String? labelText;

  const ProgramSlot({
    required this.id,
    required this.programId,
    required this.weekIndex,
    required this.weekday,
    required this.kind,
    this.routineId,
    this.labelText,
  });

  ProgramSlot copyWith({
    SlotKind? kind,
    String? routineId,
    String? labelText,
    bool clearRoutine = false,
    bool clearLabel = false,
  }) {
    return ProgramSlot(
      id: id,
      programId: programId,
      weekIndex: weekIndex,
      weekday: weekday,
      kind: kind ?? this.kind,
      routineId: clearRoutine ? null : (routineId ?? this.routineId),
      labelText: clearLabel ? null : (labelText ?? this.labelText),
    );
  }
}

class Program {
  final String id;
  final String name;
  final int colorValue;
  final int iconCode;
  final int weeksCount;
  final Set<int> deloadWeeks;
  final DateTime createdAt;
  final List<ProgramSlot> slots;

  const Program({
    required this.id,
    required this.name,
    required this.colorValue,
    this.iconCode = 58713,
    required this.weeksCount,
    this.deloadWeeks = const {},
    required this.createdAt,
    this.slots = const [],
  });

  Program copyWith({
    String? name,
    int? colorValue,
    int? iconCode,
    int? weeksCount,
    Set<int>? deloadWeeks,
    List<ProgramSlot>? slots,
  }) {
    return Program(
      id: id,
      name: name ?? this.name,
      colorValue: colorValue ?? this.colorValue,
      iconCode: iconCode ?? this.iconCode,
      weeksCount: weeksCount ?? this.weeksCount,
      deloadWeeks: deloadWeeks ?? this.deloadWeeks,
      createdAt: createdAt,
      slots: slots ?? this.slots,
    );
  }

  ProgramSlot? slotAt(int weekIndex, int weekday) {
    for (final s in slots) {
      if (s.weekIndex == weekIndex && s.weekday == weekday) return s;
    }
    return null;
  }
}
