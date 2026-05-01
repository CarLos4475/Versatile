import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/seed_data.dart';
import '../../../shared/widgets/glass_button.dart';
import '../../../shared/widgets/glass_container.dart';
import '../../../shared/widgets/screen_header.dart';
import '../../active_workout/screens/active_workout_screen.dart';

class RoutineDetailScreen extends StatefulWidget {
  const RoutineDetailScreen({super.key, required this.routineId});
  final String routineId;

  @override
  State<RoutineDetailScreen> createState() => _RoutineDetailScreenState();
}

class _RoutineDetailScreenState extends State<RoutineDetailScreen> {
  bool _editMode = false;

  @override
  Widget build(BuildContext context) {
    final routine = SeedData.findRoutine(widget.routineId);
    if (routine == null) return const SizedBox.shrink();

    return Scaffold(
      backgroundColor: AppColors.bgApp,
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 140),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ScreenHeader(
                    title: routine.name,
                    subtitle: '${routine.exercises.length} exercises',
                    onBack: () => Navigator.of(context).pop(),
                    trailing: GestureDetector(
                      onTap: () => setState(() => _editMode = !_editMode),
                      child: Container(
                        height: 36,
                        padding: const EdgeInsets.symmetric(horizontal: 14),
                        decoration: BoxDecoration(
                          color: _editMode
                              ? AppColors.accentTint
                              : const Color(0x99FFFCF7),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: AppColors.glassBorder,
                            width: 0.5,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            _editMode ? 'Done' : 'Edit',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: _editMode
                                  ? AppColors.accentDeep
                                  : AppColors.ink700,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 22),
                    child: Column(
                      children: [
                        ...routine.exercises.asMap().entries.map((entry) {
                          final i = entry.key;
                          final re = entry.value;
                          final ex = SeedData.findExercise(re.exerciseId);
                          if (ex == null) return const SizedBox.shrink();
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: GlassContainer(
                              radius: 16,
                              padding: const EdgeInsets.all(14),
                              child: Row(
                                children: [
                                  Container(
                                    width: 32,
                                    height: 32,
                                    decoration: BoxDecoration(
                                      color: AppColors.accentTint,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Center(
                                      child: Text(
                                        '${i + 1}',
                                        style: const TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w700,
                                          color: AppColors.accentDeep,
                                          fontFeatures: [FontFeature.tabularFigures()],
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          ex.name,
                                          style: const TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w600,
                                            color: AppColors.ink900,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          '${re.targetSets} × ${re.targetReps} reps · ${re.restSeconds}s rest',
                                          style: const TextStyle(
                                            fontSize: 12,
                                            color: AppColors.ink500,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  if (_editMode)
                                    Row(
                                      children: [
                                        _SmallButton(
                                          icon: Icons.edit_outlined,
                                          onTap: () {},
                                          subtle: true,
                                        ),
                                        const SizedBox(width: 6),
                                        _SmallButton(
                                          icon: Icons.delete_outline,
                                          onTap: () {},
                                          danger: true,
                                        ),
                                      ],
                                    )
                                  else
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 7, vertical: 3),
                                      decoration: BoxDecoration(
                                        color: const Color(0x0A000000),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        ex.muscle,
                                        style: const TextStyle(
                                          fontSize: 11,
                                          color: AppColors.ink400,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          );
                        }),
                        if (_editMode)
                          GestureDetector(
                            onTap: () {},
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: AppColors.accent.withOpacity(0.4),
                                ),
                                borderRadius: BorderRadius.circular(16),
                                color: AppColors.accentTint.withOpacity(0.5),
                              ),
                              child: const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.add,
                                      size: 18, color: AppColors.accentDeep),
                                  SizedBox(width: 8),
                                  Text(
                                    'Add exercise',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.accentDeep,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Floating start button
            if (!_editMode)
              Positioned(
                left: 22,
                right: 22,
                bottom: 22,
                child: GlassButton(
                  label: 'Start this workout',
                  variant: GlassButtonVariant.primary,
                  size: GlassButtonSize.lg,
                  expand: true,
                  leading: const Icon(Icons.play_arrow,
                      color: Colors.white, size: 16),
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) =>
                          ActiveWorkoutScreen(routineId: routine.id),
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

class _SmallButton extends StatelessWidget {
  const _SmallButton({
    required this.icon,
    required this.onTap,
    this.subtle = false,
    this.danger = false,
  });

  final IconData icon;
  final VoidCallback onTap;
  final bool subtle;
  final bool danger;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: danger
              ? AppColors.accentTint
              : const Color(0xB3FFFFFF),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(
          icon,
          size: 15,
          color: danger ? AppColors.accentDeep : AppColors.ink700,
        ),
      ),
    );
  }
}
