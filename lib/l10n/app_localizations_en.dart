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
  String get skipped => 'Skipped';

  @override
  String get skipExercise => 'Skip exercise';

  @override
  String get skipExerciseContent =>
      'Skip this exercise? Its sets will be filled from your last session.';

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
  String get name_label => 'NAME';

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

  @override
  String get configureExercise => 'Configure Exercise';

  @override
  String get apply => 'Apply';

  @override
  String get setsLabel => 'Sets';

  @override
  String get repsRangeLabel => 'Reps';

  @override
  String get restSecondsLabel => 'Rest (s)';

  @override
  String get sound => 'SOUND';

  @override
  String get restTimerAlert => 'Rest timer alert';

  @override
  String get defaultSound => 'Default';

  @override
  String get customSound => 'Custom';

  @override
  String get pickSoundFile => 'Pick sound file';

  @override
  String get noSoundSelected => 'No sound selected';

  @override
  String get sessionComplete => 'Session complete!';

  @override
  String get congratulations => 'Congratulations!';

  @override
  String get backToHome => 'Back to home';

  @override
  String get notificationSubtitle => 'Stay focused. Tap to return';

  @override
  String get accentColor => 'Accent color';

  @override
  String get colorEmber => 'Ember';

  @override
  String get colorPink => 'Pink';

  @override
  String get colorWine => 'Wine';

  @override
  String get colorBrick => 'Brick';

  @override
  String get colorCamel => 'Camel';

  @override
  String get colorOlive => 'Olive';

  @override
  String get colorSlate => 'Slate';

  @override
  String get colorPlum => 'Plum';

  @override
  String get profileSessionsLabel => 'sessions';

  @override
  String get profileTimeLabel => 'time';

  @override
  String get profilePrsLabel => 'PRs';

  @override
  String get planActiveSection => 'Active plan';

  @override
  String get noActivePlanTitle => 'No active plan';

  @override
  String get noActivePlanSubtitle => 'Pick a program to get started';

  @override
  String programWeekProgress(int current, int total) {
    return 'Week $current of $total';
  }

  @override
  String get programDeloadNone => 'no deload';

  @override
  String programDeloadCount(int n) {
    return '$n deload';
  }

  @override
  String get activeBadge => 'ACTIVE';

  @override
  String get aboutBy => 'by';

  @override
  String get thisWeekSection => 'This week';

  @override
  String get yourProgramsSection => 'Your programs';

  @override
  String programsTotalCount(int n) {
    return '$n total';
  }

  @override
  String get splashEyebrow => 'Your gym tracker';

  @override
  String get splashTaglinePrefix => 'Lift what';

  @override
  String get splashTaglineAccent => 'you log.';

  @override
  String get splashLoading => 'Loading';

  @override
  String get todayYouTrain => 'Today you train';

  @override
  String get todayYouRest => 'Today you';

  @override
  String get todayRestWord => 'rest';

  @override
  String get todayLabelPrefix => 'Today:';

  @override
  String get templateBannerTitle => 'Labels are placeholders';

  @override
  String get templateBannerBody =>
      'Tap any day to swap a label for one of your routines. Create the routines first if you don\'t have them yet.';

  @override
  String get newProgramTitle => 'New program';

  @override
  String get newProgramSubtitle => 'Configure your plan in 4 steps';

  @override
  String get stepName => 'Name';

  @override
  String get stepColor => 'Color';

  @override
  String get stepWeeks => 'Weeks';

  @override
  String get stepCalendar => 'Calendar';

  @override
  String get weeksUnit => 'weeks';

  @override
  String get weeksUnitOne => 'week';

  @override
  String get deloadShort => 'DELOAD';

  @override
  String get calendarHint => 'Tap any day to assign a routine, rest, or label.';

  @override
  String editDayEyebrow(int week, String day) {
    return 'Week $week · $day';
  }

  @override
  String whatTodayQuestion(String day) {
    return 'What\'s on for $day?';
  }

  @override
  String get restDayCta => 'Rest day';

  @override
  String get restDayCtaSubtitle => 'Recover for the next one';

  @override
  String get orPickRoutine => 'Or pick a routine';

  @override
  String get orUseLabel => 'Or use a label';

  @override
  String get saveSelection => 'Save selection';

  @override
  String get labelYoga => 'Yoga';

  @override
  String get customLabelChip => 'Custom…';

  @override
  String routineExerciseCount(int n) {
    return '$n exercises';
  }

  @override
  String get designYourWeek => 'Design your ideal week';

  @override
  String get designYourWeekBody =>
      'Assign a routine to each day — and rest where it fits. The app will tell you what to do today.';

  @override
  String get createFromScratch => 'Create from scratch';

  @override
  String get orStartFromTemplate => 'Or start with a template';

  @override
  String get recommendedBadge => 'RECOMMENDED';

  @override
  String get templateUpperLowerName => 'Upper / Lower';

  @override
  String get templateUpperLowerSub => '4 days · sensible rest';

  @override
  String get templatePplName => 'Push · Pull · Legs';

  @override
  String get templatePplSub => '6 days · classic';

  @override
  String get templateFullBodyName => 'Full Body 3×';

  @override
  String get templateFullBodySub => '3 days · beginners';

  @override
  String get colorPreviewHint => 'this is how it\'ll look in the list';

  @override
  String get progressTitle => 'Progress';

  @override
  String get estimatedOneRm => 'Est. 1RM';

  @override
  String get noProgressYet =>
      'No data yet. Complete a workout with this exercise to track your progress.';

  @override
  String get seeProgress => 'See progress';

  @override
  String get best_label => 'BEST';

  @override
  String get oneRmDescription =>
      'Best estimated max single-rep weight per session';

  @override
  String get volumeDescription => 'Total kg × reps across all sets per session';

  @override
  String get coachmarkHomeTitle => 'Your next workout';

  @override
  String get coachmarkHomeBody =>
      'This card suggests the routine you should train today. Tap Start to begin.';

  @override
  String get coachmarkRoutinesTitle => 'Create your routines';

  @override
  String get coachmarkRoutinesBody =>
      'Tap + to build a custom workout with your exercises, sets, and rest times.';

  @override
  String get coachmarkExercisesTitle => 'Track your progress';

  @override
  String get coachmarkExercisesBody =>
      'Tap any exercise to view your progress chart and personal records.';

  @override
  String get coachmarkGotIt => 'Got it';

  @override
  String get coachmarkSkipAll => 'Skip all';

  @override
  String get coachmarkTabRoutinesTitle => 'Create routines';

  @override
  String get coachmarkTabRoutinesBody =>
      'Tap here to build and manage your workout routines.';

  @override
  String get coachmarkTabExercisesTitle => 'Your exercises';

  @override
  String get coachmarkTabExercisesBody =>
      'Browse the exercise library and tap any exercise to track your progress.';

  @override
  String get coachmarkTabHistoryTitle => 'History & progress';

  @override
  String get coachmarkTabHistoryBody =>
      'Your past sessions and progress graphs for every exercise live here. Tap to explore.';

  @override
  String get coachmarkRoutineEditTitle => 'Edit your routine';

  @override
  String get coachmarkRoutineEditBody =>
      'Tap Edit to reorder exercises, adjust sets and rest time, or rename this routine.';

  @override
  String get coachmarkExerciseAddTitle => 'Add custom exercises';

  @override
  String get coachmarkExerciseAddBody =>
      'Tap + to create your own exercises with a name, muscle group, and equipment type.';

  @override
  String get coachmarkSettingsColorsTitle => 'Make it yours';

  @override
  String get coachmarkSettingsColorsBody =>
      'Choose an accent color and switch between light and dark themes to personalize the app.';

  @override
  String get coachmarkSettingsSoundTitle => 'Rest timer sound';

  @override
  String get coachmarkSettingsSoundBody =>
      'Enable an alert when your rest period ends. Use the default tone or pick a custom audio file.';

  @override
  String get coachmarkSettingsDataTitle => 'Back up your data';

  @override
  String get coachmarkSettingsDataBody =>
      'Export your routines and history as a JSON file to keep a backup or move to another device.';

  @override
  String get onboardingSkip => 'Skip';

  @override
  String get onboardingContinue => 'Continue';

  @override
  String get onboardingWhatsYourName => 'What\'s your name?';

  @override
  String get onboardingPage1Title => 'Your gym,\nunfiltered.';

  @override
  String get onboardingPage1Body =>
      'Fast, private tracking built for you. No account. No cloud. Just your lifts.';

  @override
  String get onboardingPage2Title => 'Weigh what\nyou lift.';

  @override
  String get onboardingPage2Body =>
      'Every set, every rep. Watch your estimated 1RM climb week after week.';

  @override
  String get onboardingPage3Title => 'Your week,\nyour way.';

  @override
  String get onboardingPage3Body =>
      'Build routines, order exercises, and place rest exactly where it belongs.';

  @override
  String get onboardingPage4Title => 'Your data,\nstays here.';

  @override
  String get onboardingPage4Body =>
      'No internet. No account. No cloud. Everything stays on your phone.';

  @override
  String get onboardingNameTitle => 'Hi,\nwhat\'s your name?';

  @override
  String get onboardingNameSubtitle => 'Optional. You can always skip this.';

  @override
  String get onboardingNameHint => 'Your name…';

  @override
  String get onboardingLetsGo => 'Let\'s go';

  @override
  String get obCtaStart => 'Start';

  @override
  String get obCtaAlmostReady => 'Almost ready';

  @override
  String get obTagWeights => 'Weights & PRs';

  @override
  String get obTagRoutines => 'Routines';

  @override
  String get obTagLocal => '100% local';

  @override
  String get obB2DeltaNote => 'in 11 wk.';

  @override
  String get obB4Banner => 'No internet · No account · No cloud';

  @override
  String get obB5Body => 'Optional. You can skip it now or change it later.';

  @override
  String get obB5Footnote => 'Saved only on this device';

  @override
  String get obB1Eyebrow => 'Versatile · Welcome';

  @override
  String get obB2Eyebrow => 'Log · Record';

  @override
  String get obB3Eyebrow => 'Routines · Your plan';

  @override
  String get obB4Eyebrow => 'Private · 100% local';

  @override
  String get obB5Eyebrow => 'One last thing · Who trains?';

  @override
  String get obB4ItemAccounts => 'Accounts & subscriptions';

  @override
  String get obB4ItemCloud => 'Cloud sync';

  @override
  String get obB4ItemAds => 'Ads & tracking';

  @override
  String get obB4ItemLocal => 'Everything on your phone';

  @override
  String get obB5NameLabel => 'Your name';

  @override
  String get obB5SavedLocally => 'Saved only on this device';

  @override
  String get coachmarkHistoryFirstCardTitle => 'Tap to see the details';

  @override
  String get coachmarkHistoryFirstCardBody =>
      'Here you\'ll find every set and rep you logged. Your training history is always one tap away.';

  @override
  String get coachmarkSessionChartTitle => 'Track your progress';

  @override
  String get coachmarkSessionChartBody =>
      'Tap this button to see a chart of your estimated 1RM and total volume over time for this exercise.';

  @override
  String get coachmarkRestTimerTitle => 'Rest timer';

  @override
  String get coachmarkRestTimerBody =>
      'This counts down your rest between sets. Tap +15s to extend, or Skip to move on early.';

  @override
  String get coachmarkProgressToggleTitle => 'Switch metrics';

  @override
  String get coachmarkProgressToggleBody =>
      'Toggle between estimated 1RM and total volume to track your progress from two different angles.';

  @override
  String get trainingPlan => 'Training plan';

  @override
  String get trainingPlanSubtitle => 'Schedule routines across the week';

  @override
  String get programsSubtitle => 'Build a multi-week plan with rest days';

  @override
  String get createProgram => 'Create program';

  @override
  String get editProgram => 'Edit program';

  @override
  String get noProgramsYet => 'No programs yet';

  @override
  String get programsEmptyBody =>
      'Build a weekly plan that assigns a routine, or a rest day, to each day of the week.';

  @override
  String get deleteProgramTitle => 'Delete program?';

  @override
  String deleteProgramContent(String name) {
    return 'This will permanently delete \'$name\'. Routines and history stay intact.';
  }

  @override
  String get activateProgram => 'Activate';

  @override
  String get deactivateProgram => 'Deactivate';

  @override
  String programWeeksSummary(int weeks, int deload) {
    String _temp0 = intl.Intl.pluralLogic(
      weeks,
      locale: localeName,
      other: 'weeks',
      one: 'week',
    );
    return '$weeks $_temp0 · $deload deload';
  }

  @override
  String get pickStartDate => 'Pick a start date';

  @override
  String get programName => 'Name';

  @override
  String get programNameHint => 'e.g. 4-week Push/Pull/Legs';

  @override
  String get weeksLabel => 'Weeks';

  @override
  String weeksCountValue(int weeks) {
    String _temp0 = intl.Intl.pluralLogic(
      weeks,
      locale: localeName,
      other: 'weeks',
      one: 'week',
    );
    return '$weeks $_temp0';
  }

  @override
  String get scheduleLabel => 'Schedule';

  @override
  String get deloadWeekLabel => 'Deload';

  @override
  String weekN(int n) {
    return 'Week $n';
  }

  @override
  String get tapToAssign => 'Tap to assign';

  @override
  String get routineRemoved => 'Routine removed';

  @override
  String get save => 'Save';

  @override
  String get labelRest => 'Rest';

  @override
  String get labelCardio => 'Cardio';

  @override
  String get labelMobility => 'Mobility';

  @override
  String get labelStretch => 'Stretching';

  @override
  String editDayTitle(String day) {
    return 'Edit $day';
  }

  @override
  String get clear => 'Clear';

  @override
  String get pickRoutineSection => 'Pick a routine';

  @override
  String get pickLabelSection => 'Or use a label';

  @override
  String get customLabelSection => 'Custom';

  @override
  String get customLabelHint => 'Write your own label…';

  @override
  String get applyCustomLabel => 'Use custom label';

  @override
  String get weekdayMon => 'Monday';

  @override
  String get weekdayTue => 'Tuesday';

  @override
  String get weekdayWed => 'Wednesday';

  @override
  String get weekdayThu => 'Thursday';

  @override
  String get weekdayFri => 'Friday';

  @override
  String get weekdaySat => 'Saturday';

  @override
  String get weekdaySun => 'Sunday';

  @override
  String get weekdayMonShort => 'MON';

  @override
  String get weekdayTueShort => 'TUE';

  @override
  String get weekdayWedShort => 'WED';

  @override
  String get weekdayThuShort => 'THU';

  @override
  String get weekdayFriShort => 'FRI';

  @override
  String get weekdaySatShort => 'SAT';

  @override
  String get weekdaySunShort => 'SUN';

  @override
  String get plannedBadge => 'PLANNED';

  @override
  String get plannedDeloadBadge => 'DELOAD';

  @override
  String get todayLabel => 'TODAY';

  @override
  String get restDayDescription => 'Today\'s slot from your active program.';

  @override
  String get programsHelpTooltip => 'How training plans work';

  @override
  String get programsHelpTitle => 'How training plans work';

  @override
  String get programsHelpIntroTitle => 'What is a training plan?';

  @override
  String get programsHelpIntroBody =>
      'A multi-week schedule that assigns a routine or a rest day to each weekday. Useful for periodization like Push/Pull/Legs or 5-day splits.';

  @override
  String get programsHelpSlotsTitle => 'Days are slots';

  @override
  String get programsHelpSlotsBody =>
      'Each day can be a routine (your workout), a rest day, or a custom label like Cardio, Mobility, or anything you want.';

  @override
  String get programsHelpDeloadTitle => 'Deload weeks';

  @override
  String get programsHelpDeloadBody =>
      'Mark a whole week as deload (lighter intensity) for recovery. The home will show a DELOAD badge so you remember to ease off.';

  @override
  String get programsHelpActivateTitle => 'Activating a plan';

  @override
  String get programsHelpActivateBody =>
      'Pick a start date, usually a Monday. When the last week ends, the plan loops back to week 1 automatically.';

  @override
  String get programsHelpBadgesTitle => 'What you\'ll see on Home';

  @override
  String get programsHelpBadgesBody =>
      'When today has a planned routine, the home card shows a PLANNED badge. Deload weeks show DELOAD. The card still works the same. Tap Start to begin.';

  @override
  String get programsHelpOptionalTitle => '100% optional';

  @override
  String get programsHelpOptionalBody =>
      'If you ignore plans, the app behaves exactly as before. Plans are an extra you can turn on or off any time without losing routines or history.';

  @override
  String get close => 'Close';

  @override
  String get recapTitle => 'Your month in lifting';

  @override
  String get recapIntroSubtitle => 'A look back at what you trained.';

  @override
  String get recapSessionsTitle => 'You showed up';

  @override
  String recapSessionsBody(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '# workouts',
      one: '# workout',
    );
    return '$_temp0';
  }

  @override
  String get recapVolumeTitle => 'You moved';

  @override
  String recapVolumeDeltaUp(int pct, String month) {
    return '$pct% more than $month';
  }

  @override
  String recapVolumeDeltaDown(int pct, String month) {
    return '$pct% less than $month';
  }

  @override
  String recapVolumeDeltaSame(String month) {
    return 'About the same as $month';
  }

  @override
  String get recapTopRoutineTitle => 'Your go-to';

  @override
  String recapTopRoutineBody(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '# sessions',
      one: '# session',
    );
    return '$_temp0';
  }

  @override
  String get recapTopExerciseTitle => 'Star of the show';

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
  String get recapPRTitle => 'New record!';

  @override
  String recapPRBody(String exercise) {
    return 'on $exercise';
  }

  @override
  String get recapOutroTitle => 'See you next month';

  @override
  String get recapOutroBody => 'Keep showing up.';

  @override
  String get recapBalanceTitle => 'Movement balance';

  @override
  String get recapBalanceBody => 'How you split your work this month.';

  @override
  String get deloadBannerTitle => 'Time for a deload?';

  @override
  String get deloadBannerBodyStagnation =>
      'Several lifts haven\'t progressed in 3+ weeks.';

  @override
  String get deloadBannerBodyVolume =>
      'Your weekly volume has dropped recently.';

  @override
  String get deloadBannerBodyBoth =>
      'Progress has stalled and volume is down. A lighter week could help.';

  @override
  String get deloadBannerCta => 'Open program';

  @override
  String get deloadBannerDismiss => 'Not now';

  @override
  String get categoryAll => 'All';

  @override
  String get categoryPush => 'Push';

  @override
  String get categoryPull => 'Pull';

  @override
  String get categoryLegs => 'Legs';

  @override
  String get categoryOther => 'Other';

  @override
  String recapEntryCardTitle(String month) {
    return '$month recap';
  }

  @override
  String recapEntryCardSubtitle(int count, String volume) {
    return '$count sessions · $volume';
  }

  @override
  String get recapPastRecaps => 'Past recaps';

  @override
  String get recapPastRecapsEmpty => 'No past recaps yet';

  @override
  String get recapPastRecapsSubtitle => 'Look back at any closed month';

  @override
  String get recapBannerCta => 'View';

  @override
  String get recapHeadline => 'Recap';

  @override
  String get recapCoverSubtitle => 'Your month of training, in numbers.';

  @override
  String get recapTapToBegin => 'TAP TO BEGIN';

  @override
  String get recapSessionsEyebrow => 'You showed up';

  @override
  String get recapSessionsLabel => 'times this month';

  @override
  String recapSessionsDelta(int delta, String month) {
    return '$delta more than $month';
  }

  @override
  String recapSessionsAvg(String perWeek) {
    return 'That\'s an average of $perWeek per week.';
  }

  @override
  String get recapVolumeEyebrow => 'You moved';

  @override
  String get recapVolumeLabel => 'of total weight lifted';

  @override
  String recapVolumeDeltaPct(int pct, String month) {
    return '$pct% vs $month';
  }

  @override
  String recapWeekLabel(int n) {
    return 'W$n';
  }

  @override
  String get recapCalendarEyebrow => 'You showed up on';

  @override
  String get recapCalendarLabel => 'days of the month.';

  @override
  String recapBestWeek(int n) {
    return 'Best week: $n sessions';
  }

  @override
  String get recapTopLiftEyebrow => 'Top lift';

  @override
  String recapTopLiftDelta(String kg) {
    return '+$kg kg this month';
  }

  @override
  String get recapWeeklyBestLabel => 'WEEKLY BEST · LAST 7 WEEKS';

  @override
  String get recapMuscleBalanceEyebrow => 'You focused on';

  @override
  String recapMuscleTopBody(int pct) {
    return 'most of all — $pct% of your work';
  }

  @override
  String recapOutroEyebrow(String month) {
    return '$month · in summary';
  }

  @override
  String get recapOutroHeadline => 'Keep showing up.';

  @override
  String recapOutroFooter(String month) {
    return '$month is just getting started. See you in the gym.';
  }

  @override
  String get recapOutroCta => 'Back to training';

  @override
  String get recapStatSessions => 'sessions';

  @override
  String get recapStatHours => 'hours';

  @override
  String get recapStatNewPRs => 'new PRs';

  @override
  String recapHomeBannerEyebrow(String month) {
    return 'Your $month recap is ready';
  }

  @override
  String recapHomeBannerTitle(int sessions, String volume) {
    return '$sessions sessions · $volume moved';
  }

  @override
  String get share => 'Share';

  @override
  String get shareWorkout => 'Share workout';

  @override
  String get sharePreviewSubtitle => 'A square card you can post anywhere';

  @override
  String get recordLabel => 'Record';

  @override
  String get averageLabel => 'Average';

  @override
  String get sessionsLabel => 'Sessions';

  @override
  String get progressionLabel => 'Progression';

  @override
  String get viewAll => 'View all';

  @override
  String get formulaEpley => 'Epley formula';

  @override
  String get formulaEpleyDescription =>
      'Estimated 1RM is calculated using the Epley formula:';

  @override
  String get vsPrevious => 'vs previous';

  @override
  String get editorialSection => 'EDITORIAL PHOTOS';

  @override
  String get editorialEnable => 'Enable photos on home';

  @override
  String get editorialMoodboardLabel => 'Moodboard Photo';

  @override
  String get editorialBackCoverLabel => 'Back Cover Photo';

  @override
  String get editorialQuoteHint => 'Write custom caption...';

  @override
  String get editorialDefaultMoodboardQuote => 'Focus on the process';

  @override
  String get editorialDefaultBackCoverQuote =>
      'The mind is everything. What you think you become.';

  @override
  String get editorialNoImage => 'No image selected';

  @override
  String get editorialChangeImage => 'Change';

  @override
  String get editorialRemoveImage => 'Remove';

  @override
  String editorialCharLimit(Object limit) {
    return 'Max $limit characters';
  }

  @override
  String get editorialReposition => 'Reposition Photo';

  @override
  String get editorialDragInstructions => 'DRAG TO REPOSITION';

  @override
  String get sharePRBadge => 'NEW PR';

  @override
  String get shareTrainingJournal => 'TRAINING JOURNAL';

  @override
  String get shareIssueAbbrev => 'No.';
}
