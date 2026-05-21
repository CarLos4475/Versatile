import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:versatile/l10n/app_localizations.dart';
import '../../../core/providers/repository_providers.dart';
import '../../../core/theme/app_colors.dart';
import '../../../domain/entities/exercise.dart';
import '../../../domain/entities/routine.dart';
import '../../../shared/widgets/coachmark_overlay.dart';
import '../../../core/utils/l10n_utils.dart';
import '../../../shared/widgets/motion.dart';
import '../../../shared/widgets/screen_header.dart';
import '../../active_workout/screens/active_workout_screen.dart';
import '../../exercises/view_models/exercises_view_model.dart';
import '../view_models/routines_view_model.dart';
import '../widgets/routine_color_picker.dart';
import '../widgets/routine_icon_picker.dart';
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
  final _editBtnKey = GlobalKey();
  bool _coachmarkScheduled = false;

  Future<void> _checkCoachmark() async {
    if (!mounted) return;
    final service = ref.read(coachmarkServiceProvider);
    final should = await service.shouldShow('routine_edit');
    if (!should || !mounted) return;
    final l10n = AppLocalizations.of(context)!;
    CoachmarkOverlay.show(
      context: context,
      targetKey: _editBtnKey,
      title: l10n.coachmarkRoutineEditTitle,
      body: l10n.coachmarkRoutineEditBody,
      gotItLabel: l10n.coachmarkGotIt,
      skipLabel: l10n.coachmarkSkipAll,
      onDone: () => service.markSeen('routine_edit'),
    );
  }

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
        scrollable: true,
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

        if (!_coachmarkScheduled) {
          _coachmarkScheduled = true;
          WidgetsBinding.instance.addPostFrameCallback((_) => _checkCoachmark());
        }

        final isEs = Localizations.localeOf(context).languageCode == 'es';
        final currentColorValue = _editColorValue ?? routine.colorValue;
        final currentIconCode = _editIconCode ?? routine.iconCode;

        return Scaffold(
          backgroundColor: context.colors.bgApp,
          body: SafeArea(
            child: Column(
              children: [
                ScreenHeader(
                  prefix: isEs ? 'Rutina —' : 'Routine —',
                  accent: '${routine.name}.',
                  eyebrow:
                      '${routine.exercises.length} ${l10n.exercisesLabel}',
                  onBack: () => Navigator.of(context).pop(),
                  trailing: _HeaderActions(
                    editKey: _editBtnKey,
                    editMode: _editMode,
                    editLabel: l10n.edit,
                    doneLabel: l10n.done,
                    onToggleEdit: () => _toggleEdit(routine),
                    onDelete: _editMode
                        ? () => _confirmDelete(routine)
                        : null,
                  ),
                  accentBack: true,
                ),
                const SizedBox(height: 10),
                Expanded(
                  child: _editMode
                      ? _EditBody(
                          routine: routine,
                          findEx: findEx,
                          onReorder: (a, b) => _onReorder(routine, a, b),
                          onEditExercise: (re, exName) => _showEditDialog(
                            context,
                            routine.id,
                            re,
                            exName,
                          ),
                          onRemoveExercise: (dbId) => ref
                              .read(routinesProvider.notifier)
                              .removeExercise(routine.id, dbId),
                          nameCtrl: _nameCtrl!,
                          nameLabel: l10n.name_label,
                          colorLabel: l10n.color_label,
                          iconLabel: l10n.icon_label,
                          sectionExercises:
                              isEs ? 'Ejercicios' : 'Exercises',
                          setsLabel: l10n.sets,
                          restLabel: l10n.rest,
                          selectedColorValue: currentColorValue,
                          selectedIconCode: currentIconCode,
                          onColorSelected: (color) {
                            setState(
                              () => _editColorValue = color.toARGB32(),
                            );
                            ref.read(routinesProvider.notifier).updateMeta(
                                  routine.id,
                                  color.toARGB32(),
                                  currentIconCode,
                                );
                          },
                          onIconSelected: (icon) {
                            setState(() => _editIconCode = icon.codePoint);
                            ref.read(routinesProvider.notifier).updateMeta(
                                  routine.id,
                                  currentColorValue,
                                  icon.codePoint,
                                );
                          },
                          onNameSubmitted: (v) {
                            final name = v.trim();
                            if (name.isNotEmpty && name != routine.name) {
                              ref
                                  .read(routinesProvider.notifier)
                                  .updateName(routine.id, name);
                            }
                          },
                        )
                      : _ViewBody(
                          routine: routine,
                          findEx: findEx,
                          setsLabel: l10n.sets,
                          restLabel: l10n.rest,
                          emptyText: isEs
                              ? 'Aún no hay ejercicios.'
                              : 'No exercises yet.',
                        ),
                ),
                _BottomCta(
                  label: _editMode
                      ? l10n.addExercise
                      : l10n.startThisWorkout,
                  icon: _editMode ? Icons.add_rounded : Icons.play_arrow,
                  onTap: _editMode
                      ? () => Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => ExercisePickerScreen(
                                routineId: routine.id,
                              ),
                            ),
                          )
                      : () => Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => ActiveWorkoutScreen(
                                routineId: routine.id,
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

class _GridDivider extends StatelessWidget {
  const _GridDivider();
  @override
  Widget build(BuildContext context) {
    return Container(height: 0.6, color: context.colors.hairline);
  }
}

class _SectionEyebrow extends StatelessWidget {
  const _SectionEyebrow({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Row(
      children: [
        Container(
          width: 22,
          height: 1,
          color: colors.ink400.withValues(alpha: 0.55),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text.toUpperCase(),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w800,
              color: colors.ink500,
              letterSpacing: 0.18,
            ),
          ),
        ),
      ],
    );
  }
}

class _MuscleIcon extends StatelessWidget {
  const _MuscleIcon({required this.muscle});
  final String muscle;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final asset = _muscleAsset(muscle);
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: colors.accentSoft,
      ),
      child: asset != null
          ? Padding(
              padding: const EdgeInsets.all(6),
              child: Image.asset(asset, fit: BoxFit.contain),
            )
          : Icon(
              Icons.fitness_center,
              size: 16,
              color: colors.ink500,
            ),
    );
  }
}

