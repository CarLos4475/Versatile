import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:versatile/l10n/app_localizations.dart';
import '../../../core/navigation/app_page_transitions.dart';
import '../../../core/providers/repository_providers.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/coachmark_overlay.dart';
import '../../../shared/widgets/motion.dart';
import '../../programs/screens/program_editor_screen.dart';
import '../../programs/view_models/programs_view_model.dart';
import '../../recap/screens/monthly_recap_screen.dart';
import '../../recap/view_models/recap_view_model.dart';
import 'dart:io';
import '../../../core/providers/editorial_photos_provider.dart';
import '../view_models/deload_view_model.dart';
import '../view_models/home_view_model.dart';
import '../../active_workout/screens/active_workout_screen.dart';
import '../../history/screens/session_detail_screen.dart';
import '../../routines/screens/create_routine_screen.dart';
import '../../settings/screens/settings_screen.dart';
import '../../../core/utils/format_utils.dart';
import '../../../core/utils/l10n_utils.dart';
import '../../../domain/entities/exercise.dart';
import '../../../domain/entities/session.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final _heroCardKey = GlobalKey();
  bool _coachmarkChecked = false;
  bool _pendingHistoryCoachmark = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkCoachmark();
    });
  }

  Future<void> _checkCoachmark() async {
    if (!mounted || _coachmarkChecked) return;
    _coachmarkChecked = true;
    final service = ref.read(coachmarkServiceProvider);
    final shouldShowHome = await service.shouldShow('home');
    if (!mounted) return;
    if (shouldShowHome) {
      final l10n = AppLocalizations.of(context)!;
      CoachmarkOverlay.show(
        context: context,
        targetKey: _heroCardKey,
        title: l10n.coachmarkHomeTitle,
        body: l10n.coachmarkHomeBody,
        gotItLabel: l10n.coachmarkGotIt,
        skipLabel: l10n.coachmarkSkipAll,
        onDone: () {
          service.markSeen('home');
          _checkRoutinesTabCoachmark();
        },
      );
    } else {
      _checkRoutinesTabCoachmark();
    }
  }

  Future<void> _checkRoutinesTabCoachmark() async {
    if (!mounted) return;
    final service = ref.read(coachmarkServiceProvider);
    final should = await service.shouldShow('tab_routines');
    if (!should || !mounted) return;
    final routinesKey = ref.read(routinesNavKeyProvider);
    if (routinesKey == null) return;
    final l10n = AppLocalizations.of(context)!;
    CoachmarkOverlay.show(
      context: context,
      targetKey: routinesKey,
      title: l10n.coachmarkTabRoutinesTitle,
      body: l10n.coachmarkTabRoutinesBody,
      gotItLabel: l10n.coachmarkGotIt,
      skipLabel: l10n.coachmarkSkipAll,
      onDone: () {
        service.markSeen('tab_routines');
        _checkExercisesTabCoachmark();
      },
    );
  }

  Future<void> _checkExercisesTabCoachmark() async {
    if (!mounted) return;
    final service = ref.read(coachmarkServiceProvider);
    final should = await service.shouldShow('tab_exercises');
    if (!should || !mounted) return;
    final exercisesKey = ref.read(exercisesNavKeyProvider);
    if (exercisesKey == null) return;
    final l10n = AppLocalizations.of(context)!;
    CoachmarkOverlay.show(
      context: context,
      targetKey: exercisesKey,
      title: l10n.coachmarkTabExercisesTitle,
      body: l10n.coachmarkTabExercisesBody,
      gotItLabel: l10n.coachmarkGotIt,
      skipLabel: l10n.coachmarkSkipAll,
      onDone: () => service.markSeen('tab_exercises'),
    );
  }

  Future<void> _checkTabHistoryCoachmark() async {
    if (!mounted) return;
    final service = ref.read(coachmarkServiceProvider);
    final should = await service.shouldShow('tab_history');
    if (!should || !mounted) return;
    if (ref.read(homeProvider).sessions.isEmpty) return;
    final historyKey = ref.read(historyNavKeyProvider);
    if (historyKey == null) return;
    final l10n = AppLocalizations.of(context)!;
    CoachmarkOverlay.show(
      context: context,
      targetKey: historyKey,
      title: l10n.coachmarkTabHistoryTitle,
      body: l10n.coachmarkTabHistoryBody,
      gotItLabel: l10n.coachmarkGotIt,
      skipLabel: l10n.coachmarkSkipAll,
      onDone: () => service.markSeen('tab_history'),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final state = ref.watch(homeProvider);
    final isCurrentRoute = ModalRoute.of(context)?.isCurrent ?? true;
    final isEs = Localizations.localeOf(context).languageCode == 'es';

    ref.listen<int>(
      homeProvider.select((s) => s.sessions.length),
      (previous, current) {
        if ((previous ?? 0) == 0 && current > 0) {
          _pendingHistoryCoachmark = true;
        }
      },
    );

    if (_pendingHistoryCoachmark && isCurrentRoute) {
      _pendingHistoryCoachmark = false;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _checkTabHistoryCoachmark();
      });
    }

    final now = DateTime.now();
    final nextRoutine = state.nextRoutine;
    final heroInfo = ref.watch(heroCardInfoProvider).value;
    final daysAgo = state.nextRoutineDaysAgo;

    String lastDoneText;
    if (daysAgo == null) {
      lastDoneText = l10n.neverDone;
    } else if (daysAgo == 0) {
      lastDoneText = l10n.doneToday;
    } else if (daysAgo == 1) {
      lastDoneText = l10n.doneYesterday;
    } else {
      lastDoneText = l10n.lastDoneDaysAgo(daysAgo);
    }

    final hasName = state.userName != 'there' && state.userName.isNotEmpty;
    final dateLabel = FormatUtils.date(
      now.toIso8601String().substring(0, 10),
      locale: Localizations.localeOf(context).languageCode,
    );

    final recapBanner = ref.watch(unseenLastRecapProvider).value;
    final deloadSuggestion = ref.watch(deloadSuggestionProvider);
    final editorialState = ref.watch(editorialPhotosProvider);

    return Scaffold(
      backgroundColor: context.colors.bgApp,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 96),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _HomeMagazineHeader(
                hello: l10n.hello,
                helloThere: l10n.helloThere,
                userName: state.userName,
                hasName: hasName,
                dateLabel: dateLabel,
                onSettings: () => Navigator.of(
                  context,
                ).push(AppRoute(page: const SettingsScreen())),
              ),
              const SizedBox(height: 24),
              const _GridDivider(),
              KeyedSubtree(
                key: _heroCardKey,
                child: state.todayLabel != null
                    ? _HomeLabelHeroBlock(
                        label: state.todayLabel!,
                        isDeload: state.isDeloadWeek,
                        isEs: isEs,
                      )
                    : state.isAutoRestDay
                        ? _HomeLabelHeroBlock(
                            label: l10n.labelRest,
                            isDeload: state.isDeloadWeek,
                            isEs: isEs,
                          )
                        : nextRoutine != null
                            ? _HomeHeroBlock(
                                routineId: nextRoutine.id,
                                routineName: nextRoutine.name,
                                exerciseCount: nextRoutine.exercises.length,
                                estimatedMin: nextRoutine.estimatedMinutes,
                                lastDoneText: lastDoneText,
                                mainExerciseId: heroInfo?.id,
                                mainExerciseName: heroInfo?.exerciseName,
                                mainPrKg: heroInfo?.pr,
                                plannedFromProgram: state.plannedFromProgram,
                                isDeload: state.isDeloadWeek,
                                isEs: isEs,
                              )
                            : _HomeEmptyHeroBlock(
                                onCreateRoutine: () => Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => const CreateRoutineScreen(),
                                  ),
                                ),
                                isEs: isEs,
                              ),
              ),
              if (recapBanner != null) ...[
                const _GridDivider(),
                _RecapBlock(monthKey: recapBanner),
              ],
              if (deloadSuggestion != null) ...[
                const _GridDivider(),
                _DeloadBlock(suggestion: deloadSuggestion),
              ],
              const _GridDivider(),
              _StatsRow(
                weekSessions: state.weekSessions,
                weekVolume: state.weekVolume,
                avgTimeMins: state.avgTimeMins,
                thisWeekLabel: l10n.thisWeek,
                sessionsLabel: l10n.sessions,
                volumeLabel: l10n.volume,
                avgTimeLabel: l10n.avgTime,
              ),
              if (editorialState.enabled)
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  child: _GridDivider(),
                )
              else
                const _GridDivider(),
              if (editorialState.enabled) ...[
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: _HomeMoodboardBlock(
                    imagePath: editorialState.moodboardPath,
                    quote: editorialState.moodboardQuote,
                    defaultQuote: l10n.editorialDefaultMoodboardQuote,
                    alignX: editorialState.moodboardAlignX,
                    alignY: editorialState.moodboardAlignY,
                    scale: editorialState.moodboardScale,
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  child: _GridDivider(),
                ),
              ],
              _ActivityBlock(
                workoutDays: state.workoutDays,
                sessionCount: state.sessions.length,
                activityLabel: l10n.activity,
                sessionsLastYearLabel: l10n.sessionsLastYear,
              ),
              if (state.sessions.isNotEmpty) ...[
                const _GridDivider(),
                _RecentSessionsBlock(
                  sessions: state.sessions,
                  recentLabel: l10n.recentSessions,
                  totalLabel: l10n.total,
                ),
              ],
              if (editorialState.enabled) ...[
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  child: _GridDivider(),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: _HomeBackCoverBlock(
                    imagePath: editorialState.backCoverPath,
                    quote: editorialState.backCoverQuote,
                    defaultQuote: l10n.editorialDefaultBackCoverQuote,
                    alignX: editorialState.backCoverAlignX,
                    alignY: editorialState.backCoverAlignY,
                    scale: editorialState.backCoverScale,
                  ),
                ),
              ],
              if (editorialState.enabled)
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  child: _GridDivider(),
                )
              else
                const _GridDivider(),
            ],
          ),
        ),
      ),
    );
  }
}

