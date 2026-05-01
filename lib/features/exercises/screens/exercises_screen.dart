import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/seed_data.dart';
import '../../../domain/entities/exercise.dart';
import '../../../shared/widgets/filter_chip_widget.dart';
import '../../../shared/widgets/glass_button.dart';
import '../../../shared/widgets/glass_container.dart';
import '../../../shared/widgets/screen_header.dart';
import '../view_models/exercises_view_model.dart';

class ExercisesScreen extends ConsumerWidget {
  const ExercisesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(exercisesProvider);
    final notifier = ref.read(exercisesProvider.notifier);
    final filtered = ref.watch(filteredExercisesProvider);
    final myCount = SeedData.exercises.where((e) => e.isCustom).length;

    return Scaffold(
      backgroundColor: AppColors.bgApp,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ScreenHeader(
              title: 'Exercises',
              subtitle: '${SeedData.exercises.length} in your library',
              trailing: IconCircleButton(
                icon: const Icon(Icons.add),
                onPressed: () {},
                accent: true,
              ),
            ),
            const SizedBox(height: 14),

            // Tabs
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 22),
              child: GlassContainer(
                radius: 14,
                padding: const EdgeInsets.all(4),
                child: Row(
                  children: [
                    _TabButton(
                      label: 'Catalog',
                      count: SeedData.exercises.length,
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

            // Search bar
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
                    if (state.query.isNotEmpty)
                      GestureDetector(
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
                      ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 12),

            // Muscle filter chips
            SizedBox(
              height: 32,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 22),
                itemCount: SeedData.muscleGroups.length,
                separatorBuilder: (context, index) => const SizedBox(width: 6),
                itemBuilder: (context, i) {
                  final m = SeedData.muscleGroups[i];
                  return VersatileChip(
                    label: m,
                    isActive: state.selectedMuscle == m,
                    onTap: () => notifier.setMuscle(m),
                  );
                },
              ),
            ),

            const SizedBox(height: 14),

            // Exercise list
            Expanded(
              child: filtered.isEmpty
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
      child: GestureDetector(
        onTap: onTap,
        child: Container(
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
      'Legs' => AppColors.accentSoft,
      'Shoulders' => const Color(0xFFB48C64),
      'Arms' => const Color(0xFFC8825A),
      'Core' => const Color(0xFF9B7850),
      _ => AppColors.ink400,
    };
  }

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
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
            child: Icon(Icons.fitness_center, size: 18, color: _muscleColor),
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
                  ],
                ),
                const SizedBox(height: 1),
                Text(
                  '${exercise.muscle} · ${exercise.equipment}',
                  style: const TextStyle(fontSize: 12, color: AppColors.ink500),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () {},
            child: Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: const Color(0x0A000000),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.add, size: 15, color: AppColors.ink500),
            ),
          ),
        ],
      ),
    );
  }
}
