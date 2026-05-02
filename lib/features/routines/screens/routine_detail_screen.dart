import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../domain/entities/exercise.dart';
import '../../../domain/entities/routine.dart';
import '../../../shared/widgets/glass_button.dart';
import '../../../shared/widgets/glass_container.dart';
import '../../../shared/widgets/motion.dart';
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
        backgroundColor: context.colors.bgFrame,
        title: Text(
          'Delete routine?',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w600,
            color: context.colors.ink900,
          ),
        ),
        content: Text(
          'This will permanently remove this routine.',
          style: TextStyle(fontSize: 14, color: context.colors.ink500),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(
              'Cancel',
              style: TextStyle(color: context.colors.ink500),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(
              'Delete',
              style: TextStyle(
                color: context.colors.accentDeep,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
    if (ok == true && mounted) {
      await ref.read(routinesProvider.notifier).deleteRoutine(widget.routineId);
      if (mounted) Navigator.of(context).pop();
    }
  }

  void _onReorder(Routine routine, int oldIndex, int newIndex) {
    if (newIndex > oldIndex) newIndex--;
    final exercises = [...routine.exercises];
    final moved = exercises.removeAt(oldIndex);
    exercises.insert(newIndex, moved);
    ref.read(routinesProvider.notifier).reorderExercises(routine.id, exercises);
  }

  @override
  Widget build(BuildContext context) {
    final routinesAsync = ref.watch(routinesProvider);
    final exercises = ref.watch(exercisesAsyncProvider).value ?? [];

    return routinesAsync.when(
      loading: () => Scaffold(
        backgroundColor: context.colors.bgApp,
        body: Center(
          child: CircularProgressIndicator(
            color: context.colors.accent,
            strokeWidth: 2,
          ),
        ),
      ),
      error: (e, _) => Scaffold(
        backgroundColor: context.colors.bgApp,
        body: Center(child: Text('$e')),
      ),
      data: (routines) {
        final routine = _find(routines);
        if (routine == null) {
          return Scaffold(
            backgroundColor: context.colors.bgApp,
            body: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Routine not found',
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
          );
        }

        Exercise? findEx(String id) {
          try {
            return exercises.firstWhere((e) => e.id == id);
          } catch (_) {
            return null;
          }
        }

        final trailing = Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (_editMode)
              PressableScale(
                onTap: _confirmDelete,
                child: Container(
                  width: 36,
                  height: 36,
                  margin: const EdgeInsets.only(right: 8),
                  decoration: BoxDecoration(
                    color: context.colors.accentTint,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: context.colors.accent.withValues(alpha: 0.4),
                      width: 0.5,
                    ),
                  ),
                  child: Icon(
                    Icons.delete_outline,
                    size: 18,
                    color: context.colors.accentDeep,
                  ),
                ),
              ),
            PressableScale(
              onTap: () => setState(() => _editMode = !_editMode),
              child: Container(
                height: 36,
                padding: const EdgeInsets.symmetric(horizontal: 14),
                decoration: BoxDecoration(
                  gradient: _editMode
                      ? null
                      : const LinearGradient(
                          colors: [Color(0xFFE08866), Color(0xFFD97757)],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                  color: _editMode ? context.colors.accentTint : null,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _editMode
                        ? context.colors.accent.withValues(alpha: 0.4)
                        : context.colors.accentDeep.withValues(alpha: 0.2),
                    width: 0.5,
                  ),
                  boxShadow: _editMode
                      ? null
                      : [
                          BoxShadow(
                            color: context.colors.accentDeep
                                .withValues(alpha: 0.25),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                ),
                child: Center(
                  child: Text(
                    _editMode ? 'Done' : 'Edit',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: _editMode ? context.colors.accentDeep : Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ],
        );

        return Scaffold(
          backgroundColor: context.colors.bgApp,
          body: SafeArea(
            child: Column(
              children: [
                ScreenHeader(
                  title: routine.name,
                  subtitle: '${routine.exercises.length} exercises',
                  onBack: () => Navigator.of(context).pop(),
                  trailing: trailing,
                  accentBack: true,
                ),
                SizedBox(height: 4),
                Expanded(
                  child: _editMode
                      ? ReorderableListView(
                          padding: const EdgeInsets.fromLTRB(22, 8, 22, 8),
                          onReorder: (old, neu) =>
                              _onReorder(routine, old, neu),
                          children: routine.exercises.asMap().entries.map((
                            entry,
                          ) {
                            final i = entry.key;
                            final re = entry.value;
                            final ex = findEx(re.exerciseId);
                            if (ex == null) {
                              return SizedBox.shrink(
                                key: ValueKey(re.dbId ?? re.exerciseId),
                              );
                            }
                            return Padding(
                              key: ValueKey(re.dbId ?? re.exerciseId),
                              padding: const EdgeInsets.only(bottom: 8),
                              child: GlassContainer(
                                radius: 16,
                                padding: const EdgeInsets.all(14),
                                child: Row(
                                  children: [
                                    ReorderableDragStartListener(
                                      index: i,
                                      child: Icon(
                                        Icons.drag_handle,
                                        size: 18,
                                        color: context.colors.ink300,
                                      ),
                                    ),
                                    SizedBox(width: 10),
                                    Container(
                                      width: 28,
                                      height: 28,
                                      decoration: BoxDecoration(
                                        color: context.colors.accentTint,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Center(
                                        child: Text(
                                          '${i + 1}',
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w700,
                                            color: context.colors.accentDeep,
                                          ),
                                        ),
                                      ),
                                    ),
                                    SizedBox(width: 10),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            ex.name,
                                            style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w600,
                                              color: context.colors.ink900,
                                            ),
                                          ),
                                          Text(
                                            '${re.targetSets} × ${re.targetReps} · ${re.restSeconds}s rest',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: context.colors.ink500,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    PressableScale(
                                      onTap: re.dbId != null
                                          ? () => ref
                                                .read(routinesProvider.notifier)
                                                .removeExercise(
                                                  routine.id,
                                                  re.dbId!,
                                                )
                                          : null,
                                      child: Container(
                                        width: 32,
                                        height: 32,
                                        decoration: BoxDecoration(
                                          color: context.colors.accentTint,
                                          borderRadius: BorderRadius.circular(
                                            10,
                                          ),
                                        ),
                                        child: Icon(
                                          Icons.delete_outline,
                                          size: 15,
                                          color: context.colors.accentDeep,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }).toList(),
                        )
                      : ListView(
                          padding: const EdgeInsets.fromLTRB(22, 8, 22, 8),
                          children: routine.exercises.asMap().entries.map((
                            entry,
                          ) {
                            final i = entry.key;
                            final re = entry.value;
                            final ex = findEx(re.exerciseId);
                            if (ex == null) return SizedBox.shrink();
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
                                        color: context.colors.accentTint,
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Center(
                                        child: Text(
                                          '${i + 1}',
                                          style: TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w700,
                                            color: context.colors.accentDeep,
                                            fontFeatures: [
                                              FontFeature.tabularFigures(),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                    SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            ex.name,
                                            style: TextStyle(
                                              fontSize: 15,
                                              fontWeight: FontWeight.w600,
                                              color: context.colors.ink900,
                                            ),
                                          ),
                                          SizedBox(height: 2),
                                          Text(
                                            '${re.targetSets} × ${re.targetReps} reps · ${re.restSeconds}s rest',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: context.colors.ink500,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 7,
                                        vertical: 3,
                                      ),
                                      decoration: BoxDecoration(
                                        color: const Color(0x0A000000),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        ex.muscle,
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: context.colors.ink400,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                ),
                if (_editMode)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(22, 0, 22, 22),
                    child: PressableScale(
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) =>
                              ExercisePickerScreen(routineId: routine.id),
                        ),
                      ),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFFE08866), Color(0xFFD97757)],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: context.colors.accentDeep
                                  .withValues(alpha: 0.25),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Icon(
                              Icons.add_rounded,
                              size: 18,
                              color: Colors.white,
                            ),
                            SizedBox(width: 8),
                            Text(
                              'Add exercise',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                if (!_editMode)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(22, 0, 22, 22),
                    child: GlassButton(
                      label: 'Start this workout',
                      variant: GlassButtonVariant.primary,
                      size: GlassButtonSize.lg,
                      expand: true,
                      leading: Icon(
                        Icons.play_arrow,
                        color: Colors.white,
                        size: 16,
                      ),
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