class _HeaderActions extends StatelessWidget {
  const _HeaderActions({
    required this.editKey,
    required this.editMode,
    required this.editLabel,
    required this.doneLabel,
    required this.onToggleEdit,
    this.onDelete,
  });

  final GlobalKey editKey;
  final bool editMode;
  final String editLabel;
  final String doneLabel;
  final VoidCallback onToggleEdit;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (onDelete != null)
          PressableScale(
            onTap: onDelete,
            child: Container(
              width: 38,
              height: 38,
              margin: const EdgeInsets.only(right: 8),
              decoration: BoxDecoration(
                color: colors.ink900.withValues(alpha: 0.04),
                border: Border.all(color: colors.hairline, width: 0.6),
              ),
              child: Icon(
                Icons.delete_outline,
                size: 18,
                color: colors.ink700,
              ),
            ),
          ),
        KeyedSubtree(
          key: editKey,
          child: PressableScale(
            onTap: onToggleEdit,
            child: Container(
              height: 38,
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: editMode
                    ? colors.ink900.withValues(alpha: 0.04)
                    : colors.accent,
                border: Border.all(
                  color: editMode
                      ? colors.hairline
                      : colors.accentDeep.withValues(alpha: 0.6),
                  width: 0.6,
                ),
              ),
              child: Center(
                child: Text(
                  (editMode ? doneLabel : editLabel).toUpperCase(),
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: editMode ? colors.ink700 : Colors.white,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _ViewBody extends StatelessWidget {
  const _ViewBody({
    required this.routine,
    required this.findEx,
    required this.setsLabel,
    required this.restLabel,
    required this.emptyText,
  });

  final Routine routine;
  final Exercise? Function(String) findEx;
  final String setsLabel;
  final String restLabel;
  final String emptyText;

  @override
  Widget build(BuildContext context) {
    if (routine.exercises.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: Text(
            emptyText.toUpperCase(),
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w800,
              color: context.colors.ink400,
              letterSpacing: 0.18,
            ),
          ),
        ),
      );
    }
    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        children: [
          const _GridDivider(),
          for (final re in routine.exercises) ...[
            if (findEx(re.exerciseId) != null) ...[
              _ExerciseRow(
                exercise: findEx(re.exerciseId)!,
                re: re,
                setsLabel: setsLabel,
                restLabel: restLabel,
              ),
              const _GridDivider(),
            ],
          ],
        ],
      ),
    );
  }
}

