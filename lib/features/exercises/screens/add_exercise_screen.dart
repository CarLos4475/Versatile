import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:versatile/l10n/app_localizations.dart';
import 'package:uuid/uuid.dart';
import '../../../core/theme/app_colors.dart';
import '../../../domain/entities/exercise.dart';
import '../../../core/utils/l10n_utils.dart';
import '../../../shared/widgets/glass_button.dart';
import '../../../shared/widgets/glass_container.dart';
import '../../../shared/widgets/motion.dart';
import '../../../shared/widgets/screen_header.dart';
import '../view_models/exercises_view_model.dart';

class AddExerciseScreen extends ConsumerStatefulWidget {
  const AddExerciseScreen({super.key});

  @override
  ConsumerState<AddExerciseScreen> createState() => _AddExerciseScreenState();
}

class _AddExerciseScreenState extends ConsumerState<AddExerciseScreen> {
  final _nameCtrl = TextEditingController();
  String _selectedMuscle = 'Chest';
  String? _selectedSubMuscle;
  String _selectedEquip = 'Barbell';
  bool _isUnilateral = false;
  bool _saving = false;

  final _mainMuscles = ['Chest', 'Back', 'Legs', 'Shoulders', 'Arms', 'Core'];
  final _equipments = ['Barbell', 'Dumbbell', 'Cable', 'Bodyweight', 'Machine'];

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final name = _nameCtrl.text.trim();
    if (name.isEmpty) return;
    setState(() => _saving = true);

    final ex = Exercise(
      id: const Uuid().v4(),
      name: name,
      muscle: _selectedSubMuscle ?? _selectedMuscle,
      equipment: _selectedEquip,
      isCustom: true,
      isUnilateral: _isUnilateral,
    );

    await ref.read(exercisesAsyncProvider.notifier).addExercise(ex);
    if (mounted) Navigator.of(context).pop();
  }

  Widget _buildSubMuscleRow() {
    final subs = switch (_selectedMuscle) {
      'Arms' => kArmsSubMuscles,
      'Legs' => kLegsSubMuscles,
      _ => <String>[],
    };

    return AnimatedSize(
      duration: const Duration(milliseconds: 240),
      curve: Curves.easeOutCubic,
      alignment: Alignment.topLeft,
      child: subs.isEmpty
          ? const SizedBox(width: double.infinity, height: 0)
          : Padding(
              padding: const EdgeInsets.only(top: 12),
              child: SizedBox(
                height: 32,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: subs.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (ctx, i) {
                    final m = subs[i];
                    final dummy = Exercise(id: '', name: '', muscle: m, equipment: '');
                    return _ChoiceChip(
                      label: dummy.getLocalizedMuscle(context),
                      isActive: _selectedSubMuscle == m,
                      onTap: () => setState(() => _selectedSubMuscle = m),
                    );
                  },
                ),
              ),
            ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: context.colors.bgApp,
      body: SafeArea(
        child: Column(
          children: [
            ScreenHeader(
              title: l10n.newExercise,
              subtitle: l10n.addCustomExercise,
              onBack: () => Navigator.of(context).pop(),
              accentBack: true,
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _Label(l10n.exerciseName),
                    const SizedBox(height: 10),
                    GlassContainer(
                      radius: 14,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: TextField(
                        controller: _nameCtrl,
                        style: TextStyle(color: context.colors.ink900),
                        decoration: InputDecoration(
                          hintText: l10n.egBenchPress,
                          hintStyle: TextStyle(color: context.colors.ink400),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                      ),
                    ),
                    const SizedBox(height: 28),
                    _Label(l10n.muscleGroup),
                    const SizedBox(height: 10),
                    SizedBox(
                      height: 36,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: _mainMuscles.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 8),
                        itemBuilder: (ctx, i) {
                          final m = _mainMuscles[i];
                          final dummy = Exercise(id: '', name: '', muscle: m, equipment: '');
                          return _ChoiceChip(
                            label: dummy.getLocalizedMuscle(context),
                            isActive: _selectedMuscle == m,
                            onTap: () => setState(() {
                              _selectedMuscle = m;
                              _selectedSubMuscle = null;
                            }),
                          );
                        },
                      ),
                    ),
                    _buildSubMuscleRow(),
                    const SizedBox(height: 28),
                    _Label(l10n.category),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _equipments.map((e) {
                        final dummy = Exercise(id: '', name: '', muscle: '', equipment: e);
                        return _ChoiceChip(
                          label: dummy.getLocalizedEquipment(context),
                          isActive: _selectedEquip == e,
                          onTap: () => setState(() => _selectedEquip = e),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 28),
                    Row(
                      children: [
                        _ChoiceChip(
                          label: l10n.bilateral,
                          isActive: !_isUnilateral,
                          onTap: () => setState(() => _isUnilateral = false),
                        ),
                        const SizedBox(width: 8),
                        _ChoiceChip(
                          label: l10n.unilateral,
                          isActive: _isUnilateral,
                          onTap: () => setState(() => _isUnilateral = true),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(22),
              child: GlassButton(
                label: l10n.saveExercise,
                variant: GlassButtonVariant.primary,
                size: GlassButtonSize.lg,
                expand: true,
                loading: _saving,
                onPressed: _save,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Label extends StatelessWidget {
  const _Label(this.text);
  final String text;
  @override
  Widget build(BuildContext context) => Text(
    text,
    style: TextStyle(
      fontSize: 11,
      fontWeight: FontWeight.w600,
      letterSpacing: 0.05,
      color: context.colors.ink400,
    ),
  );
}

class _ChoiceChip extends StatelessWidget {
  const _ChoiceChip({required this.label, required this.isActive, required this.onTap});
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return PressableScale(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? context.colors.accentDeep : context.colors.glassBg,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isActive ? Colors.transparent : context.colors.glassBorder,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: isActive ? Colors.white : context.colors.ink700,
          ),
        ),
      ),
    );
  }
}
