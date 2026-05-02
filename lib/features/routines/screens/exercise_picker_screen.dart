import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/navigation/app_page_transitions.dart';
import '../../../core/theme/app_colors.dart';
import '../../../domain/entities/exercise.dart';
import '../../../domain/entities/routine.dart';
import '../../../shared/widgets/glass_container.dart';
import '../../../shared/widgets/motion.dart';
import '../../../shared/widgets/screen_header.dart';
import '../../exercises/screens/add_exercise_screen.dart';
import '../../exercises/view_models/exercises_view_model.dart';
import '../view_models/routines_view_model.dart';

const _kPickerMuscleGroups = [
  'All',
  'Chest',
  'Back',
  'Shoulders',
  'Arms',
  'Core',
  'Legs',
  'Other',
];

class ExercisePickerScreen extends ConsumerStatefulWidget {
  const ExercisePickerScreen({super.key, required this.routineId});
  final String routineId;

  @override
  ConsumerState<ExercisePickerScreen> createState() =>
      _ExercisePickerScreenState();
}

class _ExercisePickerScreenState extends ConsumerState<ExercisePickerScreen> {
  String _query = '';
  String _muscle = 'All';
  String? _subMuscle;
  final _queryCtrl = TextEditingController();

  @override
  void dispose() {
    _queryCtrl.dispose();
    super.dispose();
  }

  List<String> get _subMuscles {
    if (_muscle == 'Arms') return kArmsSubMuscles;
    if (_muscle == 'Legs') return kLegsSubMuscles;
    return [];
  }

  bool get _hasSubRow => _muscle == 'Arms' || _muscle == 'Legs';

