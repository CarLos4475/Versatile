import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../domain/entities/exercise.dart';
import '../../../domain/entities/routine.dart';
import '../../../shared/widgets/glass_button.dart';
import '../../../shared/widgets/glass_container.dart';
import '../../../shared/widgets/screen_header.dart';
import '../../active_workout/screens/active_workout_screen.dart';
import '../../exercises/view_models/exercises_view_model.dart';
import '../view_models/routines_view_model.dart';
import 'exercise_picker_screen.dart';

class RoutineDetailScreen extends ConsumerStatefulWidget {
  const RoutineDetailScreen({super.key, required this.routineId});
  final String routineId;

  @override
  ConsumerState<RoutineDetailScreen> createState() =>
      _RoutineDetailScreenState();
}

class _RoutineDetailScreenState extends ConsumerState<RoutineDetailScreen> {
  bool _editMode = false;

  Routine? _find(List<Routine> list) {
    try {
      return list.firstWhere((r) => r.id == widget.routineId);
    } catch (_) {
      return null;
    }
  }

  Future<void> _confirmDelete() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.bgFrame,
        title: const Text('Delete routine?',
            style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w600,
                color: AppColors.ink900)),
        content: const Text(
          'This will permanently remove this routine.',
          style: TextStyle(fontSize: 14, color: AppColors.ink500),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel',
                style: TextStyle(color: AppColors.ink500)),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete',
                style: TextStyle(
                    color: AppColors.accentDeep,
                    fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
    if (ok == true && mounted) {
      await ref
          .read(routinesProvider.notifier)
          .deleteRoutine(widget.routineId);
      if (mounted) Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final routinesAsync = ref.watch(routinesProvider);
    final exercises = ref.watch(exercisesAsyncProvider).value ?? [];

    return routinesAsync.when(
      loading: () => const Scaffold(
        backgroundColor: AppColors.bgApp,
        body: Center(
            child: CircularProgressIndicator(
                color: AppColors.accent, strokeWidth: 2)),
      ),
      error: (e, _) => Scaffold(
        backgroundColor: AppColors.bgApp,
        body: Center(child: Text('$e')),
      ),
      data: (routines) {
        final routine = _find(routines);
        if (routine == null) {
          return Scaffold(
            backgroundColor: AppColors.bgApp,
            body: Center(
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                const Text('Routine not found',
                    style: TextStyle(color: AppColors.ink500)),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Go back'),
                ),
              ]),
            ),
          );
        }

        Exercise? findEx(String id) {
          try {
            return exercises.firstWhere((e) => e.id == id);
          } catch (_) {
            return null;
          }
        }

        return Scaffold(
          backgroundColor: AppColors.bgApp,
          body: SafeArea(
            child: Stack(
              children: [
                SingleChildScrollView(
                  padding: const EdgeInsets.only(bottom: 140),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ScreenHeader(
                        title: routine.name,
                        subtitle: '${routine.exercises.length} exercises',
                        onBack: () => Navigator.of(context).pop(),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (_editMode)
                              GestureDetector(
                                onTap: _confirmDelete,
                                child: Container(
                                  width: 36,
                                  height: 36,
                                  margin: const EdgeInsets.only(right: 8),
                                  decoration: BoxDecoration(
                                    color: AppColors.accentTint,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                        color: AppColors.glassBorder,
                                        width: 0.5),
                                  ),
                                  child: const Icon(Icons.delete_outline,
                                      size: 16, color: AppColors.accentDeep),
                                ),
                              ),
                            GestureDetector(
                              onTap: () =>
                                  setState(() => _editMode = !_editMode),
                              child: Container(
                                height: 36,
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 14),
                                decoration: BoxDecoration(
                                  color: _editMode
                                      ? AppColors.accentTint
                                      : const Color(0x99FFFCF7),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                      color: AppColors.glassBorder,
                                      width: 0.5),
                                ),
                                child: Center(
                                  child: Text(
                                    _editMode ? 'Done' : 'Edit',
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: _editMode
                                          ? AppColors.accentDeep
                                          : AppColors.ink700,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      Padding(
                        padding:
                            const EdgeInsets.symmetric(horizontal: 22),
                        child: Column(
                          children: [
                            ...routine.exercises.asMap().entries.map((entry) {
                              final i = entry.key;
                              final re = entry.value;
                              final ex = findEx(re.exerciseId);
                              if (ex == null) return const SizedBox.shrink();
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 8),
                                child: GlassContainer(
                                  radius: 16,
                                  padding: const EdgeInsets.all(14),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 32,
                                        height: 32,
                                        decoration: BoxDecoration(
                                          color: AppColors.accentTint,
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                        child: Center(
                                          child: Text(
                                            '${i + 1}',
                                            style: const TextStyle(
                                              fontSize: 13,
                                              fontWeight: FontWeight.w700,
                                              color: AppColors.accentDeep,
                                              fontFeatures: [
                                                FontFeature.tabularFigures()
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              ex.name,
                                              style: const TextStyle(
                                                fontSize: 15,
                                                fontWeight: FontWeight.w600,
                                                color: AppColors.ink900,
                                              ),
                                            ),
                                            const SizedBox(height: 2),
                                            Text(
                                              '${re.targetSets} × ${re.targetReps} reps · ${re.restSeconds}s rest',
                                              style: const TextStyle(
                                                fontSize: 12,
                                                color: AppColors.ink500,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      if (_editMode)
                                        GestureDetector(
                                          onTap: re.dbId != null
                                              ? () => ref
                                                  .read(routinesProvider
                                                      .notifier)
                                                  .removeExercise(
                                                      routine.id, re.dbId!)
                                              : null,
                                          child: Container(
                                            width: 32,
                                            height: 32,
                                            decoration: BoxDecoration(
                                              color: AppColors.accentTint,
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                            child: const Icon(
                                              Icons.delete_outline,
                                              size: 15,
                                              color: AppColors.accentDeep,
                                            ),
                                          ),
                                        )
                                      else
                                        Container(
                                          padding:
                                              const EdgeInsets.symmetric(
                                                  horizontal: 7, vertical: 3),
                                          decoration: BoxDecoration(
                                            color: const Color(0x0A000000),
                                            borderRadius:
                                                BorderRadius.circular(6),
                                          ),
                                          child: Text(
                                            ex.muscle,
                                            style: const TextStyle(
                                              fontSize: 11,
                                              color: AppColors.ink400,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              );
                            }),
                            if (_editMode)
                              GestureDetector(
                                onTap: () => Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => ExercisePickerScreen(
                                        routineId: routine.id),
                                  ),
                                ),
                                child: Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.all(14),
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: AppColors.accent.withOpacity(0.4),
                                    ),
                                    borderRadius: BorderRadius.circular(16),
                                    color: AppColors.accentTint.withOpacity(0.5),
                                  ),
                                  child: const Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.add,
                                          size: 18,
                                          color: AppColors.accentDeep),
                                      SizedBox(width: 8),
                                      Text(
                                        'Add exercise',
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          color: AppColors.accentDeep,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                if (!_editMode)
                  Positioned(
                    left: 22,
                    right: 22,
                    bottom: 22,
                    child: GlassButton(
                      label: 'Start this workout',
                      variant: GlassButtonVariant.primary,
                      size: GlassButtonSize.lg,
                      expand: true,
                      leading: const Icon(Icons.play_arrow,
                          color: Colors.white, size: 16),
                      onPressed: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) =>
                              ActiveWorkoutScreen(routineId: routine.id),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}
