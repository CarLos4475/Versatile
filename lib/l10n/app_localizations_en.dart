// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'Versatile';

  @override
  String get settings => 'Settings';

  @override
  String get appearance => 'APPEARANCE';

  @override
  String get theme => 'Theme';

  @override
  String get themeLight => 'Light';

  @override
  String get themeDark => 'Dark';

  @override
  String get themeSystem => 'System';

  @override
  String get language => 'Language';

  @override
  String get languageEn => 'English';

  @override
  String get languageEs => 'Spanish';

  @override
  String get profile => 'PROFILE';

  @override
  String get userName => 'User name';

  @override
  String get changeName => 'Change name';

  @override
  String get data => 'DATA';

  @override
  String get exportData => 'Export data';

  @override
  String get importData => 'Import data';

  @override
  String get wipeAllData => 'Wipe all data';

  @override
  String get wipeConfirmTitle => 'Wipe all data?';

  @override
  String get wipeConfirmContent =>
      'This will permanently delete all your routines, history, and custom exercises. This cannot be undone.';

  @override
  String get cancel => 'Cancel';

  @override
  String get wipe => 'Wipe';

  @override
  String get dataWiped => 'All data wiped';

  @override
  String wipeFailed(String error) {
    return 'Wipe failed: $error';
  }

  @override
  String get home => 'Home';

  @override
  String get routines => 'Routines';

  @override
  String get exercises => 'Exercises';

  @override
  String get history => 'History';

  @override
  String get hello => 'Hello';

  @override
  String get helloThere => 'Hello there';

  @override
  String get today => 'Today';

  @override
  String get todaysSession => 'TODAY\'S SESSION';

  @override
  String get startWorkout => 'Start workout';

  @override
  String get thisWeek => 'THIS WEEK';

  @override
  String get sessions => 'sessions';

  @override
  String get volume => 'VOLUME';

  @override
  String get avgTime => 'AVG TIME';

  @override
  String get activity => 'ACTIVITY';

  @override
  String get sessionsLastYear => 'sessions in the last year';

  @override
  String get less => 'Less';

  @override
  String get more => 'More';

  @override
  String get recentSessions => 'Recent sessions';

  @override
  String get total => 'total';

  @override
  String get noRoutinesYet => 'No routines yet';

  @override
  String get createFirstOne => 'Create your first one';

  @override
  String get createRoutine => 'Create routine';

  @override
  String get workoutInProgress => 'Workout in progress';

  @override
  String get restoredProgress => 'Restored progress from your active workout.';

  @override
  String routinesInLibrary(int count) {
    return '$count routines in your library';
  }

  @override
  String get exercisesLabel => 'exercises';

  @override
  String get noRoutinesMatch => 'No routines match';

  @override
  String get edit => 'Edit';

  @override
  String get done => 'Done';

  @override
  String get addExercise => 'Add exercise';

  @override
  String get deleteRoutineTitle => 'Delete routine?';

  @override
  String deleteRoutineContent(String name) {
    return 'This will permanently delete the routine \'$name\'.';
  }

  @override
  String get delete => 'Delete';

  @override
  String get startThisWorkout => 'Start this workout';

  @override
  String get rest => 'rest';

  @override
  String get active => 'ACTIVE';

  @override
  String get sets => 'sets';

  @override
  String get finishWorkout => 'Finish workout';

  @override
  String get saving => 'Saving…';

  @override
  String get preparingWorkout => 'Preparing workout...';

  @override
  String get workoutFinished => 'Workout finished!';

  @override
  String get greatJob => 'Great job! Your session has been saved.';

  @override
  String get finish => 'Finish';

  @override
  String get discardWorkoutTitle => 'Discard workout?';

  @override
  String get discardWorkoutContent =>
      'This will delete all progress from this session.';

  @override
  String get discard => 'Discard';

  @override
  String finishSet(int number) {
    return 'Finish set $number';
  }

  @override
  String get addExerciseTitle => 'Add Exercise';

  @override
  String inLibrary(int count) {
    return '$count in library';
  }

  @override
  String get newExercise => 'New Exercise';

  @override
  String get addCustomExercise => 'Add a custom exercise';

  @override
  String get exerciseName => 'Exercise name';

  @override
  String get egBenchPress => 'e.g. Bench Press';

  @override
  String get muscleGroup => 'MUSCLE GROUP';

  @override
  String get category => 'CATEGORY';

  @override
  String get bilateral => 'Bilateral';

  @override
  String get unilateral => 'Unilateral';

  @override
  String get saveExercise => 'Save exercise';

  @override
  String get search => 'Search…';

  @override
  String get noExercisesMatch => 'No exercises match';

  @override
  String get custom => 'CUSTOM';

  @override
  String get all => 'All';

  @override
  String get noHistoryYet => 'No history yet';

  @override
  String get startTrainingToSee => 'Start training to see your progress here';

  @override
  String get sessionDetail => 'Session Detail';

  @override
  String get workoutSummary => 'Workout Summary';

  @override
  String get duration => 'Duration';

  @override
  String get volumeTotal => 'Total Volume';

  @override
  String get exercisesPerformed => 'Exercises Performed';

  @override
  String get neverDone => 'Never done';

  @override
  String get doneToday => 'Done today';

  @override
  String get doneYesterday => 'Done yesterday';

  @override
  String lastDoneDaysAgo(int days) {
    return 'Last done $days days ago';
  }

  @override
  String get set_label => 'SET';

  @override
  String get weight_label => 'WEIGHT';

  @override
  String get reps_label => 'REPS';

  @override
  String get last_label => 'Last';

  @override
  String get split_label => 'Split';

  @override
  String get skip => 'Skip';

  @override
  String get about => 'ABOUT';

  @override
  String get version => 'Version';

  @override
  String get author => 'Author';

  @override
  String get noRecordYet => 'No record yet';

  @override
  String get newRoutine => 'New Routine';

  @override
  String get nameItAndPickColor => 'Name it and pick a color';

  @override
  String get color_label => 'COLOR';

  @override
  String get icon_label => 'ICON';

  @override
  String get createRoutineBtn => 'Create Routine';

  @override
  String get exportSubtitle => 'Share a JSON backup of all your data';

  @override
  String get importSubtitle => 'Restore from a JSON backup';

  @override
  String get wipeSubtitle => 'Delete all routines, sessions and history';

  @override
  String get routineNotFound => 'Routine not found';

  @override
  String get goBack => 'Go back';

  @override
  String get ex_bench_press => 'Bench Press';

  @override
  String get ex_incline_dumbbell_press => 'Incline Dumbbell Press';

  @override
  String get ex_cable_fly => 'Cable Fly';

  @override
  String get ex_pull_up => 'Pull-Up';

  @override
  String get ex_barbell_row => 'Barbell Row';

  @override
  String get ex_lat_pulldown => 'Lat Pulldown';

  @override
  String get ex_squat => 'Squat';

  @override
  String get ex_romanian_deadlift => 'Romanian Deadlift';

  @override
  String get ex_leg_press => 'Leg Press';

  @override
  String get ex_overhead_press => 'Overhead Press';

  @override
  String get ex_lateral_raise => 'Lateral Raise';

  @override
  String get ex_face_pull => 'Face Pull';

  @override
  String get ex_bicep_curl => 'Bicep Curl';

  @override
  String get ex_tricep_pushdown => 'Tricep Pushdown';

  @override
  String get ex_hammer_curl => 'Hammer Curl';

  @override
  String get ex_plank => 'Plank';

  @override
  String get ex_hanging_leg_raise => 'Hanging Leg Raise';

  @override
  String get ex_landmine_press => 'Landmine Press';

  @override
  String get ex_pendlay_row => 'Pendlay Row';

  @override
  String get muscle_chest => 'Chest';

  @override
  String get muscle_back => 'Back';

  @override
  String get muscle_shoulders => 'Shoulders';

  @override
  String get muscle_biceps => 'Biceps';

  @override
  String get muscle_triceps => 'Triceps';

  @override
  String get muscle_forearms => 'Forearms';

  @override
  String get muscle_quadriceps => 'Quadriceps';

  @override
  String get muscle_hamstrings => 'Hamstrings';

  @override
  String get muscle_glutes => 'Glutes';

  @override
  String get muscle_calves => 'Calves';

  @override
  String get muscle_core => 'Core';

  @override
  String get muscle_other => 'Other';

  @override
  String get muscle_arms => 'Arms';

  @override
  String get muscle_legs => 'Legs';

  @override
  String get equip_barbell => 'Barbell';

  @override
  String get equip_dumbbell => 'Dumbbell';

  @override
  String get equip_cable => 'Cable';

  @override
  String get equip_bodyweight => 'Bodyweight';

  @override
  String get equip_machine => 'Machine';

  @override
  String get deleteExerciseTitle => 'Delete exercise?';

  @override
  String deleteExerciseContent(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'exercises',
      one: 'exercise',
    );
    return 'This will permanently delete $count custom $_temp0. This cannot be undone.';
  }

  @override
  String get unilateral_label => 'UNILATERAL';
}
