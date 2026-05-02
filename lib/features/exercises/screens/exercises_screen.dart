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
    return SizedBox.shrink();
  }
  return Padding(
    padding: const EdgeInsets.only(top: 8),
    child: SizedBox(
      height: 32,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 22),
        itemCount: subs.length,
        separatorBuilder: (_, __) => SizedBox(width: 6),
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
      backgroundColor: context.colors.bgApp,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ScreenHeader(
              title: 'Exercises',
              subtitle: '${allExercises.length} in your library',
              trailing: IconCircleButton(
                icon: Icon(Icons.add),
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const AddExerciseScreen()),
                ),
                accent: true,
              ),
            ),
            SizedBox(height: 14),
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
            SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 22),
              child: GlassContainer(
                radius: 14,
                height: 44,
                child: Row(
                  children: [
                    Padding(
                      padding: EdgeInsets.only(left: 12),
                      child: Icon(
                        Icons.search,
                        size: 16,
                        color: context.colors.ink400,
                      ),
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        onChanged: notifier.setQuery,
                        decoration: InputDecoration(
                          hintText: 'Search exercises…',
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
                          : SizedBox.shrink(key: ValueKey('no-query')),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 12),
            SizedBox(
              height: 32,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 22),
                itemCount: _kMuscleGroups.length,
                separatorBuilder: (context, index) => SizedBox(width: 6),
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
            SizedBox(height: 8),
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
                  SizedBox(width: 6),
                  _LateralityChip(
                    label: 'Bilateral',
                    isActive: state.laterality == ExerciseLaterality.bilateral,
                    onTap: () =>
                        notifier.setLaterality(ExerciseLaterality.bilateral),
                  ),
                  SizedBox(width: 6),
                  _LateralityChip(
                    label: 'Unilateral',
                    isActive: state.laterality == ExerciseLaterality.unilateral,
                    onTap: () =>
                        notifier.setLaterality(ExerciseLaterality.unilateral),
                  ),
                ],
              ),
            ),
            SizedBox(height: 10),
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
                        'No exercises match',
                        style: TextStyle(fontSize: 13, color: context.colors.ink400),
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(22, 0, 22, 96),
                      itemCount: filtered.length,
                      separatorBuilder: (context, index) =>
                          SizedBox(height: 6),
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
            gradient: isActive
                ? const LinearGradient(
                    colors: [Color(0xFFE08866), Color(0xFFD97757)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  )
                : null,
            color: isActive ? null : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            boxShadow: isActive
                ? [
                    BoxShadow(
                      color: context.colors.accentDeep.withValues(alpha: 0.25),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
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
                  color: isActive ? Colors.white : context.colors.ink500,
                ),
              ),
              SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                decoration: BoxDecoration(
                  color: isActive
                      ? Colors.white.withValues(alpha: 0.2)
                      : const Color(0x0D000000),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  '$count',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: isActive ? Colors.white : context.colors.ink400,
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
                color: context.colors.accentTint,
                borderRadius: BorderRadius.circular(11),
              ),
              child: asset != null
                  ? Padding(
                      padding: const EdgeInsets.all(7),
                      child: Image.asset(asset, fit: BoxFit.contain),
                    )
                  : Icon(Icons.fitness_center, size: 18, color: context.colors.accentDeep),
            ),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        exercise.name,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: context.colors.ink900,
                          letterSpacing: -0.07,
                        ),
                      ),
                      if (exercise.isCustom) ...[
                        SizedBox(width: 6),
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
                            'CUSTOM',
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
                        SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 5,
                            vertical: 1,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0x14000000),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            'UNILATERAL',
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w700,
                              color: context.colors.ink500,
                              letterSpacing: 0.05,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  SizedBox(height: 1),
                  Text(
                    '${exercise.muscle} · ${exercise.equipment}',
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
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isActive ? context.colors.accentDeep : context.colors.glassBg,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isActive ? Colors.transparent : context.colors.glassBorder,
            width: 0.5,
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