class _GridDivider extends StatelessWidget {
  const _GridDivider();
  @override
  Widget build(BuildContext context) {
    return Container(height: 0.6, color: context.colors.hairline);
  }
}

class _VGridDivider extends StatelessWidget {
  const _VGridDivider();
  @override
  Widget build(BuildContext context) {
    return Container(width: 0.6, color: context.colors.hairline);
  }
}

class _Eyebrow extends StatelessWidget {
  const _Eyebrow({required this.text, this.color, this.center = false});
  final String text;
  final Color? color;
  final bool center;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final c = color ?? colors.ink500;
    if (center) {
      return Text(
        text.toUpperCase(),
        textAlign: TextAlign.center,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w800,
          color: c,
          letterSpacing: 0.18,
        ),
      );
    }
    return Row(
      children: [
        Container(width: 22, height: 1, color: c.withValues(alpha: 0.55)),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text.toUpperCase(),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w800,
              color: c,
              letterSpacing: 0.18,
            ),
          ),
        ),
      ],
    );
  }
}

class _HomeMagazineHeader extends StatelessWidget {
  const _HomeMagazineHeader({
    required this.hello,
    required this.helloThere,
    required this.userName,
    required this.hasName,
    required this.dateLabel,
    required this.onSettings,
  });

  final String hello;
  final String helloThere;
  final String userName;
  final bool hasName;
  final String dateLabel;
  final VoidCallback onSettings;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final compact = MediaQuery.sizeOf(context).height < 780;
    final titleSize = compact ? 52.0 : 60.0;

