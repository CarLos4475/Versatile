import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../../core/theme/app_colors.dart';
import '../../../domain/entities/exercise.dart';
import '../../../shared/widgets/glass_button.dart';
import '../../../shared/widgets/glass_container.dart';
import '../../../shared/widgets/screen_header.dart';
import '../view_models/exercises_view_model.dart';

const _kMuscles = [
  'Chest', 'Back', 'Legs', 'Shoulders', 'Arms', 'Core',
];

const _kEquipment = [
  'Barbell', 'Dumbbell', 'Cable', 'Machine', 'Bodyweight', 'Other',
];

class AddExerciseScreen extends ConsumerStatefulWidget {
  const AddExerciseScreen({super.key});

  @override
  ConsumerState<AddExerciseScreen> createState() => _AddExerciseScreenState();
}

class _AddExerciseScreenState extends ConsumerState<AddExerciseScreen> {
  final _ctrl = TextEditingController();
  String _muscle = 'Chest';
  String _equipment = 'Barbell';
  bool _saving = false;

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final name = _ctrl.text.trim();
    if (name.isEmpty) return;
    setState(() => _saving = true);
    final exercise = Exercise(
      id: const Uuid().v4(),
      name: name,
      muscle: _muscle,
      equipment: _equipment,
      isCustom: true,
    );
    await ref.read(exercisesAsyncProvider.notifier).addExercise(exercise);
    if (!mounted) return;
    Navigator.of(context).pop(exercise);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgApp,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ScreenHeader(
              title: 'New Exercise',
              subtitle: 'Add a custom exercise',
              onBack: () => Navigator.of(context).pop(),
            ),
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 22),
              child: GlassContainer(
                radius: 16,
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: TextField(
                  controller: _ctrl,
                  autofocus: true,
                  style: const TextStyle(
                    fontSize: 16,
                    color: AppColors.ink900,
                    fontWeight: FontWeight.w500,
                  ),
                  decoration: const InputDecoration(
                    hintText: 'Exercise name…',
                    hintStyle:
                        TextStyle(fontSize: 16, color: AppColors.ink400),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            _Section(
              label: 'MUSCLE GROUP',
              options: _kMuscles,
              selected: _muscle,
              onSelected: (v) => setState(() => _muscle = v),
            ),
            const SizedBox(height: 20),
            _Section(
              label: 'EQUIPMENT',
              options: _kEquipment,
              selected: _equipment,
              onSelected: (v) => setState(() => _equipment = v),
            ),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.fromLTRB(22, 0, 22, 24),
              child: GlassButton(
                label: 'Save Exercise',
                variant: GlassButtonVariant.primary,
                size: GlassButtonSize.lg,
                expand: true,
                loading: _saving,
                onPressed: _saving ? null : _save,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({
    required this.label,
    required this.options,
    required this.selected,
    required this.onSelected,
  });

  final String label;
  final List<String> options;
  final String selected;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 22),
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.06,
              color: AppColors.ink400,
            ),
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 36,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 22),
            itemCount: options.length,
            separatorBuilder: (context, index) => const SizedBox(width: 8),
            itemBuilder: (context, i) {
              final opt = options[i];
              final active = opt == selected;
              return GestureDetector(
                onTap: () => onSelected(opt),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 160),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: active
                        ? AppColors.accentDeep
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
                    opt,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: active ? Colors.white : AppColors.ink700,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
