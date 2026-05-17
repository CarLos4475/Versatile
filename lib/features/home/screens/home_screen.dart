import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:versatile/l10n/app_localizations.dart';
import '../../../core/navigation/app_page_transitions.dart';
import '../../../core/providers/repository_providers.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/coachmark_overlay.dart';
import '../../../shared/widgets/glass_container.dart';
import '../../../shared/widgets/motion.dart';
import '../../../shared/widgets/screen_header.dart';
import '../view_models/home_view_model.dart';
import '../widgets/session_card.dart';
import '../widgets/stat_card.dart';
import '../../active_workout/screens/active_workout_screen.dart';
import '../../history/screens/session_detail_screen.dart';
import '../../routines/screens/create_routine_screen.dart';
import '../../settings/screens/settings_screen.dart';
import '../../../core/utils/format_utils.dart';
import '../../../core/utils/l10n_utils.dart';
import '../../../domain/entities/exercise.dart';

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

    // Subscribe to route changes so we rebuild when the home screen becomes
    // current again (e.g. after popping back from the workout completion screen).
    final isCurrentRoute = ModalRoute.of(context)?.isCurrent ?? true;

    ref.listen<int>(
      homeProvider.select((s) => s.sessions.length),
      (previous, current) {
        if ((previous ?? 0) == 0 && current > 0) {
          _pendingHistoryCoachmark = true;
        }
      },
    );

    // Show the history coachmark only once we're back on the home screen.
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

    final greeting = state.userName == 'there' || state.userName.isEmpty
        ? l10n.helloThere
        : '${l10n.hello}, ${state.userName}';

    return Scaffold(
      backgroundColor: context.colors.bgApp,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 96),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ScreenHeader(
                title: greeting,
                subtitle: FormatUtils.date(
                  now.toIso8601String().substring(0, 10),
                  locale: Localizations.localeOf(context).languageCode,
                ),
                titleStyle: TextStyle(
                  fontSize: 38,
                  fontWeight: FontWeight.w700,
                  color: context.colors.ink900,
                  letterSpacing: -0.76,
                  height: 1.05,
                ),
                trailing: PressableScale(
                  onTap: () => Navigator.of(
                    context,
                  ).push(AppRoute(page: const SettingsScreen())),
                  child: Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: context.colors.glassBg,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: context.colors.glassBorder,
                        width: 0.5,
                      ),
                      boxShadow: context.colors.glassShadow,
                    ),
                    child: Icon(
                      Icons.settings_outlined,
                      color: context.colors.ink700,
                      size: 20,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 22),
                child: FadeSlideIn(
                  delay: const Duration(milliseconds: 60),
                  child: KeyedSubtree(
                    key: _heroCardKey,
                    child: state.todayLabel != null
                        ? _LabelHeroCard(
                            label: state.todayLabel!,
                            isDeload: state.isDeloadWeek,
                          )
                        : state.isAutoRestDay
                        ? _LabelHeroCard(
                            label: l10n.labelRest,
                            isDeload: state.isDeloadWeek,
                          )
                        : nextRoutine != null
                            ? _HeroCard(
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
                              )
                            : _EmptyHeroCard(
                                onCreateRoutine: () => Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => const CreateRoutineScreen(),
                                  ),
                                ),
                              ),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 22),
                child: FadeSlideIn(
                  delay: const Duration(milliseconds: 120),
                  child: Row(
                    children: [
                      Expanded(
                        child: StatCard(
                          label: l10n.thisWeek,
                          value: state.weekSessions.toString(),
                          unit: l10n.sessions,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: StatCard(
                          label: l10n.volume,
                          value: state.weekVolume >= 1000
                              ? (state.weekVolume / 1000).toStringAsFixed(1)
                              : state.weekVolume.toStringAsFixed(0),
                          unit: state.weekVolume >= 1000 ? 'k kg' : 'kg',
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: StatCard(
                          label: l10n.avgTime,
                          value: '${state.avgTimeMins}',
                          unit: 'min',
                          accent: true,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 22),
                child: FadeSlideIn(
                  delay: const Duration(milliseconds: 180),
                  child: _ActivityGrid(
                    workoutDays: state.workoutDays,
                    sessionCount: state.sessions.length,
                  ),
                ),
              ),

              if (state.sessions.isNotEmpty) ...[
                const SizedBox(height: 24),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 22),
                  child: FadeSlideIn(
                    delay: const Duration(milliseconds: 220),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text(
                          l10n.recentSessions,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            letterSpacing: -0.18,
                            color: context.colors.ink900,
                          ),
                        ),
                        Text(
                          '${state.sessions.length} ${l10n.total}',
                          style: TextStyle(
                            fontSize: 13,
                            color: context.colors.ink400,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 22),
                  child: Column(
                    children: state.sessions
                        .take(4)
                        .map(
                          (s) => Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: SessionCard(
                              session: s,
                              onTap: () => Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) =>
                                      SessionDetailScreen(session: s),
                                ),
                              ),
                            ),
                          ),
                        )
                        .toList(),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _ActivityGrid extends StatelessWidget {
  const _ActivityGrid({required this.workoutDays, required this.sessionCount});

  final Set<String> workoutDays;
  final int sessionCount;

  static const _months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];
  static const _dayLabels = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
  static const int _numWeeks = 26;
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
    final l10n = AppLocalizations.of(context)!;

    return LayoutBuilder(
      builder: (context, constraints) {
        const overhead = 32.0 + 22.0 + 2.0;
        final weeksAreaWidth = constraints.maxWidth - overhead;
        final numWeeks = (weeksAreaWidth / _slot).floor().clamp(4, _numWeeks);

        final gridStart = currentMonday.subtract(
          Duration(days: 7 * (numWeeks - 1)),
        );
        final weeks = List.generate(
          numWeeks,
          (w) => gridStart.add(Duration(days: 7 * w)),
        );

        return GlassContainer(
          radius: 20,
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.activity,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.06,
                  color: context.colors.ink400,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                '$sessionCount ${l10n.sessionsLastYear}',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w400,
                  letterSpacing: -0.4,
                  color: context.colors.ink900,
                  height: 1.1,
                ),
              ),
              const SizedBox(height: 14),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 22,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: _slot + 2),
                        ..._dayLabels.map(
                          (label) => SizedBox(
                            height: _slot,
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                label,
                                style: TextStyle(
                                  fontSize: 8,
                                  color: context.colors.ink400,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 2),
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
                                      _months[monday.month - 1],
                                      style: TextStyle(
                                        fontSize: 7,
                                        color: context.colors.ink400,
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
                              final trained =
                                  !isFuture && workoutDays.contains(_fmt(day));
                              return Container(
                                width: _cell,
                                height: _cell,
                                margin: const EdgeInsets.only(bottom: _gap),
                                decoration: BoxDecoration(
                                  color: isFuture
                                      ? Colors.transparent
                                      : trained
                                      ? context.colors.accentDeep
                                      : const Color(0x0F000000),
                                  borderRadius: BorderRadius.circular(2),
                                  border: isFuture
                                      ? null
                                      : Border.all(
                                          color: trained
                                              ? Colors.transparent
                                              : const Color(0x14000000),
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
    );
  }
}

class _HeroCard extends StatelessWidget {
  const _HeroCard({
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

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
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

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [context.colors.accentLight, context.colors.accent, context.colors.accentDeep],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: context.colors.accentDeep.withValues(alpha: 0.35),
            blurRadius: 36,
            offset: const Offset(0, 18),
          ),
        ],
      ),
      padding: const EdgeInsets.all(22),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            right: -60,
            top: -60,
            child: Container(
              width: 280,
              height: 280,
              decoration: const BoxDecoration(
                gradient: RadialGradient(
                  colors: [
                    Color(0x55FFFFFF),
                    Color(0x22FFFFFF),
                    Color(0x00FFFFFF),
                  ],
                  stops: [0.0, 0.45, 1.0],
                ),
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    l10n.todaysSession,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.06,
                    ),
                  ),
                  if (plannedFromProgram) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 7,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.22),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        isDeload
                            ? l10n.plannedDeloadBadge
                            : l10n.plannedBadge,
                        style: const TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          letterSpacing: 0.08,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 10),
              Text(
                routineName,
                style: const TextStyle(
                  fontSize: 34,
                  color: Colors.white,
                  fontWeight: FontWeight.w400,
                  letterSpacing: -0.68,
                  height: 1.05,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '$exerciseCount ${l10n.exercisesLabel} · ~$estimatedMin min',
                style: const TextStyle(
                  fontSize: 13,
                  color: Colors.white,
                  fontWeight: FontWeight.w400,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                lastDoneText,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.white.withValues(alpha: 0.6),
                  fontWeight: FontWeight.w400,
                ),
              ),
              if (mainExerciseName != null) ...[
                const SizedBox(height: 14),
                _PrChip(exerciseName: displayExName, prKg: mainPrKg),
              ],
              const SizedBox(height: 16),
              PressableScale(
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => ActiveWorkoutScreen(routineId: routineId),
                  ),
                ),
                child: Container(
                  height: 50,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.3),
                      width: 0.5,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.play_arrow,
                        color: Colors.white,
                        size: 16,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        l10n.startWorkout,
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PrChip extends StatelessWidget {
  const _PrChip({required this.exerciseName, this.prKg});

  final String exerciseName;
  final double? prKg;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final prStr = prKg == null
        ? l10n.noRecordYet
        : prKg! % 1 == 0
        ? '${prKg!.toInt()} kg'
        : '${prKg!.toStringAsFixed(1)} kg';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.25),
          width: 0.5,
        ),
      ),
      child: Row(
        children: [
          Text(
            'PR',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: Colors.white.withValues(alpha: 0.6),
              letterSpacing: 0.5,
            ),
          ),
          Container(
            width: 1,
            height: 10,
            margin: const EdgeInsets.symmetric(horizontal: 8),
            color: Colors.white.withValues(alpha: 0.3),
          ),
          Expanded(
            child: Text(
              exerciseName,
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            prStr,
            style: TextStyle(
              fontSize: 13,
              fontWeight: prKg != null ? FontWeight.w700 : FontWeight.w400,
              color: prKg != null
                  ? Colors.white
                  : Colors.white.withValues(alpha: 0.6),
            ),
          ),
        ],
      ),
    );
  }
}

