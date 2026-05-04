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
