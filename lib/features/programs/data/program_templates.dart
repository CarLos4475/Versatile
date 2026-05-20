import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';

class TemplatePattern {
  final int weekday;
  final bool isRest;
  final String? labelKey; // resolved to actual label via l10n at apply time
  const TemplatePattern.rest(this.weekday) : isRest = true, labelKey = null;
  const TemplatePattern.routine(this.weekday, this.labelKey) : isRest = false;
}

class ProgramTemplate {
  final String id;
  final String nameKey;
  final String subKey;
  final Color color;
  final bool recommended;
  final int weeksCount;
  final Set<int> deloadWeeks;
  final List<TemplatePattern> pattern;

  const ProgramTemplate({
    required this.id,
    required this.nameKey,
    required this.subKey,
    required this.color,
    required this.recommended,
    required this.weeksCount,
    required this.deloadWeeks,
    required this.pattern,
  });

  String name(AppLocalizations l10n) {
    switch (id) {
      case 'upper_lower':
        return l10n.templateUpperLowerName;
      case 'ppl':
        return l10n.templatePplName;
      case 'full_body_3':
        return l10n.templateFullBodyName;
      default:
        return id;
    }
  }

  String sub(AppLocalizations l10n) {
    switch (id) {
      case 'upper_lower':
        return l10n.templateUpperLowerSub;
      case 'ppl':
        return l10n.templatePplSub;
      case 'full_body_3':
        return l10n.templateFullBodySub;
      default:
        return '';
    }
  }
}

const kProgramTemplates = <ProgramTemplate>[
  ProgramTemplate(
    id: 'upper_lower',
    nameKey: 'templateUpperLowerName',
    subKey: 'templateUpperLowerSub',
    color: Color(0xFFD97757),
    recommended: true,
    weeksCount: 4,
    deloadWeeks: {3},
    pattern: [
      TemplatePattern.routine(1, 'Upper'),
      TemplatePattern.rest(2),
      TemplatePattern.routine(3, 'Lower'),
      TemplatePattern.rest(4),
      TemplatePattern.routine(5, 'Upper'),
      TemplatePattern.routine(6, 'Lower'),
      TemplatePattern.rest(7),
    ],
  ),
  ProgramTemplate(
    id: 'ppl',
    nameKey: 'templatePplName',
    subKey: 'templatePplSub',
    color: Color(0xFFCC5C2E),
    recommended: false,
    weeksCount: 6,
    deloadWeeks: {5},
    pattern: [
      TemplatePattern.routine(1, 'Push'),
      TemplatePattern.routine(2, 'Pull'),
      TemplatePattern.routine(3, 'Legs'),
      TemplatePattern.rest(4),
      TemplatePattern.routine(5, 'Push'),
      TemplatePattern.routine(6, 'Pull'),
      TemplatePattern.routine(7, 'Legs'),
    ],
  ),
  ProgramTemplate(
    id: 'full_body_3',
    nameKey: 'templateFullBodyName',
    subKey: 'templateFullBodySub',
    color: Color(0xFFE0A24E),
    recommended: false,
    weeksCount: 4,
    deloadWeeks: {},
    pattern: [
      TemplatePattern.routine(1, 'Full Body'),
      TemplatePattern.rest(2),
      TemplatePattern.routine(3, 'Full Body'),
      TemplatePattern.rest(4),
      TemplatePattern.routine(5, 'Full Body'),
      TemplatePattern.rest(6),
      TemplatePattern.rest(7),
    ],
  ),
];

/// Program color palette. Matches AccentColors palette so accent and program
/// pickers share the same visual vocabulary.
const kProgramColors = <Color>[
  Color(0xFFD97757), // Ember
  Color(0xFFCC5C2E), // Rust
  Color(0xFFE8825A), // Coral
  Color(0xFFB85432), // Brick
  Color(0xFF9E7B4E), // Camel
  Color(0xFF7A8C5B), // Olive
  Color(0xFF5B7A8C), // Slate
  Color(0xFF8C5B6E), // Plum
];
