import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_es.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('es'),
  ];

  /// No description provided for @appName.
  ///
  /// In en, this message translates to:
  /// **'Versatile'**
  String get appName;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @appearance.
  ///
  /// In en, this message translates to:
  /// **'APPEARANCE'**
  String get appearance;

  /// No description provided for @theme.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get theme;

  /// No description provided for @themeLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get themeLight;

  /// No description provided for @themeDark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get themeDark;

  /// No description provided for @themeSystem.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get themeSystem;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @languageEn.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get languageEn;

  /// No description provided for @languageEs.
  ///
  /// In en, this message translates to:
  /// **'Spanish'**
  String get languageEs;

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'PROFILE'**
  String get profile;

  /// No description provided for @userName.
  ///
  /// In en, this message translates to:
  /// **'User name'**
  String get userName;

  /// No description provided for @changeName.
  ///
  /// In en, this message translates to:
  /// **'Change name'**
  String get changeName;

  /// No description provided for @data.
  ///
  /// In en, this message translates to:
  /// **'DATA'**
  String get data;

  /// No description provided for @exportData.
  ///
  /// In en, this message translates to:
  /// **'Export data'**
  String get exportData;

  /// No description provided for @importData.
  ///
  /// In en, this message translates to:
  /// **'Import data'**
  String get importData;

  /// No description provided for @wipeAllData.
  ///
  /// In en, this message translates to:
  /// **'Wipe all data'**
  String get wipeAllData;

  /// No description provided for @wipeConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Wipe all data?'**
  String get wipeConfirmTitle;

  /// No description provided for @wipeConfirmContent.
  ///
  /// In en, this message translates to:
  /// **'This will permanently delete all your routines, history, and custom exercises. This cannot be undone.'**
  String get wipeConfirmContent;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @wipe.
  ///
  /// In en, this message translates to:
  /// **'Wipe'**
  String get wipe;

  /// No description provided for @dataWiped.
  ///
  /// In en, this message translates to:
  /// **'All data wiped'**
  String get dataWiped;

  /// No description provided for @wipeFailed.
  ///
  /// In en, this message translates to:
  /// **'Wipe failed: {error}'**
  String wipeFailed(String error);

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @routines.
  ///
  /// In en, this message translates to:
  /// **'Routines'**
  String get routines;

  /// No description provided for @exercises.
  ///
  /// In en, this message translates to:
  /// **'Exercises'**
  String get exercises;

  /// No description provided for @history.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get history;

  /// No description provided for @hello.
  ///
  /// In en, this message translates to:
  /// **'Hello'**
  String get hello;

  /// No description provided for @helloThere.
  ///
  /// In en, this message translates to:
  /// **'Hello there'**
  String get helloThere;

  /// No description provided for @today.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get today;

  /// No description provided for @todaysSession.
  ///
  /// In en, this message translates to:
  /// **'TODAY\'S SESSION'**
  String get todaysSession;

  /// No description provided for @startWorkout.
  ///
  /// In en, this message translates to:
  /// **'Start workout'**
  String get startWorkout;

  /// No description provided for @thisWeek.
  ///
  /// In en, this message translates to:
  /// **'THIS WEEK'**
  String get thisWeek;

  /// No description provided for @sessions.
  ///
  /// In en, this message translates to:
  /// **'sessions'**
  String get sessions;

  /// No description provided for @volume.
  ///
  /// In en, this message translates to:
  /// **'VOLUME'**
  String get volume;

  /// No description provided for @avgTime.
  ///
  /// In en, this message translates to:
  /// **'AVG TIME'**
  String get avgTime;

  /// No description provided for @activity.
  ///
  /// In en, this message translates to:
  /// **'ACTIVITY'**
  String get activity;

  /// No description provided for @sessionsLastYear.
  ///
  /// In en, this message translates to:
  /// **'sessions in the last year'**
  String get sessionsLastYear;

  /// No description provided for @less.
  ///
  /// In en, this message translates to:
  /// **'Less'**
  String get less;

  /// No description provided for @more.
  ///
  /// In en, this message translates to:
  /// **'More'**
  String get more;

  /// No description provided for @recentSessions.
  ///
  /// In en, this message translates to:
  /// **'Recent sessions'**
  String get recentSessions;

  /// No description provided for @total.
  ///
  /// In en, this message translates to:
  /// **'total'**
  String get total;

  /// No description provided for @noRoutinesYet.
  ///
  /// In en, this message translates to:
  /// **'No routines yet'**
  String get noRoutinesYet;

  /// No description provided for @createFirstOne.
  ///
  /// In en, this message translates to:
  /// **'Create your first one'**
  String get createFirstOne;

  /// No description provided for @createRoutine.
  ///
  /// In en, this message translates to:
  /// **'Create routine'**
  String get createRoutine;

  /// No description provided for @workoutInProgress.
  ///
  /// In en, this message translates to:
  /// **'Workout in progress'**
  String get workoutInProgress;

  /// No description provided for @restoredProgress.
  ///
  /// In en, this message translates to:
  /// **'Restored progress from your active workout.'**
  String get restoredProgress;

  /// No description provided for @routinesInLibrary.
  ///
  /// In en, this message translates to:
  /// **'{count} routines in your library'**
  String routinesInLibrary(int count);

  /// No description provided for @exercisesLabel.
  ///
  /// In en, this message translates to:
  /// **'exercises'**
  String get exercisesLabel;

  /// No description provided for @noRoutinesMatch.
  ///
  /// In en, this message translates to:
  /// **'No routines match'**
  String get noRoutinesMatch;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @done.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get done;

  /// No description provided for @addExercise.
  ///
  /// In en, this message translates to:
  /// **'Add exercise'**
  String get addExercise;

  /// No description provided for @deleteRoutineTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete routine?'**
  String get deleteRoutineTitle;

  /// No description provided for @deleteRoutineContent.
  ///
  /// In en, this message translates to:
  /// **'This will permanently delete the routine \'{name}\'.'**
  String deleteRoutineContent(String name);

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @startThisWorkout.
  ///
  /// In en, this message translates to:
  /// **'Start this workout'**
  String get startThisWorkout;

  /// No description provided for @rest.
  ///
  /// In en, this message translates to:
  /// **'rest'**
  String get rest;

  /// No description provided for @active.
  ///
  /// In en, this message translates to:
  /// **'ACTIVE'**
  String get active;

  /// No description provided for @sets.
  ///
  /// In en, this message translates to:
  /// **'sets'**
  String get sets;

  /// No description provided for @finishWorkout.
  ///
  /// In en, this message translates to:
  /// **'Finish workout'**
  String get finishWorkout;

  /// No description provided for @saving.
  ///
  /// In en, this message translates to:
  /// **'Saving…'**
  String get saving;

  /// No description provided for @preparingWorkout.
  ///
  /// In en, this message translates to:
  /// **'Preparing workout...'**
  String get preparingWorkout;

  /// No description provided for @workoutFinished.
  ///
  /// In en, this message translates to:
  /// **'Workout finished!'**
  String get workoutFinished;

  /// No description provided for @greatJob.
  ///
  /// In en, this message translates to:
  /// **'Great job! Your session has been saved.'**
  String get greatJob;

  /// No description provided for @finish.
  ///
  /// In en, this message translates to:
  /// **'Finish'**
  String get finish;

  /// No description provided for @discardWorkoutTitle.
  ///
  /// In en, this message translates to:
  /// **'Discard workout?'**
  String get discardWorkoutTitle;

  /// No description provided for @discardWorkoutContent.
  ///
  /// In en, this message translates to:
  /// **'This will delete all progress from this session.'**
  String get discardWorkoutContent;

  /// No description provided for @discard.
  ///
  /// In en, this message translates to:
  /// **'Discard'**
  String get discard;

  /// No description provided for @finishSet.
  ///
  /// In en, this message translates to:
  /// **'Finish set {number}'**
  String finishSet(int number);

  /// No description provided for @addExerciseTitle.
  ///
  /// In en, this message translates to:
  /// **'Add Exercise'**
  String get addExerciseTitle;

  /// No description provided for @inLibrary.
  ///
  /// In en, this message translates to:
  /// **'{count} in library'**
  String inLibrary(int count);

  /// No description provided for @newExercise.
  ///
  /// In en, this message translates to:
  /// **'New Exercise'**
  String get newExercise;

  /// No description provided for @addCustomExercise.
  ///
  /// In en, this message translates to:
  /// **'Add a custom exercise'**
  String get addCustomExercise;

  /// No description provided for @exerciseName.
  ///
  /// In en, this message translates to:
  /// **'Exercise name'**
  String get exerciseName;

  /// No description provided for @egBenchPress.
  ///
  /// In en, this message translates to:
  /// **'e.g. Bench Press'**
  String get egBenchPress;

  /// No description provided for @muscleGroup.
  ///
  /// In en, this message translates to:
  /// **'MUSCLE GROUP'**
  String get muscleGroup;

  /// No description provided for @category.
  ///
  /// In en, this message translates to:
  /// **'CATEGORY'**
  String get category;

  /// No description provided for @bilateral.
  ///
  /// In en, this message translates to:
  /// **'Bilateral'**
  String get bilateral;

  /// No description provided for @unilateral.
  ///
  /// In en, this message translates to:
  /// **'Unilateral'**
  String get unilateral;

  /// No description provided for @saveExercise.
  ///
  /// In en, this message translates to:
  /// **'Save exercise'**
  String get saveExercise;

  /// No description provided for @search.
  ///
  /// In en, this message translates to:
  /// **'Search…'**
  String get search;

  /// No description provided for @noExercisesMatch.
  ///
  /// In en, this message translates to:
  /// **'No exercises match'**
  String get noExercisesMatch;

  /// No description provided for @custom.
  ///
  /// In en, this message translates to:
  /// **'CUSTOM'**
  String get custom;

  /// No description provided for @all.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get all;

  /// No description provided for @noHistoryYet.
  ///
  /// In en, this message translates to:
  /// **'No history yet'**
  String get noHistoryYet;

  /// No description provided for @startTrainingToSee.
  ///
  /// In en, this message translates to:
  /// **'Start training to see your progress here'**
  String get startTrainingToSee;

  /// No description provided for @sessionDetail.
  ///
  /// In en, this message translates to:
  /// **'Session Detail'**
  String get sessionDetail;

  /// No description provided for @workoutSummary.
  ///
  /// In en, this message translates to:
  /// **'Workout Summary'**
  String get workoutSummary;

  /// No description provided for @duration.
  ///
  /// In en, this message translates to:
  /// **'Duration'**
  String get duration;

  /// No description provided for @volumeTotal.
  ///
  /// In en, this message translates to:
  /// **'Total Volume'**
  String get volumeTotal;

  /// No description provided for @exercisesPerformed.
  ///
  /// In en, this message translates to:
  /// **'Exercises Performed'**
  String get exercisesPerformed;

  /// No description provided for @neverDone.
  ///
  /// In en, this message translates to:
  /// **'Never done'**
  String get neverDone;

  /// No description provided for @doneToday.
  ///
  /// In en, this message translates to:
  /// **'Done today'**
  String get doneToday;

  /// No description provided for @doneYesterday.
  ///
  /// In en, this message translates to:
  /// **'Done yesterday'**
  String get doneYesterday;

  /// No description provided for @lastDoneDaysAgo.
  ///
  /// In en, this message translates to:
  /// **'Last done {days} days ago'**
  String lastDoneDaysAgo(int days);

  /// No description provided for @set_label.
  ///
  /// In en, this message translates to:
  /// **'SET'**
  String get set_label;

  /// No description provided for @weight_label.
  ///
  /// In en, this message translates to:
  /// **'WEIGHT'**
  String get weight_label;

  /// No description provided for @reps_label.
  ///
  /// In en, this message translates to:
  /// **'REPS'**
  String get reps_label;

  /// No description provided for @last_label.
  ///
  /// In en, this message translates to:
  /// **'Last'**
  String get last_label;

  /// No description provided for @split_label.
  ///
  /// In en, this message translates to:
  /// **'Split'**
  String get split_label;

  /// No description provided for @skip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get skip;

  /// Label shown on an exercise card that was skipped during a workout
  ///
  /// In en, this message translates to:
  /// **'Skipped'**
  String get skipped;

  /// No description provided for @skipExercise.
  ///
  /// In en, this message translates to:
  /// **'Skip exercise'**
  String get skipExercise;

  /// Confirmation message when skipping an exercise
  ///
  /// In en, this message translates to:
  /// **'Skip this exercise? Its sets will be filled from your last session.'**
  String get skipExerciseContent;

  /// No description provided for @about.
  ///
  /// In en, this message translates to:
  /// **'ABOUT'**
  String get about;

  /// No description provided for @version.
  ///
  /// In en, this message translates to:
  /// **'Version'**
  String get version;

  /// No description provided for @author.
  ///
  /// In en, this message translates to:
  /// **'Author'**
  String get author;

  /// No description provided for @noRecordYet.
  ///
  /// In en, this message translates to:
  /// **'No record yet'**
  String get noRecordYet;

  /// No description provided for @newRoutine.
  ///
  /// In en, this message translates to:
  /// **'New Routine'**
  String get newRoutine;

  /// No description provided for @nameItAndPickColor.
  ///
  /// In en, this message translates to:
  /// **'Name it and pick a color'**
  String get nameItAndPickColor;

  /// No description provided for @name_label.
  ///
  /// In en, this message translates to:
  /// **'NAME'**
  String get name_label;

  /// No description provided for @color_label.
  ///
  /// In en, this message translates to:
  /// **'COLOR'**
  String get color_label;

  /// No description provided for @icon_label.
  ///
  /// In en, this message translates to:
  /// **'ICON'**
  String get icon_label;

  /// No description provided for @createRoutineBtn.
  ///
  /// In en, this message translates to:
  /// **'Create Routine'**
  String get createRoutineBtn;

  /// No description provided for @exportSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Share a JSON backup of all your data'**
  String get exportSubtitle;

  /// No description provided for @importSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Restore from a JSON backup'**
  String get importSubtitle;

  /// No description provided for @wipeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Delete all routines, sessions and history'**
  String get wipeSubtitle;

  /// No description provided for @routineNotFound.
  ///
  /// In en, this message translates to:
  /// **'Routine not found'**
  String get routineNotFound;

  /// No description provided for @goBack.
  ///
  /// In en, this message translates to:
  /// **'Go back'**
  String get goBack;

  /// No description provided for @ex_bench_press.
  ///
  /// In en, this message translates to:
  /// **'Bench Press'**
  String get ex_bench_press;

  /// No description provided for @ex_incline_dumbbell_press.
  ///
  /// In en, this message translates to:
  /// **'Incline Dumbbell Press'**
  String get ex_incline_dumbbell_press;

  /// No description provided for @ex_cable_fly.
  ///
  /// In en, this message translates to:
  /// **'Cable Fly'**
  String get ex_cable_fly;

  /// No description provided for @ex_pull_up.
  ///
  /// In en, this message translates to:
  /// **'Pull-Up'**
  String get ex_pull_up;

  /// No description provided for @ex_barbell_row.
  ///
  /// In en, this message translates to:
  /// **'Barbell Row'**
  String get ex_barbell_row;

  /// No description provided for @ex_lat_pulldown.
  ///
  /// In en, this message translates to:
  /// **'Lat Pulldown'**
  String get ex_lat_pulldown;

  /// No description provided for @ex_squat.
  ///
  /// In en, this message translates to:
  /// **'Squat'**
  String get ex_squat;

  /// No description provided for @ex_romanian_deadlift.
  ///
  /// In en, this message translates to:
  /// **'Romanian Deadlift'**
  String get ex_romanian_deadlift;

  /// No description provided for @ex_leg_press.
  ///
  /// In en, this message translates to:
  /// **'Leg Press'**
  String get ex_leg_press;

  /// No description provided for @ex_overhead_press.
  ///
  /// In en, this message translates to:
  /// **'Overhead Press'**
  String get ex_overhead_press;

  /// No description provided for @ex_lateral_raise.
  ///
  /// In en, this message translates to:
  /// **'Lateral Raise'**
  String get ex_lateral_raise;

  /// No description provided for @ex_face_pull.
  ///
  /// In en, this message translates to:
  /// **'Face Pull'**
  String get ex_face_pull;

  /// No description provided for @ex_bicep_curl.
  ///
  /// In en, this message translates to:
  /// **'Bicep Curl'**
  String get ex_bicep_curl;

  /// No description provided for @ex_tricep_pushdown.
  ///
  /// In en, this message translates to:
  /// **'Tricep Pushdown'**
  String get ex_tricep_pushdown;

  /// No description provided for @ex_hammer_curl.
  ///
  /// In en, this message translates to:
  /// **'Hammer Curl'**
  String get ex_hammer_curl;

  /// No description provided for @ex_plank.
  ///
  /// In en, this message translates to:
  /// **'Plank'**
  String get ex_plank;

  /// No description provided for @ex_hanging_leg_raise.
  ///
  /// In en, this message translates to:
  /// **'Hanging Leg Raise'**
  String get ex_hanging_leg_raise;

  /// No description provided for @ex_landmine_press.
  ///
  /// In en, this message translates to:
  /// **'Landmine Press'**
  String get ex_landmine_press;

  /// No description provided for @ex_pendlay_row.
  ///
  /// In en, this message translates to:
  /// **'Pendlay Row'**
  String get ex_pendlay_row;

  /// No description provided for @muscle_chest.
  ///
  /// In en, this message translates to:
  /// **'Chest'**
  String get muscle_chest;

  /// No description provided for @muscle_back.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get muscle_back;

  /// No description provided for @muscle_shoulders.
  ///
  /// In en, this message translates to:
  /// **'Shoulders'**
  String get muscle_shoulders;

  /// No description provided for @muscle_biceps.
  ///
  /// In en, this message translates to:
  /// **'Biceps'**
  String get muscle_biceps;

  /// No description provided for @muscle_triceps.
  ///
  /// In en, this message translates to:
  /// **'Triceps'**
  String get muscle_triceps;

  /// No description provided for @muscle_forearms.
  ///
  /// In en, this message translates to:
  /// **'Forearms'**
  String get muscle_forearms;

  /// No description provided for @muscle_quadriceps.
  ///
  /// In en, this message translates to:
  /// **'Quadriceps'**
  String get muscle_quadriceps;

  /// No description provided for @muscle_hamstrings.
  ///
  /// In en, this message translates to:
  /// **'Hamstrings'**
  String get muscle_hamstrings;

  /// No description provided for @muscle_glutes.
  ///
  /// In en, this message translates to:
  /// **'Glutes'**
  String get muscle_glutes;

  /// No description provided for @muscle_calves.
  ///
  /// In en, this message translates to:
  /// **'Calves'**
  String get muscle_calves;

  /// No description provided for @muscle_core.
  ///
  /// In en, this message translates to:
  /// **'Core'**
  String get muscle_core;

  /// No description provided for @muscle_other.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get muscle_other;

  /// No description provided for @muscle_arms.
  ///
  /// In en, this message translates to:
  /// **'Arms'**
  String get muscle_arms;

  /// No description provided for @muscle_legs.
  ///
  /// In en, this message translates to:
  /// **'Legs'**
  String get muscle_legs;

  /// No description provided for @equip_barbell.
  ///
  /// In en, this message translates to:
  /// **'Barbell'**
  String get equip_barbell;

  /// No description provided for @equip_dumbbell.
  ///
  /// In en, this message translates to:
  /// **'Dumbbell'**
  String get equip_dumbbell;

  /// No description provided for @equip_cable.
  ///
  /// In en, this message translates to:
  /// **'Cable'**
  String get equip_cable;

  /// No description provided for @equip_bodyweight.
  ///
  /// In en, this message translates to:
  /// **'Bodyweight'**
  String get equip_bodyweight;

  /// No description provided for @equip_machine.
  ///
  /// In en, this message translates to:
  /// **'Machine'**
  String get equip_machine;

  /// No description provided for @deleteExerciseTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete exercise?'**
  String get deleteExerciseTitle;

  /// No description provided for @deleteExerciseContent.
  ///
  /// In en, this message translates to:
  /// **'This will permanently delete {count} custom {count, plural, one{exercise} other{exercises}}. This cannot be undone.'**
  String deleteExerciseContent(int count);

  /// No description provided for @unilateral_label.
  ///
  /// In en, this message translates to:
  /// **'UNILATERAL'**
  String get unilateral_label;

  /// No description provided for @configureExercise.
  ///
  /// In en, this message translates to:
  /// **'Configure Exercise'**
  String get configureExercise;

  /// No description provided for @apply.
  ///
  /// In en, this message translates to:
  /// **'Apply'**
  String get apply;

  /// No description provided for @setsLabel.
  ///
  /// In en, this message translates to:
  /// **'Sets'**
  String get setsLabel;

  /// No description provided for @repsRangeLabel.
  ///
  /// In en, this message translates to:
  /// **'Reps'**
  String get repsRangeLabel;

  /// No description provided for @restSecondsLabel.
  ///
  /// In en, this message translates to:
  /// **'Rest (s)'**
  String get restSecondsLabel;

  /// No description provided for @sound.
  ///
  /// In en, this message translates to:
  /// **'SOUND'**
  String get sound;

  /// No description provided for @restTimerAlert.
  ///
  /// In en, this message translates to:
  /// **'Rest timer alert'**
  String get restTimerAlert;

  /// No description provided for @defaultSound.
  ///
  /// In en, this message translates to:
  /// **'Default'**
  String get defaultSound;

  /// No description provided for @customSound.
  ///
  /// In en, this message translates to:
  /// **'Custom'**
  String get customSound;

  /// No description provided for @pickSoundFile.
  ///
  /// In en, this message translates to:
  /// **'Pick sound file'**
  String get pickSoundFile;

  /// No description provided for @noSoundSelected.
  ///
  /// In en, this message translates to:
  /// **'No sound selected'**
  String get noSoundSelected;

  /// No description provided for @sessionComplete.
  ///
  /// In en, this message translates to:
  /// **'Session complete!'**
  String get sessionComplete;

  /// No description provided for @congratulations.
  ///
  /// In en, this message translates to:
  /// **'Congratulations!'**
  String get congratulations;

  /// No description provided for @backToHome.
  ///
  /// In en, this message translates to:
  /// **'Back to home'**
  String get backToHome;

  /// No description provided for @notificationSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Stay focused. Tap to return'**
  String get notificationSubtitle;

  /// No description provided for @accentColor.
  ///
  /// In en, this message translates to:
  /// **'Accent color'**
  String get accentColor;

  /// No description provided for @colorOrange.
  ///
  /// In en, this message translates to:
  /// **'Orange'**
  String get colorOrange;

  /// No description provided for @colorBlue.
  ///
  /// In en, this message translates to:
  /// **'Blue'**
  String get colorBlue;

  /// No description provided for @colorGreen.
  ///
  /// In en, this message translates to:
  /// **'Green'**
  String get colorGreen;

  /// No description provided for @colorPurple.
  ///
  /// In en, this message translates to:
  /// **'Purple'**
  String get colorPurple;

  /// No description provided for @colorRed.
  ///
  /// In en, this message translates to:
  /// **'Red'**
  String get colorRed;

  /// No description provided for @colorTeal.
  ///
  /// In en, this message translates to:
  /// **'Teal'**
  String get colorTeal;

  /// No description provided for @colorPink.
  ///
  /// In en, this message translates to:
  /// **'Pink'**
  String get colorPink;

  /// No description provided for @colorAmber.
  ///
  /// In en, this message translates to:
  /// **'Amber'**
  String get colorAmber;

  /// No description provided for @progressTitle.
  ///
  /// In en, this message translates to:
  /// **'Progress'**
  String get progressTitle;

  /// No description provided for @estimatedOneRm.
  ///
  /// In en, this message translates to:
  /// **'Est. 1RM'**
  String get estimatedOneRm;

  /// No description provided for @noProgressYet.
  ///
  /// In en, this message translates to:
  /// **'No data yet. Complete a workout with this exercise to track your progress.'**
  String get noProgressYet;

  /// No description provided for @seeProgress.
  ///
  /// In en, this message translates to:
  /// **'See progress'**
  String get seeProgress;

  /// No description provided for @best_label.
  ///
  /// In en, this message translates to:
  /// **'BEST'**
  String get best_label;

  /// No description provided for @oneRmDescription.
  ///
  /// In en, this message translates to:
  /// **'Best estimated max single-rep weight per session'**
  String get oneRmDescription;

  /// No description provided for @volumeDescription.
  ///
  /// In en, this message translates to:
  /// **'Total kg × reps across all sets per session'**
  String get volumeDescription;

  /// No description provided for @coachmarkHomeTitle.
  ///
  /// In en, this message translates to:
  /// **'Your next workout'**
  String get coachmarkHomeTitle;

  /// No description provided for @coachmarkHomeBody.
  ///
  /// In en, this message translates to:
  /// **'This card suggests the routine you should train today. Tap Start to begin.'**
  String get coachmarkHomeBody;

  /// No description provided for @coachmarkRoutinesTitle.
  ///
  /// In en, this message translates to:
  /// **'Create your routines'**
  String get coachmarkRoutinesTitle;

  /// No description provided for @coachmarkRoutinesBody.
  ///
  /// In en, this message translates to:
  /// **'Tap + to build a custom workout with your exercises, sets, and rest times.'**
  String get coachmarkRoutinesBody;

  /// No description provided for @coachmarkExercisesTitle.
  ///
  /// In en, this message translates to:
  /// **'Track your progress'**
  String get coachmarkExercisesTitle;

  /// No description provided for @coachmarkExercisesBody.
  ///
  /// In en, this message translates to:
  /// **'Tap any exercise to view your progress chart and personal records.'**
  String get coachmarkExercisesBody;

  /// No description provided for @coachmarkGotIt.
  ///
  /// In en, this message translates to:
  /// **'Got it'**
  String get coachmarkGotIt;

  /// No description provided for @coachmarkSkipAll.
  ///
  /// In en, this message translates to:
  /// **'Skip all'**
  String get coachmarkSkipAll;

  /// No description provided for @coachmarkTabRoutinesTitle.
  ///
  /// In en, this message translates to:
  /// **'Create routines'**
  String get coachmarkTabRoutinesTitle;

  /// No description provided for @coachmarkTabRoutinesBody.
  ///
  /// In en, this message translates to:
  /// **'Tap here to build and manage your workout routines.'**
  String get coachmarkTabRoutinesBody;

  /// No description provided for @coachmarkTabExercisesTitle.
  ///
  /// In en, this message translates to:
  /// **'Your exercises'**
  String get coachmarkTabExercisesTitle;

  /// No description provided for @coachmarkTabExercisesBody.
  ///
  /// In en, this message translates to:
  /// **'Browse the exercise library and tap any exercise to track your progress.'**
  String get coachmarkTabExercisesBody;

  /// No description provided for @coachmarkTabHistoryTitle.
  ///
  /// In en, this message translates to:
  /// **'History & progress'**
  String get coachmarkTabHistoryTitle;

  /// No description provided for @coachmarkTabHistoryBody.
  ///
  /// In en, this message translates to:
  /// **'Your past sessions and progress graphs for every exercise live here. Tap to explore.'**
  String get coachmarkTabHistoryBody;

  /// No description provided for @coachmarkRoutineEditTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit your routine'**
  String get coachmarkRoutineEditTitle;

  /// No description provided for @coachmarkRoutineEditBody.
  ///
  /// In en, this message translates to:
  /// **'Tap Edit to reorder exercises, adjust sets and rest time, or rename this routine.'**
  String get coachmarkRoutineEditBody;

  /// No description provided for @coachmarkExerciseAddTitle.
  ///
  /// In en, this message translates to:
  /// **'Add custom exercises'**
  String get coachmarkExerciseAddTitle;

  /// No description provided for @coachmarkExerciseAddBody.
  ///
  /// In en, this message translates to:
  /// **'Tap + to create your own exercises with a name, muscle group, and equipment type.'**
  String get coachmarkExerciseAddBody;

  /// No description provided for @coachmarkSettingsColorsTitle.
  ///
  /// In en, this message translates to:
  /// **'Make it yours'**
  String get coachmarkSettingsColorsTitle;

  /// No description provided for @coachmarkSettingsColorsBody.
  ///
  /// In en, this message translates to:
  /// **'Choose an accent color and switch between light and dark themes to personalize the app.'**
  String get coachmarkSettingsColorsBody;

  /// No description provided for @coachmarkSettingsSoundTitle.
  ///
  /// In en, this message translates to:
  /// **'Rest timer sound'**
  String get coachmarkSettingsSoundTitle;

  /// No description provided for @coachmarkSettingsSoundBody.
  ///
  /// In en, this message translates to:
  /// **'Enable an alert when your rest period ends. Use the default tone or pick a custom audio file.'**
  String get coachmarkSettingsSoundBody;

  /// No description provided for @coachmarkSettingsDataTitle.
  ///
  /// In en, this message translates to:
  /// **'Back up your data'**
  String get coachmarkSettingsDataTitle;

  /// No description provided for @coachmarkSettingsDataBody.
  ///
  /// In en, this message translates to:
  /// **'Export your routines and history as a JSON file to keep a backup or move to another device.'**
  String get coachmarkSettingsDataBody;

  /// No description provided for @onboardingSkip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get onboardingSkip;

  /// No description provided for @onboardingContinue.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get onboardingContinue;

  /// No description provided for @onboardingWhatsYourName.
  ///
  /// In en, this message translates to:
  /// **'What\'s your name?'**
  String get onboardingWhatsYourName;

  /// No description provided for @onboardingPage1Title.
  ///
  /// In en, this message translates to:
  /// **'Built for\nevery rep.'**
  String get onboardingPage1Title;

  /// No description provided for @onboardingPage1Body.
  ///
  /// In en, this message translates to:
  /// **'A gym tracker that\'s fast, private, and built for you. No logins, no cloud, just your lifts.'**
  String get onboardingPage1Body;

  /// No description provided for @onboardingPage2Title.
  ///
  /// In en, this message translates to:
  /// **'Log weights.\nBreak records.'**
  String get onboardingPage2Title;

  /// No description provided for @onboardingPage2Body.
  ///
  /// In en, this message translates to:
  /// **'Record every set, rep, and weight. Watch your estimated 1-rep max climb over time.'**
  String get onboardingPage2Body;

  /// No description provided for @onboardingPage3Title.
  ///
  /// In en, this message translates to:
  /// **'Routines\nyour way.'**
  String get onboardingPage3Title;

  /// No description provided for @onboardingPage3Body.
  ///
  /// In en, this message translates to:
  /// **'Build custom workouts with exactly the exercises you need. Reorder them, adjust sets, and keep evolving.'**
  String get onboardingPage3Body;

  /// No description provided for @onboardingPage4Title.
  ///
  /// In en, this message translates to:
  /// **'Your data,\nyour device.'**
  String get onboardingPage4Title;

  /// No description provided for @onboardingPage4Body.
  ///
  /// In en, this message translates to:
  /// **'No internet. No account. No subscription. Everything stays on your phone, always.'**
  String get onboardingPage4Body;

  /// No description provided for @onboardingNameTitle.
  ///
  /// In en, this message translates to:
  /// **'What should\nwe call you?'**
  String get onboardingNameTitle;

  /// No description provided for @onboardingNameSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Optional. You can always skip this.'**
  String get onboardingNameSubtitle;

  /// No description provided for @onboardingNameHint.
  ///
  /// In en, this message translates to:
  /// **'Your name…'**
  String get onboardingNameHint;

  /// No description provided for @onboardingLetsGo.
  ///
  /// In en, this message translates to:
  /// **'Let\'s go'**
  String get onboardingLetsGo;

  /// No description provided for @coachmarkHistoryFirstCardTitle.
  ///
  /// In en, this message translates to:
  /// **'Tap to see the details'**
  String get coachmarkHistoryFirstCardTitle;

  /// No description provided for @coachmarkHistoryFirstCardBody.
  ///
  /// In en, this message translates to:
  /// **'Here you\'ll find every set and rep you logged. Your training history is always one tap away.'**
  String get coachmarkHistoryFirstCardBody;

  /// No description provided for @coachmarkSessionChartTitle.
  ///
  /// In en, this message translates to:
  /// **'Track your progress'**
  String get coachmarkSessionChartTitle;

  /// No description provided for @coachmarkSessionChartBody.
  ///
  /// In en, this message translates to:
  /// **'Tap this button to see a chart of your estimated 1RM and total volume over time for this exercise.'**
  String get coachmarkSessionChartBody;

  /// No description provided for @coachmarkRestTimerTitle.
  ///
  /// In en, this message translates to:
  /// **'Rest timer'**
  String get coachmarkRestTimerTitle;

  /// No description provided for @coachmarkRestTimerBody.
  ///
  /// In en, this message translates to:
  /// **'This counts down your rest between sets. Tap +15s to extend, or Skip to move on early.'**
  String get coachmarkRestTimerBody;

  /// No description provided for @coachmarkProgressToggleTitle.
  ///
  /// In en, this message translates to:
  /// **'Switch metrics'**
  String get coachmarkProgressToggleTitle;

  /// No description provided for @coachmarkProgressToggleBody.
  ///
  /// In en, this message translates to:
  /// **'Toggle between estimated 1RM and total volume to track your progress from two different angles.'**
  String get coachmarkProgressToggleBody;

  /// No description provided for @trainingPlan.
  ///
  /// In en, this message translates to:
  /// **'Training plan'**
  String get trainingPlan;

  /// No description provided for @trainingPlanSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Schedule routines across the week'**
  String get trainingPlanSubtitle;

  /// No description provided for @programsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Build a multi-week plan with rest days'**
  String get programsSubtitle;

  /// No description provided for @createProgram.
  ///
  /// In en, this message translates to:
  /// **'Create program'**
  String get createProgram;

  /// No description provided for @editProgram.
  ///
  /// In en, this message translates to:
  /// **'Edit program'**
  String get editProgram;

  /// No description provided for @noProgramsYet.
  ///
  /// In en, this message translates to:
  /// **'No programs yet'**
  String get noProgramsYet;

  /// No description provided for @programsEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'Build a weekly plan that assigns a routine, or a rest day, to each day of the week.'**
  String get programsEmptyBody;

  /// No description provided for @deleteProgramTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete program?'**
  String get deleteProgramTitle;

  /// No description provided for @deleteProgramContent.
  ///
  /// In en, this message translates to:
  /// **'This will permanently delete \'{name}\'. Routines and history stay intact.'**
  String deleteProgramContent(String name);

  /// No description provided for @activateProgram.
  ///
  /// In en, this message translates to:
  /// **'Activate'**
  String get activateProgram;

  /// No description provided for @deactivateProgram.
  ///
  /// In en, this message translates to:
  /// **'Deactivate'**
  String get deactivateProgram;

  /// No description provided for @programWeeksSummary.
  ///
  /// In en, this message translates to:
  /// **'{weeks} {weeks, plural, one{week} other{weeks}} · {deload} deload'**
  String programWeeksSummary(int weeks, int deload);

  /// No description provided for @pickStartDate.
  ///
  /// In en, this message translates to:
  /// **'Pick a start date'**
  String get pickStartDate;

  /// No description provided for @programName.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get programName;

  /// No description provided for @programNameHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. 4-week Push/Pull/Legs'**
  String get programNameHint;

  /// No description provided for @weeksLabel.
  ///
  /// In en, this message translates to:
  /// **'Weeks'**
  String get weeksLabel;

  /// No description provided for @weeksCountValue.
  ///
  /// In en, this message translates to:
  /// **'{weeks} {weeks, plural, one{week} other{weeks}}'**
  String weeksCountValue(int weeks);

  /// No description provided for @scheduleLabel.
  ///
  /// In en, this message translates to:
  /// **'Schedule'**
  String get scheduleLabel;

  /// No description provided for @deloadWeekLabel.
  ///
  /// In en, this message translates to:
  /// **'Deload'**
  String get deloadWeekLabel;

  /// No description provided for @weekN.
  ///
  /// In en, this message translates to:
  /// **'Week {n}'**
  String weekN(int n);

  /// No description provided for @tapToAssign.
  ///
  /// In en, this message translates to:
  /// **'Tap to assign'**
  String get tapToAssign;

  /// No description provided for @routineRemoved.
  ///
  /// In en, this message translates to:
  /// **'Routine removed'**
  String get routineRemoved;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @labelRest.
  ///
  /// In en, this message translates to:
  /// **'Rest'**
  String get labelRest;

  /// No description provided for @labelCardio.
  ///
  /// In en, this message translates to:
  /// **'Cardio'**
  String get labelCardio;

  /// No description provided for @labelMobility.
  ///
  /// In en, this message translates to:
  /// **'Mobility'**
  String get labelMobility;

  /// No description provided for @labelStretch.
  ///
  /// In en, this message translates to:
  /// **'Stretching'**
  String get labelStretch;

  /// No description provided for @editDayTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit {day}'**
  String editDayTitle(String day);

  /// No description provided for @clear.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get clear;

  /// No description provided for @pickRoutineSection.
  ///
  /// In en, this message translates to:
  /// **'Pick a routine'**
  String get pickRoutineSection;

  /// No description provided for @pickLabelSection.
  ///
  /// In en, this message translates to:
  /// **'Or use a label'**
  String get pickLabelSection;

  /// No description provided for @customLabelSection.
  ///
  /// In en, this message translates to:
  /// **'Custom'**
  String get customLabelSection;

  /// No description provided for @customLabelHint.
  ///
  /// In en, this message translates to:
  /// **'Write your own label…'**
  String get customLabelHint;

  /// No description provided for @applyCustomLabel.
  ///
  /// In en, this message translates to:
  /// **'Use custom label'**
  String get applyCustomLabel;

  /// No description provided for @weekdayMon.
  ///
  /// In en, this message translates to:
  /// **'Monday'**
  String get weekdayMon;

  /// No description provided for @weekdayTue.
  ///
  /// In en, this message translates to:
  /// **'Tuesday'**
  String get weekdayTue;

  /// No description provided for @weekdayWed.
  ///
  /// In en, this message translates to:
  /// **'Wednesday'**
  String get weekdayWed;

  /// No description provided for @weekdayThu.
  ///
  /// In en, this message translates to:
  /// **'Thursday'**
  String get weekdayThu;

  /// No description provided for @weekdayFri.
  ///
  /// In en, this message translates to:
  /// **'Friday'**
  String get weekdayFri;

  /// No description provided for @weekdaySat.
  ///
  /// In en, this message translates to:
  /// **'Saturday'**
  String get weekdaySat;

  /// No description provided for @weekdaySun.
  ///
  /// In en, this message translates to:
  /// **'Sunday'**
  String get weekdaySun;

  /// No description provided for @weekdayMonShort.
  ///
  /// In en, this message translates to:
  /// **'MON'**
  String get weekdayMonShort;

  /// No description provided for @weekdayTueShort.
  ///
  /// In en, this message translates to:
  /// **'TUE'**
  String get weekdayTueShort;

  /// No description provided for @weekdayWedShort.
  ///
  /// In en, this message translates to:
  /// **'WED'**
  String get weekdayWedShort;

  /// No description provided for @weekdayThuShort.
  ///
  /// In en, this message translates to:
  /// **'THU'**
  String get weekdayThuShort;

  /// No description provided for @weekdayFriShort.
  ///
  /// In en, this message translates to:
  /// **'FRI'**
  String get weekdayFriShort;

  /// No description provided for @weekdaySatShort.
  ///
  /// In en, this message translates to:
  /// **'SAT'**
  String get weekdaySatShort;

  /// No description provided for @weekdaySunShort.
  ///
  /// In en, this message translates to:
  /// **'SUN'**
  String get weekdaySunShort;

  /// No description provided for @plannedBadge.
  ///
  /// In en, this message translates to:
  /// **'PLANNED'**
  String get plannedBadge;

  /// No description provided for @plannedDeloadBadge.
  ///
  /// In en, this message translates to:
  /// **'DELOAD'**
  String get plannedDeloadBadge;

  /// No description provided for @todayLabel.
  ///
  /// In en, this message translates to:
  /// **'TODAY'**
  String get todayLabel;

  /// No description provided for @restDayDescription.
  ///
  /// In en, this message translates to:
  /// **'Today\'s slot from your active program.'**
  String get restDayDescription;

  /// No description provided for @programsHelpTooltip.
  ///
  /// In en, this message translates to:
  /// **'How training plans work'**
  String get programsHelpTooltip;

  /// No description provided for @programsHelpTitle.
  ///
  /// In en, this message translates to:
  /// **'How training plans work'**
  String get programsHelpTitle;

  /// No description provided for @programsHelpIntroTitle.
  ///
  /// In en, this message translates to:
  /// **'What is a training plan?'**
  String get programsHelpIntroTitle;

  /// No description provided for @programsHelpIntroBody.
  ///
  /// In en, this message translates to:
  /// **'A multi-week schedule that assigns a routine or a rest day to each weekday. Useful for periodization like Push/Pull/Legs or 5-day splits.'**
  String get programsHelpIntroBody;

  /// No description provided for @programsHelpSlotsTitle.
  ///
  /// In en, this message translates to:
  /// **'Days are slots'**
  String get programsHelpSlotsTitle;

  /// No description provided for @programsHelpSlotsBody.
  ///
  /// In en, this message translates to:
  /// **'Each day can be a routine (your workout), a rest day, or a custom label like Cardio, Mobility, or anything you want.'**
  String get programsHelpSlotsBody;

  /// No description provided for @programsHelpDeloadTitle.
  ///
  /// In en, this message translates to:
  /// **'Deload weeks'**
  String get programsHelpDeloadTitle;

  /// No description provided for @programsHelpDeloadBody.
  ///
  /// In en, this message translates to:
  /// **'Mark a whole week as deload (lighter intensity) for recovery. The home will show a DELOAD badge so you remember to ease off.'**
  String get programsHelpDeloadBody;

  /// No description provided for @programsHelpActivateTitle.
  ///
  /// In en, this message translates to:
  /// **'Activating a plan'**
  String get programsHelpActivateTitle;

  /// No description provided for @programsHelpActivateBody.
  ///
  /// In en, this message translates to:
  /// **'Pick a start date, usually a Monday. When the last week ends, the plan loops back to week 1 automatically.'**
  String get programsHelpActivateBody;

  /// No description provided for @programsHelpBadgesTitle.
  ///
  /// In en, this message translates to:
  /// **'What you\'ll see on Home'**
  String get programsHelpBadgesTitle;

  /// No description provided for @programsHelpBadgesBody.
  ///
  /// In en, this message translates to:
  /// **'When today has a planned routine, the home card shows a PLANNED badge. Deload weeks show DELOAD. The card still works the same. Tap Start to begin.'**
  String get programsHelpBadgesBody;

  /// No description provided for @programsHelpOptionalTitle.
  ///
  /// In en, this message translates to:
  /// **'100% optional'**
  String get programsHelpOptionalTitle;

  /// No description provided for @programsHelpOptionalBody.
  ///
  /// In en, this message translates to:
  /// **'If you ignore plans, the app behaves exactly as before. Plans are an extra you can turn on or off any time without losing routines or history.'**
  String get programsHelpOptionalBody;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @recapTitle.
  ///
  /// In en, this message translates to:
  /// **'Your month in lifting'**
  String get recapTitle;

  /// No description provided for @recapIntroSubtitle.
  ///
  /// In en, this message translates to:
  /// **'A look back at what you trained.'**
  String get recapIntroSubtitle;

  /// No description provided for @recapSessionsTitle.
  ///
  /// In en, this message translates to:
  /// **'You showed up'**
  String get recapSessionsTitle;

  /// No description provided for @recapSessionsBody.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{# workout} other{# workouts}}'**
  String recapSessionsBody(int count);

  /// No description provided for @recapVolumeTitle.
  ///
  /// In en, this message translates to:
  /// **'You moved'**
  String get recapVolumeTitle;

  /// No description provided for @recapVolumeDeltaUp.
  ///
  /// In en, this message translates to:
  /// **'{pct}% more than {month}'**
  String recapVolumeDeltaUp(int pct, String month);

  /// No description provided for @recapVolumeDeltaDown.
  ///
  /// In en, this message translates to:
  /// **'{pct}% less than {month}'**
  String recapVolumeDeltaDown(int pct, String month);

  /// No description provided for @recapVolumeDeltaSame.
  ///
  /// In en, this message translates to:
  /// **'About the same as {month}'**
  String recapVolumeDeltaSame(String month);

  /// No description provided for @recapTopRoutineTitle.
  ///
  /// In en, this message translates to:
  /// **'Your go-to'**
  String get recapTopRoutineTitle;

  /// No description provided for @recapTopRoutineBody.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{# session} other{# sessions}}'**
  String recapTopRoutineBody(int count);

  /// No description provided for @recapTopExerciseTitle.
  ///
  /// In en, this message translates to:
  /// **'Star of the show'**
  String get recapTopExerciseTitle;

  /// No description provided for @recapTopExerciseBody.
  ///
  /// In en, this message translates to:
  /// **'{sets, plural, one{# set} other{# sets}} · {volume}'**
  String recapTopExerciseBody(int sets, String volume);

  /// No description provided for @recapPRTitle.
  ///
  /// In en, this message translates to:
  /// **'New record!'**
  String get recapPRTitle;

  /// No description provided for @recapPRBody.
  ///
  /// In en, this message translates to:
  /// **'on {exercise}'**
  String recapPRBody(String exercise);

  /// No description provided for @recapOutroTitle.
  ///
  /// In en, this message translates to:
  /// **'See you next month'**
  String get recapOutroTitle;

  /// No description provided for @recapOutroBody.
  ///
  /// In en, this message translates to:
  /// **'Keep showing up.'**
  String get recapOutroBody;

  /// No description provided for @recapBalanceTitle.
  ///
  /// In en, this message translates to:
  /// **'Movement balance'**
  String get recapBalanceTitle;

  /// No description provided for @recapBalanceBody.
  ///
  /// In en, this message translates to:
  /// **'How you split your work this month.'**
  String get recapBalanceBody;

  /// No description provided for @deloadBannerTitle.
  ///
  /// In en, this message translates to:
  /// **'Time for a deload?'**
  String get deloadBannerTitle;

  /// No description provided for @deloadBannerBodyStagnation.
  ///
  /// In en, this message translates to:
  /// **'Several lifts haven\'t progressed in 3+ weeks.'**
  String get deloadBannerBodyStagnation;

  /// No description provided for @deloadBannerBodyVolume.
  ///
  /// In en, this message translates to:
  /// **'Your weekly volume has dropped recently.'**
  String get deloadBannerBodyVolume;

  /// No description provided for @deloadBannerBodyBoth.
  ///
  /// In en, this message translates to:
  /// **'Progress has stalled and volume is down. A lighter week could help.'**
  String get deloadBannerBodyBoth;

  /// No description provided for @deloadBannerCta.
  ///
  /// In en, this message translates to:
  /// **'Open program'**
  String get deloadBannerCta;

  /// No description provided for @deloadBannerDismiss.
  ///
  /// In en, this message translates to:
  /// **'Not now'**
  String get deloadBannerDismiss;

  /// No description provided for @categoryAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get categoryAll;

  /// No description provided for @categoryPush.
  ///
  /// In en, this message translates to:
  /// **'Push'**
  String get categoryPush;

  /// No description provided for @categoryPull.
  ///
  /// In en, this message translates to:
  /// **'Pull'**
  String get categoryPull;

  /// No description provided for @categoryLegs.
  ///
  /// In en, this message translates to:
  /// **'Legs'**
  String get categoryLegs;

  /// No description provided for @categoryOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get categoryOther;

  /// No description provided for @recapEntryCardTitle.
  ///
  /// In en, this message translates to:
  /// **'{month} recap'**
  String recapEntryCardTitle(String month);

  /// No description provided for @recapEntryCardSubtitle.
  ///
  /// In en, this message translates to:
  /// **'{count} sessions · {volume}'**
  String recapEntryCardSubtitle(int count, String volume);

  /// No description provided for @recapPastRecaps.
  ///
  /// In en, this message translates to:
  /// **'Past recaps'**
  String get recapPastRecaps;

  /// No description provided for @recapPastRecapsEmpty.
  ///
  /// In en, this message translates to:
  /// **'No past recaps yet'**
  String get recapPastRecapsEmpty;

  /// No description provided for @recapPastRecapsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Look back at any closed month'**
  String get recapPastRecapsSubtitle;

  /// No description provided for @recapBannerCta.
  ///
  /// In en, this message translates to:
  /// **'View'**
  String get recapBannerCta;

  /// No description provided for @share.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get share;

  /// No description provided for @shareWorkout.
  ///
  /// In en, this message translates to:
  /// **'Share workout'**
  String get shareWorkout;

  /// No description provided for @sharePreviewSubtitle.
  ///
  /// In en, this message translates to:
  /// **'A square card you can post anywhere'**
  String get sharePreviewSubtitle;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'es'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