class _ExerciseRow extends StatelessWidget {
  const _ExerciseRow({
    required this.exercise,
    required this.re,
    required this.setsLabel,
    required this.restLabel,
  });

  final Exercise exercise;
  final RoutineExercise re;
  final String setsLabel;
  final String restLabel;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Container(
      padding: const EdgeInsets.fromLTRB(22, 16, 22, 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _MuscleIcon(muscle: exercise.muscle),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  exercise.getLocalizedMuscle(context).toUpperCase(),
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    color: colors.ink400,
                    letterSpacing: 0.18,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  exercise.getLocalizedName(context),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: colors.ink900,
                    letterSpacing: -0.15,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  '${re.targetSets} $setsLabel · ${re.targetReps} reps · ${re.restSeconds}s $restLabel',
                  style: TextStyle(fontSize: 12, color: colors.ink500),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _EditBody extends StatelessWidget {
  const _EditBody({
    required this.routine,
    required this.findEx,
    required this.onReorder,
    required this.onEditExercise,
    required this.onRemoveExercise,
    required this.nameCtrl,
    required this.nameLabel,
    required this.colorLabel,
    required this.iconLabel,
    required this.sectionExercises,
    required this.setsLabel,
    required this.restLabel,
    required this.selectedColorValue,
    required this.selectedIconCode,
    required this.onColorSelected,
    required this.onIconSelected,
    required this.onNameSubmitted,
  });

  final Routine routine;
  final Exercise? Function(String) findEx;
  final void Function(int, int) onReorder;
  final void Function(RoutineExercise, String) onEditExercise;
  final void Function(int) onRemoveExercise;
  final TextEditingController nameCtrl;
  final String nameLabel;
  final String colorLabel;
  final String iconLabel;
  final String sectionExercises;
  final String setsLabel;
  final String restLabel;
  final int selectedColorValue;
  final int selectedIconCode;
  final ValueChanged<Color> onColorSelected;
  final ValueChanged<IconData> onIconSelected;
  final ValueChanged<String> onNameSubmitted;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _GridDivider(),
          Padding(
            padding: const EdgeInsets.fromLTRB(22, 18, 22, 8),
            child: _SectionEyebrow(text: sectionExercises),
          ),
          if (routine.exercises.isEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(22, 10, 22, 18),
              child: Text(
                'Toca + abajo para agregar ejercicios.',
                style: TextStyle(
                  fontSize: 13,
                  color: context.colors.ink500,
                ),
              ),
            )
          else
            ReorderableListView(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: EdgeInsets.zero,
              buildDefaultDragHandles: false,
              onReorder: onReorder,
              children: [
                for (var i = 0; i < routine.exercises.length; i++)
                  _EditableExerciseRow(
                    key: ValueKey(
                      routine.exercises[i].dbId ??
                          routine.exercises[i].exerciseId,
                    ),
                    index: i,
                    exercise: findEx(routine.exercises[i].exerciseId),
                    re: routine.exercises[i],
                    setsLabel: setsLabel,
                    restLabel: restLabel,
                    onEdit: () {
                      final ex = findEx(routine.exercises[i].exerciseId);
                      if (ex == null) return;
                      onEditExercise(
                        routine.exercises[i],
                        ex.getLocalizedName(context),
                      );
                    },
                    onRemove: routine.exercises[i].dbId != null
                        ? () => onRemoveExercise(
                              routine.exercises[i].dbId!,
                            )
                        : null,
                  ),
              ],
            ),
          const _GridDivider(),
          _NameSection(
            label: nameLabel,
            controller: nameCtrl,
            onSubmitted: onNameSubmitted,
          ),
          const _GridDivider(),
          _ColorSection(
            label: colorLabel,
            selectedValue: selectedColorValue,
            onSelected: onColorSelected,
          ),
          const _GridDivider(),
          _IconSection(
            label: iconLabel,
            selectedCode: selectedIconCode,
            onSelected: onIconSelected,
          ),
          const _GridDivider(),
        ],
      ),
    );
  }
}

