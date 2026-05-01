import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme/app_colors.dart';
import 'core/theme/app_theme.dart';
import 'features/exercises/screens/exercises_screen.dart';
import 'features/history/screens/history_screen.dart';
import 'features/home/screens/home_screen.dart';
import 'features/routines/screens/routines_screen.dart';
import 'features/splash/screens/splash_screen.dart';
import 'shared/widgets/bottom_nav_bar.dart';

class VersatileApp extends StatelessWidget {
  const VersatileApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Versatile',
      theme: AppTheme.light(),
      debugShowCheckedModeBanner: false,
      home: const SplashScreen(),
    );
  }
}

class MainShell extends ConsumerStatefulWidget {
  const MainShell({super.key});

  @override
  ConsumerState<MainShell> createState() => _MainShellState();
}

class _MainShellState extends ConsumerState<MainShell> {
  int _currentIndex = 0;

  static const _screens = [
    HomeScreen(),
    RoutinesScreen(),
    ExercisesScreen(),
    HistoryScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgApp,
      body: Stack(
        children: [
          IndexedStack(
            index: _currentIndex,
            children: _screens,
          ),
          Positioned(
            left: 12,
            right: 12,
            bottom: 14,
            child: VersatileBottomNav(
              currentIndex: _currentIndex,
              onChanged: (i) => setState(() => _currentIndex = i),
            ),
          ),
        ],
      ),
    );
  }
}
