import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:versatile/l10n/app_localizations.dart';
import '../../../core/providers/repository_providers.dart';
import '../../../core/services/workout_notification_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/coachmark_overlay.dart';
import '../../../core/utils/format_utils.dart';
import '../../../shared/widgets/motion.dart';
import '../view_models/active_workout_view_model.dart';
import '../widgets/exercise_card.dart';
import '../widgets/pr_celebration_banner.dart';
import '../widgets/rest_timer_bar.dart';
import 'workout_complete_screen.dart';

class ActiveWorkoutScreen extends ConsumerWidget {
  const ActiveWorkoutScreen({
    super.key,
    required this.routineId,
    this.restoredStartedAt,
    this.restoredProgressJson,
  });
  final String routineId;
  final DateTime? restoredStartedAt;
  final String? restoredProgressJson;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final initAsync = ref.watch(workoutInitProvider(routineId));
    return initAsync.when(
      loading: () => _LoadingScaffold(label: l10n.preparingWorkout),
      error: (e, _) => Scaffold(
        backgroundColor: context.colors.bgApp,
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                l10n.routineNotFound,
                style: TextStyle(color: context.colors.ink500),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(l10n.goBack),
              ),
            ],
          ),
        ),
      ),
      data: (_) => _WorkoutBody(
        routineId: routineId,
        restoredStartedAt: restoredStartedAt,
        restoredProgressJson: restoredProgressJson,
      ),
    );
  }
}

class _LoadingScaffold extends StatelessWidget {
  const _LoadingScaffold({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.bgApp,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(
              color: context.colors.accent,
              strokeWidth: 2,
            ),
            const SizedBox(height: 14),
            Text(
              label,
              style: TextStyle(fontSize: 14, color: context.colors.ink500),
            ),
          ],
        ),
      ),
    );
  }
}

class _WorkoutBody extends ConsumerStatefulWidget {
  const _WorkoutBody({
    required this.routineId,
    this.restoredStartedAt,
    this.restoredProgressJson,
  });
  final String routineId;
  final DateTime? restoredStartedAt;
  final String? restoredProgressJson;

  @override
  ConsumerState<_WorkoutBody> createState() => _WorkoutBodyState();
}

