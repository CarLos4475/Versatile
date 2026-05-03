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

  Future<({int sets, String reps, int rest})?> _showConfigureDialog() async {
    final l10n = AppLocalizations.of(context)!;
    final repsCtrl = TextEditingController(text: '8-12');

    final result = await showDialog<({int sets, String reps, int rest})>(
      context: context,
      builder: (ctx) {
        var sets = 3;
        var rest = 90;
        return StatefulBuilder(
          builder: (ctx, setDialogState) => AlertDialog(
            backgroundColor: ctx.colors.bgFrame,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: Text(
              l10n.configureExercise,
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: ctx.colors.ink900,
              ),
            ),
            contentPadding: const EdgeInsets.fromLTRB(24, 20, 24, 8),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _dialogRow(
                  ctx,
                  l10n.setsLabel,
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _stepBtn(
                        ctx,
                        Icons.remove,
                        sets > 1 ? () => setDialogState(() => sets--) : null,
                      ),
                      SizedBox(
                        width: 40,
                        child: Text(
                          '$sets',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: ctx.colors.ink900,
                          ),
                        ),
                      ),
                      _stepBtn(
                        ctx,
                        Icons.add,
                        sets < 20 ? () => setDialogState(() => sets++) : null,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                _dialogRow(
                  ctx,
                  l10n.repsRangeLabel,
                  SizedBox(
                    width: 96,
                    height: 36,
                    child: Container(
                      decoration: BoxDecoration(
                        color: ctx.colors.fieldBg,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: TextField(
                        controller: repsCtrl,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: ctx.colors.ink900,
                        ),
                        decoration: InputDecoration(
                          hintText: '8-12',
                          hintStyle: TextStyle(color: ctx.colors.ink400),
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
                  ctx,
                  l10n.restSecondsLabel,
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _stepBtn(
                        ctx,
                        Icons.remove,
                        rest >= 15
                            ? () => setDialogState(() => rest -= 15)
                            : null,
                      ),
                      SizedBox(
                        width: 40,
                        child: Text(
                          '$rest',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: ctx.colors.ink900,
                          ),
                        ),
                      ),
                      _stepBtn(
                        ctx,
                        Icons.add,
                        rest <= 585
                            ? () => setDialogState(() => rest += 15)
                            : null,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(null),
                child: Text(
                  l10n.cancel,
                  style: TextStyle(color: ctx.colors.ink500),
                ),
              ),
              TextButton(
                onPressed: () {
                  final r = repsCtrl.text.trim();
                  Navigator.of(ctx).pop((
                    sets: sets,
                    reps: r.isEmpty ? '8-12' : r,
                    rest: rest,
                  ));
                },
                child: Text(
                  l10n.apply,
                  style: TextStyle(
                    color: ctx.colors.accentDeep,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );

    repsCtrl.dispose();
    return result;
  }

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

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final allExercises = ref.watch(exercisesAsyncProvider).value ?? [];
    final filtered = allExercises.where((e) {
      if (_query.isEmpty) return true;
      return e.getLocalizedName(context).toLowerCase().contains(_query.toLowerCase());
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
                      padding: const EdgeInsets.all(14),
                      child: Row(
                        children: [
                          Container(
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
                label: l10n.done,
                variant: GlassButtonVariant.primary,
                size: GlassButtonSize.lg,
                expand: true,
                onPressed: _selectedIds.isEmpty
                    ? null
                    : () async {
                        final nav = Navigator.of(context);
                        final params = await _showConfigureDialog();
                        if (params == null || !mounted) return;
                        for (final id in _selectedIds) {
                          await ref
                              .read(routinesProvider.notifier)
                              .addExercise(
                                widget.routineId,
                                RoutineExercise(
                                  exerciseId: id,
                                  targetSets: params.sets,
                                  targetReps: params.reps,
                                  restSeconds: params.rest,
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