    return FadeSlideIn(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(22, 8, 22, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 44,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 24,
                        height: 1,
                        color: colors.ink400.withValues(alpha: 0.55),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        dateLabel.toUpperCase(),
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: colors.ink500,
                          letterSpacing: 0.18,
                          fontFeatures: const [FontFeature.tabularFigures()],
                        ),
                      ),
                    ],
                  ),
                  PressableScale(
                    onTap: onSettings,
                    child: Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: colors.ink900.withValues(alpha: 0.04),
                        border: Border.all(
                          color: colors.hairline,
                          width: 0.6,
                        ),
                      ),
                      child: Icon(
                        Icons.settings_outlined,
                        color: colors.ink700,
                        size: 18,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 2),
            if (hasName)
              Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: '$hello,\n',
                      style: GoogleFonts.playfairDisplay(
                        fontSize: titleSize,
                        height: 0.92,
                        fontWeight: FontWeight.w500,
                        letterSpacing: -0.08,
                        color: colors.ink900,
                      ),
                    ),
                    TextSpan(
                      text: '$userName.',
                      style: TextStyle(
                        fontSize: titleSize,
                        height: 0.94,
                        fontWeight: FontWeight.w400,
                        fontStyle: FontStyle.italic,
                        letterSpacing: -0.05,
                        color: colors.accentLight,
                      ),
                    ),
                  ],
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              )
            else
              Text(
                helloThere,
                style: GoogleFonts.playfairDisplay(
                  fontSize: titleSize,
                  height: 0.92,
                  fontWeight: FontWeight.w500,
                  letterSpacing: -0.08,
                  color: colors.ink900,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _MagazineTitleSplit extends StatelessWidget {
  const _MagazineTitleSplit({
    required this.prefix,
    required this.accent,
    this.size = 40,
  });

  final String prefix;
  final String accent;
  final double size;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          prefix.trimRight(),
          textAlign: TextAlign.left,
          style: GoogleFonts.playfairDisplay(
            fontSize: size,
            height: 0.92,
            fontWeight: FontWeight.w500,
            letterSpacing: -0.08,
            color: colors.ink900,
          ),
        ),
        Text(
          accent,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: size,
            height: 0.94,
            fontWeight: FontWeight.w400,
            fontStyle: FontStyle.italic,
            letterSpacing: -0.045,
            color: colors.accentLight,
          ),
        ),
      ],
    );
  }
}

