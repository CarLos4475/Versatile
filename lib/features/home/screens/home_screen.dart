import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/navigation/app_page_transitions.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/glass_container.dart';
import '../../../shared/widgets/motion.dart';
import '../../../shared/widgets/screen_header.dart';
import '../view_models/home_view_model.dart';
import '../widgets/session_card.dart';
import '../widgets/stat_card.dart';
import '../../active_workout/screens/active_workout_screen.dart';
import '../../history/screens/session_detail_screen.dart';
import '../../routines/screens/create_routine_screen.dart';
import '../../settings/screens/settings_screen.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(homeProvider);
    final now = DateTime.now();
    const weekdays = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];

    final nextRoutine = state.nextRoutine;
    final heroInfo = ref.watch(heroCardInfoProvider).value;
    final daysAgo = state.nextRoutineDaysAgo;
    final lastDoneText = daysAgo == null
        ? 'Never done'
        : daysAgo == 0
            ? 'Done today'
            : daysAgo == 1
                ? 'Done yesterday'
                : 'Last done $daysAgo days ago';

    return Scaffold(
      backgroundColor: context.colors.bgApp,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 96),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ScreenHeader(
                title: 'Hello, ${state.userName}',
                subtitle:
                    '${weekdays[now.weekday - 1]}, ${months[now.month - 1]} ${now.day}',
                trailing: PressableScale(
                  onTap: () => Navigator.of(context).push(
                    AppRoute(page: const SettingsScreen()),
                  ),
                  child: Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: context.colors.glassBg,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: context.colors.glassBorder,
                        width: 0.5,
                      ),
                      boxShadow: context.colors.glassShadow,
                    ),
                    child: Icon(
                      Icons.settings_outlined,
                      color: context.colors.ink700,
                      size: 20,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 20),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 22),
                child: FadeSlideIn(
                  delay: const Duration(milliseconds: 60),
                  child: nextRoutine != null
                      ? _HeroCard(
                          routineId: nextRoutine.id,
                          routineName: nextRoutine.name,
                          exerciseCount: nextRoutine.exercises.length,
                          estimatedMin: nextRoutine.estimatedMinutes,
                          lastDoneText: lastDoneText,
                          mainExerciseName: heroInfo?.exerciseName,
                          mainPrKg: heroInfo?.pr,
                        )
                      : _EmptyHeroCard(
                          onCreateRoutine: () => Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const CreateRoutineScreen(),
                            ),
                          ),
                        ),
                ),
              ),

              SizedBox(height: 16),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 22),
                child: FadeSlideIn(
                  delay: const Duration(milliseconds: 120),
                  child: Row(
                    children: [
                      Expanded(
                        child: StatCard(
                          label: 'This week',
                          value: state.weekSessions.toString(),
                          unit: 'sessions',
                        ),
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        child: StatCard(
                          label: 'Volume',
                          value: state.weekVolume >= 1000
                              ? (state.weekVolume / 1000).toStringAsFixed(1)
                              : state.weekVolume.toStringAsFixed(0),
                          unit: state.weekVolume >= 1000 ? 'k kg' : 'kg',
                        ),
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        child: StatCard(
                          label: 'Avg time',
                          value: '${state.avgTimeMins}',
                          unit: 'min',
                          accent: true,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 22),
                child: FadeSlideIn(
                  delay: const Duration(milliseconds: 180),
                  child: _ActivityGrid(
                    workoutDays: state.workoutDays,
                    sessionCount: state.sessions.length,
                  ),
                ),
              ),

              if (state.sessions.isNotEmpty) ...[
                SizedBox(height: 24),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 22),
                  child: FadeSlideIn(
                    delay: const Duration(milliseconds: 220),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text(
                          'Recent sessions',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            letterSpacing: -0.18,
                            color: context.colors.ink900,
                          ),
                        ),
                        Text(
                          '${state.sessions.length} total',
                          style: TextStyle(
                            fontSize: 13,
                            color: context.colors.ink400,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 22),
                  child: Column(
                    children: state.sessions
                        .take(4)
                        .map(
                          (s) => Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: SessionCard(
                              session: s,
                              onTap: () => Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) =>
                                      SessionDetailScreen(session: s),
                                ),
                              ),
                            ),
                          ),
                        )
                        .toList(),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _ActivityGrid extends StatelessWidget {
  const _ActivityGrid({required this.workoutDays, required this.sessionCount});

  final Set<String> workoutDays;
  final int sessionCount;

  static const _months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];
  static const _dayLabels = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
  static const int _numWeeks = 26;
  static const double _cell = 10;
  static const double _gap = 2;
  static const double _slot = _cell + _gap;

  String _fmt(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final currentMonday = today.subtract(Duration(days: today.weekday - 1));

    return LayoutBuilder(
      builder: (context, constraints) {
        // constraints.maxWidth = screen width minus the outer 22+22 padding.
        // GlassContainer adds 16+16 inner padding; label col = 22; gap = 2.
        const overhead = 32.0 + 22.0 + 2.0;
        final weeksAreaWidth = constraints.maxWidth - overhead;
        final numWeeks =
            (weeksAreaWidth / _slot).floor().clamp(4, _numWeeks);

        final gridStart = currentMonday.subtract(
          Duration(days: 7 * (numWeeks - 1)),
        );
        final weeks = List.generate(
          numWeeks,
          (w) => gridStart.add(Duration(days: 7 * w)),
        );

    return GlassContainer(
      radius: 20,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'ACTIVITY',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.06,
              color: context.colors.ink400,
            ),
          ),
          SizedBox(height: 2),
          Text(
            '$sessionCount sessions in the last 30 days',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w400,
              letterSpacing: -0.4,
              color: context.colors.ink900,
              height: 1.1,
            ),
          ),
          SizedBox(height: 14),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Fixed-width weekday label column
              SizedBox(
                width: 22,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: _slot + 2), // month row + gap
                    ..._dayLabels.map(
                      (label) => SizedBox(
                        height: _slot,
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            label,
                            style: TextStyle(
                              fontSize: 8,
                              color: context.colors.ink400,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 2),
              // Fixed-width week columns
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: weeks.asMap().entries.map((entry) {
                  final w = entry.key;
                  final monday = entry.value;
                  final showMonth =
                      w == 0 || monday.month != weeks[w - 1].month;

                  return SizedBox(
                    width: _slot,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Month label
                        SizedBox(
                          height: _slot,
                          child: showMonth
                              ? Text(
                                  _months[monday.month - 1],
                                  style: TextStyle(
                                    fontSize: 7,
                                    color: context.colors.ink400,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  overflow: TextOverflow.visible,
                                  softWrap: false,
                                )
                              : null,
                        ),
                        SizedBox(height: 2),
                        // 7 day cells
                        ...List.generate(7, (d) {
                          final day = monday.add(Duration(days: d));
                          final isFuture = day.isAfter(today);
                          final trained =
                              !isFuture && workoutDays.contains(_fmt(day));
                          return Container(
                            width: _cell,
                            height: _cell,
                            margin: const EdgeInsets.only(bottom: _gap),
                            decoration: BoxDecoration(
                              color: isFuture
                                  ? Colors.transparent
                                  : trained
                                  ? context.colors.accentDeep
                                  : const Color(0x0F000000),
                              borderRadius: BorderRadius.circular(2),
                              border: isFuture
                                  ? null
                                  : Border.all(
                                      color: trained
                                          ? Colors.transparent
                                          : const Color(0x14000000),
                                      width: 0.5,
                                    ),
                            ),
                          );
                        }),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ],
      ),
    );
      },
    );
  }
}

class _HeroCard extends StatelessWidget {
  const _HeroCard({
    required this.routineId,
    required this.routineName,
    required this.exerciseCount,
    required this.estimatedMin,
    required this.lastDoneText,
    this.mainExerciseName,
    this.mainPrKg,
  });

  final String routineId;
  final String routineName;
  final int exerciseCount;
  final int estimatedMin;
  final String lastDoneText;
  final String? mainExerciseName;
  final double? mainPrKg;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFE08866), Color(0xFFD97757), Color(0xFFB85432)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: context.colors.accentDeep.withOpacity(0.35),
            blurRadius: 36,
            offset: const Offset(0, 18),
          ),
        ],
      ),
      padding: const EdgeInsets.all(22),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            right: -60,
            top: -60,
            child: Container(
              width: 280,
              height: 280,
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  colors: [Color(0x55FFFFFF), Color(0x22FFFFFF), Color(0x00FFFFFF)],
                  stops: [0.0, 0.45, 1.0],
                ),
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                  ),
                  SizedBox(width: 6),
                  Text(
                    "NEXT WORKOUT",
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.06,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10),
              Text(
                routineName,
                style: TextStyle(
                  fontSize: 34,
                  color: Colors.white,
                  fontWeight: FontWeight.w400,
                  letterSpacing: -0.68,
                  height: 1.05,
                ),
              ),
              SizedBox(height: 4),
              Text(
                '$exerciseCount exercises · ~$estimatedMin min',
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.white,
                  fontWeight: FontWeight.w400,
                ),
              ),
              SizedBox(height: 2),
              Text(
                lastDoneText,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.white.withOpacity(0.6),
                  fontWeight: FontWeight.w400,
                ),
              ),
              if (mainExerciseName != null) ...[
                SizedBox(height: 14),
                _PrChip(exerciseName: mainExerciseName!, prKg: mainPrKg),
              ],
              SizedBox(height: 16),
              PressableScale(
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => ActiveWorkoutScreen(routineId: routineId),
                  ),
                ),
                child: Container(
                  height: 50,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.18),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.3),
                      width: 0.5,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.play_arrow, color: Colors.white, size: 16),
                      SizedBox(width: 8),
                      Text(
                        'Start workout',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PrChip extends StatelessWidget {
  const _PrChip({required this.exerciseName, this.prKg});

  final String exerciseName;
  final double? prKg;

  @override
  Widget build(BuildContext context) {
    final prStr = prKg == null
        ? null
        : prKg! % 1 == 0
            ? '${prKg!.toInt()} kg'
            : '${prKg!.toStringAsFixed(1)} kg';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: Colors.white.withOpacity(0.25),
          width: 0.5,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'PR',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: Colors.white.withOpacity(0.6),
              letterSpacing: 0.5,
            ),
          ),
          Container(
            width: 1,
            height: 10,
            margin: const EdgeInsets.symmetric(horizontal: 8),
            color: Colors.white.withOpacity(0.3),
          ),
          Text(
            exerciseName,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: Colors.white,
            ),
          ),
          SizedBox(width: 8),
          Text(
            prStr ?? 'No record yet',
            style: TextStyle(
              fontSize: 13,
              fontWeight: prStr != null ? FontWeight.w700 : FontWeight.w400,
              color: prStr != null
                  ? Colors.white
                  : Colors.white.withOpacity(0.6),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyHeroCard extends StatelessWidget {
  const _EmptyHeroCard({required this.onCreateRoutine});
  final VoidCallback onCreateRoutine;

  @override
  Widget build(BuildContext context) {
    return PressableScale(
      onTap: onCreateRoutine,
      child: Container(
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          color: context.colors.glassBg,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: context.colors.glassBorder, width: 0.5),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'No routines yet',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w500,
                color: context.colors.ink900,
                letterSpacing: -0.44,
              ),
            ),
            SizedBox(height: 6),
            Text(
              'Tap here to create your first workout template.',
              style: TextStyle(fontSize: 14, color: context.colors.ink500),
            ),
            SizedBox(height: 18),
            Row(
              children: [
                Icon(
                  Icons.add_circle_outline,
                  size: 16,
                  color: context.colors.accentDeep,
                ),
                SizedBox(width: 6),
                Text(
                  'Create routine',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: context.colors.accentDeep,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
