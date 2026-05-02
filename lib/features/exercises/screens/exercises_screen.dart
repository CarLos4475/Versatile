import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../domain/entities/exercise.dart';
import '../../../shared/widgets/filter_chip_widget.dart';
import '../../../shared/widgets/glass_button.dart';
import '../../../shared/widgets/glass_container.dart';
import '../../../shared/widgets/motion.dart';
import '../../../shared/widgets/screen_header.dart';
import '../view_models/exercises_view_model.dart';
import 'add_exercise_screen.dart';

const _kMuscleGroups = [
  'All',
  'Chest',
  'Back',
  'Shoulders',
  'Arms',
  'Core',
  'Legs',
  'Other',
];

Widget _subMuscleRow(ExercisesState state, ExercisesNotifier notifier) {
  final List<String> subs;
  if (state.selectedMuscle == 'Arms') {
    subs = kArmsSubMuscles;
  } else if (state.selectedMuscle == 'Legs') {
    subs = kLegsSubMuscles;
  } else {
    return const SizedBox.shrink();
  }
  return Padding(
    padding: const EdgeInsets.only(top: 8),
    child: SizedBox(
      height: 32,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 22),
        itemCount: subs.length,
        separatorBuilder: (_, __) => const SizedBox(width: 6),
        itemBuilder: (context, i) {
          final m = subs[i];
          return VersatileChip(
            label: m,
            isActive: state.selectedSubMuscle == m,
            onTap: () => notifier.setSubMuscle(m),
          );
        },
      ),
    ),
  );
}

class ExercisesScreen extends ConsumerWidget {
  const ExercisesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(exercisesProvider);
    final notifier = ref.read(exercisesProvider.notifier);
    final allAsync = ref.watch(exercisesAsyncProvider);
    final filtered = ref.watch(filteredExercisesProvider);

    final allExercises = allAsync.value ?? [];
    final myCount = allExercises.where((e) => e.isCustom).length;

