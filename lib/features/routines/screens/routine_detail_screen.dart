import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:versatile/l10n/app_localizations.dart';
import '../../../core/theme/app_colors.dart';
import '../../../domain/entities/exercise.dart';
import '../../../domain/entities/routine.dart';
import '../../../core/utils/l10n_utils.dart';
import '../../../shared/widgets/glass_button.dart';
import '../../../shared/widgets/glass_container.dart';
import '../../../shared/widgets/motion.dart';
import '../../../shared/widgets/screen_header.dart';
import '../../active_workout/screens/active_workout_screen.dart';
import '../../exercises/view_models/exercises_view_model.dart';
import '../view_models/routines_view_model.dart';
import '../widgets/routine_color_picker.dart';
import 'exercise_picker_screen.dart';

const _kColors = [
  Color(0xFFD97757),
  Color(0xFFB85432),
  Color(0xFFE89A7E),
  Color(0xFFB48C64),
  Color(0xFF9B7850),
  Color(0xFF4A7B6F),
  Color(0xFF7B5EA7),
  Color(0xFF5E7BA7),
];

const _kIcons = [
  Icons.fitness_center,
  Icons.bolt,
  Icons.timer,
  Icons.favorite,
  Icons.trending_up,
  Icons.directions_run,
  Icons.speed,
  Icons.monitor_weight,
  Icons.rocket_launch,
  Icons.local_fire_department,
  Icons.self_improvement,
];

String? _muscleAsset(String muscle) => switch (muscle) {
  'Chest' => 'assets/assets/Torso/pecho/pecho_edit_24359279032740.png',
  'Back' => 'assets/assets/Torso/espalda/back_edit_24411266380648.png',
  'Shoulders' =>
    'assets/assets/Torso/hombro/shoulder_edit_24384715995236.png',
  'Core' => 'assets/assets/Torso/core/Core_edit_24439960498352.png',
  'Biceps' => 'assets/assets/Torso/brazos/biceps_edit_24565456161875.png',
  'Triceps' =>
    'assets/assets/Torso/brazos/triceps_edit_24496361907719.png',
  'Forearms' =>
    'assets/assets/Torso/brazos/forearm_edit_24532082903547.png',
  'Quadriceps' => 'assets/assets/Piernas/cuadriceps.png',
  'Hamstrings' => 'assets/assets/Piernas/femoral_edit_24694965504563.png',
  'Glutes' => 'assets/assets/Piernas/glutes_edit_24675899562379.png',
  'Calves' => 'assets/assets/Piernas/calf_edit_24757805204033.png',
  _ => null,
};

class RoutineDetailScreen extends ConsumerStatefulWidget {
  const RoutineDetailScreen({super.key, required this.routineId});
  final String routineId;

  @override
  ConsumerState<RoutineDetailScreen> createState() =>
      _RoutineDetailScreenState();
}

class _RoutineDetailScreenState extends ConsumerState<RoutineDetailScreen> {
  bool _editMode = false;
  int? _editColorValue;
  int? _editIconCode;
  TextEditingController? _nameCtrl;

  @override
  void dispose() {
    _nameCtrl?.dispose();
    super.dispose();
  }

  Routine? _find(List<Routine> list) {
    try {
      return list.firstWhere((r) => r.id == widget.routineId);
    } catch (_) {
      return null;
    }
  }

