import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:versatile/l10n/app_localizations.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/exercise_category.dart';
import '../../../domain/entities/exercise.dart';
import '../../../core/utils/l10n_utils.dart';
import '../../../core/providers/repository_providers.dart';
import '../../../shared/widgets/filter_chip_widget.dart';
import '../../../shared/widgets/glass_button.dart';
import '../../../shared/widgets/glass_container.dart';
import '../../../shared/widgets/motion.dart';
import '../../../shared/widgets/screen_header.dart';
import '../../active_workout/view_models/active_workout_view_model.dart';
import '../view_models/exercises_view_model.dart';
import 'add_exercise_screen.dart';
import 'exercise_progress_screen.dart';

class ExercisesScreen extends ConsumerStatefulWidget {
  const ExercisesScreen({super.key});

  @override
  ConsumerState<ExercisesScreen> createState() => _ExercisesScreenState();
}

class _ExercisesScreenState extends ConsumerState<ExercisesScreen> {
  late TextEditingController _searchCtrl;
  final _firstExerciseKey = GlobalKey();
  final _addBtnKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _searchCtrl = TextEditingController(
      text: ref.read(exercisesProvider).query,
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        ref.read(exercisesSearchKeyProvider.notifier).state = _firstExerciseKey;
        ref.read(exercisesAddKeyProvider.notifier).state = _addBtnKey;
      }
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _confirmDelete(Set<String> ids) async {
    final l10n = AppLocalizations.of(context)!;
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: context.colors.bgFrame,
        scrollable: true,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          l10n.deleteExerciseTitle,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: context.colors.ink900,
          ),
        ),
        content: Text(
          l10n.deleteExerciseContent(ids.length),
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
              style: const TextStyle(
                color: Colors.red,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );

    if (ok == true) {
      await ref.read(exercisesAsyncProvider.notifier).deleteExercises(ids);
      ref.read(exercisesProvider.notifier).toggleEditMode();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final state = ref.watch(exercisesProvider);
    final notifier = ref.read(exercisesProvider.notifier);
    final allAsync = ref.watch(exercisesAsyncProvider);
    final filtered = ref.watch(filteredExercisesProvider);

    final allExercises = allAsync.value ?? [];
    final myCount = allExercises.where((e) => e.isCustom).length;

    // Synchronize controller with state query (useful when cleared from outside)
    if (_searchCtrl.text != state.query) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _searchCtrl.text = state.query;
        }
      });
    }

    return Scaffold(
      backgroundColor: context.colors.bgApp,
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ScreenHeader(
                  prefix: Localizations.localeOf(context).languageCode == 'es'
                      ? 'La'
                      : 'The',
                  accent: Localizations.localeOf(context).languageCode == 'es'
                      ? 'librería.'
                      : 'library.',
                  eyebrow: l10n.inLibrary(allExercises.length),
                  trailing: state.tab == ExercisesTab.mine && myCount > 0
                      ? Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            PressableScale(
                              onTap: notifier.toggleEditMode,
                              child: Container(
                                width: 38,
                                height: 38,
                                decoration: BoxDecoration(
                                  color: state.isEditMode
                                      ? context.colors.accent
                                      : Theme.of(context).brightness == Brightness.dark
                                          ? context.colors.glassBg
                                          : Colors.white,
                                  border: Border.all(
                                    color: state.isEditMode
                                        ? Colors.transparent
                                        : context.colors.glassBorder,
                                    width: 0.5,
                                  ),
                                  boxShadow: state.isEditMode
                                      ? [
                                          BoxShadow(
                                            color: context.colors.accentDeep
                                                .withValues(alpha: 0.3),
                                            blurRadius: 12,
                                            offset: const Offset(0, 4),
                                          ),
                                        ]
                                      : context.colors.glassShadow,
                                ),
                                child: Icon(
                                  state.isEditMode
                                      ? Icons.close
                                      : Icons.checklist_rtl_rounded,
                                  size: 20,
                                  color: state.isEditMode
                                      ? Colors.white
                                      : context.colors.ink700,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            KeyedSubtree(
                              key: _addBtnKey,
                              child: IconCircleButton(
                                icon: const Icon(Icons.add),
                                onPressed: () => Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => const AddExerciseScreen(),
                                  ),
                                ),
                                accent: true,
                              ),
                            ),
                          ],
                        )
                      : KeyedSubtree(
                          key: _addBtnKey,
                          child: IconCircleButton(
                            icon: const Icon(Icons.add),
                            onPressed: () => Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => const AddExerciseScreen(),
                              ),
                            ),
                            accent: true,
                          ),
                        ),
                ),
                const SizedBox(height: 14),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 22),
                  child: GlassContainer(
                    radius: 14,
                    padding: const EdgeInsets.all(4),
                    child: Stack(
                      children: [
                        AnimatedAlign(
                          duration: const Duration(milliseconds: 280),
                          curve: Curves.easeOutCubic,
                          alignment: state.tab == ExercisesTab.all
                              ? Alignment.centerLeft
                              : Alignment.centerRight,
                          child: FractionallySizedBox(
                            widthFactor: 0.5,
                            child: Container(
                              height: 36,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [context.colors.accentLight, context.colors.accent],
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                ),
                                borderRadius: BorderRadius.circular(10),
                                boxShadow: [
                                  BoxShadow(
                                    color: context.colors.accentDeep
                                        .withValues(alpha: 0.25),
                                    blurRadius: 8,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        Row(
                          children: [
                            _TabButton(
                              label: l10n.all,
                              count: allExercises.length,
                              isActive: state.tab == ExercisesTab.all,
                              onTap: () => notifier.setTab(ExercisesTab.all),
                            ),
                            _TabButton(
                              label: l10n.custom,
                              count: myCount,
                              isActive: state.tab == ExercisesTab.mine,
                              onTap: () => notifier.setTab(ExercisesTab.mine),
                            ),
                          ],
                        ),
                      ],
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
                        Padding(
                          padding: const EdgeInsets.only(left: 12),
                          child: Icon(
                            Icons.search,
                            size: 16,
                            color: context.colors.ink400,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: TextField(
                            controller: _searchCtrl,
                            onChanged: notifier.setQuery,
                            decoration: InputDecoration(
                              hintText: l10n.search,
                              hintStyle: TextStyle(
                                fontSize: 14,
                                color: context.colors.ink400,
                              ),
                              border: InputBorder.none,
                              isDense: true,
                              contentPadding: EdgeInsets.zero,
                            ),
                            style: TextStyle(
                              fontSize: 14,
                              color: context.colors.ink900,
                            ),
                          ),
                        ),
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 180),
                          child: state.query.isNotEmpty
                              ? PressableScale(
                                  key: const ValueKey('clear-query'),
                                  onTap: () => notifier.setQuery(''),
                                  child: Container(
                                    width: 22,
                                    height: 22,
                                    margin: const EdgeInsets.only(right: 10),
                                    decoration: BoxDecoration(
                                      color: const Color(0x14000000),
                                      borderRadius: BorderRadius.circular(11),
                                    ),
                                    child: Icon(
                                      Icons.close,
                                      size: 12,
                                      color: context.colors.ink500,
                                    ),
                                  ),
                                )
                              : const SizedBox.shrink(key: ValueKey('no-query')),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 32,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 22),
                    itemCount: _kMuscleGroups.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(width: 6),
                    itemBuilder: (context, i) {
                      final m = _kMuscleGroups[i];
                      final dummy = Exercise(id: '', name: '', muscle: m, equipment: '');
                      return VersatileChip(
                        label: dummy.getLocalizedMuscle(context),
                        isActive: state.selectedMuscle == m,
                        onTap: () => notifier.setMuscle(m),
                      );
                    },
                  ),
                ),
                AnimatedSize(
                  duration: const Duration(milliseconds: 240),
                  curve: Curves.easeOutCubic,
                  alignment: Alignment.topLeft,
                  child: _subMuscleRow(state, notifier),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  height: 32,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 22),
                    children: [
                      _LateralityChip(
                        label: l10n.all,
                        isActive: state.laterality == ExerciseLaterality.all,
                        onTap: () =>
                            notifier.setLaterality(ExerciseLaterality.all),
                      ),
                      const SizedBox(width: 6),
                      _LateralityChip(
                        label: l10n.bilateral,
                        isActive:
                            state.laterality == ExerciseLaterality.bilateral,
                        onTap: () => notifier
                            .setLaterality(ExerciseLaterality.bilateral),
                      ),
                      const SizedBox(width: 6),
                      _LateralityChip(
                        label: l10n.unilateral,
                        isActive:
                            state.laterality == ExerciseLaterality.unilateral,
                        onTap: () => notifier
                            .setLaterality(ExerciseLaterality.unilateral),
                      ),
                      const SizedBox(width: 14),
                      Container(
                        width: 1,
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        color: context.colors.hairline,
                      ),
                      const SizedBox(width: 14),
                      _CategoryChip(
                        label: l10n.categoryPush,
                        isActive:
                            state.selectedCategory == ExerciseCategory.push,
                        onTap: () =>
                            notifier.setCategory(ExerciseCategory.push),
                      ),
                      const SizedBox(width: 6),
                      _CategoryChip(
                        label: l10n.categoryPull,
                        isActive:
                            state.selectedCategory == ExerciseCategory.pull,
                        onTap: () =>
                            notifier.setCategory(ExerciseCategory.pull),
                      ),
                      const SizedBox(width: 6),
                      _CategoryChip(
                        label: l10n.categoryLegs,
                        isActive:
                            state.selectedCategory == ExerciseCategory.legs,
                        onTap: () =>
                            notifier.setCategory(ExerciseCategory.legs),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                Expanded(
                  child: allAsync.isLoading
                      ? Center(
                          child: CircularProgressIndicator(
                            color: context.colors.accent,
                            strokeWidth: 2,
                          ),
                        )
                      : filtered.isEmpty
                      ? Center(
                          child: Text(
                            l10n.noExercisesMatch,
                            style: TextStyle(
                              fontSize: 13,
                              color: context.colors.ink400,
                            ),
                          ),
                        )
                      : ListView.separated(
                          padding: const EdgeInsets.fromLTRB(22, 0, 22, 96),
                          itemCount: filtered.length,
                          separatorBuilder: (context, index) =>
                              const SizedBox(height: 6),
                          itemBuilder: (context, i) {
                            final exercise = filtered[i];
                            return _ExerciseRow(
                              exercise: exercise,
                              isEditMode: state.isEditMode,
                              isSelected: state.selectedIds.contains(
                                exercise.id,
                              ),
                              onSelect: () => notifier.toggleSelection(
                                exercise.id,
                              ),
                              containerKey: i == 0 ? _firstExerciseKey : null,
                            );
                          },
                        ),
                ),
              ],
            ),
            if (state.isEditMode && state.selectedIds.isNotEmpty)
              Positioned(
                left: 22,
                right: 22,
                // Raise the delete button above the active workout overlay when one is present
                bottom: ref.watch(activeWorkoutRoutineIdProvider) != null ? 166 : 94,
                child: FadeSlideIn(
                  offset: const Offset(0, 0.1),
                  child: GlassButton(
                    label: '${l10n.delete} (${state.selectedIds.length})',
                    variant: GlassButtonVariant.primary,
                    size: GlassButtonSize.lg,
                    expand: true,
                    onPressed: () => _confirmDelete(state.selectedIds),
                    leading: const Icon(
                      Icons.delete_outline,
                      color: Colors.white,
                      size: 20,
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

class _TabButton extends StatelessWidget {
  const _TabButton({
    required this.label,
    required this.count,
    required this.isActive,
    required this.onTap,
  });

  final String label;
  final int count;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: PressableScale(
        onTap: onTap,
        child: Container(
          height: 36,
          decoration: const BoxDecoration(
            color: Colors.transparent,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 280),
                curve: Curves.easeOutCubic,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: isActive ? Colors.white : context.colors.ink500,
                ),
                child: Text(label),
              ),
              const SizedBox(width: 6),
              AnimatedContainer(
                duration: const Duration(milliseconds: 280),
                curve: Curves.easeOutCubic,
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                decoration: BoxDecoration(
                  color: isActive
                      ? Colors.white.withValues(alpha: 0.2)
                      : const Color(0x0D000000),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: AnimatedDefaultTextStyle(
                  duration: const Duration(milliseconds: 280),
                  curve: Curves.easeOutCubic,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: isActive ? Colors.white : context.colors.ink400,
                  ),
                  child: Text('$count'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ExerciseRow extends StatelessWidget {
  const _ExerciseRow({
    required this.exercise,
    this.isEditMode = false,
    this.isSelected = false,
    this.onSelect,
    this.containerKey,
  });
  final Exercise exercise;
  final bool isEditMode;
  final bool isSelected;
  final VoidCallback? onSelect;
  final GlobalKey? containerKey;

  String? get _muscleAsset => switch (exercise.muscle) {
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

  @override
  Widget build(BuildContext context) {
    final asset = _muscleAsset;
    return FadeSlideIn(
      child: GlassContainer(
        key: containerKey,
        radius: 14,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        onTap: isEditMode
            ? onSelect
            : () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => ExerciseProgressScreen(
                      exerciseId: exercise.id,
                      exerciseName: exercise.name,
                      muscle: exercise.muscle,
                    ),
                  ),
                ),
        child: Row(
          children: [
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              transitionBuilder: (child, anim) => SizeTransition(
                sizeFactor: anim,
                axis: Axis.horizontal,
                child: FadeTransition(opacity: anim, child: child),
              ),
              child: isEditMode
                  ? Padding(
                      padding: const EdgeInsets.only(right: 12),
                      child: Container(
                        width: 22,
                        height: 22,
                        decoration: BoxDecoration(
                          color: isSelected
                              ? context.colors.accent
                              : context.colors.fieldBg,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: isSelected
                                ? Colors.transparent
                                : context.colors.glassBorder,
                            width: 1,
                          ),
                        ),
                        child: isSelected
                            ? const Icon(
                                Icons.check,
                                size: 14,
                                color: Colors.white,
                              )
                            : null,
                      ),
                    )
                  : const SizedBox.shrink(),
            ),
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
                      child: Image.asset(asset, fit: BoxFit.contain),
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
                          exercise.getLocalizedName(context),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: context.colors.ink900,
                            letterSpacing: -0.07,
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
                            color: context.colors.accentTint,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            AppLocalizations.of(context)!.custom,
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w700,
                              color: context.colors.accentDeep,
                              letterSpacing: 0.05,
                            ),
                          ),
                        ),
                      ],
                      if (exercise.isUnilateral) ...[
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
                            AppLocalizations.of(context)!.unilateral_label,
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
                  const SizedBox(height: 1),
                  Text(
                    '${exercise.getLocalizedMuscle(context)} · ${exercise.getLocalizedEquipment(context)}',
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
  }
}

class _LateralityChip extends StatelessWidget {
  const _LateralityChip({
    required this.label,
    required this.isActive,
    required this.onTap,
  });
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
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: isActive ? Colors.white : context.colors.ink700,
          ),
        ),
      ),
    );
  }
}

/// Movement-pattern chip. Visually distinct from `_LateralityChip` (accent
/// outline instead of filled) so the user reads them as a separate axis.
class _CategoryChip extends StatelessWidget {
  const _CategoryChip({
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
          color: isActive
              ? colors.accent.withValues(alpha: 0.14)
              : colors.glassBg,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isActive ? colors.accent : colors.glassBorder,
            width: isActive ? 1 : 0.8,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: isActive ? colors.accentDeep : colors.ink700,
          ),
        ),
      ),
    );
  }
}

const _kMuscleGroups = [
  'All',
  'Chest',
  'Back',
  'Legs',
  'Shoulders',
  'Arms',
  'Core'
];

Widget _subMuscleRow(ExercisesState state, ExercisesNotifier notifier) {
  final muscles = switch (state.selectedMuscle) {
    'Arms' => kArmsSubMuscles,
    'Legs' => kLegsSubMuscles,
    _ => <String>[],
  };

  return AnimatedSize(
    duration: const Duration(milliseconds: 240),
    curve: Curves.easeOutCubic,
    alignment: Alignment.topLeft,
    child: muscles.isEmpty
        ? const SizedBox(width: double.infinity, height: 0)
        : Padding(
            padding: const EdgeInsets.fromLTRB(22, 8, 22, 0),
            child: SizedBox(
              height: 32,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: muscles.length,
                separatorBuilder: (_, __) => const SizedBox(width: 6),
                itemBuilder: (context, i) {
                  final m = muscles[i];
                  final isActive = state.selectedSubMuscle == m;

                  final dummy = Exercise(
                    id: '',
                    name: '',
                    muscle: m,
                    equipment: '',
                  );

                  return PressableScale(
                    onTap: () => notifier.setSubMuscle(m),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: isActive
                            ? context.colors.accent
                            : context.colors.glassBg,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: isActive
                              ? Colors.transparent
                              : context.colors.glassBorder,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          dummy.getLocalizedMuscle(context),
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: isActive
                                ? Colors.white
                                : context.colors.ink500,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
  );
}
