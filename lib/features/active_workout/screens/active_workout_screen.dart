import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/format_utils.dart';
import '../../../shared/widgets/glass_button.dart';
import '../../../shared/widgets/glass_container.dart';
import '../view_models/active_workout_view_model.dart';
import '../widgets/exercise_card.dart';
import '../widgets/rest_timer_bar.dart';

class ActiveWorkoutScreen extends ConsumerWidget {
  const ActiveWorkoutScreen({super.key, required this.routineId});
  final String routineId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final initAsync = ref.watch(workoutInitProvider(routineId));
    return initAsync.when(
      loading: () => const _LoadingScaffold(),
      error: (e, _) => Scaffold(
        backgroundColor: AppColors.bgApp,
        body: Center(
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            const Text('Could not load workout',
                style: TextStyle(color: AppColors.ink500)),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Go back'),
            ),
          ]),
        ),
      ),
      data: (_) => _WorkoutBody(routineId: routineId),
    );
  }
}

class _LoadingScaffold extends StatelessWidget {
  const _LoadingScaffold();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: AppColors.bgApp,
      body: Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          CircularProgressIndicator(color: AppColors.accent, strokeWidth: 2),
          SizedBox(height: 14),
          Text('Getting ready…',
              style: TextStyle(fontSize: 14, color: AppColors.ink400)),
        ]),
      ),
    );
  }
}

class _WorkoutBody extends ConsumerStatefulWidget {
  const _WorkoutBody({required this.routineId});
  final String routineId;

  @override
  ConsumerState<_WorkoutBody> createState() => _WorkoutBodyState();
}

class _WorkoutBodyState extends ConsumerState<_WorkoutBody> {
  bool _finishing = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(activeWorkoutRoutineIdProvider.notifier).state =
          widget.routineId;
    });
  }

  Future<void> _finish() async {
    if (_finishing) return;
    setState(() => _finishing = true);
    final notifier =
        ref.read(activeWorkoutProvider(widget.routineId).notifier);
    await notifier.finishWorkout();
    if (mounted) {
      ref.read(activeWorkoutRoutineIdProvider.notifier).state = null;
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(activeWorkoutProvider(widget.routineId));
    final notifier =
        ref.read(activeWorkoutProvider(widget.routineId).notifier);

    return Scaffold(
      backgroundColor: AppColors.bgApp,
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
                        horizontal: 16, vertical: 14),
                    child: Row(
                      children: [
                        GestureDetector(
                          onTap: () => Navigator.of(context).pop(),
                          child: Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: const Color(0x0A000000),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(Icons.chevron_left,
                                size: 18, color: AppColors.ink700),
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
                                    'Active · ${state.routine.name}',
                                    style: const TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      letterSpacing: 0.06,
                                      color: AppColors.accentDeep,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 2),
                              Row(
                                crossAxisAlignment:
                                    CrossAxisAlignment.baseline,
                                textBaseline: TextBaseline.alphabetic,
                                children: [
                                  Text(
                                    FormatUtils.timer(state.elapsedSeconds),
                                    style: const TextStyle(
                                      fontSize: 26,
                                      fontWeight: FontWeight.w500,
                                      letterSpacing: -0.52,
                                      color: AppColors.ink900,
                                      height: 1,
                                      fontFeatures: [
                                        FontFeature.tabularFigures()
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    '${state.completedSets}/${state.totalSets} sets'
                                    ' · ${FormatUtils.volume(state.totalVolume)}',
                                    style: const TextStyle(
                                        fontSize: 12,
                                        color: AppColors.ink500),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        GestureDetector(
                          onTap: notifier.togglePause,
                          child: Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: AppColors.accentTint,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              state.isRunning
                                  ? Icons.pause
                                  : Icons.play_arrow,
                              size: 18,
                              color: AppColors.accentDeep,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(2),
                    child: LinearProgressIndicator(
                      value: state.totalSets > 0
                          ? state.completedSets / state.totalSets
                          : 0,
                      backgroundColor: const Color(0x0D000000),
                      valueColor: const AlwaysStoppedAnimation<Color>(
                          AppColors.accent),
                      minHeight: 4,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
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
                        if (ex == null) return const SizedBox.shrink();
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
                        label: _finishing
                            ? 'Saving…'
                            : 'Finish workout',
                        variant: GlassButtonVariant.glass,
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
            if (state.restTimer != null)
              RestTimerBar(
                restTimer: state.restTimer!,
                onSkip: notifier.skipRest,
                onAddTime: () => notifier.addRestTime(15),
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
    _anim = Tween<double>(begin: 1.0, end: 0.4).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );
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
        decoration: const BoxDecoration(
          color: AppColors.accent,
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}