  Future<void> _confirmDelete(Routine routine) async {
    final l10n = AppLocalizations.of(context)!;
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: context.colors.bgFrame,
        title: Text(
          l10n.deleteRoutineTitle,
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w600,
            color: context.colors.ink900,
          ),
        ),
        content: Text(
          l10n.deleteRoutineContent(routine.name),
          style: TextStyle(fontSize: 14, color: context.colors.ink500),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(
              l10n.cancel,
              style: TextStyle(color: context.colors.ink500),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(
              l10n.delete,
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

  void _toggleEdit(Routine routine) {
    if (_editMode) {
      final name = _nameCtrl?.text.trim() ?? '';
      if (name.isNotEmpty && name != routine.name) {
        ref.read(routinesProvider.notifier).updateName(routine.id, name);
      }
      _nameCtrl?.dispose();
      _nameCtrl = null;
      setState(() => _editMode = false);
    } else {
      setState(() {
        _editMode = true;
        _editColorValue = routine.colorValue;
        _editIconCode = routine.iconCode;
        _nameCtrl = TextEditingController(text: routine.name);
      });
    }
  }

  Future<void> _showEditDialog(
    BuildContext context,
    String routineId,
    RoutineExercise re,
    String exerciseName,
  ) async {
    if (re.dbId == null) return;
    final result = await showDialog<({int sets, String reps, int rest})>(
      context: context,
      builder: (_) => ExerciseConfigDialog(
        exerciseName: exerciseName,
        index: 0,
        total: 1,
        initialSets: re.targetSets,
        initialReps: re.targetReps,
        initialRest: re.restSeconds,
      ),
    );
    if (result == null || !mounted) return;
    await ref.read(routinesProvider.notifier).updateExercise(
      routineId,
      re.dbId!,
      result.sets,
      result.reps,
      result.rest,
    );
  }

  void _onReorder(Routine routine, int oldIndex, int newIndex) {
    if (newIndex > oldIndex) newIndex--;
    final exercises = [...routine.exercises];
    final moved = exercises.removeAt(oldIndex);
    exercises.insert(newIndex, moved);
    ref.read(routinesProvider.notifier).reorderExercises(routine.id, exercises);
  }

  Widget _muscleIcon(String muscle) {
    final asset = _muscleAsset(muscle);
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: context.colors.accentTint,
        borderRadius: BorderRadius.circular(10),
      ),
      child: asset != null
          ? Padding(
              padding: const EdgeInsets.all(7),
              child: Image.asset(asset, fit: BoxFit.contain),
            )
          : Icon(
              Icons.fitness_center,
              size: 16,
              color: context.colors.accentDeep,
            ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
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
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Go back'),
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

        final currentColorValue = _editColorValue ?? routine.colorValue;
        final currentIconCode = _editIconCode ?? routine.iconCode;

        final trailing = Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (_editMode)
              PressableScale(
                onTap: () => _confirmDelete(routine),
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
              onTap: () => _toggleEdit(routine),
              child: Container(
                height: 36,
                padding: const EdgeInsets.symmetric(horizontal: 14),
                decoration: BoxDecoration(
                  gradient: _editMode
                      ? null
                      : LinearGradient(
                          colors: [context.colors.accentLight, context.colors.accent],
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
                            color: context.colors.accentDeep.withValues(
                              alpha: 0.25,
                            ),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                ),
                child: Center(
                  child: Text(
                    _editMode ? l10n.done : l10n.edit,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: _editMode
                          ? context.colors.accentDeep
                          : Colors.white,
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
                  subtitle:
                      '${routine.exercises.length} ${l10n.exercisesLabel}',
                  onBack: () => Navigator.of(context).pop(),
                  trailing: trailing,
                  accentBack: true,
                ),
                const SizedBox(height: 4),
                Expanded(
                  child: _editMode
                      ? ReorderableListView(
                          padding: const EdgeInsets.fromLTRB(22, 8, 22, 8),
                          onReorder: (old, neu) =>
                              _onReorder(routine, old, neu),
                          children: routine.exercises.asMap().entries.map((
                            entry,
                          ) {
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
                                      index: entry.key,
                                      child: Icon(
                                        Icons.drag_handle,
                                        size: 18,
                                        color: context.colors.ink300,
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    _muscleIcon(ex.muscle),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            ex.getLocalizedName(context),
                                            style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w600,
                                              color: context.colors.ink900,
                                            ),
                                          ),
                                          Text(
                                            '${re.targetSets} × ${re.targetReps} · ${re.restSeconds}s ${l10n.rest}',
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
                                          ? () => _showEditDialog(
                                                context,
                                                routine.id,
                                                re,
                                                ex.getLocalizedName(context),
                                              )
                                          : null,
                                      child: Container(
                                        width: 32,
                                        height: 32,
                                        margin: const EdgeInsets.only(right: 6),
                                        decoration: BoxDecoration(
                                          color: context.colors.accentTint,
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                        child: Icon(
                                          Icons.edit_outlined,
                                          size: 15,
                                          color: context.colors.accentDeep,
                                        ),
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
                                    _muscleIcon(ex.muscle),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            ex.getLocalizedName(context),
                                            style: TextStyle(
                                              fontSize: 15,
                                              fontWeight: FontWeight.w600,
                                              color: context.colors.ink900,
                                            ),
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            '${re.targetSets} ${l10n.sets} · ${re.targetReps} reps · ${re.restSeconds}s ${l10n.rest}',
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
                                        ex.getLocalizedMuscle(context),
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
                    padding: const EdgeInsets.fromLTRB(22, 8, 22, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.name_label,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.06,
                            color: context.colors.ink400,
                          ),
                        ),
                        const SizedBox(height: 10),
                        GlassContainer(
                          radius: 14,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 4,
                          ),
                          child: TextField(
                            controller: _nameCtrl,
                            style: TextStyle(
                              fontSize: 16,
                              color: context.colors.ink900,
                              fontWeight: FontWeight.w500,
                            ),
                            decoration: InputDecoration(
                              hintStyle: TextStyle(
                                fontSize: 16,
                                color: context.colors.ink400,
                              ),
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(
                                vertical: 14,
                              ),
                            ),
                            onSubmitted: (v) {
                              final name = v.trim();
                              if (name.isNotEmpty && name != routine.name) {
                                ref
                                    .read(routinesProvider.notifier)
                                    .updateName(routine.id, name);
                              }
                            },
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          l10n.color_label,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.06,
                            color: context.colors.ink400,
                          ),
                        ),
                        const SizedBox(height: 10),
                        RoutineColorPicker(
                          colors: _kColors,
                          selectedColorValue: currentColorValue,
                          onSelected: (color) {
                            setState(() => _editColorValue = color.toARGB32());
                            ref
                                .read(routinesProvider.notifier)
                                .updateMeta(
                                  routine.id,
                                  color.toARGB32(),
                                  currentIconCode,
                                );
                          },
                        ),
                        const SizedBox(height: 14),
                        Text(
                          l10n.icon_label,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.06,
                            color: context.colors.ink400,
                          ),
                        ),
                        const SizedBox(height: 10),
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: _kIcons.map((icon) {
                              final active = icon.codePoint == currentIconCode;
                              return Padding(
                                padding: const EdgeInsets.only(right: 10),
                                child: PressableScale(
                                  onTap: () {
                                    setState(
                                      () => _editIconCode = icon.codePoint,
                                    );
                                    ref
                                        .read(routinesProvider.notifier)
                                        .updateMeta(
                                          routine.id,
                                          currentColorValue,
                                          icon.codePoint,
                                        );
                                  },
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 180),
                                    width: 38,
                                    height: 38,
                                    decoration: BoxDecoration(
                                      color: active
                                          ? context.colors.accent
                                          : context.colors.glassBg,
                                      borderRadius: BorderRadius.circular(12),
                                      border: active
                                          ? Border.all(
                                              color: Colors.white,
                                              width: 2,
                                            )
                                          : Border.all(
                                              color: context.colors.glassBorder,
                                              width: 0.5,
                                            ),
                                      boxShadow: active
                                          ? [
                                              BoxShadow(
                                                color: context.colors.accentDeep
                                                    .withValues(alpha: 0.3),
                                                blurRadius: 10,
                                                offset: const Offset(0, 3),
                                              ),
                                            ]
                                          : null,
                                    ),
                                    child: Icon(
                                      icon,
                                      size: 18,
                                      color: active
                                          ? Colors.white
                                          : context.colors.ink700,
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                        const SizedBox(height: 12),
                      ],
                    ),
                  ),
                if (_editMode)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(22, 0, 22, 22),
                    child: GlassButton(
                      label: l10n.addExercise,
                      variant: GlassButtonVariant.primary,
                      size: GlassButtonSize.md,
                      expand: true,
                      onPressed: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) =>
                              ExercisePickerScreen(routineId: routine.id),
                        ),
                      ),
                      leading: const Icon(
                        Icons.add_rounded,
                        size: 18,
                        color: Colors.white,
                      ),
                    ),
                  ),
                if (!_editMode)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(22, 0, 22, 22),
                    child: GlassButton(
                      label: l10n.startThisWorkout,
                      variant: GlassButtonVariant.primary,
                      size: GlassButtonSize.lg,
                      expand: true,
                      leading: const Icon(
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
