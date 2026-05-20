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
  String get notificationSubtitle => 'Mantén el ritmo. Toca para volver';

  @override
  String get accentColor => 'Color de acento';

  @override
  String get colorEmber => 'Brasa';

  @override
  String get colorPink => 'Rosado';

  @override
  String get colorWine => 'Vino';

  @override
  String get colorBrick => 'Ladrillo';

  @override
  String get colorCamel => 'Camello';

  @override
  String get colorOlive => 'Oliva';

  @override
  String get colorSlate => 'Pizarra';

  @override
  String get colorPlum => 'Ciruela';

  @override
  String get profileSessionsLabel => 'sesiones';

  @override
  String get profileTimeLabel => 'tiempo';

  @override
  String get profilePrsLabel => 'PRs';

  @override
  String get planActiveSection => 'Plan activo';

  @override
  String get noActivePlanTitle => 'Sin plan activo';

  @override
  String get noActivePlanSubtitle => 'Elige un programa para empezar';

  @override
  String programWeekProgress(int current, int total) {
    return 'Semana $current de $total';
  }

  @override
  String get programDeloadNone => 'sin deload';

  @override
  String programDeloadCount(int n) {
    return '$n deload';
  }

  @override
  String get activeBadge => 'ACTIVO';

  @override
  String get aboutBy => 'por';

  @override
  String get thisWeekSection => 'Esta semana';

  @override
  String get yourProgramsSection => 'Tus programas';

  @override
  String programsTotalCount(int n) {
    return '$n totales';
  }

  @override
  String get splashEyebrow => 'Tu gym tracker';

  @override
  String get splashTaglinePrefix => 'Pesa lo que';

  @override
  String get splashTaglineAccent => 'levantas.';

  @override
  String get splashLoading => 'Cargando';

  @override
  String get todayYouTrain => 'Hoy te toca';

  @override
  String get todayYouRest => 'Hoy te toca';

  @override
  String get todayRestWord => 'descansar';

  @override
  String get todayLabelPrefix => 'Hoy te toca';

  @override
  String get templateBannerTitle => 'Las etiquetas son temporales';

  @override
  String get templateBannerBody =>
      'Toca cualquier día para cambiar la etiqueta por una de tus rutinas. Crea las rutinas primero si todavía no las tienes.';

  @override
  String get newProgramTitle => 'Nuevo programa';

  @override
  String get newProgramSubtitle => 'Configura tu plan en 4 pasos';

  @override
  String get stepName => 'Nombre';

  @override
  String get stepColor => 'Color';

  @override
  String get stepWeeks => 'Semanas';

  @override
  String get stepCalendar => 'Calendario';

  @override
  String get weeksUnit => 'semanas';

  @override
  String get weeksUnitOne => 'semana';

  @override
  String get deloadShort => 'DELOAD';

  @override
  String get calendarHint =>
      'Toca cualquier día para asignar rutina, descanso o etiqueta.';

  @override
  String editDayEyebrow(int week, String day) {
    return 'Semana $week · $day';
  }

  @override
  String whatTodayQuestion(String day) {
    return '¿Qué toca el $day?';
  }

  @override
  String get restDayCta => 'Día de descanso';

  @override
  String get restDayCtaSubtitle => 'Recupera para el siguiente';

  @override
  String get orPickRoutine => 'O asigna una rutina';

  @override
  String get orUseLabel => 'O usa una etiqueta';

  @override
  String get saveSelection => 'Guardar selección';

  @override
  String get labelYoga => 'Yoga';

  @override
  String get customLabelChip => 'Personalizado…';

  @override
  String routineExerciseCount(int n) {
    return '$n ejercicios';
  }

  @override
  String get designYourWeek => 'Diseña tu semana ideal';

  @override
  String get designYourWeekBody =>
      'Asigna una rutina a cada día — y descansos donde toque. La app te dirá qué hacer hoy.';

  @override
  String get createFromScratch => 'Crear desde cero';

  @override
  String get orStartFromTemplate => 'O empieza con una plantilla';

  @override
  String get recommendedBadge => 'RECOMENDADO';

  @override
  String get templateUpperLowerName => 'Upper / Lower';

  @override
  String get templateUpperLowerSub => '4 días · descansos lógicos';

  @override
  String get templatePplName => 'Push · Pull · Legs';

  @override
  String get templatePplSub => '6 días · clásico';

  @override
  String get templateFullBodyName => 'Full Body 3×';

  @override
  String get templateFullBodySub => '3 días · principiantes';

  @override
  String get colorPreviewHint => 'así se verá en la lista';

  @override
  String get progressTitle => 'Progreso';

  @override
  String get estimatedOneRm => '1RM Est.';

  @override
  String get noProgressYet =>
      'Sin datos aún. Completa un entrenamiento con este ejercicio para ver tu progreso.';

  @override
  String get seeProgress => 'Ver progreso';

  @override
  String get best_label => 'MEJOR';

  @override
  String get oneRmDescription =>
      'Mejor estimación de peso máximo para 1 repetición por sesión';

  @override
  String get volumeDescription =>
      'Total de kg × repeticiones en todas las series por sesión';

  @override
  String get coachmarkHomeTitle => 'Tu próximo entrenamiento';

  @override
  String get coachmarkHomeBody =>
      'Esta tarjeta sugiere la rutina que deberías entrenar hoy. Toca Iniciar para comenzar.';

  @override
  String get coachmarkRoutinesTitle => 'Crea tus rutinas';

  @override
  String get coachmarkRoutinesBody =>
      'Toca + para crear un entrenamiento con tus ejercicios, series y tiempos de descanso.';

  @override
  String get coachmarkExercisesTitle => 'Sigue tu progreso';

  @override
  String get coachmarkExercisesBody =>
      'Toca cualquier ejercicio para ver tu gráfica de progreso y récords personales.';

  @override
  String get coachmarkGotIt => 'Entendido';

  @override
  String get coachmarkSkipAll => 'Omitir';

  @override
  String get coachmarkTabRoutinesTitle => 'Crea rutinas';

  @override
  String get coachmarkTabRoutinesBody =>
      'Toca aquí para crear y gestionar tus rutinas de entrenamiento.';

  @override
  String get coachmarkTabExercisesTitle => 'Tus ejercicios';

  @override
  String get coachmarkTabExercisesBody =>
      'Explora la biblioteca de ejercicios y toca cualquiera para ver tu progreso.';

  @override
  String get coachmarkTabHistoryTitle => 'Historial y gráficas';

  @override
  String get coachmarkTabHistoryBody =>
      'Aquí están tus sesiones pasadas y las gráficas de progreso de cada ejercicio. Toca para explorar.';

  @override
  String get coachmarkRoutineEditTitle => 'Edita tu rutina';

  @override
  String get coachmarkRoutineEditBody =>
      'Toca Editar para reordenar ejercicios, ajustar series y descanso, o renombrar esta rutina.';

  @override
  String get coachmarkExerciseAddTitle => 'Añade ejercicios propios';

  @override
  String get coachmarkExerciseAddBody =>
      'Toca + para crear tus propios ejercicios con nombre, grupo muscular y tipo de equipo.';

  @override
  String get coachmarkSettingsColorsTitle => 'Personalízalo a tu gusto';

  @override
  String get coachmarkSettingsColorsBody =>
      'Elige un color de acento y cambia entre temas claro y oscuro para personalizar la app.';

  @override
  String get coachmarkSettingsSoundTitle => 'Sonido del temporizador';

  @override
  String get coachmarkSettingsSoundBody =>
      'Activa una alerta cuando termine tu descanso. Usa el tono predeterminado o elige tu propio audio.';

  @override
  String get coachmarkSettingsDataTitle => 'Respalda tus datos';

  @override
  String get coachmarkSettingsDataBody =>
      'Exporta tus rutinas e historial como JSON para hacer un respaldo o transferirlos a otro dispositivo.';

  @override
  String get onboardingSkip => 'Omitir';

  @override
  String get onboardingContinue => 'Continuar';

  @override
  String get onboardingWhatsYourName => '¿Cómo te llamas?';

  @override
  String get onboardingPage1Title => 'Tu gym,\nen bruto.';

  @override
  String get onboardingPage1Body =>
      'Registro rápido, privado y hecho para ti. Sin cuentas. Sin nube. Solo tus pesas.';

  @override
  String get onboardingPage2Title => 'Pesa lo que\nlevantas.';

  @override
  String get onboardingPage2Body =>
      'Cada serie, cada repetición. Mira tu 1RM estimado subir semana a semana.';

  @override
  String get onboardingPage3Title => 'La semana,\na tu medida.';

  @override
  String get onboardingPage3Body =>
      'Crea rutinas, ordena ejercicios y deja descansos donde toque.';

  @override
  String get onboardingPage4Title => 'Tu data,\nse queda aquí.';

  @override
  String get onboardingPage4Body =>
      'Sin internet. Sin cuenta. Sin nube. Todo se queda en tu teléfono.';

  @override
  String get onboardingNameTitle => 'Hola,\n¿Cómo te llamas?';

  @override
  String get onboardingNameSubtitle => 'Opcional. Siempre puedes omitirlo.';

  @override
  String get onboardingNameHint => 'Tu nombre…';

  @override
  String get onboardingLetsGo => '¡Vamos!';

  @override
  String get obCtaStart => 'Empezar';

  @override
  String get obCtaAlmostReady => 'Casi listo';

  @override
  String get obTagWeights => 'Pesos & PRs';

  @override
  String get obTagRoutines => 'Rutinas';

  @override
  String get obTagLocal => '100% local';

  @override
  String get obB2DeltaNote => 'en 11 sem.';

  @override
  String get obB4Banner => 'Sin internet · Sin cuenta · Sin nube';

  @override
  String get obB5Body =>
      'Opcional. Puedes saltarlo o cambiarlo cuando quieras.';

  @override
  String get obB5Footnote => 'Se guarda solo en este dispositivo';

  @override
  String get obB1Eyebrow => 'Versatile · Bienvenido';

  @override
  String get obB2Eyebrow => 'Registra · Récord';

  @override
  String get obB3Eyebrow => 'Rutinas · Tu plan';

  @override
  String get obB4Eyebrow => 'Privado · 100% local';

  @override
  String get obB5Eyebrow => 'Lo último · ¿Quién entrena?';

  @override
  String get obB4ItemAccounts => 'Cuentas y suscripciones';

  @override
  String get obB4ItemCloud => 'Sincronización a la nube';

  @override
  String get obB4ItemAds => 'Anuncios y rastreo';

  @override
  String get obB4ItemLocal => 'Todo en tu teléfono';

  @override
  String get obB5NameLabel => 'Tu nombre';

  @override
  String get obB5SavedLocally => 'Se guarda solo en este dispositivo';

  @override
  String get coachmarkHistoryFirstCardTitle => 'Toca para ver los detalles';

  @override
  String get coachmarkHistoryFirstCardBody =>
      'Aquí encontrarás cada serie y repetición que registraste. Tu historial siempre a un toque.';

  @override
  String get coachmarkSessionChartTitle => 'Sigue tu progreso';

  @override
  String get coachmarkSessionChartBody =>
      'Toca este botón para ver una gráfica de tu 1RM estimado y volumen total a lo largo del tiempo.';

  @override
  String get coachmarkRestTimerTitle => 'Temporizador de descanso';

  @override
  String get coachmarkRestTimerBody =>
      'Cuenta regresiva entre series. Toca +15s para agregar tiempo o Saltar para continuar antes.';

  @override
  String get coachmarkProgressToggleTitle => 'Cambia la métrica';

  @override
  String get coachmarkProgressToggleBody =>
      'Alterna entre 1RM estimado y volumen total para ver tu progreso desde dos ángulos distintos.';

  @override
  String get trainingPlan => 'Plan de entrenamiento';

  @override
  String get trainingPlanSubtitle => 'Asigna rutinas por día de la semana';

  @override
  String get programsSubtitle =>
      'Arma un plan multisemana con días de descanso';

  @override
  String get createProgram => 'Crear programa';

  @override
  String get editProgram => 'Editar programa';

  @override
  String get noProgramsYet => 'Aún no hay programas';

  @override
  String get programsEmptyBody =>
      'Crea un plan semanal que asigne una rutina, o un día de descanso, a cada día de la semana.';

  @override
  String get deleteProgramTitle => '¿Eliminar programa?';

  @override
  String deleteProgramContent(String name) {
    return 'Se eliminará permanentemente \'$name\'. Tus rutinas e historial no se tocan.';
  }

  @override
  String get activateProgram => 'Activar';

  @override
  String get deactivateProgram => 'Desactivar';

  @override
  String programWeeksSummary(int weeks, int deload) {
    String _temp0 = intl.Intl.pluralLogic(
      weeks,
      locale: localeName,
      other: 'semanas',
      one: 'semana',
    );
    return '$weeks $_temp0 · $deload deload';
  }

  @override
  String get pickStartDate => 'Elige fecha de inicio';

  @override
  String get programName => 'Nombre';

  @override
  String get programNameHint => 'p. ej. Push/Pull/Legs de 4 semanas';

  @override
  String get weeksLabel => 'Semanas';

  @override
  String weeksCountValue(int weeks) {
    String _temp0 = intl.Intl.pluralLogic(
      weeks,
      locale: localeName,
      other: 'semanas',
      one: 'semana',
    );
    return '$weeks $_temp0';
  }

  @override
  String get scheduleLabel => 'Calendario';

  @override
  String get deloadWeekLabel => 'Descarga';

  @override
  String weekN(int n) {
    return 'Semana $n';
  }

  @override
  String get tapToAssign => 'Toca para asignar';

  @override
  String get routineRemoved => 'Rutina eliminada';

  @override
  String get save => 'Guardar';

  @override
  String get labelRest => 'Descanso';

  @override
  String get labelCardio => 'Cardio';

  @override
  String get labelMobility => 'Movilidad';

  @override
  String get labelStretch => 'Estiramiento';

  @override
  String editDayTitle(String day) {
    return 'Editar $day';
  }

  @override
  String get clear => 'Vaciar';

  @override
  String get pickRoutineSection => 'Elige una rutina';

  @override
  String get pickLabelSection => 'O usa una etiqueta';

  @override
  String get customLabelSection => 'Personalizado';

  @override
  String get customLabelHint => 'Escribe tu propia etiqueta…';

  @override
  String get applyCustomLabel => 'Usar etiqueta personalizada';

  @override
  String get weekdayMon => 'Lunes';

  @override
  String get weekdayTue => 'Martes';

  @override
  String get weekdayWed => 'Miércoles';

  @override
  String get weekdayThu => 'Jueves';

  @override
  String get weekdayFri => 'Viernes';

  @override
  String get weekdaySat => 'Sábado';

  @override
  String get weekdaySun => 'Domingo';

  @override
  String get weekdayMonShort => 'LUN';

  @override
  String get weekdayTueShort => 'MAR';

  @override
  String get weekdayWedShort => 'MIÉ';

  @override
  String get weekdayThuShort => 'JUE';

  @override
  String get weekdayFriShort => 'VIE';

  @override
  String get weekdaySatShort => 'SÁB';

  @override
  String get weekdaySunShort => 'DOM';

  @override
  String get plannedBadge => 'PLANEADO';

  @override
  String get plannedDeloadBadge => 'DESCARGA';

  @override
  String get todayLabel => 'HOY';

  @override
  String get restDayDescription => 'El día de hoy según tu programa activo.';

  @override
  String get programsHelpTooltip => 'Cómo funcionan los planes';

  @override
  String get programsHelpTitle => 'Cómo funcionan los planes';

  @override
  String get programsHelpIntroTitle => '¿Qué es un plan de entrenamiento?';

  @override
  String get programsHelpIntroBody =>
      'Un calendario de varias semanas que asigna una rutina o un día de descanso a cada día. Útil para periodizar tipo Push/Pull/Legs o splits de 5 días.';

  @override
  String get programsHelpSlotsTitle => 'Los días son slots';

  @override
  String get programsHelpSlotsBody =>
      'Cada día puede ser una rutina (tu entrenamiento), un día de descanso, o una etiqueta personalizada como Cardio, Movilidad, o lo que quieras.';

  @override
  String get programsHelpDeloadTitle => 'Semanas de descarga';

  @override
  String get programsHelpDeloadBody =>
      'Marca una semana completa como deload (intensidad menor) para recuperación. La home mostrará el badge DESCARGA para recordarte bajar el ritmo.';

  @override
  String get programsHelpActivateTitle => 'Activar un plan';

  @override
  String get programsHelpActivateBody =>
      'Elige una fecha de inicio, normalmente un lunes. Cuando la última semana termina, el plan vuelve automáticamente a la semana 1.';

  @override
  String get programsHelpBadgesTitle => 'Qué verás en la Home';

  @override
  String get programsHelpBadgesBody =>
      'Cuando el día de hoy tiene una rutina planeada, la tarjeta de inicio muestra el badge PLANEADO. Las semanas de descarga muestran DESCARGA. La tarjeta sigue funcionando igual. Toca Start para comenzar.';

  @override
  String get programsHelpOptionalTitle => '100% opcional';

  @override
  String get programsHelpOptionalBody =>
      'Si ignoras los planes, la app funciona exactamente igual que antes. Los planes son un extra que puedes activar o desactivar en cualquier momento sin perder rutinas ni historial.';

  @override
  String get close => 'Cerrar';

  @override
  String get recapTitle => 'Tu mes entrenando';

  @override
  String get recapIntroSubtitle => 'Un vistazo a lo que entrenaste.';

  @override
  String get recapSessionsTitle => 'Entrenaste';

  @override
  String recapSessionsBody(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '# entrenamientos',
      one: '# entrenamiento',
    );
    return '$_temp0';
  }

  @override
  String get recapVolumeTitle => 'Levantaste';

  @override
  String recapVolumeDeltaUp(int pct, String month) {
    return '$pct% más que en $month';
  }

  @override
  String recapVolumeDeltaDown(int pct, String month) {
    return '$pct% menos que en $month';
  }

  @override
  String recapVolumeDeltaSame(String month) {
    return 'Más o menos igual que en $month';
  }

  @override
  String get recapTopRoutineTitle => 'Tu favorita';

  @override
  String recapTopRoutineBody(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '# sesiones',
      one: '# sesión',
    );
    return '$_temp0';
  }

  @override
  String get recapTopExerciseTitle => 'La estrella del mes';

  @override
  String recapTopExerciseBody(int sets, String volume) {
    String _temp0 = intl.Intl.pluralLogic(
      sets,
      locale: localeName,
      other: '# sets',
      one: '# set',
    );
    return '$_temp0 · $volume';
  }

  @override
  String get recapPRTitle => '¡Nuevo récord!';

  @override
  String recapPRBody(String exercise) {
    return 'en $exercise';
  }

  @override
  String get recapOutroTitle => 'Nos vemos el próximo mes';

  @override
  String get recapOutroBody => 'Sigue entrenando.';

  @override
  String get recapBalanceTitle => 'Balance de movimiento';

  @override
  String get recapBalanceBody => 'Cómo repartiste el trabajo este mes.';

  @override
  String get deloadBannerTitle => '¿Toca semana de descarga?';

  @override
  String get deloadBannerBodyStagnation =>
      'Varios ejercicios no han progresado en 3+ semanas.';

  @override
  String get deloadBannerBodyVolume =>
      'Tu volumen semanal ha bajado últimamente.';

  @override
  String get deloadBannerBodyBoth =>
      'El progreso está parado y el volumen bajó. Una semana ligera puede ayudar.';

  @override
  String get deloadBannerCta => 'Abrir programa';

  @override
  String get deloadBannerDismiss => 'Ahora no';

  @override
  String get categoryAll => 'Todos';

  @override
  String get categoryPush => 'Push';

  @override
  String get categoryPull => 'Pull';

  @override
  String get categoryLegs => 'Piernas';

  @override
  String get categoryOther => 'Otros';

  @override
  String recapEntryCardTitle(String month) {
    return 'Resumen de $month';
  }

  @override
  String recapEntryCardSubtitle(int count, String volume) {
    return '$count sesiones · $volume';
  }

  @override
  String get recapPastRecaps => 'Resúmenes anteriores';

  @override
  String get recapPastRecapsEmpty => 'Aún no hay resúmenes pasados';

  @override
  String get recapPastRecapsSubtitle => 'Revisa cualquier mes cerrado';

  @override
  String get recapBannerCta => 'Ver';

  @override
  String get recapHeadline => 'Resumen';

  @override
  String get recapCoverSubtitle => 'Tu mes de entrenamiento, en números.';

  @override
  String get recapTapToBegin => 'TOCA PARA COMENZAR';

  @override
  String get recapSessionsEyebrow => 'Entrenaste';

  @override
  String get recapSessionsLabel => 'veces este mes';

  @override
  String recapSessionsDelta(int delta, String month) {
    return '$delta más que $month';
  }

  @override
  String recapSessionsAvg(String perWeek) {
    return 'Un promedio de $perWeek por semana.';
  }

  @override
  String get recapVolumeEyebrow => 'Levantaste';

  @override
  String get recapVolumeLabel => 'en peso total';

  @override
  String recapVolumeDeltaPct(int pct, String month) {
    return '$pct% vs $month';
  }

  @override
  String recapWeekLabel(int n) {
    return 'Sem $n';
  }

  @override
  String get recapCalendarEyebrow => 'Entrenaste';

  @override
  String get recapCalendarLabel => 'días del mes.';

  @override
  String recapBestWeek(int n) {
    return 'Mejor semana: $n sesiones';
  }

  @override
  String get recapTopLiftEyebrow => 'Mejor ejercicio';

  @override
  String recapTopLiftDelta(String kg) {
    return '+$kg kg este mes';
  }

  @override
  String get recapWeeklyBestLabel => 'MEJOR SEMANAL · ÚLTIMAS 7 SEMANAS';

  @override
  String get recapMuscleBalanceEyebrow => 'Trabajaste más';

  @override
  String recapMuscleTopBody(int pct) {
    return 'el $pct% de tu esfuerzo total';
  }

  @override
  String recapOutroEyebrow(String month) {
    return '$month · en resumen';
  }

  @override
  String get recapOutroHeadline => 'Sigue entrenando.';

  @override
  String recapOutroFooter(String month) {
    return '$month apenas empieza. Nos vemos en el gym.';
  }

  @override
  String get recapOutroCta => 'Volver a entrenar';

  @override
  String get recapStatSessions => 'sesiones';

  @override
  String get recapStatHours => 'horas';

  @override
  String get recapStatNewPRs => 'Récords nuevos';

  @override
  String recapHomeBannerEyebrow(String month) {
    return 'Tu resumen de $month está listo';
  }

  @override
  String recapHomeBannerTitle(int sessions, String volume) {
    return '$sessions sesiones · $volume levantados';
  }

  @override
  String get share => 'Compartir';

  @override
  String get shareWorkout => 'Compartir entrenamiento';

  @override
  String get sharePreviewSubtitle =>
      'Una tarjeta cuadrada para publicar donde quieras';

  @override
  String get recordLabel => 'Récord';

  @override
  String get averageLabel => 'Promedio';

  @override
  String get sessionsLabel => 'Sesiones';

  @override
  String get progressionLabel => 'Progresión';

  @override
  String get viewAll => 'Ver todas';

  @override
  String get formulaEpley => 'Fórmula Epley';

  @override
  String get vsPrevious => 'vs anterior';
}
