import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:versatile/l10n/app_localizations.dart';
import 'package:uuid/uuid.dart';
import '../../../core/theme/app_colors.dart';
import '../../../domain/entities/exercise.dart';
import '../../../core/utils/l10n_utils.dart';
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
                    return _MagChoiceChip(
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
    final colors = context.colors;
    return Scaffold(
      backgroundColor: colors.bgApp,
      body: SafeArea(
        child: Column(
          children: [
            ScreenHeader(
              prefix: Localizations.localeOf(context).languageCode == 'es'
                  ? 'Nuevo'
                  : 'New',
              accent: Localizations.localeOf(context).languageCode == 'es'
                  ? 'ejercicio.'
                  : 'exercise.',
              eyebrow: l10n.addCustomExercise,
              onBack: () => Navigator.of(context).pop(),
              accentBack: true,
            ),
            const _GridDivider(),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _MagFieldBlock(
                      eyebrow: l10n.exerciseName,
                      child: Container(
                        height: 48,
                        color: colors.bgFrame,
                        padding: const EdgeInsets.symmetric(horizontal: 22),
                        child: TextField(
                          controller: _nameCtrl,
                          style: TextStyle(
                            color: colors.ink900,
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                          ),
                          decoration: InputDecoration(
                            hintText: l10n.egBenchPress,
                            hintStyle: TextStyle(color: colors.ink400),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                        ),
                      ),
                    ),
                    const _GridDivider(),
                    _MagFieldBlock(
                      eyebrow: l10n.muscleGroup,
                      child: SizedBox(
                        height: 36,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(horizontal: 22),
                          itemCount: _mainMuscles.length,
                          separatorBuilder: (_, __) => const SizedBox(width: 8),
                          itemBuilder: (ctx, i) {
                            final m = _mainMuscles[i];
                            final dummy = Exercise(id: '', name: '', muscle: m, equipment: '');
                            return _MagChoiceChip(
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
                      extra: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 22),
                        child: _buildSubMuscleRow(),
                      ),
                    ),
                    const _GridDivider(),
                    _MagFieldBlock(
                      eyebrow: l10n.category,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 22),
                        child: Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: _equipments.map((e) {
                            final dummy = Exercise(id: '', name: '', muscle: '', equipment: e);
                            return _MagChoiceChip(
                              label: dummy.getLocalizedEquipment(context),
                              isActive: _selectedEquip == e,
                              onTap: () => setState(() => _selectedEquip = e),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                    const _GridDivider(),
                    _MagFieldBlock(
                      eyebrow: l10n.bilateral,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 22),
                        child: Row(
                          children: [
                            _MagChoiceChip(
                              label: l10n.bilateral,
                              isActive: !_isUnilateral,
                              onTap: () => setState(() => _isUnilateral = false),
                            ),
                            const SizedBox(width: 8),
                            _MagChoiceChip(
                              label: l10n.unilateral,
                              isActive: _isUnilateral,
                              onTap: () => setState(() => _isUnilateral = true),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const _GridDivider(),
                  ],
                ),
              ),
            ),
            const _GridDivider(),
            Padding(
              padding: const EdgeInsets.all(22),
              child: PressableScale(
                onTap: _saving ? null : _save,
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 180),
                  opacity: _saving ? 0.6 : 1,
                  child: Container(
                    width: double.infinity,
                    height: 52,
                    decoration: BoxDecoration(
                      color: colors.accent,
                      border: Border.all(
                        color: colors.accentDeep.withValues(alpha: 0.6),
                        width: 0.6,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (_saving)
                          SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 1.5,
                              color: Colors.white,
                            ),
                          )
                        else
                          const Icon(Icons.check, color: Colors.white, size: 16),
                        const SizedBox(width: 8),
                        Text(
                          l10n.saveExercise.toUpperCase(),
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
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

class _MagEyebrow extends StatelessWidget {
  const _MagEyebrow({required this.text});
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

class _MagFieldBlock extends StatelessWidget {
  const _MagFieldBlock({
    required this.eyebrow,
    required this.child,
    this.extra,
  });

  final String eyebrow;
  final Widget child;
  final Widget? extra;

  @override
  Widget build(BuildContext context) {
    return FadeSlideIn(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 22),
              child: _MagEyebrow(text: eyebrow),
            ),
            const SizedBox(height: 14),
            child,
            if (extra != null) extra!,
          ],
        ),
      ),
    );
  }
}

class _MagChoiceChip extends StatelessWidget {
  const _MagChoiceChip({
    required this.label,
    required this.isActive,
    required this.onTap,
  });
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return PressableScale(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? colors.accentDeep : Colors.transparent,
          border: Border.all(
            color: isActive ? Colors.transparent : colors.hairline,
            width: 0.8,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: isActive ? Colors.white : colors.ink700,
          ),
        ),
      ),
    );
  }
}
