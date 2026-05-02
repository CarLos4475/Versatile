import 'package:flutter/widgets.dart';
import '../../domain/entities/exercise.dart';
import '../../l10n/app_localizations.dart';

extension ExerciseL10n on Exercise {
  String getLocalizedName(BuildContext context) {
    return getLocalizedNameNonContext(Localizations.localeOf(context).languageCode);
  }

  String getLocalizedNameNonContext(String locale) {
    if (!isCustom) {
      if (locale == 'es') {
        switch (id) {
          case 'ex-1': return 'Press de banca';
          case 'ex-2': return 'Press inclinado con mancuernas';
          case 'ex-3': return 'Cruces en polea';
          case 'ex-4': return 'Dominadas';
          case 'ex-5': return 'Remo con barra';
          case 'ex-6': return 'Jalón al pecho';
          case 'ex-7': return 'Sentadilla';
          case 'ex-8': return 'Peso muerto rumano';
          case 'ex-9': return 'Prensa de piernas';
          case 'ex-10': return 'Press militar';
          case 'ex-11': return 'Elevaciones laterales';
          case 'ex-12': return 'Face pull';
          case 'ex-13': return 'Curl de bíceps';
          case 'ex-14': return 'Extensión de tríceps en polea';
          case 'ex-15': return 'Curl martillo';
          case 'ex-16': return 'Plancha';
          case 'ex-17': return 'Elevación de piernas colgado';
          case 'c1': return 'Press Landmine';
          case 'c2': return 'Remo Pendlay';
        }
      }
    }
    return name;
  }

  String getLocalizedMuscle(BuildContext context) {
    return getLocalizedMuscleNonContext(Localizations.localeOf(context).languageCode);
  }

  String getLocalizedMuscleNonContext(String locale) {
    if (locale == 'es') {
      switch (muscle) {
        case 'Chest': return 'Pecho';
        case 'Back': return 'Espalda';
        case 'Shoulders': return 'Hombros';
        case 'Biceps': return 'Bíceps';
        case 'Triceps': return 'Tríceps';
        case 'Forearms': return 'Antebrazos';
        case 'Quadriceps': return 'Cuádriceps';
        case 'Hamstrings': return 'Isquiotibiales';
        case 'Glutes': return 'Glúteos';
        case 'Calves': return 'Gemelos';
        case 'Core': return 'Core';
        case 'Arms': return 'Brazos';
        case 'Legs': return 'Piernas';
        case 'Other': return 'Otros';
        case 'All': return 'Todo';
      }
    }
    return muscle;
  }

  String getLocalizedEquipment(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    switch (equipment) {
      case 'Barbell': return l10n.equip_barbell;
      case 'Dumbbell': return l10n.equip_dumbbell;
      case 'Cable': return l10n.equip_cable;
      case 'Bodyweight': return l10n.equip_bodyweight;
      case 'Machine': return l10n.equip_machine;
    }
    return equipment;
  }
}
