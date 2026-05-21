import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:versatile/l10n/app_localizations.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/exercise_category.dart';
import '../../../domain/entities/exercise.dart';
import '../../../core/utils/l10n_utils.dart';
import '../../../core/providers/repository_providers.dart';
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
                            _MagIconButton(
                              icon: state.isEditMode
                                  ? Icons.close
                                  : Icons.checklist_rtl_rounded,
                              isActive: state.isEditMode,
                              onTap: notifier.toggleEditMode,
                            ),
                            const SizedBox(width: 8),
                            KeyedSubtree(
                              key: _addBtnKey,
                              child: _MagIconButton(
                                icon: Icons.add,
                                isActive: true,
                                onTap: () => Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => const AddExerciseScreen(),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        )
                      : KeyedSubtree(
                          key: _addBtnKey,
                          child: _MagIconButton(
                            icon: Icons.add,
                            isActive: true,
                            onTap: () => Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => const AddExerciseScreen(),
                              ),
                            ),
                          ),
                        ),
                ),
                const SizedBox(height: 14),
                const _GridDivider(),
                _MagTabSwitcher(
                  allLabel: l10n.all,
                  allCount: allExercises.length,
                  mineLabel: l10n.custom,
                  mineCount: myCount,
                  activeTab: state.tab,
                  onTabChanged: notifier.setTab,
                ),
                const _GridDivider(),
                _MagSearchBar(
                  controller: _searchCtrl,
                  hint: l10n.search,
                  query: state.query,
                  onChanged: notifier.setQuery,
                ),
                const _GridDivider(),
                const SizedBox(height: 10),
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
                      return _MagChip(
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
                      _MagChip(
                        label: l10n.all,
                        isActive: state.laterality == ExerciseLaterality.all,
                        onTap: () =>
                            notifier.setLaterality(ExerciseLaterality.all),
                      ),
                      const SizedBox(width: 6),
                      _MagChip(
                        label: l10n.bilateral,
                        isActive:
                            state.laterality == ExerciseLaterality.bilateral,
                        onTap: () => notifier
                            .setLaterality(ExerciseLaterality.bilateral),
                      ),
                      const SizedBox(width: 6),
                      _MagChip(
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
                      _MagChip(
                        label: l10n.categoryPush,
                        isActive:
                            state.selectedCategory == ExerciseCategory.push,
                        onTap: () =>
                            notifier.setCategory(ExerciseCategory.push),
                        outline: true,
                      ),
                      const SizedBox(width: 6),
                      _MagChip(
                        label: l10n.categoryPull,
                        isActive:
                            state.selectedCategory == ExerciseCategory.pull,
                        onTap: () =>
                            notifier.setCategory(ExerciseCategory.pull),
                        outline: true,
                      ),
                      const SizedBox(width: 6),
                      _MagChip(
                        label: l10n.categoryLegs,
                        isActive:
                            state.selectedCategory == ExerciseCategory.legs,
                        onTap: () =>
                            notifier.setCategory(ExerciseCategory.legs),
                        outline: true,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                const _GridDivider(),
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
                      : FadeSlideIn(
                          child: ListView.separated(
                            padding: const EdgeInsets.only(bottom: 96),
                            itemCount: filtered.length,
                            separatorBuilder: (_, __) => const _GridDivider(),
                            itemBuilder: (context, index) {
                              final ex = filtered[index];
                              return _ExerciseRow(
                                exercise: ex,
                                isEditMode: state.isEditMode,
                                isSelected: state.selectedIds.contains(ex.id),
                                onSelect: () => notifier.toggleSelection(ex.id),
                                containerKey: ex == filtered.first ? _firstExerciseKey : null,
                              );
                            },
                          ),
                        ),
                ),
              ],
            ),
            if (state.isEditMode && state.selectedIds.isNotEmpty)
              Positioned(
                left: 22,
                right: 22,
                bottom: ref.watch(activeWorkoutRoutineIdProvider) != null ? 166 : 94,
                child: FadeSlideIn(
                  offset: const Offset(0, 0.1),
                  child: _MagDeleteButton(
                    label: '${l10n.delete} (${state.selectedIds.length})',
                    onPressed: () => _confirmDelete(state.selectedIds),
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

class _MagIconButton extends StatelessWidget {
  const _MagIconButton({
    required this.icon,
    required this.isActive,
    required this.onTap,
  });

  final IconData icon;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return PressableScale(
      onTap: onTap,
      child: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: isActive
              ? colors.accent
              : colors.ink900.withValues(alpha: 0.04),
          border: Border.all(
            color: isActive
                ? colors.accentDeep.withValues(alpha: 0.6)
                : colors.hairline,
            width: 0.6,
          ),
        ),
        child: Icon(
          icon,
          size: 20,
          color: isActive ? Colors.white : colors.ink700,
        ),
      ),
    );
  }
}

class _MagTabSwitcher extends StatelessWidget {
  const _MagTabSwitcher({
    required this.allLabel,
    required this.allCount,
    required this.mineLabel,
    required this.mineCount,
    required this.activeTab,
    required this.onTabChanged,
  });