class _EditableExerciseRow extends StatelessWidget {
  const _EditableExerciseRow({
    super.key,
    required this.index,
    required this.exercise,
    required this.re,
    required this.setsLabel,
    required this.restLabel,
    required this.onEdit,
    this.onRemove,
  });

  final int index;
  final Exercise? exercise;
  final RoutineExercise re;
  final String setsLabel;
  final String restLabel;
  final VoidCallback onEdit;
  final VoidCallback? onRemove;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    if (exercise == null) {
      return const SizedBox.shrink();
    }
    return Container(
      key: ValueKey('row-${re.dbId ?? re.exerciseId}'),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: colors.hairline, width: 0.6),
        ),
      ),
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
      child: Row(
        children: [
          ReorderableDragStartListener(
            index: index,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Icon(
                Icons.drag_handle,
                size: 18,
                color: colors.ink400,
              ),
            ),
          ),
          const SizedBox(width: 4),
          _MuscleIcon(muscle: exercise!.muscle),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  exercise!.getLocalizedName(context),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: colors.ink900,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${re.targetSets} × ${re.targetReps} · ${re.restSeconds}s $restLabel',
                  style: TextStyle(fontSize: 12, color: colors.ink500),
                ),
              ],
            ),
          ),
          PressableScale(
            onTap: re.dbId != null ? onEdit : null,
            child: Container(
              width: 32,
              height: 32,
              margin: const EdgeInsets.only(left: 6),
              decoration: BoxDecoration(
                color: colors.accentSoft,
              ),
              child: Icon(
                Icons.edit_outlined,
                size: 14,
                color: colors.accentDeep,
              ),
            ),
          ),
          PressableScale(
            onTap: onRemove,
            child: Container(
              width: 32,
              height: 32,
              margin: const EdgeInsets.only(left: 6),
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.08),
              ),
              child: Icon(
                Icons.delete_outline,
                size: 14,
                color: Colors.red.withValues(alpha: 0.7),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _NameSection extends StatelessWidget {
  const _NameSection({
    required this.label,
    required this.controller,
    required this.onSubmitted,
  });

  final String label;
  final TextEditingController controller;
  final ValueChanged<String> onSubmitted;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Padding(
      padding: const EdgeInsets.fromLTRB(22, 20, 22, 22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionEyebrow(text: label),
          const SizedBox(height: 10),
          TextField(
            controller: controller,
            cursorColor: colors.accent,
            style: TextStyle(
              fontSize: 22,
              color: colors.ink900,
              fontWeight: FontWeight.w500,
              letterSpacing: -0.25,
            ),
            decoration: const InputDecoration(
              border: InputBorder.none,
              isDense: true,
              contentPadding: EdgeInsets.zero,
            ),
            onSubmitted: onSubmitted,
          ),
        ],
      ),
    );
  }
}

class _ColorSection extends StatelessWidget {
  const _ColorSection({
    required this.label,
    required this.selectedValue,
    required this.onSelected,
  });

  final String label;
  final int selectedValue;
  final ValueChanged<Color> onSelected;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(22, 20, 22, 22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionEyebrow(text: label),
          const SizedBox(height: 14),
          RoutineColorPicker(
            colors: _kColors,
            selectedColorValue: selectedValue,
            onSelected: onSelected,
          ),
        ],
      ),
    );
  }
}

class _IconSection extends StatelessWidget {
  const _IconSection({
    required this.label,
    required this.selectedCode,
    required this.onSelected,
  });

  final String label;
  final int selectedCode;
  final ValueChanged<IconData> onSelected;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(22, 20, 22, 22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionEyebrow(text: label),
          const SizedBox(height: 14),
          RoutineIconPicker(
            icons: _kIcons,
            selectedCode: selectedCode,
            onSelected: onSelected,
          ),
        ],
      ),
    );
  }
}

class _BottomCta extends StatelessWidget {
  const _BottomCta({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return PressableScale(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 60,
        decoration: BoxDecoration(
          color: colors.accent,
          border: Border(
            top: BorderSide(
              color: colors.accentDeep.withValues(alpha: 0.4),
              width: 0.6,
            ),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 18),
            const SizedBox(width: 10),
            Text(
              label.toUpperCase(),
              style: const TextStyle(
                fontSize: 13,
                color: Colors.white,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
