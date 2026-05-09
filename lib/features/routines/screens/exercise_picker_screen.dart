import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:versatile/l10n/app_localizations.dart';
import '../../../core/navigation/app_page_transitions.dart';
import '../../../core/theme/app_colors.dart';
import '../../../domain/entities/routine.dart';
import '../../../core/utils/l10n_utils.dart';
import '../../../shared/widgets/glass_button.dart';
import '../../../shared/widgets/glass_container.dart';
import '../../../shared/widgets/motion.dart';
import '../../../shared/widgets/screen_header.dart';
import '../../exercises/screens/add_exercise_screen.dart';
import '../../exercises/view_models/exercises_view_model.dart';
import '../view_models/routines_view_model.dart';

String? _muscleAsset(String muscle) => switch (muscle) {
  'Chest' =>
    'assets/assets/Torso/pecho/pecho_edit_24359279032740.png',
  'Back' =>
    'assets/assets/Torso/espalda/back_edit_24411266380648.png',
  'Shoulders' =>
    'assets/assets/Torso/hombro/shoulder_edit_24384715995236.png',
  'Core' => 'assets/assets/Torso/core/Core_edit_24439960498352.png',
  'Biceps' =>
    'assets/assets/Torso/brazos/biceps_edit_24565456161875.png',
  'Triceps' =>
    'assets/assets/Torso/brazos/triceps_edit_24496361907719.png',
  'Forearms' =>
    'assets/assets/Torso/brazos/forearm_edit_24532082903547.png',
  'Quadriceps' => 'assets/assets/Piernas/cuadriceps.png',
  'Hamstrings' =>
    'assets/assets/Piernas/femoral_edit_24694965504563.png',
  'Glutes' => 'assets/assets/Piernas/glutes_edit_24675899562379.png',
  'Calves' => 'assets/assets/Piernas/calf_edit_24757805204033.png',
  _ => null,
};

// ─── Stepper / row helpers (shared by _ExerciseConfigDialog) ────────────────

Widget _dialogRow(BuildContext ctx, String label, Widget child) => Row(
  mainAxisAlignment: MainAxisAlignment.spaceBetween,
  children: [
    Text(
      label,
      style: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: ctx.colors.ink700,
      ),
    ),
    child,
  ],
);

Widget _stepBtn(BuildContext ctx, IconData icon, VoidCallback? onTap) =>
    GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 120),
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: onTap != null ? ctx.colors.accentTint : ctx.colors.fieldBg,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          size: 14,
          color: onTap != null ? ctx.colors.accentDeep : ctx.colors.ink400,
        ),
      ),
    );

// ─── Per-exercise configuration dialog ──────────────────────────────────────

class ExerciseConfigDialog extends StatefulWidget {
  const ExerciseConfigDialog({
    super.key,
    required this.exerciseName,
    required this.index,
    required this.total,
    this.initialSets = 3,
    this.initialReps = '8-12',
    this.initialRest = 90,
  });

  final String exerciseName;
  final int index;
  final int total;
  final int initialSets;
  final String initialReps;
  final int initialRest;

  @override
  State<ExerciseConfigDialog> createState() => _ExerciseConfigDialogState();
}

class _ExerciseConfigDialogState extends State<ExerciseConfigDialog> {
  late int _sets;
  late int _rest;
  late final TextEditingController _repsCtrl;

  @override
  void initState() {
    super.initState();
    _sets = widget.initialSets;
    _rest = widget.initialRest;
    _repsCtrl = TextEditingController(text: widget.initialReps);
  }

