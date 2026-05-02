import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/navigation/app_page_transitions.dart';
import '../../core/providers/repository_providers.dart';
import '../../core/theme/app_colors.dart';
import '../../app.dart';
import '../../shared/widgets/motion.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final _pageCtrl = PageController();
  final _nameCtrl = TextEditingController();
  int _currentPage = 0;

  @override
  void dispose() {
    _pageCtrl.dispose();
    _nameCtrl.dispose();
    super.dispose();
  }

  void _next() {
    _pageCtrl.nextPage(
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeInOut,
    );
  }

  Future<void> _finish() async {
    final settings = ref.read(settingsRepositoryProvider);
    final name = _nameCtrl.text.trim();
    if (name.isNotEmpty) await settings.setUserName(name);
    await settings.setOnboarded();
    ref.invalidate(userNameProvider);
    if (!mounted) return;
    Navigator.of(context).pushReplacement(AppRoute(page: const MainShell()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.bgFrame,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView(
                controller: _pageCtrl,
                onPageChanged: (p) => setState(() => _currentPage = p),
                children: [
                  _OnboardPage(
                    icon: Icons.fitness_center,
                    title: 'Welcome to\nVersatile',
                    body:
                        'Your personal gym tracker.\nSimple, powerful, private.',
                    onNext: _next,
                    isFirst: true,
                  ),
                  _OnboardPage(
                    icon: Icons.show_chart,
                    title: 'Track\nevery rep',
                    body:
                        'Log sets, weight and reps. Watch your progress build over time.',
                    onNext: _next,
                  ),
                  _OnboardPage(
                    icon: Icons.format_list_bulleted,
                    title: 'Build your\nroutines',
                    body:
                        'Create custom workouts, reorder exercises and stay consistent.',
                    onNext: _next,
                  ),
                  _OnboardPage(
                    icon: Icons.lock_outline,
                    title: '100% local.\nZero tracking.',
                    body:
                        'No internet. No account. No payment. No data ever leaves your device.',
                    onNext: _next,
                    highlightBody: true,
                  ),
                  _NamePage(controller: _nameCtrl, onFinish: _finish),
                ],
              ),
            ),
            _PageDots(currentPage: _currentPage, totalPages: 5),
            SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

class _OnboardPage extends StatelessWidget {
  const _OnboardPage({
    required this.icon,
    required this.title,
    required this.body,
    required this.onNext,
    this.isFirst = false,
    this.highlightBody = false,
  });

  final IconData icon;
  final String title;
  final String body;
  final VoidCallback onNext;
  final bool isFirst;
  final bool highlightBody;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 36),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [
                  Color(0xFFE08866),
                  Color(0xFFD97757),
                  Color(0xFFB85432),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(22),
              boxShadow: [
                BoxShadow(
                  color: context.colors.accentDeep.withOpacity(0.3),
                  blurRadius: 32,
                  offset: const Offset(0, 12),
                ),
              ],
            ),
            child: Icon(icon, color: Colors.white, size: 32),
          ),
          SizedBox(height: 36),
          Text(
            title,
            style: TextStyle(
              fontSize: 38,
              fontWeight: FontWeight.w400,
              letterSpacing: -1.14,
              color: context.colors.ink900,
              height: 1.05,
            ),
          ),
          SizedBox(height: 16),
          Text(
            body,
            style: TextStyle(
              fontSize: 16,
              color: highlightBody ? context.colors.ink700 : context.colors.ink500,
              height: 1.5,
              fontWeight: highlightBody ? FontWeight.w500 : FontWeight.w400,
            ),
          ),
          SizedBox(height: 48),
          PressableScale(
            onTap: onNext,
            child: Container(
              height: 54,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFE08866), Color(0xFFD97757)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: context.colors.accentDeep.withOpacity(0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Continue',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(width: 8),
                  Icon(Icons.arrow_forward, size: 16, color: Colors.white),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _NamePage extends StatelessWidget {
  const _NamePage({required this.controller, required this.onFinish});

  final TextEditingController controller;
  final VoidCallback onFinish;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 36,
        right: 36,
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [
                  Color(0xFFE08866),
                  Color(0xFFD97757),
                  Color(0xFFB85432),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(22),
              boxShadow: [
                BoxShadow(
                  color: context.colors.accentDeep.withOpacity(0.3),
                  blurRadius: 32,
                  offset: const Offset(0, 12),
                ),
              ],
            ),
            child: Icon(
              Icons.waving_hand_outlined,
              color: Colors.white,
              size: 32,
            ),
          ),
          SizedBox(height: 36),
          Text(
            'What should\nwe call you?',
            style: TextStyle(
              fontSize: 38,
              fontWeight: FontWeight.w400,
              letterSpacing: -1.14,
              color: context.colors.ink900,
              height: 1.05,
            ),
          ),
          SizedBox(height: 16),
          Text(
            'Optional — you can skip this.',
            style: TextStyle(fontSize: 15, color: context.colors.ink400),
          ),
          SizedBox(height: 28),
          Container(
            decoration: BoxDecoration(
              color: context.colors.glassBg,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: context.colors.glassBorder, width: 0.5),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: TextField(
              controller: controller,
              autofocus: false,
              textCapitalization: TextCapitalization.words,
              style: TextStyle(
                fontSize: 18,
                color: context.colors.ink900,
                fontWeight: FontWeight.w500,
              ),
              decoration: InputDecoration(
                hintText: 'Your name…',
                hintStyle: TextStyle(fontSize: 18, color: context.colors.ink300),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),
          SizedBox(height: 24),
          PressableScale(
            onTap: onFinish,
            child: Container(
              height: 54,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFE08866), Color(0xFFD97757)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: context.colors.accentDeep.withOpacity(0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.check, size: 18, color: Colors.white),
                  SizedBox(width: 8),
                  Text(
                    "Let's go",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PageDots extends StatelessWidget {
  const _PageDots({required this.currentPage, required this.totalPages});

  final int currentPage;
  final int totalPages;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(totalPages, (i) {
        final active = i == currentPage;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          margin: const EdgeInsets.symmetric(horizontal: 3),
          width: active ? 20 : 6,
          height: 6,
          decoration: BoxDecoration(
            color: active ? context.colors.accentDeep : context.colors.ink300,
            borderRadius: BorderRadius.circular(3),
          ),
        );
      }),
    );
  }
}