class _HomeHeroBlock extends StatelessWidget {
  const _HomeHeroBlock({
    required this.routineId,
    required this.routineName,
    required this.exerciseCount,
    required this.estimatedMin,
    required this.lastDoneText,
    this.mainExerciseId,
    this.mainExerciseName,
    this.mainPrKg,
    this.plannedFromProgram = false,
    this.isDeload = false,
    required this.isEs,
  });

  final String routineId;
  final String routineName;
  final int exerciseCount;
  final int estimatedMin;
  final String lastDoneText;
  final String? mainExerciseId;
  final String? mainExerciseName;
  final double? mainPrKg;
  final bool plannedFromProgram;
  final bool isDeload;
  final bool isEs;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = context.colors;
    String displayExName = mainExerciseName ?? '';
    if (mainExerciseId != null && !mainExerciseId!.startsWith('custom-')) {
      final dummy = Exercise(
        id: mainExerciseId!,
        name: mainExerciseName ?? '',
        muscle: '',
        equipment: '',
      );
      displayExName = dummy.getLocalizedName(context);
    }

    final eyebrowParts = <String>[
      l10n.todaysSession,
      '$exerciseCount ${l10n.exercisesLabel}',
      '~$estimatedMin min',
      if (plannedFromProgram)
        isDeload ? l10n.plannedDeloadBadge : l10n.plannedBadge,
    ];
    final todayPrefix = isEs ? 'Hoy —' : 'Today —';

    final hairlineStrong = colors.ink900.withValues(alpha: 0.35);