class _LabelHeroCard extends StatelessWidget {
  const _LabelHeroCard({required this.label, required this.isDeload});
  final String label;
  final bool isDeload;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      decoration: BoxDecoration(
        color: context.colors.glassBg,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: context.colors.glassBorder, width: 0.5),
        boxShadow: context.colors.glassShadow,
      ),
      padding: const EdgeInsets.all(22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: context.colors.accentTint,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  isDeload ? l10n.plannedDeloadBadge : l10n.plannedBadge,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.08,
                    color: context.colors.accentDeep,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                l10n.todayLabel,
                style: TextStyle(
                  fontSize: 12,
                  color: context.colors.ink400,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.06,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(
                Icons.spa_outlined,
                size: 28,
                color: isDark
                    ? context.colors.ink700
                    : context.colors.accentDeep,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  localizeSlotLabel(context, label),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.w400,
                    letterSpacing: -0.6,
                    height: 1.05,
                    color: context.colors.ink900,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            l10n.restDayDescription,
            style: TextStyle(
              fontSize: 13,
              color: context.colors.ink500,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyHeroCard extends StatelessWidget {
  const _EmptyHeroCard({required this.onCreateRoutine});
  final VoidCallback onCreateRoutine;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return PressableScale(
      onTap: onCreateRoutine,
      child: Container(
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          color: context.colors.glassBg,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: context.colors.glassBorder, width: 0.5),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.noRoutinesYet,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w500,
                color: context.colors.ink900,
                letterSpacing: -0.44,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              l10n.createFirstOne,
              style: TextStyle(fontSize: 14, color: context.colors.ink500),
            ),
            const SizedBox(height: 18),
            Row(
              children: [
                Icon(
                  Icons.add_circle_outline,
                  size: 16,
                  color: context.colors.accentDeep,
                ),
                const SizedBox(width: 6),
                Text(
                  l10n.createRoutine,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: context.colors.accentDeep,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
