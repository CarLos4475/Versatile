import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/workout_notification_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/format_utils.dart';
import '../../../shared/widgets/glass_button.dart';
import '../../../shared/widgets/glass_container.dart';
import '../../../shared/widgets/motion.dart';
import '../view_models/active_workout_view_model.dart';
import '../widgets/exercise_card.dart';
import '../widgets/rest_timer_bar.dart';

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
    final initAsync = ref.watch(workoutInitProvider(routineId));
    return initAsync.when(
      loading: () => const _LoadingScaffold(),
      error: (e, _) => Scaffold(
        backgroundColor: context.colors.bgApp,
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Could not load workout',
                style: TextStyle(color: context.colors.ink500),
              ),
              SizedBox(height: 12),
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text('Go back'),
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
  const _LoadingScaffold();

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
            SizedBox(height: 14),
            Text(
              'Preparing workout...',
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
      WorkoutNotificationService.start(
        startedAt: notifier.workoutStartedAt,
        routineId: widget.routineId,
      );
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  Future<void> _finish() async {
    if (_finishing) return;
    setState(() => _finishing = true);
    await WorkoutNotificationService.stop();
    final notifier = ref.read(activeWorkoutProvider(widget.routineId).notifier);
    await notifier.finishWorkout();
    if (mounted) {
      ref.read(activeWorkoutRoutineIdProvider.notifier).state = null;
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(activeWorkoutProvider(widget.routineId));
    final notifier = ref.read(activeWorkoutProvider(widget.routineId).notifier);

    return Scaffold(
      backgroundColor: context.colors.bgApp,
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                  child: GlassContainer(
                    strong: true,
                    radius: 22,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    child: Row(
                      children: [
                        PressableScale(
                          onTap: () => Navigator.of(context).pop(),
                          child: Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: context.colors.press,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              Icons.chevron_left,
                              size: 18,
                              color: context.colors.ink700,
                            ),
                          ),
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  _PulseDot(),
                                  SizedBox(width: 6),
                                  Text(
                                    'ACTIVE · ${state.routine.name.toUpperCase()}',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: 0.08,
                                      color: context.colors.accent,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 2),
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
                                      fontFeatures: [
                                        FontFeature.tabularFigures(),
                                      ],
                                    ),
                                  ),
                                  SizedBox(width: 12),
                                  Text(
                                    '${state.completedSets}/${state.totalSets} sets'
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
                              borderRadius: BorderRadius.circular(12),
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
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(2),
                    child: LinearProgressIndicator(
                      value: state.totalSets > 0
                          ? state.completedSets / state.totalSets
                          : 0,
                      backgroundColor: context.colors.hairline,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        context.colors.accent,
                      ),
                      minHeight: 3,
                    ),
                  ),
                ),
                SizedBox(height: 8),
                Expanded(
                  child: ListView(
                    padding: EdgeInsets.fromLTRB(
                      16,
                      0,
                      16,
                      state.restTimer != null ? 130 : 100,
                    ),
                    children: [
                      ...state.exerciseStates.asMap().entries.map((entry) {
                        final i = entry.key;
                        final e = entry.value;
                        final ex = state.findExercise(e.exerciseId);
                        if (ex == null) return SizedBox.shrink();
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: ExerciseCard(
                            index: i,
                            data: e,
                            exercise: ex,
                            prevSets: e.prevSets,
                            onToggle: () => notifier.toggleExpand(i),
                            onFinishSet: () => notifier.finishSet(i),
                            onWeightChanged: (kg) =>
                                notifier.updateWeight(i, kg),
                            onRepsChanged: (reps) =>
                                notifier.updateReps(i, reps),
                            onToggleSplit: e.isUnilateral
                                ? () => notifier.toggleSplitMode(i)
                                : null,
                            onLeftWeightChanged: (kg) =>
                                notifier.updateLeftWeight(i, kg),
                            onLeftRepsChanged: (reps) =>
                                notifier.updateLeftReps(i, reps),
                          ),
                        );
                      }),
                      GlassButton(
                        label: _finishing ? 'Saving…' : 'Finish workout',
                        variant: GlassButtonVariant.primary,
                        size: GlassButtonSize.md,
                        expand: true,
                        loading: _finishing,
                        onPressed: _finishing ? null : _finish,
                      ),
                    ],
                  ),
                ),
              ],
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
                    ? SizedBox.shrink(key: ValueKey('rest-hidden'))
                    : RestTimerBar(
                        key: const ValueKey('rest-visible'),
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