class _WorkoutBodyState extends ConsumerState<_WorkoutBody>
    with WidgetsBindingObserver {
  bool _finishing = false;
  bool _autoFinishTriggered = false;
  bool _restCoachmarkShown = false;
  final _restTimerKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(activeWorkoutRoutineIdProvider.notifier).state =
          widget.routineId;
      final notifier = ref.read(
        activeWorkoutProvider(widget.routineId).notifier,
      );
      if (widget.restoredStartedAt != null) {
        notifier.restoreStartTime(widget.restoredStartedAt!);
      }
      if (widget.restoredProgressJson != null) {
        notifier.restoreProgress(widget.restoredProgressJson!);
      }
      final activeRoutine = ref
          .read(activeWorkoutProvider(widget.routineId))
          .routine;
      WorkoutNotificationService.start(
        startedAt: notifier.workoutStartedAt,
        routineId: widget.routineId,
        routineName: activeRoutine.name,
        routineColor: activeRoutine.colorValue,
        subtitle: AppLocalizations.of(context)!.notificationSubtitle,
      );
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive ||
        state == AppLifecycleState.hidden) {
      if (mounted) {
        ref
            .read(activeWorkoutProvider(widget.routineId).notifier)
            .persistProgress();
      }
    }
  }

  Future<void> _finish() async {
    if (_finishing) return;
    setState(() => _finishing = true);
    await WorkoutNotificationService.stop();
    final notifier = ref.read(activeWorkoutProvider(widget.routineId).notifier);
    final cachedPRs = ref
        .read(activeWorkoutProvider(widget.routineId))
        .allPRsInSession;
    final session = await notifier.finishWorkout();
    if (!mounted) return;
    ref.read(activeWorkoutRoutineIdProvider.notifier).state = null;
    if (session != null) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) =>
              WorkoutCompleteScreen(session: session, precomputedPRs: cachedPRs),
        ),
      );
    } else {
      Navigator.of(context).pop();
    }
  }

  void _confirmDiscard(
    BuildContext context,
    WidgetRef ref,
    AppLocalizations l10n,
  ) {
    showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        scrollable: true,
        title: Text(l10n.discardWorkoutTitle),
        content: Text(l10n.discardWorkoutContent),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(
              l10n.discard,
              style: const TextStyle(color: Colors.redAccent),
            ),
          ),
        ],
      ),
    ).then((confirmed) async {
      if (confirmed != true || !mounted) return;
      ref
          .read(activeWorkoutProvider(widget.routineId).notifier)
          .cancelWorkout();
      await WorkoutNotificationService.stop();
      if (!mounted) return;
      ref.read(activeWorkoutRoutineIdProvider.notifier).state = null;
      if (mounted) Navigator.of(context).pop();
    });
  }

  void _confirmSkip(BuildContext context, int index, AppLocalizations l10n) {
    showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        scrollable: true,
        title: Text(l10n.skipExercise),
        content: Text(l10n.skipExerciseContent),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(l10n.skip),
          ),
        ],
      ),
    ).then((confirmed) {
      if (confirmed != true || !mounted) return;
      ref
          .read(activeWorkoutProvider(widget.routineId).notifier)
          .skipExercise(index);
    });
  }

  Future<void> _triggerRestTimerCoachmark() async {
    if (!mounted) return;
    final service = ref.read(coachmarkServiceProvider);
    final should = await service.shouldShow('rest_timer');
    if (!should || !mounted) return;
    if (_restTimerKey.currentContext?.findRenderObject() == null) return;
    final l10n = AppLocalizations.of(context)!;
    CoachmarkOverlay.show(
      context: context,
      targetKey: _restTimerKey,
      title: l10n.coachmarkRestTimerTitle,
      body: l10n.coachmarkRestTimerBody,
      gotItLabel: l10n.coachmarkGotIt,
      skipLabel: l10n.coachmarkSkipAll,
      onDone: () => service.markSeen('rest_timer'),
      onSkipAll: () => service.markSeen('rest_timer'),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final state = ref.watch(activeWorkoutProvider(widget.routineId));
    final notifier = ref.read(activeWorkoutProvider(widget.routineId).notifier);

    ref.listen(activeWorkoutProvider(widget.routineId), (prev, next) {
      if (!_restCoachmarkShown &&
          prev?.restTimer == null &&
          next.restTimer != null) {
        _restCoachmarkShown = true;
        Future.delayed(const Duration(milliseconds: 450), () {
          if (mounted) _triggerRestTimerCoachmark();
        });
      }
    });

    if (state.autoFinish && !_autoFinishTriggered && !_finishing) {
      _autoFinishTriggered = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Future.delayed(const Duration(milliseconds: 1500), () {
          if (mounted && !_finishing) {
            _finish();
          }
        });
      });
    }

    return Scaffold(
      backgroundColor: context.colors.bgApp,
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(22, 10, 22, 14),
                  child: Row(
                    children: [
                      PressableScale(
                        onTap: () => Navigator.of(context).pop(),
                        child: Container(
                          width: 36,
                          height: 36,
                          color: context.colors.accent,
                          child: const Icon(
                            Icons.chevron_left,
                            size: 18,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      PressableScale(
                        onTap: () => _confirmDiscard(context, ref, l10n),
                        child: Container(
                          width: 36,
                          height: 36,
                          color: context.colors.accent,
                          child: const Icon(
                            Icons.close_rounded,
                            size: 18,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                _PulseDot(),
                                const SizedBox(width: 6),
                                Text(
                                  '${l10n.active} · ${state.routine.name.toUpperCase()}',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 0.08,
                                    color: context.colors.accent,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 2),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.baseline,
                              textBaseline: TextBaseline.alphabetic,
                              children: [
                                Text(
                                  FormatUtils.timer(state.elapsedSeconds),
                                  style: TextStyle(
                                    fontSize: 26,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: -0.52,
                                    color: context.colors.ink900,
                                    height: 1,
                                    fontFeatures: const [
                                      FontFeature.tabularFigures(),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  '${state.completedSets}/${state.totalSets} ${l10n.sets}'
                                  ' · ${FormatUtils.volume(state.totalVolume)}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    color: context.colors.ink500,
                                  ),
                                ),
                              ],
                              ),
                            ],
                          ),
                        ),
                      PressableScale(
                        onTap: notifier.togglePause,
                        child: Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: context.colors.accentTint,
                            border: Border.all(
                              color: context.colors.accent.withValues(alpha: 0.4),
                              width: 0.6,
                            ),
                          ),
                          child: Icon(
                            state.isRunning
                                ? Icons.pause_rounded
                                : Icons.play_arrow_rounded,
                            size: 18,
                            color: context.colors.accentDeep,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                LinearProgressIndicator(
                  value: state.totalSets > 0
                      ? state.completedSets / state.totalSets
                      : 0,
                  backgroundColor: context.colors.hairline,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    context.colors.accent,
                  ),
                  minHeight: 2,
                ),
                Container(height: 0.5, color: context.colors.hairline),
                Expanded(
                  child: ListView(
                    padding: EdgeInsets.fromLTRB(
                      0,
                      0,
                      0,
                      state.restTimer != null ? 130 : 100,
                    ),
                    children: [
                      for (final entry
                          in state.exerciseStates.asMap().entries) ...[
                        if (state.findExercise(entry.value.exerciseId) != null)
                          ExerciseCard(
                            index: entry.key,
                            data: entry.value,
                            exercise:
                                state.findExercise(entry.value.exerciseId)!,
                            prevSets: entry.value.prevSets,
                            onToggle: () => notifier.toggleExpand(entry.key),
                            onFinishSet: () => notifier.finishSet(entry.key),
                            onWeightChanged: (kg) =>
                                notifier.updateWeight(entry.key, kg),
                            onRepsChanged: (reps) =>
                                notifier.updateReps(entry.key, reps),
                            onToggleSplit: entry.value.isUnilateral
                                ? () => notifier.toggleSplitMode(entry.key)
                                : null,
                            onLeftWeightChanged: (kg) =>
                                notifier.updateLeftWeight(entry.key, kg),
                            onLeftRepsChanged: (reps) =>
                                notifier.updateLeftReps(entry.key, reps),
                            onSkip: () =>
                                _confirmSkip(context, entry.key, l10n),
                          ),
                        Container(
                          height: 0.5,
                          color: context.colors.hairline,
                        ),
                      ],
                      const SizedBox(height: 22),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 22),
                        child: _MagazineFinishButton(
                          label: _finishing
                              ? l10n.saving
                              : l10n.finishWorkout,
                          loading: _finishing,
                          onPressed: _finishing ? null : _finish,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            Positioned(
              top: 80,
              left: 0,
              right: 0,
              child: PRCelebrationBanner(routineId: widget.routineId),
            ),
            Positioned(
              left: 12,
              right: 12,
              bottom: 14,
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 260),
                reverseDuration: const Duration(milliseconds: 200),
                transitionBuilder: (child, animation) => FadeTransition(
                  opacity: animation,
                  child: SlideTransition(
                    position:
                        Tween<Offset>(
                          begin: const Offset(0, 0.15),
                          end: Offset.zero,
                        ).animate(
                          CurvedAnimation(
                            parent: animation,
                            curve: Curves.easeOutCubic,
                          ),
                        ),
                    child: child,
                  ),
                ),
                child: state.restTimer == null
                    ? const SizedBox.shrink(key: ValueKey('rest-hidden'))
                    : RestTimerBar(
                        key: const ValueKey('rest-visible'),
                        barKey: _restTimerKey,
                        restTimer: state.restTimer!,
                        onSkip: notifier.skipRest,
                        onAddTime: () => notifier.addRestTime(15),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PulseDot extends StatefulWidget {
  const _PulseDot();
  @override
  State<_PulseDot> createState() => _PulseDotState();
}

class _PulseDotState extends State<_PulseDot>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      duration: const Duration(milliseconds: 1400),
      vsync: this,
    )..repeat(reverse: true);
    _anim = Tween<double>(
      begin: 1.0,
      end: 0.4,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _anim,
      child: Container(
        width: 6,
        height: 6,
        decoration: BoxDecoration(
          color: context.colors.accent,
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}

class _MagazineFinishButton extends StatelessWidget {
  const _MagazineFinishButton({
    required this.label,
    required this.loading,
    required this.onPressed,
  });

  final String label;
  final bool loading;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final enabled = onPressed != null;
    return PressableScale(
      onTap: enabled ? onPressed : () {},
      child: Container(
        width: double.infinity,
        height: 52,
        alignment: Alignment.center,
        color: enabled
            ? colors.accent
            : colors.accent.withValues(alpha: 0.4),
        child: loading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Text(
                label.toUpperCase(),
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.18,
                  color: Colors.white,
                ),
              ),
      ),
    );
  }
}
