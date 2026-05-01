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
    final state = ref.watch(activeWorkoutProvider(routineId));
    final notifier = ref.read(activeWorkoutProvider(routineId).notifier);

    return Scaffold(
      backgroundColor: AppColors.bgApp,
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                // Top bar
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
                                crossAxisAlignment: CrossAxisAlignment.baseline,
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
                                      fontFeatures: [FontFeature.tabularFigures()],
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    '${state.completedSets}/${state.totalSets} sets'
                                    ' · ${FormatUtils.volume(state.totalVolume)}',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: AppColors.ink500,
                                    ),
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

                // Progress bar
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

                // Exercise list
                Expanded(
                  child: ListView(
                    padding: EdgeInsets.fromLTRB(
                      16, 0, 16,
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
                            prevSets: const [],
                            onToggle: () => notifier.toggleExpand(i),
                            onFinishSet: () => notifier.finishSet(i),
                            onWeightChanged: (kg) =>
                                notifier.updateWeight(i, kg),
                            onRepsChanged: (reps) =>
                                notifier.updateReps(i, reps),
                          ),
                        );
                      }),
                      GlassButton(
                        label: 'Finish workout',
                        variant: GlassButtonVariant.glass,
                        size: GlassButtonSize.md,
                        expand: true,
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            // Rest timer overlay
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