    return FadeSlideIn(
      delay: const Duration(milliseconds: 60),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: colors.bgFrame,
          border: Border(
            top: BorderSide(color: hairlineStrong, width: 0.8),
            bottom: BorderSide(color: hairlineStrong, width: 0.8),
          ),
        ),
        padding: const EdgeInsets.fromLTRB(22, 26, 22, 26),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _Eyebrow(text: eyebrowParts.join(' · '), center: true),
            const SizedBox(height: 16),
            _MagazineTitleSplit(
              prefix: todayPrefix,
              accent: '$routineName.',
              size: 44,
            ),
            const SizedBox(height: 12),
            Text(
              lastDoneText,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                color: colors.ink500,
                fontWeight: FontWeight.w500,
              ),
            ),
            if (mainExerciseName != null) ...[
              const SizedBox(height: 18),
              _HeroPrRow(name: displayExName, prKg: mainPrKg),
            ],
            const SizedBox(height: 22),
            PressableScale(
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => ActiveWorkoutScreen(routineId: routineId),
                ),
              ),
              child: Container(
                height: 52,
                decoration: BoxDecoration(
                  color: colors.accent,
                  border: Border.all(
                    color: colors.accentDeep.withValues(alpha: 0.6),
                    width: 0.6,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.play_arrow, color: Colors.white, size: 16),
                    const SizedBox(width: 8),
                    Text(
                      l10n.startWorkout.toUpperCase(),
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HeroPrRow extends StatelessWidget {
  const _HeroPrRow({required this.name, this.prKg});

  final String name;
  final double? prKg;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = context.colors;
    final prStr = prKg == null
        ? l10n.noRecordYet
        : prKg! % 1 == 0
            ? '${prKg!.toInt()} kg'
            : '${prKg!.toStringAsFixed(1)} kg';

    return Row(
      children: [
        Text(
          'PR',
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w800,
            color: colors.ink500,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(width: 10),
        Container(width: 1, height: 12, color: colors.hairline),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            name,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 13,
              color: colors.ink700,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          prStr,
          style: TextStyle(
            fontSize: 13,
            fontWeight: prKg != null ? FontWeight.w700 : FontWeight.w400,
            color: prKg != null ? colors.ink900 : colors.ink500,
            fontFeatures: const [FontFeature.tabularFigures()],
          ),
        ),
      ],
    );
  }
}

class _HomeLabelHeroBlock extends StatelessWidget {
  const _HomeLabelHeroBlock({
    required this.label,
    required this.isDeload,
    required this.isEs,
  });

  final String label;
  final bool isDeload;
  final bool isEs;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = context.colors;
    final todayPrefix = isEs ? 'Hoy —' : 'Today —';
    final localizedLabel = localizeSlotLabel(context, label).toLowerCase();
    final eyebrowParts = <String>[
      l10n.todayLabel,
      if (isDeload) l10n.plannedDeloadBadge else l10n.plannedBadge,
    ];

    return FadeSlideIn(
      delay: const Duration(milliseconds: 60),
      child: Container(
        width: double.infinity,
        color: colors.bgFrame,
        padding: const EdgeInsets.fromLTRB(22, 30, 22, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _Eyebrow(text: eyebrowParts.join(' · '), center: true),
            const SizedBox(height: 16),
            _MagazineTitleSplit(
              prefix: todayPrefix,
              accent: '$localizedLabel.',
              size: 44,
            ),
            const SizedBox(height: 12),
            Text(
              l10n.restDayDescription,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: colors.ink500,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HomeEmptyHeroBlock extends StatelessWidget {
  const _HomeEmptyHeroBlock({
    required this.onCreateRoutine,
    required this.isEs,
  });

  final VoidCallback onCreateRoutine;
  final bool isEs;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = context.colors;
    final prefix = isEs ? 'Crea —' : 'Create —';
    final accent = isEs ? 'tu primera rutina.' : 'your first routine.';

    return FadeSlideIn(
      delay: const Duration(milliseconds: 60),
      child: PressableScale(
        onTap: onCreateRoutine,
        child: Container(
          width: double.infinity,
          color: colors.bgFrame,
          padding: const EdgeInsets.fromLTRB(22, 28, 22, 30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _Eyebrow(text: l10n.noRoutinesYet, center: true),
              const SizedBox(height: 16),
              _MagazineTitleSplit(
                prefix: prefix,
                accent: accent,
                size: 40,
              ),
              const SizedBox(height: 22),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.add,
                    size: 14,
                    color: colors.accentDeep,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    l10n.createRoutine.toUpperCase(),
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: colors.accentDeep,
                      letterSpacing: 1.2,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatsRow extends StatelessWidget {
  const _StatsRow({
    required this.weekSessions,
    required this.weekVolume,
    required this.avgTimeMins,
    required this.thisWeekLabel,
    required this.sessionsLabel,
    required this.volumeLabel,
    required this.avgTimeLabel,
  });

  final int weekSessions;
  final double weekVolume;
  final int avgTimeMins;
  final String thisWeekLabel;
  final String sessionsLabel;
  final String volumeLabel;
  final String avgTimeLabel;

  @override
  Widget build(BuildContext context) {
    final volStr = weekVolume >= 1000
        ? (weekVolume / 1000).toStringAsFixed(1)
        : weekVolume.toStringAsFixed(0);
    final volUnit = weekVolume >= 1000 ? 'k kg' : 'kg';

    return FadeSlideIn(
      delay: const Duration(milliseconds: 120),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: _StatCell(
                label: thisWeekLabel,
                value: weekSessions.toString(),
                unit: sessionsLabel,
              ),
            ),
            const _VGridDivider(),
            Expanded(
              child: _StatCell(
                label: volumeLabel,
                value: volStr,
                unit: volUnit,
              ),
            ),
            const _VGridDivider(),
            Expanded(
              child: _StatCell(
                label: avgTimeLabel,
                value: '$avgTimeMins',
                unit: 'min',
                accent: true,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatCell extends StatelessWidget {
  const _StatCell({
    required this.label,
    required this.value,
    required this.unit,
    this.accent = false,
  });

  final String label;
  final String value;
  final String unit;
  final bool accent;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return ClipRect(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
          Flexible(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: value,
                      style: GoogleFonts.playfairDisplay(
                        fontSize: 26,
                        fontWeight: FontWeight.w500,
                        height: 1.0,
                        letterSpacing: -0.4,
                        color: accent ? colors.accentDeep : colors.ink900,
                      ),
                    ),
                    TextSpan(
                      text: ' $unit',
                      style: GoogleFonts.playfairDisplay(
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        fontStyle: FontStyle.italic,
                        color: colors.ink400,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 5),
          Text(
            label.toUpperCase(),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 8.5,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.4,
              color: colors.ink500,
            ),
          ),
        ],
      ),
      ),
    );
  }
}

class _ActivityBlock extends StatelessWidget {
  const _ActivityBlock({
    required this.workoutDays,
    required this.sessionCount,
    required this.activityLabel,
    required this.sessionsLastYearLabel,
  });

  final Set<String> workoutDays;
  final int sessionCount;
  final String activityLabel;
  final String sessionsLastYearLabel;

  static const double _cell = 10;
  static const double _gap = 2;
  static const double _slot = _cell + _gap;

  String _fmt(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final currentMonday = today.subtract(Duration(days: today.weekday - 1));
    final colors = context.colors;
    final locale = Localizations.localeOf(context).languageCode;
    final months = List.generate(12, (i) {
      final m = DateFormat.MMM(locale).format(DateTime(2024, i + 1));
      return '${m[0].toUpperCase()}${m.substring(1)}';
    });
    final dayLabels = List.generate(7, (i) {
      final d = DateFormat.E(locale).format(DateTime(2024, 1, i + 1));
      return '${d[0].toUpperCase()}${d.substring(1)}';
    });

    return FadeSlideIn(
      delay: const Duration(milliseconds: 180),
      child: LayoutBuilder(
        builder: (context, constraints) {
          const horizontalPad = 22.0;
          const dayLabelWidth = 22.0;
          const labelGap = 2.0;
          final weeksAreaWidth = constraints.maxWidth -
              (horizontalPad * 2) -
              dayLabelWidth -
              labelGap;
          final numWeeks = (weeksAreaWidth / _slot).floor().clamp(4, 26);

          final gridStart = currentMonday.subtract(
            Duration(days: 7 * (numWeeks - 1)),
          );
          final weeks = List.generate(
            numWeeks,
            (w) => gridStart.add(Duration(days: 7 * w)),
          );

          return Padding(
            padding: const EdgeInsets.fromLTRB(horizontalPad, 18, horizontalPad, 22),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _Eyebrow(
                  text:
                      '$activityLabel · $sessionCount $sessionsLastYearLabel',
                ),
                const SizedBox(height: 14),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: dayLabelWidth,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: _slot + 2),
                          ...dayLabels.map(
                            (label) => SizedBox(
                              height: _slot,
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  label,
                                  style: TextStyle(
                                    fontSize: 8,
                                    color: colors.ink400,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: labelGap),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: weeks.asMap().entries.map((entry) {
                        final w = entry.key;
                        final monday = entry.value;
                        final showMonth =
                            w == 0 || monday.month != weeks[w - 1].month;

                        return SizedBox(
                          width: _slot,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(
                                height: _slot,
                                child: showMonth
                                    ? Text(
                                        months[monday.month - 1],
                                        style: TextStyle(
                                          fontSize: 7,
                                          color: colors.ink400,
                                          fontWeight: FontWeight.w500,
                                        ),
                                        overflow: TextOverflow.visible,
                                        softWrap: false,
                                      )
                                    : null,
                              ),
                              const SizedBox(height: 2),
                              ...List.generate(7, (d) {
                                final day = monday.add(Duration(days: d));
                                final isFuture = day.isAfter(today);
                                final trained = !isFuture &&
                                    workoutDays.contains(_fmt(day));
                                return Container(
                                  width: _cell,
                                  height: _cell,
                                  margin: const EdgeInsets.only(bottom: _gap),
                                  decoration: BoxDecoration(
                                    color: isFuture
                                        ? Colors.transparent
                                        : trained
                                            ? colors.accentDeep
                                            : colors.ink900
                                                .withValues(alpha: 0.06),
                                    border: isFuture
                                        ? null
                                        : Border.all(
                                            color: trained
                                                ? Colors.transparent
                                                : colors.ink900
                                                    .withValues(alpha: 0.08),
                                            width: 0.5,
                                          ),
                                  ),
                                );
                              }),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _RecentSessionsBlock extends StatelessWidget {
  const _RecentSessionsBlock({
    required this.sessions,
    required this.recentLabel,
    required this.totalLabel,
  });

  final List<Session> sessions;
  final String recentLabel;
  final String totalLabel;

  @override
  Widget build(BuildContext context) {
    final recent = sessions.take(4).toList();
    return FadeSlideIn(
      delay: const Duration(milliseconds: 220),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(22, 18, 22, 14),
            child: _Eyebrow(
              text: '$recentLabel · ${sessions.length} $totalLabel',
            ),
          ),
          for (var i = 0; i < recent.length; i++) ...[
            const _GridDivider(),
            _HomeSessionRow(session: recent[i]),
          ],
        ],
      ),
    );
  }
}

class _HomeSessionRow extends StatelessWidget {
  const _HomeSessionRow({required this.session});

  final Session session;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final locale = Localizations.localeOf(context).languageCode;
    final routineColor = Color(session.colorValue);
    return PressableScale(
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => SessionDetailScreen(session: session),
        ),
      ),
      child: Container(
        padding: const EdgeInsets.fromLTRB(22, 14, 22, 14),
        child: Row(
          children: [
            Container(
              width: 26,
              height: 26,
              alignment: Alignment.center,
              color: routineColor,
              child: Icon(
                IconData(session.iconCode, fontFamily: 'MaterialIcons'),
                color: Colors.white,
                size: 14,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    session.routineName,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 17,
                      fontWeight: FontWeight.w500,
                      fontStyle: FontStyle.italic,
                      letterSpacing: -0.2,
                      color: colors.ink900,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    '${FormatUtils.duration(session.durationMin)}  ·  ${FormatUtils.volume(session.volumeKg)} kg',
                    style: TextStyle(
                      fontSize: 11,
                      color: colors.ink500,
                      fontWeight: FontWeight.w500,
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Text(
              FormatUtils.date(session.date, locale: locale),
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.4,
                color: colors.ink400,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DeloadBlock extends ConsumerWidget {
  const _DeloadBlock({required this.suggestion});
  final DeloadSuggestion suggestion;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final colors = context.colors;

    final String body;
    if (suggestion.stagnation && suggestion.volumeDrop) {
      body = l10n.deloadBannerBodyBoth;
    } else if (suggestion.stagnation) {
      body = l10n.deloadBannerBodyStagnation;
    } else {
      body = l10n.deloadBannerBodyVolume;
    }

    final active = ref.watch(activeProgramProvider).value;

    Future<void> dismiss() async {
      final today = DateTime.now();
      final until = DateTime(today.year, today.month, today.day)
          .add(const Duration(days: 7));
      await ref.read(settingsRepositoryProvider).setDeloadDismissedUntil(until);
      ref.invalidate(deloadDismissedProvider);
    }

    void openProgram() {
      if (active == null) return;
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => ProgramEditorScreen(programId: active.id),
        ),
      );
    }

    return FadeSlideIn(
      delay: const Duration(milliseconds: 90),
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
        decoration: BoxDecoration(
          color: colors.accent,
          border: Border.all(
            color: colors.accentDeep.withValues(alpha: 0.6),
            width: 0.6,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.deloadBannerTitle,
              style: GoogleFonts.playfairDisplay(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.white,
                height: 1.1,
                letterSpacing: -0.4,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              body,
              style: TextStyle(
                fontSize: 13,
                color: Colors.white.withValues(alpha: 0.85),
                height: 1.4,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                PressableScale(
                  onTap: dismiss,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 8,
                    ),
                      child: Text(
                        l10n.deloadBannerDismiss.toUpperCase(),
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: Colors.white.withValues(alpha: 0.75),
                          letterSpacing: 1.2,
                        ),
                      ),
                    ),
                  ),
                  if (active != null) ...[
                    const SizedBox(width: 14),
                    PressableScale(
                      onTap: openProgram,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                        decoration: const BoxDecoration(
                          color: Colors.white,
                        ),
                      child: Text(
                        l10n.deloadBannerCta.toUpperCase(),
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: colors.accent,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _RecapBlock extends ConsumerWidget {
  const _RecapBlock({required this.monthKey});
  final MonthKey monthKey;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final colors = context.colors;
    final recap = ref.watch(monthlyRecapProvider(monthKey));
    if (recap == null) return const SizedBox.shrink();

    final monthLabel = FormatUtils.monthYear(
      '${monthKey.year.toString().padLeft(4, '0')}-'
      '${monthKey.month.toString().padLeft(2, '0')}-01',
    );

    return FadeSlideIn(
      delay: const Duration(milliseconds: 80),
      child: PressableScale(
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => MonthlyRecapScreen(monthKey: monthKey),
          ),
        ),
        child: Container(
          width: double.infinity,
          color: const Color(0xFF0E0B07),
          padding: const EdgeInsets.fromLTRB(22, 20, 22, 22),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _Eyebrow(
                      text: l10n.recapHomeBannerEyebrow(monthLabel),
                      color: colors.accentLight,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      l10n.recapHomeBannerTitle(
                        recap.sessionsCount,
                        '${FormatUtils.volume(recap.totalVolumeKg)} kg',
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFFF5EFE2),
                        letterSpacing: -0.3,
                        height: 1.25,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              const Icon(
                Icons.chevron_right_rounded,
                size: 22,
                color: Color(0xFFF5EFE2),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HomeMoodboardBlock extends StatelessWidget {
  const _HomeMoodboardBlock({
    required this.imagePath,
    required this.quote,
    required this.defaultQuote,
    required this.alignX,
    required this.alignY,
    required this.scale,
  });

  final String? imagePath;
  final String quote;
  final String defaultQuote;
  final double alignX;
  final double alignY;
  final double scale;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final fileExists = imagePath != null && File(imagePath!).existsSync();
    final displayQuote = quote.trim().isEmpty ? defaultQuote : quote;
    final isEs = Localizations.localeOf(context).languageCode == 'es';
    final techTag = isEs ? 'VOL. 1 / EDITORIAL' : 'VOL. 1 / EDITORIAL';

    return Container(
      height: 180,
      width: double.infinity,
      color: colors.bgFrame,
      child: Row(
        children: [
          Expanded(
            flex: 4,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    techTag,
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w800,
                      color: colors.ink400,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Expanded(
                    child: Center(
                      child: Text(
                        displayQuote,
                        style: GoogleFonts.playfairDisplay(
                          fontSize: 15,
                          fontWeight: FontWeight.w400,
                          fontStyle: FontStyle.italic,
                          height: 1.15,
                          letterSpacing: -0.05,
                          color: colors.ink900,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 5,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const _VGridDivider(),
          Expanded(
            flex: 6,
            child: PressableScale(
              onTap: () {
                Navigator.of(context).push(
                  AppRoute(page: const SettingsScreen()),
                );
              },
              child: SizedBox.expand(
                child: fileExists
                    ? ClipRect(
                        child: Transform.scale(
                          scale: scale,
                          alignment: Alignment(alignX, alignY),
                          child: Image.file(
                            File(imagePath!),
                            fit: BoxFit.cover,
                            alignment: Alignment(alignX, alignY),
                          ),
                        ),
                      )
                    : Container(
                        color: colors.ink900.withValues(alpha: 0.04),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.add_photo_alternate_outlined,
                              size: 24,
                              color: colors.ink400,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              AppLocalizations.of(context)!.editorialNoImage.toUpperCase(),
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.w800,
                                color: colors.ink500,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HomeBackCoverBlock extends StatelessWidget {
  const _HomeBackCoverBlock({
    required this.imagePath,
    required this.quote,
    required this.defaultQuote,
    required this.alignX,
    required this.alignY,
    required this.scale,
  });

  final String? imagePath;
  final String quote;
  final String defaultQuote;
  final double alignX;
  final double alignY;
  final double scale;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final fileExists = imagePath != null && File(imagePath!).existsSync();
    final displayQuote = quote.trim().isEmpty ? defaultQuote : quote;
    final isEs = Localizations.localeOf(context).languageCode == 'es';
    final techTag = isEs ? 'VOL. 1 / CONTRAPORTADA' : 'VOL. 1 / BACK COVER';

    return Container(
      color: colors.bgFrame,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          PressableScale(
            onTap: () {
              Navigator.of(context).push(
                AppRoute(page: const SettingsScreen()),
              );
            },
            child: SizedBox(
              height: 260,
              width: double.infinity,
              child: fileExists
                  ? ClipRect(
                      child: Transform.scale(
                        scale: scale,
                        alignment: Alignment(alignX, alignY),
                        child: Image.file(
                          File(imagePath!),
                          fit: BoxFit.cover,
                          alignment: Alignment(alignX, alignY),
                        ),
                      ),
                    )
                  : Container(
                      color: colors.ink900.withValues(alpha: 0.04),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.add_photo_alternate_outlined,
                            size: 32,
                            color: colors.ink400,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            AppLocalizations.of(context)!.editorialNoImage.toUpperCase(),
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              color: colors.ink500,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
            ),
          ),
          const _GridDivider(),
          Padding(
            padding: const EdgeInsets.fromLTRB(22, 12, 22, 14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  techTag,
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w800,
                    color: colors.ink400,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    displayQuote,
                    textAlign: TextAlign.right,
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 13,
                      fontWeight: FontWeight.w400,
                      fontStyle: FontStyle.italic,
                      height: 1.1,
                      color: colors.ink900,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