    return Scaffold(
      backgroundColor: AppColors.bgApp,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ScreenHeader(
              title: 'Exercises',
              subtitle: '${allExercises.length} in your library',
              trailing: IconCircleButton(
                icon: const Icon(Icons.add),
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const AddExerciseScreen()),
                ),
                accent: true,
              ),
            ),
            const SizedBox(height: 14),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 22),
              child: GlassContainer(
                radius: 14,
                padding: const EdgeInsets.all(4),
                child: Row(
                  children: [
                    _TabButton(
                      label: 'Catalog',
                      count: allExercises.length,
                      isActive: state.tab == ExercisesTab.all,
                      onTap: () => notifier.setTab(ExercisesTab.all),
                    ),
                    _TabButton(
                      label: 'My exercises',
                      count: myCount,
                      isActive: state.tab == ExercisesTab.mine,
                      onTap: () => notifier.setTab(ExercisesTab.mine),
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
                        onChanged: notifier.setQuery,
                        decoration: const InputDecoration(
                          hintText: 'Search exercises…',
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
                                child: const Icon(
                                  Icons.close,
                                  size: 12,
                                  color: AppColors.ink500,
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
                separatorBuilder: (context, index) => const SizedBox(width: 6),
                itemBuilder: (context, i) {
                  final m = _kMuscleGroups[i];
                  return VersatileChip(
                    label: m,
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
                    label: 'All',
                    isActive: state.laterality == ExerciseLaterality.all,
                    onTap: () => notifier.setLaterality(ExerciseLaterality.all),
                  ),
                  const SizedBox(width: 6),
                  _LateralityChip(
                    label: 'Bilateral',
                    isActive: state.laterality == ExerciseLaterality.bilateral,
                    onTap: () =>
                        notifier.setLaterality(ExerciseLaterality.bilateral),
                  ),
                  const SizedBox(width: 6),
                  _LateralityChip(
                    label: 'Unilateral',
                    isActive: state.laterality == ExerciseLaterality.unilateral,
                    onTap: () =>
                        notifier.setLaterality(ExerciseLaterality.unilateral),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: allAsync.isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.accent,
                        strokeWidth: 2,
                      ),
                    )
                  : filtered.isEmpty
                  ? const Center(
                      child: Text(
                        'No exercises match',
                        style: TextStyle(fontSize: 13, color: AppColors.ink400),
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(22, 0, 22, 96),
                      itemCount: filtered.length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: 6),
                      itemBuilder: (context, i) =>
                          _ExerciseRow(exercise: filtered[i]),
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
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOutCubic,
          height: 36,
          decoration: BoxDecoration(
            color: isActive ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            boxShadow: isActive
                ? [
                    BoxShadow(
                      color: const Color(0xFF3C2814).withOpacity(0.08),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: isActive ? AppColors.ink900 : AppColors.ink500,
                ),
              ),
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                decoration: BoxDecoration(
                  color: isActive
                      ? AppColors.accentTint
                      : const Color(0x0D000000),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  '$count',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: isActive ? AppColors.accentDeep : AppColors.ink400,
                  ),
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
  const _ExerciseRow({required this.exercise});
  final Exercise exercise;

  Color get _muscleColor {
    return switch (exercise.muscle) {
      'Chest' => AppColors.accent,
      'Back' => AppColors.accentDeep,
      'Shoulders' => const Color(0xFFB48C64),
      'Core' => const Color(0xFF9B7850),
      'Biceps' => const Color(0xFFC8825A),
      'Triceps' => const Color(0xFFB56E40),
      'Forearms' => const Color(0xFF8A6E54),
      'Quadriceps' => AppColors.accentSoft,
      'Hamstrings' => const Color(0xFFCB8A6A),
      'Glutes' => const Color(0xFFD99060),
      'Calves' => const Color(0xFFC07A50),
      _ => AppColors.ink400,
    };
  }

  String? get _muscleAsset => switch (exercise.muscle) {
    'Chest' => 'assets/assets/Torso/pecho/pecho_color_edit_24348292703575.png',
    'Back' => 'assets/assets/Torso/espalda/back_color_edit_24399873717629.png',
    'Shoulders' =>
      'assets/assets/Torso/hombro/shoulder_color_edit_24371924634300.png',
    'Core' => 'assets/assets/Torso/core/core_color_edit_24429990449916.png',
    'Biceps' =>
      'assets/assets/Torso/brazos/biceps_color_edit_24552237308231.png',
    'Triceps' =>
      'assets/assets/Torso/brazos/triceps_color_edit_24483943284283.png',
    'Forearms' =>
      'assets/assets/Torso/brazos/forearm_color_edit_24515208562924.png',
    'Quadriceps' => 'assets/assets/Piernas/cuadriceps_color.png',
    'Hamstrings' =>
      'assets/assets/Piernas/femoral_color_edit_24685232753002.png',
    'Glutes' => 'assets/assets/Piernas/glutes_color_edit_24667069897276.png',
    'Calves' => 'assets/assets/Piernas/calf_color_edit_24747730293097.png',
    _ => null,
  };

  @override
  Widget build(BuildContext context) {
    final asset = _muscleAsset;
    return FadeSlideIn(
      child: GlassContainer(
        radius: 14,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: _muscleColor.withOpacity(0.15),
                borderRadius: BorderRadius.circular(11),
              ),
              child: asset != null
                  ? Padding(
                      padding: const EdgeInsets.all(7),
                      child: Image.asset(asset, fit: BoxFit.contain),
                    )
                  : Icon(Icons.fitness_center, size: 18, color: _muscleColor),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        exercise.name,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.ink900,
                          letterSpacing: -0.07,
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
                      if (exercise.isUnilateral) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 5,
                            vertical: 1,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0x14000000),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text(
                            'UNILATERAL',
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w700,
                              color: AppColors.ink500,
                              letterSpacing: 0.05,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 1),
                  Text(
                    '${exercise.muscle} · ${exercise.equipment}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.ink500,
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
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isActive ? AppColors.accentDeep : AppColors.glassBg,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isActive ? Colors.transparent : AppColors.glassBorder,
            width: 0.5,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: isActive ? Colors.white : AppColors.ink700,
          ),
        ),
      ),
    );
  }
}
