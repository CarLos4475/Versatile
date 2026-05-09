import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/navigation/app_page_transitions.dart';
import '../../core/providers/repository_providers.dart';
import '../../core/theme/app_colors.dart';
import '../../app.dart';
import '../../l10n/app_localizations.dart';
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

  static const _totalPages = 5;

  @override
  void dispose() {
    _pageCtrl.dispose();
    _nameCtrl.dispose();
    super.dispose();
  }

  void _next() {
    _pageCtrl.animateToPage(
      _currentPage + 1,
      duration: const Duration(milliseconds: 420),
      curve: Curves.easeInOutCubic,
    );
  }

  void _skip() {
    _pageCtrl.animateToPage(
      _totalPages - 1,
      duration: const Duration(milliseconds: 420),
      curve: Curves.easeInOutCubic,
    );
  }

  Future<void> _finish() async {
    final settings = ref.read(settingsRepositoryProvider);
    final name = _nameCtrl.text.trim();
    if (name.isNotEmpty) await settings.setUserName(name);
    await settings.setOnboarded();
    ref.invalidate(userNameProvider);
    if (!mounted) return;
    Navigator.of(
      context,
    ).pushReplacement(AppRoute(page: const MainNavigationShell()));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final keyboardVisible = MediaQuery.of(context).viewInsets.bottom > 0;
    return Scaffold(
      backgroundColor: context.colors.bgApp,
      body: Stack(
        fit: StackFit.expand,
        children: [
          _BackgroundOrbs(),
          SafeArea(
            child: Column(
              children: [
                SizedBox(
                  height: 52,
                  child: AnimatedOpacity(
                    opacity: _currentPage < _totalPages - 1 ? 1.0 : 0.0,
                    duration: const Duration(milliseconds: 200),
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: GestureDetector(
                        onTap: _skip,
                        child: Padding(
                          padding: const EdgeInsets.only(right: 24),
                          child: Text(
                            l10n.onboardingSkip,
                            style: TextStyle(
                              fontSize: 15,
                              color: context.colors.ink400,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: PageView(
                    controller: _pageCtrl,
                    onPageChanged: (p) => setState(() => _currentPage = p),
                    children: [
                      _AnimatedOnboardPage(
                        icon: Icons.fitness_center_rounded,
                        title: l10n.onboardingPage1Title,
                        body: l10n.onboardingPage1Body,
                        onNext: _next,
                      ),
                      _AnimatedOnboardPage(
                        icon: Icons.trending_up_rounded,
                        title: l10n.onboardingPage2Title,
                        body: l10n.onboardingPage2Body,
                        onNext: _next,
                      ),
                      _AnimatedOnboardPage(
                        icon: Icons.event_note_rounded,
                        title: l10n.onboardingPage3Title,
                        body: l10n.onboardingPage3Body,
                        onNext: _next,
                      ),
                      _AnimatedOnboardPage(
                        icon: Icons.shield_outlined,
                        title: l10n.onboardingPage4Title,
                        body: l10n.onboardingPage4Body,
                        onNext: _next,
                        isLast: true,
                      ),
                      _NamePage(controller: _nameCtrl, onFinish: _finish),
                    ],
                  ),
                ),
                if (!keyboardVisible) _PageDots(
                  currentPage: _currentPage,
                  totalPages: _totalPages,
                ),
                if (!keyboardVisible) const SizedBox(height: 32),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _BackgroundOrbs extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(
          top: -90,
          right: -90,
          child: Container(
            width: 340,
            height: 340,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  context.colors.accent.withValues(alpha: 0.13),
                  context.colors.accent.withValues(alpha: 0.0),
                ],
              ),
            ),
          ),
        ),
        Positioned(
          bottom: -70,
          left: -70,
          child: Container(
            width: 260,
            height: 260,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  context.colors.accentDeep.withValues(alpha: 0.09),
                  context.colors.accentDeep.withValues(alpha: 0.0),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _AnimatedOnboardPage extends StatefulWidget {
  const _AnimatedOnboardPage({
    required this.icon,
    required this.title,
    required this.body,
    required this.onNext,
    this.isLast = false,
  });

  final IconData icon;
  final String title;
  final String body;
  final VoidCallback onNext;
  final bool isLast;

  @override
  State<_AnimatedOnboardPage> createState() => _AnimatedOnboardPageState();
}

class _AnimatedOnboardPageState extends State<_AnimatedOnboardPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _iconScale;
  late Animation<double> _iconOpacity;
  late Animation<double> _titleOpacity;
  late Animation<Offset> _titleSlide;
  late Animation<double> _bodyOpacity;
  late Animation<double> _btnOpacity;
  late Animation<Offset> _btnSlide;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      duration: const Duration(milliseconds: 720),
      vsync: this,
    );

    _iconScale = Tween<double>(begin: 0.55, end: 1.0).animate(
      CurvedAnimation(
        parent: _ctrl,
        curve: const Interval(0.0, 0.55, curve: Curves.easeOutBack),
      ),
    );
    _iconOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _ctrl,
        curve: const Interval(0.0, 0.38, curve: Curves.easeOut),
      ),
    );
    _titleOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _ctrl,
        curve: const Interval(0.22, 0.55, curve: Curves.easeOut),
      ),
    );
    _titleSlide =
        Tween<Offset>(begin: const Offset(0, 0.22), end: Offset.zero).animate(
      CurvedAnimation(
        parent: _ctrl,
        curve: const Interval(0.22, 0.58, curve: Curves.easeOutCubic),
      ),
    );
    _bodyOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _ctrl,
        curve: const Interval(0.4, 0.72, curve: Curves.easeOut),
      ),
    );
    _btnOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _ctrl,
        curve: const Interval(0.58, 0.88, curve: Curves.easeOut),
      ),
    );
    _btnSlide =
        Tween<Offset>(begin: const Offset(0, 0.28), end: Offset.zero).animate(
      CurvedAnimation(
        parent: _ctrl,
        curve: const Interval(0.58, 0.88, curve: Curves.easeOutCubic),
      ),
    );

    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FadeTransition(
            opacity: _iconOpacity,
            child: ScaleTransition(
              scale: _iconScale,
              child: _IconBadge(icon: widget.icon),
            ),
          ),
          const SizedBox(height: 40),
          FadeTransition(
            opacity: _titleOpacity,
            child: SlideTransition(
              position: _titleSlide,
              child: Text(
                widget.title,
                style: TextStyle(
                  fontSize: 42,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -1.26,
                  color: context.colors.ink900,
                  height: 1.04,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          FadeTransition(
            opacity: _bodyOpacity,
            child: Text(
              widget.body,
              style: TextStyle(
                fontSize: 16,
                color: context.colors.ink500,
                height: 1.55,
                letterSpacing: -0.1,
              ),
            ),
          ),
          const SizedBox(height: 52),
          FadeTransition(
            opacity: _btnOpacity,
            child: SlideTransition(
              position: _btnSlide,
              child: _ContinueButton(
                label: widget.isLast
                    ? AppLocalizations.of(context)!.onboardingWhatsYourName
                    : AppLocalizations.of(context)!.onboardingContinue,
                icon: widget.isLast
                    ? Icons.person_outline
                    : Icons.arrow_forward,
                onTap: widget.onNext,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _IconBadge extends StatelessWidget {
  const _IconBadge({required this.icon});
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 88,
      height: 88,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            context.colors.accentLight,
            context.colors.accent,
            context.colors.accentDeep,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(26),
        boxShadow: [
          BoxShadow(
            color: context.colors.accentDeep.withValues(alpha: 0.38),
            blurRadius: 44,
            offset: const Offset(0, 18),
          ),
          BoxShadow(
            color: context.colors.accent.withValues(alpha: 0.18),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Icon(icon, color: Colors.white, size: 38),
    );
  }
}

class _ContinueButton extends StatelessWidget {
  const _ContinueButton({
    required this.label,
    required this.icon,
    required this.onTap,
  });
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return PressableScale(
      onTap: onTap,
      child: Container(
        height: 56,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [context.colors.accentLight, context.colors.accent],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: context.colors.accentDeep.withValues(alpha: 0.38),
              blurRadius: 26,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.white,
                letterSpacing: -0.1,
              ),
            ),
            const SizedBox(width: 8),
            Icon(icon, size: 16, color: Colors.white),
          ],
        ),
      ),
    );
  }
}

class _NamePage extends StatefulWidget {
  const _NamePage({required this.controller, required this.onFinish});
  final TextEditingController controller;
  final VoidCallback onFinish;

  @override
  State<_NamePage> createState() => _NamePageState();
}

class _NamePageState extends State<_NamePage>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _iconScale;
  late Animation<double> _iconOpacity;
  late Animation<double> _contentOpacity;
  late Animation<Offset> _contentSlide;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      duration: const Duration(milliseconds: 680),
      vsync: this,
    );
    _iconScale = Tween<double>(begin: 0.55, end: 1.0).animate(
      CurvedAnimation(
        parent: _ctrl,
        curve: const Interval(0.0, 0.55, curve: Curves.easeOutBack),
      ),
    );
    _iconOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _ctrl,
        curve: const Interval(0.0, 0.38, curve: Curves.easeOut),
      ),
    );
    _contentOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _ctrl,
        curve: const Interval(0.3, 0.75, curve: Curves.easeOut),
      ),
    );
    _contentSlide =
        Tween<Offset>(begin: const Offset(0, 0.18), end: Offset.zero).animate(
      CurvedAnimation(
        parent: _ctrl,
        curve: const Interval(0.3, 0.75, curve: Curves.easeOutCubic),
      ),
    );
    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FadeTransition(
            opacity: _iconOpacity,
            child: ScaleTransition(
              scale: _iconScale,
              child: const _IconBadge(icon: Icons.waving_hand_outlined),
            ),
          ),
          const SizedBox(height: 40),
          FadeTransition(
            opacity: _contentOpacity,
            child: SlideTransition(
              position: _contentSlide,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppLocalizations.of(context)!.onboardingNameTitle,
                    style: TextStyle(
                      fontSize: 42,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -1.26,
                      color: context.colors.ink900,
                      height: 1.04,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    AppLocalizations.of(context)!.onboardingNameSubtitle,
                    style: TextStyle(
                      fontSize: 15,
                      color: context.colors.ink400,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 28),
                  Container(
                    decoration: BoxDecoration(
                      color: context.colors.glassBg,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: context.colors.glassBorder,
                        width: 0.5,
                      ),
                    ),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 4),
                    child: TextField(
                      controller: widget.controller,
                      autofocus: false,
                      textCapitalization: TextCapitalization.words,
                      style: TextStyle(
                        fontSize: 18,
                        color: context.colors.ink900,
                        fontWeight: FontWeight.w500,
                      ),
                      decoration: InputDecoration(
                        hintText: AppLocalizations.of(context)!.onboardingNameHint,
                        hintStyle: TextStyle(
                          fontSize: 18,
                          color: context.colors.ink300,
                        ),
                        border: InputBorder.none,
                        contentPadding:
                            const EdgeInsets.symmetric(vertical: 14),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  _ContinueButton(
                    label: AppLocalizations.of(context)!.onboardingLetsGo,
                    icon: Icons.check,
                    onTap: widget.onFinish,
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
          duration: const Duration(milliseconds: 280),
          curve: Curves.easeInOut,
          margin: const EdgeInsets.symmetric(horizontal: 3),
          width: active ? 22 : 6,
          height: 6,
          decoration: BoxDecoration(
            color: active
                ? context.colors.accentDeep
                : context.colors.ink300,
            borderRadius: BorderRadius.circular(3),
          ),
        );
      }),
    );
  }
}
