// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appName => 'Versatile';

  @override
  String get settings => 'Ajustes';

  @override
  String get appearance => 'APARIENCIA';

  @override
  String get theme => 'Tema';

  @override
  String get themeLight => 'Claro';

  @override
  String get themeDark => 'Oscuro';

  @override
  String get themeSystem => 'Sistema';

  @override
  String get language => 'Idioma';

  @override
  String get languageEn => 'Inglés';

  @override
  String get languageEs => 'Español';

  @override
  String get profile => 'PERFIL';

  @override
  String get userName => 'Nombre de usuario';

  @override
  String get changeName => 'Cambiar nombre';

  @override
  String get data => 'DATOS';

  @override
  String get exportData => 'Exportar datos';

  @override
  String get importData => 'Importar datos';

  @override
  String get wipeAllData => 'Borrar todos los datos';

  @override
  String get wipeConfirmTitle => '¿Borrar todos los datos?';

  @override
  String get wipeConfirmContent =>
      'Esto eliminará permanentemente todas tus rutinas, historial y ejercicios personalizados. Esto no se puede deshacer.';

  @override
  String get cancel => 'Cancelar';

  @override
  String get wipe => 'Borrar';

  @override
  String get dataWiped => 'Todos los datos borrados';

  @override
  String wipeFailed(String error) {
    return 'Error al borrar: $error';
  }

  @override
  String get home => 'Inicio';

  @override
  String get routines => 'Rutinas';

  @override
  String get exercises => 'Ejercicios';

  @override
  String get history => 'Historial';

  @override
  String get hello => 'Hola';

  @override
  String get helloThere => 'Hola';

  @override
  String get today => 'Hoy';

  @override
  String get todaysSession => 'SESIÓN DE HOY';

  @override
  String get startWorkout => 'Iniciar entrenamiento';

  @override
  String get thisWeek => 'ESTA SEMANA';

  @override
  String get sessions => 'sesiones';

  @override
  String get volume => 'VOLUMEN';

  @override
  String get avgTime => 'TIEMPO PROM.';

  @override
  String get activity => 'ACTIVIDAD';

  @override
  String get sessionsLastYear => 'sesiones en el último año';

  @override
  String get less => 'Menos';

  @override
  String get more => 'Más';

  @override
  String get recentSessions => 'Sesiones recientes';

  @override
  String get total => 'total';

  @override
  String get noRoutinesYet => 'Sin rutinas aún';

  @override
  String get createFirstOne => 'Crea tu primera rutina';

  @override
  String get createRoutine => 'Crear rutina';

  @override
  String get workoutInProgress => 'Entrenamiento en curso';

  @override
  String get restoredProgress =>
      'Progreso restaurado de tu entrenamiento activo.';

  @override
  String routinesInLibrary(int count) {
    return '$count rutinas en tu biblioteca';
  }

  @override
  String get exercisesLabel => 'ejercicios';

  @override
  String get noRoutinesMatch => 'Sin coincidencias';

  @override
  String get edit => 'Editar';

  @override
  String get done => 'Hecho';

  @override
  String get addExercise => 'Añadir ejercicio';

  @override
  String get deleteRoutineTitle => '¿Borrar rutina?';

  @override
  String deleteRoutineContent(String name) {
    return 'Esto eliminará permanentemente la rutina \'$name\'.';
  }

  @override
  String get delete => 'Borrar';

  @override
  String get startThisWorkout => 'Iniciar este entrenamiento';

  @override
  String get rest => 'descanso';

  @override
  String get active => 'ACTIVO';

  @override
  String get sets => 'series';

  @override
  String get finishWorkout => 'Finalizar entrenamiento';

  @override
  String get saving => 'Guardando…';

  @override
  String get preparingWorkout => 'Preparando entrenamiento...';

  @override
  String get workoutFinished => '¡Entrenamiento finalizado!';

  @override
  String get greatJob => '¡Buen trabajo! Tu sesión ha sido guardada.';

  @override
  String get finish => 'Finalizar';

  @override
  String get discardWorkoutTitle => '¿Descartar entrenamiento?';

  @override
  String get discardWorkoutContent =>
      'Esto eliminará todo el progreso de esta sesión.';

  @override
  String get discard => 'Descartar';

  @override
  String finishSet(int number) {
    return 'Finalizar serie $number';
  }

  @override
  String get addExerciseTitle => 'Añadir ejercicio';

  @override
  String inLibrary(int count) {
    return '$count en la biblioteca';
  }

  @override
  String get newExercise => 'Nuevo ejercicio';

  @override
  String get addCustomExercise => 'Añadir un ejercicio personalizado';

  @override
  String get exerciseName => 'Nombre del ejercicio';

  @override
  String get egBenchPress => 'ej. Press de banca';

  @override
  String get muscleGroup => 'GRUPO MUSCULAR';

  @override
  String get category => 'CATEGORÍA';

  @override
  String get bilateral => 'Bilateral';

  @override
  String get unilateral => 'Unilateral';

  @override
  String get saveExercise => 'Guardar ejercicio';

  @override
  String get search => 'Buscar…';

  @override
  String get noExercisesMatch => 'Sin coincidencias';

  @override
  String get custom => 'PERSONALIZADO';

  @override
  String get all => 'Todo';

  @override
  String get noHistoryYet => 'Sin historial aún';

  @override
  String get startTrainingToSee => 'Entrena para ver tu progreso aquí';

  @override
  String get sessionDetail => 'Detalle de Sesión';

  @override
  String get workoutSummary => 'Resumen de Entrenamiento';

  @override
  String get duration => 'Duración';

  @override
  String get volumeTotal => 'Volumen Total';

  @override
  String get exercisesPerformed => 'Ejercicios Realizados';

  @override
  String get neverDone => 'Nunca';

  @override
  String get doneToday => 'Hecho hoy';

  @override
  String get doneYesterday => 'Hecho ayer';

  @override
  String lastDoneDaysAgo(int days) {
    return 'Hace $days días';
  }

  @override
  String get set_label => 'SERIE';

  @override
  String get weight_label => 'PESO';

  @override
  String get reps_label => 'REPS';

  @override
  String get last_label => 'Ant.';

  @override
  String get split_label => 'Dividir';

  @override
  String get skip => 'Saltar';

  @override
  String get skipped => 'Saltado';

  @override
  String get skipExercise => 'Saltar ejercicio';

  @override
  String get skipExerciseContent =>
      '¿Saltar este ejercicio? Sus series se rellenarán con los datos de tu última sesión.';

  @override
  String get about => 'ACERCA DE';

  @override
  String get version => 'Versión';

  @override
  String get author => 'Autor';

  @override
  String get noRecordYet => 'Sin récord aún';

  @override
  String get newRoutine => 'Nueva Rutina';

  @override
  String get nameItAndPickColor => 'Dale un nombre y elige un color';

  @override
  String get name_label => 'NOMBRE';

  @override
  String get color_label => 'COLOR';

  @override
  String get icon_label => 'ICONO';

  @override
  String get createRoutineBtn => 'Crear rutina';

  @override
  String get exportSubtitle => 'Comparte un respaldo JSON de todos tus datos';

  @override
  String get importSubtitle => 'Restaura desde un respaldo JSON';

  @override
  String get wipeSubtitle => 'Elimina todas tus rutinas, sesiones e historial';

  @override
  String get routineNotFound => 'Rutina no encontrada';

  @override
  String get goBack => 'Volver';

  @override
  String get ex_bench_press => 'Press de banca';

  @override
  String get ex_incline_dumbbell_press => 'Press inclinado con mancuernas';

  @override
  String get ex_cable_fly => 'Cruces en polea';

  @override
  String get ex_pull_up => 'Dominadas';

  @override
  String get ex_barbell_row => 'Remo con barra';

  @override
  String get ex_lat_pulldown => 'Jalón al pecho';

  @override
  String get ex_squat => 'Sentadilla';

  @override
  String get ex_romanian_deadlift => 'Peso muerto rumano';

  @override
  String get ex_leg_press => 'Prensa de piernas';

  @override
  String get ex_overhead_press => 'Press militar';

  @override
  String get ex_lateral_raise => 'Elevaciones laterales';

  @override
  String get ex_face_pull => 'Face pull';

  @override
  String get ex_bicep_curl => 'Curl de bíceps';

  @override
  String get ex_tricep_pushdown => 'Extensión de tríceps en polea';

  @override
  String get ex_hammer_curl => 'Curl martillo';

  @override
  String get ex_plank => 'Plancha';

  @override
  String get ex_hanging_leg_raise => 'Elevación de piernas colgado';

  @override
  String get ex_landmine_press => 'Press Landmine';

  @override
  String get ex_pendlay_row => 'Remo Pendlay';

  @override
  String get muscle_chest => 'Pecho';

  @override
  String get muscle_back => 'Espalda';

  @override
  String get muscle_shoulders => 'Hombros';

  @override
  String get muscle_biceps => 'Bíceps';

  @override
  String get muscle_triceps => 'Tríceps';

  @override
  String get muscle_forearms => 'Antebrazos';

  @override
  String get muscle_quadriceps => 'Cuádriceps';

  @override
  String get muscle_hamstrings => 'Isquiotibiales';

  @override
  String get muscle_glutes => 'Glúteos';

  @override
  String get muscle_calves => 'Gemelos';

  @override
  String get muscle_core => 'Core';

  @override
  String get muscle_other => 'Otros';

  @override
  String get muscle_arms => 'Brazos';

  @override
  String get muscle_legs => 'Piernas';

  @override
  String get equip_barbell => 'Barra';

  @override
  String get equip_dumbbell => 'Mancuerna';

  @override
  String get equip_cable => 'Polea';

  @override
  String get equip_bodyweight => 'Peso corporal';

  @override
  String get equip_machine => 'Máquina';

  @override
  String get deleteExerciseTitle => '¿Eliminar ejercicio?';

  @override
  String deleteExerciseContent(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'ejercicios personalizados',
      one: 'ejercicio personalizado',
    );
    return 'Esto eliminará permanentemente $count $_temp0. Esta acción no se puede deshacer.';
  }

  @override
  String get unilateral_label => 'UNILATERAL';

  @override
  String get configureExercise => 'Configurar ejercicio';

  @override
  String get apply => 'Aplicar';

  @override
  String get setsLabel => 'Series';

  @override
  String get repsRangeLabel => 'Reps';

  @override
  String get restSecondsLabel => 'Descanso (s)';

  @override
  String get sound => 'SONIDO';

  @override
  String get restTimerAlert => 'Alerta de descanso';

  @override
  String get defaultSound => 'Por defecto';

  @override
  String get customSound => 'Personalizado';

  @override
  String get pickSoundFile => 'Elegir archivo';

  @override
  String get noSoundSelected => 'Sin sonido seleccionado';

  @override
  String get sessionComplete => '¡Sesión completa!';

  @override
  String get congratulations => '¡Felicidades!';

  @override
  String get backToHome => 'Volver al inicio';

  @override
  String get notificationSubtitle => 'Mantén el ritmo — toca para volver';

  @override
  String get accentColor => 'Color de acento';

  @override
  String get colorOrange => 'Naranja';

  @override
  String get colorBlue => 'Azul';

  @override
  String get colorGreen => 'Verde';

  @override
  String get colorPurple => 'Púrpura';

  @override
  String get colorRed => 'Rojo';

  @override
  String get colorTeal => 'Turquesa';

  @override
  String get colorPink => 'Rosa';

  @override
  String get colorAmber => 'Ámbar';
}