  @override
  void dispose() {
    _repsCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return AlertDialog(
      backgroundColor: context.colors.bgFrame,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      titlePadding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (widget.total > 1)
            Text(
              '${widget.index + 1} / ${widget.total}',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: context.colors.ink400,
              ),
            ),
          if (widget.total > 1) const SizedBox(height: 3),
          Text(
            widget.exerciseName,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: context.colors.ink900,
            ),
          ),
        ],
      ),
      contentPadding: const EdgeInsets.fromLTRB(24, 20, 24, 8),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _dialogRow(
            context,
            l10n.setsLabel,
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _stepBtn(
                  context,
                  Icons.remove,
                  _sets > 1 ? () => setState(() => _sets--) : null,
                ),
                SizedBox(
                  width: 40,
                  child: Text(
                    '$_sets',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: context.colors.ink900,
                    ),
                  ),
                ),
                _stepBtn(
                  context,
                  Icons.add,
                  _sets < 20 ? () => setState(() => _sets++) : null,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _dialogRow(
            context,
            l10n.repsRangeLabel,
            SizedBox(
              width: 96,
              height: 36,
              child: Container(
                decoration: BoxDecoration(
                  color: context.colors.fieldBg,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: TextField(
                  controller: _repsCtrl,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: context.colors.ink900,
                  ),
                  decoration: InputDecoration(
                    hintText: '8-12',
                    hintStyle: TextStyle(color: context.colors.ink400),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 8,
                    ),
                    isDense: true,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          _dialogRow(
            context,
            l10n.restSecondsLabel,
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _stepBtn(
                  context,
                  Icons.remove,
                  _rest >= 15 ? () => setState(() => _rest -= 15) : null,
                ),
                SizedBox(
                  width: 40,
                  child: Text(
                    '$_rest',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: context.colors.ink900,
                    ),
                  ),
                ),
                _stepBtn(
                  context,
                  Icons.add,
                  _rest <= 585 ? () => setState(() => _rest += 15) : null,
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(null),
          child: Text(
            l10n.cancel,
            style: TextStyle(color: context.colors.ink500),
          ),
        ),
        TextButton(
          onPressed: () {
            final r = _repsCtrl.text.trim();
            Navigator.of(context).pop((
              sets: _sets,
              reps: r.isEmpty ? '8-12' : r,
              rest: _rest,
            ));
          },
          child: Text(
            l10n.apply,
            style: TextStyle(
              color: context.colors.accentDeep,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}

// ─── Exercise picker ─────────────────────────────────────────────────────────

class ExercisePickerScreen extends ConsumerStatefulWidget {
  const ExercisePickerScreen({super.key, required this.routineId});
  final String routineId;

  @override
  ConsumerState<ExercisePickerScreen> createState() =>
      _ExercisePickerScreenState();
}

class _ExercisePickerScreenState extends ConsumerState<ExercisePickerScreen> {
  String _query = '';
  final Set<String> _selectedIds = {};

  Future<({int sets, String reps, int rest})?> _showConfigureDialog({
    required String exerciseName,
    required int index,
    required int total,
  }) {
    return showDialog<({int sets, String reps, int rest})>(
      context: context,
      builder: (_) => ExerciseConfigDialog(
        exerciseName: exerciseName,
        index: index,
        total: total,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final allExercises = ref.watch(exercisesAsyncProvider).value ?? [];
    final filtered = allExercises.where((e) {
      if (_query.isEmpty) return true;
      return e
          .getLocalizedName(context)
          .toLowerCase()
          .contains(_query.toLowerCase());
    }).toList();

    return Scaffold(
      backgroundColor: context.colors.bgApp,
      body: SafeArea(
        child: Column(
          children: [
            ScreenHeader(
              title: l10n.addExerciseTitle,
              subtitle: l10n.inLibrary(allExercises.length),
              onBack: () => Navigator.of(context).pop(),
              accentBack: true,
              trailing: PressableScale(
                onTap: () async {
                  await Navigator.of(context).push(
                    AppRoute(page: const AddExerciseScreen()),
                  );
                },
                child: Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: context.colors.accentTint,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: context.colors.accent.withValues(alpha: 0.3),
                      width: 0.5,
                    ),
                  ),
                  child: Icon(
                    Icons.add,
                    size: 20,
                    color: context.colors.accentDeep,
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
              child: GlassContainer(
                radius: 14,
                height: 44,
                child: Row(
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(left: 12),
                      child: Icon(Icons.search, size: 16, color: Colors.grey),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        onChanged: (v) => setState(() => _query = v),
                        decoration: InputDecoration(
                          hintText: l10n.search,
                          hintStyle: TextStyle(
                            fontSize: 14,
                            color: context.colors.ink400,
                          ),
                          border: InputBorder.none,
                          isDense: true,
                        ),
                        style: TextStyle(
                          fontSize: 14,
                          color: context.colors.ink900,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.fromLTRB(22, 0, 22, 100),
                itemCount: filtered.length,
                separatorBuilder: (_, _) => const SizedBox(height: 8),
                itemBuilder: (context, i) {
                  final ex = filtered[i];
                  final isSelected = _selectedIds.contains(ex.id);
                  final asset = _muscleAsset(ex.muscle);
                  return PressableScale(
                    onTap: () {
                      setState(() {
                        if (isSelected) {
                          _selectedIds.remove(ex.id);
                        } else {
                          _selectedIds.add(ex.id);
                        }
                      });
                    },
                    child: GlassContainer(
                      radius: 16,
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        children: [
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 150),
                            width: 20,
                            height: 20,
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? context.colors.accent
                                  : context.colors.fieldBg,
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(
                                color: isSelected
                                    ? Colors.transparent
                                    : context.colors.glassBorder,
                              ),
                            ),
                            child: isSelected
                                ? const Icon(Icons.check,
                                    size: 14, color: Colors.white)
                                : null,
                          ),
                          const SizedBox(width: 12),
                          Container(
                            width: 38,
                            height: 38,
                            decoration: BoxDecoration(
                              color: context.colors.accentTint,
                              borderRadius: BorderRadius.circular(11),
                            ),
                            child: asset != null
                                ? Padding(
                                    padding: const EdgeInsets.all(7),
                                    child: Image.asset(
                                      asset,
                                      fit: BoxFit.contain,
                                    ),
                                  )
                                : Icon(
                                    Icons.fitness_center,
                                    size: 18,
                                    color: context.colors.accentDeep,
                                  ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        ex.getLocalizedName(context),
                                        style: TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w600,
                                          color: context.colors.ink900,
                                        ),
                                      ),
                                    ),
                                    if (ex.isUnilateral) ...[
                                      const SizedBox(width: 6),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 5,
                                          vertical: 1,
                                        ),
                                        decoration: BoxDecoration(
                                          color: const Color(0x1A5E7BA7),
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                        child: Text(
                                          l10n.unilateral_label,
                                          style: const TextStyle(
                                            fontSize: 9,
                                            fontWeight: FontWeight.w700,
                                            color: Color(0xFF5E7BA7),
                                            letterSpacing: 0.05,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                                Text(
                                  ex.getLocalizedMuscle(context),
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: context.colors.ink500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(22),
              child: GlassButton(
                label: _selectedIds.isEmpty
                    ? l10n.done
                    : '${l10n.done} (${_selectedIds.length})',
                variant: GlassButtonVariant.primary,
                size: GlassButtonSize.lg,
                expand: true,
                onPressed: _selectedIds.isEmpty
                    ? null
                    : () async {
                        final nav = Navigator.of(context);
                        final exercises =
                            ref.read(exercisesAsyncProvider).value ?? [];
                        final ids = _selectedIds.toList();
                        final total = ids.length;

                        // Pre-capture localized names before any async gap.
                        final entries = ids.map((id) {
                          final ex = exercises.firstWhere(
                            (e) => e.id == id,
                            orElse: () => exercises.first,
                          );
                          return (id: id, name: ex.getLocalizedName(context));
                        }).toList();

                        // One dialog per exercise; cancelling aborts all.
                        final configs =
                            <({String id, int sets, String reps, int rest})>[];
                        for (var i = 0; i < entries.length; i++) {
                          final params = await _showConfigureDialog(
                            exerciseName: entries[i].name,
                            index: i,
                            total: total,
                          );
                          if (params == null || !mounted) return;
                          configs.add((
                            id: entries[i].id,
                            sets: params.sets,
                            reps: params.reps,
                            rest: params.rest,
                          ));
                        }

                        for (final cfg in configs) {
                          await ref
                              .read(routinesProvider.notifier)
                              .addExercise(
                                widget.routineId,
                                RoutineExercise(
                                  exerciseId: cfg.id,
                                  targetSets: cfg.sets,
                                  targetReps: cfg.reps,
                                  restSeconds: cfg.rest,
                                ),
                              );
                        }
                        nav.pop();
                      },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
