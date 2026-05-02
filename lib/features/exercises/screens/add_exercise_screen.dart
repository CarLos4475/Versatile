import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../../core/theme/app_colors.dart';
import '../../../domain/entities/exercise.dart';
import '../../../shared/widgets/glass_button.dart';
import '../../../shared/widgets/glass_container.dart';
import '../../../shared/widgets/motion.dart';
import '../../../shared/widgets/screen_header.dart';
import '../view_models/exercises_view_model.dart';

const _kMuscleGroups = [
  'Chest',
  'Back',
  'Shoulders',
  'Arms',
  'Core',
  'Legs',
  'Other',
];

const _kEquipment = [
  'Barbell',
  'Dumbbell',
  'Cable',
  'Machine',
  'Bodyweight',
  'Other',
];

class AddExerciseScreen extends ConsumerStatefulWidget {
  const AddExerciseScreen({super.key});

  @override
  ConsumerState<AddExerciseScreen> createState() => _AddExerciseScreenState();
}

class _AddExerciseScreenState extends ConsumerState<AddExerciseScreen> {
  final _ctrl = TextEditingController();
  String _muscleGroup = 'Chest';
  String? _subMuscle;
  String _equipment = 'Barbell';
  bool _isUnilateral = false;
  bool _saving = false;

  String get _effectiveMuscle => _subMuscle ?? _muscleGroup;

  List<String> get _subMuscles {
    if (_muscleGroup == 'Arms') return kArmsSubMuscles;
    if (_muscleGroup == 'Legs') return kLegsSubMuscles;
    return [];
  }

  void _onGroupChanged(String group) {
    setState(() {
      _muscleGroup = group;
      if (group == 'Arms') {
        _subMuscle = kArmsSubMuscles.first;
      } else if (group == 'Legs') {
        _subMuscle = kLegsSubMuscles.first;
      } else {
        _subMuscle = null;
      }
    });
  }

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
      muscle: _effectiveMuscle,
      equipment: _equipment,
      isCustom: true,
      isUnilateral: _isUnilateral,
    );
    await ref.read(exercisesAsyncProvider.notifier).addExercise(exercise);
    if (!mounted) return;
    Navigator.of(context).pop(exercise);
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Scaffold(
      backgroundColor: context.colors.bgApp,
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ScreenHeader(
              title: 'New Exercise',
              subtitle: 'Add a custom exercise',
              onBack: () => Navigator.of(context).pop(),
              accentBack: true,
            ),
            Expanded(
              child: SingleChildScrollView(
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                padding: EdgeInsets.only(bottom: bottomInset + 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 24),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 22),
                      child: GlassContainer(
                        radius: 16,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 4,
                        ),
                        child: TextField(
                          controller: _ctrl,
                          autofocus: true,
                          style: TextStyle(
                            fontSize: 16,
                            color: context.colors.ink900,
                            fontWeight: FontWeight.w500,
                          ),
                          decoration: InputDecoration(
                            hintText: 'Exercise name…',
                            hintStyle: TextStyle(
                              fontSize: 16,
                              color: context.colors.ink400,
                            ),
                            border: InputBorder.none,
                            contentPadding:
                                EdgeInsets.symmetric(vertical: 14),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 24),
                    _SectionLabel('MUSCLE GROUP'),
                    SizedBox(height: 10),
                    SizedBox(
                      height: 36,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        padding:
                            const EdgeInsets.symmetric(horizontal: 22),
                        itemCount: _kMuscleGroups.length,
                        separatorBuilder: (_, __) =>
                            SizedBox(width: 8),
                        itemBuilder: (context, i) {
                          final g = _kMuscleGroups[i];
                          final active = _muscleGroup == g;
                          return PressableScale(
                            onTap: () => _onGroupChanged(g),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 160),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: active
                                    ? context.colors.accentDeep
                                    : context.colors.glassBg,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: active
                                      ? Colors.transparent
                                      : context.colors.glassBorder,
                                  width: 0.5,
                                ),
                              ),
                              child: Text(
                                g,
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: active
                                      ? Colors.white
                                      : context.colors.ink700,
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
                      child: _subMuscles.isNotEmpty
                          ? Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: SizedBox(
                                height: 36,
                                child: ListView.separated(
                                  scrollDirection: Axis.horizontal,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 22),
                                  itemCount: _subMuscles.length,
                                  separatorBuilder: (_, __) =>
                                      SizedBox(width: 8),
                                  itemBuilder: (context, i) {
                                    final m = _subMuscles[i];
                                    final active = _subMuscle == m;
                                    return PressableScale(
                                      onTap: () =>
                                          setState(() => _subMuscle = m),
                                      child: AnimatedContainer(
                                        duration: const Duration(
                                            milliseconds: 160),
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 14,
                                          vertical: 8,
                                        ),
                                        decoration: BoxDecoration(
                                          color: active
                                              ? context.colors.accent
                                              : context.colors.glassBg,
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          border: Border.all(
                                            color: active
                                                ? Colors.transparent
                                                : context.colors.glassBorder,
                                            width: 0.5,
                                          ),
                                        ),
                                        child: Text(
                                          m,
                                          style: TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w600,
                                            color: active
                                                ? Colors.white
                                                : context.colors.ink700,
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            )
                          : SizedBox.shrink(),
                    ),
                    SizedBox(height: 20),
                    _SectionLabel('EQUIPMENT'),
                    SizedBox(height: 10),
                    SizedBox(
                      height: 36,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        padding:
                            const EdgeInsets.symmetric(horizontal: 22),
                        itemCount: _kEquipment.length,
                        separatorBuilder: (_, __) =>
                            SizedBox(width: 8),
                        itemBuilder: (context, i) {
                          final opt = _kEquipment[i];
                          final active = opt == _equipment;
                          return PressableScale(
                            onTap: () =>
                                setState(() => _equipment = opt),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 160),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: active
                                    ? context.colors.accentDeep
                                    : context.colors.glassBg,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: active
                                      ? Colors.transparent
                                      : context.colors.glassBorder,
                                  width: 0.5,
                                ),
                              ),
                              child: Text(
                                opt,
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: active
                                      ? Colors.white
                                      : context.colors.ink700,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    SizedBox(height: 24),
                    Padding(
                      padding:
                          const EdgeInsets.symmetric(horizontal: 22),
                      child: PressableScale(
                        onTap: () =>
                            setState(() => _isUnilateral = !_isUnilateral),
                        child: Row(
                          children: [
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 160),
                              width: 44,
                              height: 26,
                              decoration: BoxDecoration(
                                color: _isUnilateral
                                    ? context.colors.accentDeep
                                    : context.colors.glassBg,
                                borderRadius: BorderRadius.circular(13),
                                border: Border.all(
                                  color: _isUnilateral
                                      ? Colors.transparent
                                      : context.colors.glassBorder,
                                  width: 0.5,
                                ),
                              ),
                              child: AnimatedAlign(
                                duration:
                                    const Duration(milliseconds: 160),
                                alignment: _isUnilateral
                                    ? Alignment.centerRight
                                    : Alignment.centerLeft,
                                child: Container(
                                  width: 20,
                                  height: 20,
                                  margin: const EdgeInsets.symmetric(
                                      horizontal: 3),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle,
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
                                    'Unilateral exercise',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: context.colors.ink900,
                                    ),
                                  ),
                                  Text(
                                    'Track left and right sides separately',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: context.colors.ink400,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 32),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 22),
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
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.label);
  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 22),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.06,
          color: context.colors.ink400,
        ),
      ),
    );
  }
}