  void _pickExercise(Exercise exercise) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => _ConfigSheet(
        exercise: exercise,
        onConfirm: (re) async {
          await ref
              .read(routinesProvider.notifier)
              .addExercise(widget.routineId, re);
          if (mounted) Navigator.of(context).pop();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final allExercises = ref.watch(exercisesAsyncProvider).value ?? [];

    final filtered = allExercises.where((e) {
      if (_muscle != 'All') {
        if (_muscle == 'Arms') {
          if (_subMuscle != null) {
            if (e.muscle != _subMuscle) return false;
          } else {
            if (!kArmsSet.contains(e.muscle)) return false;
          }
        } else if (_muscle == 'Legs') {
          if (_subMuscle != null) {
            if (e.muscle != _subMuscle) return false;
          } else {
            if (!kLegsSet.contains(e.muscle)) return false;
          }
        } else {
          if (e.muscle != _muscle) return false;
        }
      }
      if (_query.isNotEmpty &&
          !e.name.toLowerCase().contains(_query.toLowerCase())) {
        return false;
      }
      return true;
    }).toList();

    return Scaffold(
      backgroundColor: AppColors.bgApp,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ScreenHeader(
              title: 'Add Exercise',
              subtitle: '${allExercises.length} in library',
              onBack: () => Navigator.of(context).pop(),
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
                    color: AppColors.accentTint,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppColors.accent.withOpacity(0.3),
                      width: 0.5,
                    ),
                  ),
                  child: const Icon(
                    Icons.add,
                    size: 20,
                    color: AppColors.accentDeep,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 22),
              child: GlassContainer(
                radius: 14,
                height: 44,
                child: Row(
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(left: 12),
                      child: Icon(
                        Icons.search,
                        size: 16,
                        color: AppColors.ink400,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        controller: _queryCtrl,
                        onChanged: (v) => setState(() => _query = v),
                        decoration: const InputDecoration(
                          hintText: 'Search…',
                          hintStyle: TextStyle(
                            fontSize: 14,
                            color: AppColors.ink400,
                          ),
                          border: InputBorder.none,
                          isDense: true,
                          contentPadding: EdgeInsets.zero,
                        ),
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppColors.ink900,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              height: 32,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 22),
                itemCount: _kPickerMuscleGroups.length,
                separatorBuilder: (context, index) => const SizedBox(width: 6),
                itemBuilder: (context, i) {
                  final m = _kPickerMuscleGroups[i];
                  final active = _muscle == m;
                  return PressableScale(
                    onTap: () => setState(() {
                      _muscle = m;
                      _subMuscle = null;
                    }),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: active ? AppColors.accentDeep : AppColors.glassBg,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: active
                              ? Colors.transparent
                              : AppColors.glassBorder,
                          width: 0.5,
                        ),
                      ),
                      child: Text(
                        m,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: active ? Colors.white : AppColors.ink700,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            AnimatedSize(
              duration: const Duration(milliseconds: 240),
              curve: Curves.easeOutCubic,
              alignment: Alignment.topLeft,
              child: _hasSubRow
                  ? Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: SizedBox(
                        height: 32,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(horizontal: 22),
                          itemCount: _subMuscles.length,
                          separatorBuilder: (_, __) => const SizedBox(width: 6),
                          itemBuilder: (context, i) {
                            final m = _subMuscles[i];
                            final active = _subMuscle == m;
                            return PressableScale(
                              onTap: () => setState(() {
                                _subMuscle = active ? null : m;
                              }),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 150),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: active
                                      ? AppColors.accent
                                      : AppColors.glassBg,
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: active
                                        ? Colors.transparent
                                        : AppColors.glassBorder,
                                    width: 0.5,
                                  ),
                                ),
                                child: Text(
                                  m,
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: active ? Colors.white : AppColors.ink700,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    )
                  : const SizedBox.shrink(),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(
                  horizontal: 22,
                  vertical: 4,
                ),
                itemCount: filtered.length,
                separatorBuilder: (context, index) => const SizedBox(height: 6),
                itemBuilder: (context, i) =>
                    _ExerciseRow(exercise: filtered[i], onPick: _pickExercise),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ExerciseRow extends StatelessWidget {
  const _ExerciseRow({required this.exercise, required this.onPick});
  final Exercise exercise;
  final ValueChanged<Exercise> onPick;

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      radius: 14,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        exercise.name,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.ink900,
                        ),
                      ),
                    ),
                    if (exercise.isCustom) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 5,
                          vertical: 1,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.accentTint,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          'CUSTOM',
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                            color: AppColors.accentDeep,
                            letterSpacing: 0.05,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  '${exercise.muscle} · ${exercise.equipment}',
                  style: const TextStyle(fontSize: 12, color: AppColors.ink500),
                ),
              ],
            ),
          ),
          PressableScale(
            onTap: () => onPick(exercise),
            child: Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: AppColors.accentTint,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.add,
                size: 16,
                color: AppColors.accentDeep,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ConfigSheet extends StatefulWidget {
  const _ConfigSheet({required this.exercise, required this.onConfirm});
  final Exercise exercise;
  final Future<void> Function(RoutineExercise) onConfirm;

  @override
  State<_ConfigSheet> createState() => _ConfigSheetState();
}

class _ConfigSheetState extends State<_ConfigSheet> {
  int _sets = 3;
  final _repsCtrl = TextEditingController(text: '8-12');
  int _restSeconds = 60;
  bool _saving = false;

  @override
  void dispose() {
    _repsCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      padding: const EdgeInsets.fromLTRB(22, 20, 22, 32),
      decoration: const BoxDecoration(
        color: AppColors.bgFrame,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.ink300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            widget.exercise.name,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              letterSpacing: -0.18,
              color: AppColors.ink900,
            ),
          ),
          Text(
            '${widget.exercise.muscle} · ${widget.exercise.equipment}',
            style: const TextStyle(fontSize: 13, color: AppColors.ink400),
          ),
          const SizedBox(height: 24),
          _ConfigRow(
            label: 'Sets',
            child: _Stepper(
              value: _sets,
              onDecrement: () =>
                  setState(() => _sets = (_sets - 1).clamp(1, 20)),
              onIncrement: () =>
                  setState(() => _sets = (_sets + 1).clamp(1, 20)),
              display: '$_sets',
            ),
          ),
          const SizedBox(height: 14),
          _ConfigRow(
            label: 'Reps',
            child: SizedBox(
              width: 120,
              child: TextField(
                controller: _repsCtrl,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppColors.ink900,
                ),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: const Color(0x0A000000),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 14),
          _ConfigRow(
            label: 'Rest',
            child: _Stepper(
              value: _restSeconds,
              onDecrement: () => setState(
                () => _restSeconds = (_restSeconds - 15).clamp(0, 600),
              ),
              onIncrement: () => setState(
                () => _restSeconds = (_restSeconds + 15).clamp(0, 600),
              ),
              display: '${_restSeconds}s',
            ),
          ),
          const SizedBox(height: 28),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accentDeep,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              onPressed: _saving
                  ? null
                  : () async {
                      setState(() => _saving = true);
                      await widget.onConfirm(
                        RoutineExercise(
                          exerciseId: widget.exercise.id,
                          targetSets: _sets,
                          targetReps: _repsCtrl.text.trim().isEmpty
                              ? '8-12'
                              : _repsCtrl.text.trim(),
                          restSeconds: _restSeconds,
                        ),
                      );
                    },
              child: _saving
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text(
                      'Add to Routine',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ConfigRow extends StatelessWidget {
  const _ConfigRow({required this.label, required this.child});
  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w500,
            color: AppColors.ink700,
          ),
        ),
        child,
      ],
    );
  }
}

class _Stepper extends StatelessWidget {
  const _Stepper({
    required this.value,
    required this.onDecrement,
    required this.onIncrement,
    required this.display,
  });
  final int value;
  final VoidCallback onDecrement;
  final VoidCallback onIncrement;
  final String display;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _StepBtn(icon: Icons.remove, onTap: onDecrement),
        SizedBox(
          width: 48,
          child: Text(
            display,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.ink900,
            ),
          ),
        ),
        _StepBtn(icon: Icons.add, onTap: onIncrement),
      ],
    );
  }
}

class _StepBtn extends StatelessWidget {
  const _StepBtn({required this.icon, required this.onTap});
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return PressableScale(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: const Color(0x0A000000),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, size: 16, color: AppColors.ink700),
      ),
    );
  }
}