  final String allLabel;
  final int allCount;
  final String mineLabel;
  final int mineCount;
  final ExercisesTab activeTab;
  final void Function(ExercisesTab) onTabChanged;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return SizedBox(
      height: 48,
      child: Row(
        children: [
          _MagTab(
            label: allLabel,
            count: allCount,
            isActive: activeTab == ExercisesTab.all,
            onTap: () => onTabChanged(ExercisesTab.all),
          ),
          Container(width: 0.6, color: colors.hairline),
          _MagTab(
            label: mineLabel,
            count: mineCount,
            isActive: activeTab == ExercisesTab.mine,
            onTap: () => onTabChanged(ExercisesTab.mine),
          ),
        ],
      ),
    );
  }
}

class _MagTab extends StatelessWidget {
  const _MagTab({
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
    final colors = context.colors;
    return Expanded(
      child: PressableScale(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutCubic,
          color: isActive ? colors.bgFrame : Colors.transparent,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeOutCubic,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.18,
                  color: isActive ? colors.accentDeep : colors.ink400,
                ),
                child: Text(label.toUpperCase()),
              ),
              const SizedBox(height: 2),
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeOutCubic,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w500,
                  letterSpacing: -0.55,
                  color: isActive ? colors.ink900 : colors.ink400,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
                child: Text('$count'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MagSearchBar extends StatelessWidget {
  const _MagSearchBar({
    required this.controller,
    required this.hint,
    required this.query,
    required this.onChanged,
  });

  final TextEditingController controller;
  final String hint;
  final String query;
  final void Function(String) onChanged;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Container(
      height: 46,
      color: colors.bgFrame,
      padding: const EdgeInsets.symmetric(horizontal: 22),
      child: Row(
        children: [
          Icon(Icons.search, size: 16, color: colors.ink400),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: controller,
              onChanged: onChanged,
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: TextStyle(
                  fontSize: 14,
                  color: colors.ink400,
                ),
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
              style: TextStyle(
                fontSize: 14,
                color: colors.ink900,
              ),
            ),
          ),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 180),
            child: query.isNotEmpty
                ? PressableScale(
                    key: const ValueKey('clear-query'),
                    onTap: () => onChanged(''),
                    child: Container(
                      width: 22,
                      height: 22,
                      color: colors.ink900.withValues(alpha: 0.06),
                      child: Icon(
                        Icons.close,
                        size: 12,
                        color: colors.ink500,
                      ),
                    ),
                  )
                : const SizedBox.shrink(key: ValueKey('no-query')),
          ),
        ],
      ),
    );
  }
}

class _MagChip extends StatelessWidget {
  const _MagChip({
    required this.label,
    required this.isActive,
    required this.onTap,
    this.outline = false,
  });

  final String label;
  final bool isActive;
  final VoidCallback onTap;
  final bool outline;

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
              ? (outline ? colors.accent.withValues(alpha: 0.14) : colors.accentDeep)
              : Colors.transparent,
          border: Border.all(
            color: isActive
                ? (outline ? colors.accent : Colors.transparent)
                : colors.hairline,
            width: 0.8,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: isActive
                ? (outline ? colors.accentDeep : Colors.white)
                : colors.ink700,
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
    final colors = context.colors;
    return PressableScale(
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
      child: Container(
        key: containerKey,
        padding: const EdgeInsets.fromLTRB(22, 16, 22, 16),
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
                              ? colors.accent
                              : colors.fieldBg,
                          border: Border.all(
                            color: isSelected
                                ? Colors.transparent
                                : colors.hairline,
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
                color: colors.accent,
              ),
              child: asset != null
                  ? Padding(
                      padding: const EdgeInsets.all(7),
                      child: Image.asset(asset, fit: BoxFit.contain),
                    )
                  : Icon(
                      Icons.fitness_center,
                      size: 18,
                      color: Colors.white,
                    ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          exercise.getLocalizedName(context),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w600,
                            color: colors.ink900,
                            letterSpacing: -0.17,
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
                            color: colors.accent,
                          ),
                          child: Text(
                            AppLocalizations.of(context)!.custom,
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
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
                          decoration: const BoxDecoration(
                            color: Color(0x1A5E7BA7),
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
                  const SizedBox(height: 3),
                  Text(
                    '${exercise.getLocalizedMuscle(context)} · ${exercise.getLocalizedEquipment(context)}',
                    style: TextStyle(fontSize: 12, color: colors.ink500),
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

class _MagDeleteButton extends StatelessWidget {
  const _MagDeleteButton({
    required this.label,
    required this.onPressed,
  });

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return PressableScale(
      onTap: onPressed,
      child: Container(
        height: 52,
        decoration: BoxDecoration(
          color: const Color(0xFFD93B3B),
          border: Border.all(
            color: const Color(0xFFAA2020),
            width: 0.6,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.delete_outline, color: Colors.white, size: 18),
            const SizedBox(width: 8),
            Text(
              label.toUpperCase(),
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

                  return _MagChip(
                    label: dummy.getLocalizedMuscle(context),
                    isActive: isActive,
                    onTap: () => notifier.setSubMuscle(m),
                  );
                },
              ),
            ),
          ),
  );
}
