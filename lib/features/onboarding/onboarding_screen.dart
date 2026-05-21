import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app.dart';
import '../../core/navigation/app_page_transitions.dart';
import '../../core/providers/repository_providers.dart';
import '../../core/theme/app_colors.dart';
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

  static const _totalPages = 5;
  int _currentPage = 0;

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

  void _skipToEnd() {
    _pageCtrl.animateToPage(
      _totalPages - 1,
      duration: const Duration(milliseconds: 420),
      curve: Curves.easeInOutCubic,
    );
  }

  Future<void> _finish() async {
    final settings = ref.read(settingsRepositoryProvider);
    final name = _nameCtrl.text.trim();
    if (name.isNotEmpty) {
      await settings.setUserName(name);
    }
    await settings.setOnboarded();
    ref.invalidate(userNameProvider);
    if (!mounted) {
      return;
    }
    Navigator.of(
      context,
    ).pushReplacement(AppRoute(page: const MainNavigationShell()));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final keyboardVisible = MediaQuery.viewInsetsOf(context).bottom > 0;
    final pageLabels = [
      l10n.obB1Eyebrow,
      l10n.obB2Eyebrow,
      l10n.obB3Eyebrow,
      l10n.obB4Eyebrow,
      l10n.obB5Eyebrow,
    ];

    return Scaffold(
      backgroundColor: context.colors.bgApp,
      body: DecoratedBox(
        decoration: BoxDecoration(color: context.colors.bgApp),
        child: Stack(
          fit: StackFit.expand,
          children: [
            const _BackgroundGlow(),
            SafeArea(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 430),
                      child: Column(
                        children: [
                          _OBTopBar(
                            step: _currentPage,
                            total: _totalPages,
                            skipLabel: l10n.onboardingSkip,
                            showSkip: _currentPage < _totalPages - 1,
                            onSkip: _skipToEnd,
                          ),
                          Expanded(
                            child: PageView(
                              controller: _pageCtrl,
                              physics: const ClampingScrollPhysics(),
                              onPageChanged: (page) {
                                setState(() => _currentPage = page);
                              },
                              children: [
                                _OnboardB1(l10n: l10n, onNext: _next),
                                _OnboardB2(l10n: l10n, onNext: _next),
                                _OnboardB3(l10n: l10n, onNext: _next),
                                _OnboardB4(l10n: l10n, onNext: _next),
                                _OnboardB5(
                                  l10n: l10n,
                                  controller: _nameCtrl,
                                  onFinish: _finish,
                                ),
                              ],
                            ),
                          ),
                          if (!keyboardVisible)
                            _OBProgressBar(
                              step: _currentPage,
                              total: _totalPages,
                              labels: pageLabels,
                            ),
                          if (!keyboardVisible) const SizedBox(height: 22),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OBTopBar extends StatelessWidget {
  const _OBTopBar({
    required this.step,
    required this.total,
    required this.skipLabel,
    required this.showSkip,
    required this.onSkip,
  });

  final int step;
  final int total;
  final String skipLabel;
  final bool showSkip;
  final VoidCallback onSkip;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return SizedBox(
      height: 56,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30),
        child: Row(
          children: [
            Text(
              '${(step + 1).toString().padLeft(2, '0')} / ${total.toString().padLeft(2, '0')}',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: colors.ink500,
                letterSpacing: 0.08,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
            const Spacer(),
            AnimatedOpacity(
              opacity: showSkip ? 1 : 0,
              duration: const Duration(milliseconds: 180),
              child: IgnorePointer(
                ignoring: !showSkip,
                child: PressableScale(
                  onTap: onSkip,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 2,
                      vertical: 4,
                    ),
                    child: Text(
                      skipLabel,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: colors.ink500,
                      ),
                    ),
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

class _OBProgressBar extends StatelessWidget {
  const _OBProgressBar({
    required this.step,
    required this.total,
    required this.labels,
  });

  final int step;
  final int total;
  final List<String> labels;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final label = labels.elementAt(step);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  label.toUpperCase(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    color: colors.ink500,
                    letterSpacing: 0.16,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                '${(step + 1).toString().padLeft(2, '0')} · ${total.toString().padLeft(2, '0')}',
                style: TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.w600,
                  color: colors.ink500,
                  letterSpacing: 0.1,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
            ],
          ),
          const SizedBox(height: 7),
          SizedBox(
            height: 2,
            child: Stack(
              children: [
                Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(color: colors.hairline),
                  ),
                ),
                FractionallySizedBox(
                  widthFactor: (step + 1) / total,
                  alignment: Alignment.centerLeft,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [colors.accentSoft, colors.accent],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: colors.accent.withValues(alpha: 0.4),
                          blurRadius: 10,
                        ),
                      ],
                    ),
                    child: const SizedBox.expand(),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _BackgroundGlow extends StatelessWidget {
  const _BackgroundGlow();

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Stack(
      children: [
        Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  colors.bgApp,
                  colors.bgApp,
                  colors.bgFrame.withValues(alpha: 0.98),
                ],
              ),
            ),
          ),
        ),
        Positioned(
          top: -110,
          right: -70,
          child: _GlowOrb(
            size: 320,
            color: colors.accent.withValues(alpha: 0.24),
          ),
        ),
        Positioned(
          top: 110,
          left: -180,
          child: _GlowOrb(
            size: 300,
            color: colors.accentDeep.withValues(alpha: 0.1),
          ),
        ),
        Positioned(
          bottom: -170,
          right: -120,
          child: _GlowOrb(
            size: 360,
            color: colors.doneStrong.withValues(alpha: 0.08),
          ),
        ),
      ],
    );
  }
}

class _GlowOrb extends StatelessWidget {
  const _GlowOrb({required this.size, required this.color});

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: ImageFiltered(
        imageFilter: ImageFilter.blur(sigmaX: 40, sigmaY: 40),
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: [color, color.withValues(alpha: 0)],
            ),
          ),
        ),
      ),
    );
  }
}

mixin _PageAnimState<T extends StatefulWidget> on State<T> {
  late final AnimationController ctrl;
  late final Animation<double> fade;
  late final Animation<Offset> slide;

  @override
  void initState() {
    super.initState();
    ctrl = AnimationController(
      duration: const Duration(milliseconds: 560),
      vsync: this as TickerProvider,
    );
    fade = CurvedAnimation(
      parent: ctrl,
      curve: const Interval(0, 0.72, curve: Curves.easeOut),
    );
    slide = Tween<Offset>(begin: const Offset(0, 0.055), end: Offset.zero)
        .animate(
          CurvedAnimation(
            parent: ctrl,
            curve: const Interval(0, 0.72, curve: Curves.easeOutCubic),
          ),
        );
    ctrl.forward();
  }

  @override
  void dispose() {
    ctrl.dispose();
    super.dispose();
  }
}

class _OnboardB1 extends StatefulWidget {
  const _OnboardB1({required this.l10n, required this.onNext});

  final AppLocalizations l10n;
  final VoidCallback onNext;

  @override
  State<_OnboardB1> createState() => _OnboardB1State();
}

class _OnboardB1State extends State<_OnboardB1>
    with SingleTickerProviderStateMixin, _PageAnimState {
  @override
  Widget build(BuildContext context) {
    final l10n = widget.l10n;
    final colors = context.colors;
    final compact = MediaQuery.sizeOf(context).height < 780;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30),
      child: FadeTransition(
        opacity: fade,
        child: SlideTransition(
          position: slide,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 22),
              _Eyebrow(text: l10n.obB1Eyebrow),
              const Spacer(flex: 2),
              _SplitDisplayTitle(
                top: l10n.onboardingPage1Title.split('\n').first,
                bottom: l10n.onboardingPage1Title.split('\n').last,
                bottomColor: colors.accentLight,
                size: compact ? 72 : 82,
              ),
              const SizedBox(height: 24),
              Text(
                l10n.onboardingPage1Body,
                style: TextStyle(
                  fontSize: 15.5,
                  height: 1.42,
                  color: colors.ink500,
                ),
              ),
              const SizedBox(height: 20),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _Tag(label: l10n.obTagWeights),
                  _Tag(label: l10n.obTagRoutines),
                  _Tag(label: l10n.obTagLocal),
                ],
              ),
              const Spacer(flex: 3),
              _OBButton(
                label: l10n.obCtaStart,
                icon: Icons.arrow_forward_rounded,
                onTap: widget.onNext,
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }
}

class _OnboardB2 extends StatefulWidget {
  const _OnboardB2({required this.l10n, required this.onNext});

  final AppLocalizations l10n;
  final VoidCallback onNext;

  @override
  State<_OnboardB2> createState() => _OnboardB2State();
}

class _OnboardB2State extends State<_OnboardB2>
    with SingleTickerProviderStateMixin, _PageAnimState {
  @override
  Widget build(BuildContext context) {
    final l10n = widget.l10n;
    final colors = context.colors;
    final compact = MediaQuery.sizeOf(context).height < 780;
    final isEs = Localizations.localeOf(context).languageCode == 'es';


    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30),
      child: FadeTransition(
        opacity: fade,
        child: SlideTransition(
          position: slide,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 22),
              _Eyebrow(text: l10n.obB2Eyebrow),
              const Spacer(flex: 2),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '+46',
                    style: TextStyle(
                      fontSize: compact ? 110 : 128,
                      height: 0.86,
                      fontWeight: FontWeight.w600,
                      letterSpacing: -0.06,
                      color: colors.ink900,
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 8, bottom: 14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'kg',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w500,
                            color: colors.ink700,
                          ),
                        ),
                        Text(
                          (isEs ? 'en 11 sem.' : 'in 11 wk.').toUpperCase(),
                          style: TextStyle(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.14,
                            color: colors.doneStrong,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              _SplitDisplayTitle(
                top: l10n.onboardingPage2Title.split('\n').first,
                bottom: l10n.onboardingPage2Title.split('\n').last,
                bottomColor: colors.accentLight,
                size: compact ? 54 : 60,
              ),
              const SizedBox(height: 16),
              Text(
                l10n.onboardingPage2Body,
                style: TextStyle(
                  fontSize: 15.5,
                  height: 1.42,
                  color: colors.ink500,
                ),
              ),
              const SizedBox(height: 22),
              const _MiniBars(),
              const Spacer(flex: 3),
              _OBButton(
                label: l10n.onboardingContinue,
                icon: Icons.arrow_forward_rounded,
                onTap: widget.onNext,
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }
}

class _MiniBars extends StatelessWidget {
  const _MiniBars();

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    const values = [0.16, 0.2, 0.26, 0.34, 0.44, 0.46, 0.52, 0.7, 0.56];

    return SizedBox(
      height: 24,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: List.generate(values.length, (index) {
          final highlight = index == values.length - 2;
          return Expanded(
            child: Padding(
              padding: EdgeInsets.only(
                right: index == values.length - 1 ? 0 : 4,
              ),
              child: Container(
                height: values[index] * 24,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(2.5),
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: highlight
                        ? [colors.accentLight, colors.accent]
                        : [
                            colors.accent.withValues(
                              alpha: 0.32 + index * 0.03,
                            ),
                            colors.accentDeep.withValues(
                              alpha: 0.2 + index * 0.02,
                            ),
                          ],
                  ),
                  boxShadow: highlight
                      ? [
                          BoxShadow(
                            color: colors.accent.withValues(alpha: 0.34),
                            blurRadius: 14,
                          ),
                        ]
                      : null,
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

class _OnboardB3 extends StatefulWidget {
  const _OnboardB3({required this.l10n, required this.onNext});

  final AppLocalizations l10n;
  final VoidCallback onNext;

  @override
  State<_OnboardB3> createState() => _OnboardB3State();
}

class _OnboardB3State extends State<_OnboardB3>
    with SingleTickerProviderStateMixin, _PageAnimState {
  @override
  Widget build(BuildContext context) {
    final l10n = widget.l10n;
    final colors = context.colors;
    final compact = MediaQuery.sizeOf(context).height < 780;
    final days = [
      (l10n.weekdayMonShort, 'Upper', colors.accentSoft, false),
      (l10n.weekdayTueShort, 'Lower', colors.accentLight, false),
      (l10n.weekdayWedShort, l10n.labelRest, colors.ink400, true),
      (l10n.weekdayThuShort, 'Pull', colors.accent, false),
      (l10n.weekdayFriShort, 'Push', colors.accentSoft, false),
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30),
      child: FadeTransition(
        opacity: fade,
        child: SlideTransition(
          position: slide,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 22),
              _Eyebrow(text: l10n.obB3Eyebrow),
              const Spacer(flex: 2),
              Column(
                children: days
                    .map(
                      (day) => _RoutineLine(
                        day: day.$1,
                        label: day.$2,
                        color: day.$3,
                        muted: day.$4,
                      ),
                    )
                    .toList(),
              ),
              const SizedBox(height: 26),
              _SplitDisplayTitle(
                top: l10n.onboardingPage3Title.split('\n').first,
                bottom: l10n.onboardingPage3Title.split('\n').last,
                bottomColor: colors.accentLight,
                size: compact ? 54 : 60,
              ),
              const SizedBox(height: 16),
              Text(
                l10n.onboardingPage3Body,
                style: TextStyle(
                  fontSize: 15.5,
                  height: 1.42,
                  color: colors.ink500,
                ),
              ),
              const Spacer(flex: 2),
              _OBButton(
                label: l10n.onboardingContinue,
                icon: Icons.arrow_forward_rounded,
                onTap: widget.onNext,
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }
}

class _RoutineLine extends StatelessWidget {
  const _RoutineLine({
    required this.day,
    required this.label,
    required this.color,
    required this.muted,
  });

  final String day;
  final String label;
  final Color color;
  final bool muted;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: colors.hairline, width: 0.6)),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 44,
            child: Text(
              day,
              style: TextStyle(
                fontSize: 10.5,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.16,
                color: colors.ink500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: muted ? 24 : 26,
                fontWeight: FontWeight.w500,
                height: 1.1,
                letterSpacing: -0.04,
                color: muted ? colors.ink500 : colors.ink900,
                fontStyle: muted ? FontStyle.italic : FontStyle.normal,
              ),
            ),
          ),
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color,
              boxShadow: muted
                  ? null
                  : [
                      BoxShadow(
                        color: color.withValues(alpha: 0.45),
                        blurRadius: 10,
                      ),
                    ],
            ),
          ),
        ],
      ),
    );
  }
}

class _OnboardB4 extends StatefulWidget {
  const _OnboardB4({required this.l10n, required this.onNext});

  final AppLocalizations l10n;
  final VoidCallback onNext;

  @override
  State<_OnboardB4> createState() => _OnboardB4State();
}

class _OnboardB4State extends State<_OnboardB4>
    with SingleTickerProviderStateMixin, _PageAnimState {
  @override
  Widget build(BuildContext context) {
    final l10n = widget.l10n;
    final colors = context.colors;
    final compact = MediaQuery.sizeOf(context).height < 780;
    final isEs = Localizations.localeOf(context).languageCode == 'es';

    final items = [
      (l10n.obB4ItemAccounts, true),
      (l10n.obB4ItemCloud, true),
      (l10n.obB4ItemAds, true),
      (l10n.obB4ItemLocal, false),
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30),
      child: FadeTransition(
        opacity: fade,
        child: SlideTransition(
          position: slide,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 22),
              _Eyebrow(text: l10n.obB4Eyebrow),
              const Spacer(flex: 2),
              Text(
                (isEs
                        ? 'Sin internet · Sin cuenta · Sin nube'
                        : 'No internet · No account · No cloud')
                    .toUpperCase(),
                style: TextStyle(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.14,
                  color: colors.doneStrong,
                ),
              ),
              const SizedBox(height: 12),
              _SplitDisplayTitle(
                top: l10n.onboardingPage4Title.split('\n').first,
                bottom: l10n.onboardingPage4Title.split('\n').last,
                bottomColor: colors.doneStrong,
                size: compact ? 66 : 74,
              ),
              const SizedBox(height: 24),
              ...items.map(
                (item) => _PrivacyLine(label: item.$1, blocked: item.$2),
              ),
              const Spacer(flex: 3),
              _OBButton(
                label: l10n.obCtaAlmostReady,
                icon: Icons.arrow_forward_rounded,
                onTap: widget.onNext,
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }
}

class _PrivacyLine extends StatelessWidget {
  const _PrivacyLine({required this.label, required this.blocked});

  final String label;
  final bool blocked;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Padding(
      padding: const EdgeInsets.only(bottom: 11),
      child: Row(
        children: [
          Icon(
            blocked ? Icons.radio_button_unchecked_rounded : Icons.check_circle,
            size: 14,
            color: blocked ? colors.ink500 : colors.doneStrong,
          ),
          const SizedBox(width: 11),
          Text(
            label,
            style: TextStyle(
              fontSize: 14.5,
              height: 1.3,
              color: blocked ? colors.ink500 : colors.ink900,
            ),
          ),
        ],
      ),
    );
  }
}

class _OnboardB5 extends StatefulWidget {
  const _OnboardB5({
    required this.l10n,
    required this.controller,
    required this.onFinish,
  });

  final AppLocalizations l10n;
  final TextEditingController controller;
  final VoidCallback onFinish;

  @override
  State<_OnboardB5> createState() => _OnboardB5State();
}

class _OnboardB5State extends State<_OnboardB5>
    with SingleTickerProviderStateMixin, _PageAnimState {
  @override
  Widget build(BuildContext context) {
    final l10n = widget.l10n;
    final colors = context.colors;
    final compact = MediaQuery.sizeOf(context).height < 780;
    final isEs = Localizations.localeOf(context).languageCode == 'es';


    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30),
      child: FadeTransition(
        opacity: fade,
        child: SlideTransition(
          position: slide,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 22),
              _Eyebrow(text: l10n.obB5Eyebrow),
              const Spacer(flex: 2),
              _SplitDisplayTitle(
                top: l10n.onboardingNameTitle.split('\n').first,
                bottom: l10n.onboardingNameTitle.split('\n').last,
                bottomColor: colors.accentLight,
                size: compact ? 62 : 70,
              ),
              const SizedBox(height: 16),
              Text(
                isEs
                    ? 'Opcional. Puedes saltarlo o cambiarlo cuando quieras.'
                    : 'Optional. You can skip it now or change it later.',
                style: TextStyle(
                  fontSize: 14.5,
                  height: 1.38,
                  color: colors.ink500,
                ),
              ),
              const SizedBox(height: 24),
              _NameCard(
                controller: widget.controller,
                label: l10n.obB5NameLabel,
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Icon(Icons.shield_outlined, size: 12, color: colors.ink500),
                  const SizedBox(width: 6),
                  Text(
                    isEs
                        ? 'Se guarda solo en este dispositivo'
                        : 'Saved only on this device',
                    style: TextStyle(fontSize: 11, color: colors.ink500),
                  ),
                ],
              ),
              const Spacer(flex: 3),
              _OBButton(
                label: l10n.onboardingLetsGo,
                icon: Icons.check_rounded,
                onTap: widget.onFinish,
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }
}

class _NameCard extends StatelessWidget {
  const _NameCard({required this.controller, required this.label});

  final TextEditingController controller;
  final String label;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
      decoration: BoxDecoration(
        color: colors.glassBg.withValues(alpha: 0.58),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: colors.accent.withValues(alpha: 0.34),
          width: 0.8,
        ),
        boxShadow: [
          BoxShadow(
            color: colors.accent.withValues(alpha: 0.12),
            blurRadius: 22,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label.toUpperCase(),
            style: TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.14,
              color: colors.ink500,
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: controller,
            textCapitalization: TextCapitalization.words,
            cursorColor: colors.accent,
            style: TextStyle(
              fontSize: 36,
              height: 1,
              fontWeight: FontWeight.w500,
              letterSpacing: -0.04,
              color: colors.ink900,
            ),
            decoration: InputDecoration(
              hintText: '',
              hintStyle: TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.w500,
                letterSpacing: -0.04,
                color: colors.ink300,
              ),
              border: InputBorder.none,
              isDense: true,
              contentPadding: EdgeInsets.zero,
            ),
          ),
        ],
      ),
    );
  }
}

class _SplitDisplayTitle extends StatelessWidget {
  const _SplitDisplayTitle({
    required this.top,
    required this.bottom,
    required this.bottomColor,
    required this.size,
  });

  final String top;
  final String bottom;
  final Color bottomColor;
  final double size;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return SizedBox(
      width: double.infinity,
      child: FittedBox(
        fit: BoxFit.scaleDown,
        alignment: Alignment.centerLeft,
        child: Text.rich(
          TextSpan(
            children: [
              TextSpan(
                text: '$top\n',
                style: TextStyle(
                  fontSize: size,
                  height: 0.92,
                  fontWeight: FontWeight.w500,
                  letterSpacing: -0.055,
                  color: colors.ink900,
                ),
              ),
              TextSpan(
                text: bottom,
                style: TextStyle(
                  fontSize: size,
                  height: 0.92,
                  fontWeight: FontWeight.w400,
                  fontStyle: FontStyle.italic,
                  letterSpacing: -0.05,
                  color: bottomColor,
                ),
              ),
            ],
          ),
          softWrap: false,
          maxLines: 2,
        ),
      ),
    );
  }
}

class _OBButton extends StatelessWidget {
  const _OBButton({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return PressableScale(
      onTap: onTap,
      child: Container(
        height: 56,
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [colors.accentLight, colors.accent],
          ),
          boxShadow: [
            const BoxShadow(
              color: Color(0x40FFFFFF),
              blurRadius: 0,
              offset: Offset(0, 1),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 15.5,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.02,
                color: Colors.white,
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

class _Eyebrow extends StatelessWidget {
  const _Eyebrow({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Row(
      children: [
        Container(
          width: 28,
          height: 1,
          color: colors.ink400.withValues(alpha: 0.55),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text.toUpperCase(),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 10.5,
              fontWeight: FontWeight.w800,
              color: colors.ink500,
              letterSpacing: 0.2,
            ),
          ),
        ),
      ],
    );
  }
}

class _Tag extends StatelessWidget {
  const _Tag({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: colors.glassBg.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: colors.glassBorder.withValues(alpha: 0.55),
          width: 0.7,
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w500,
          color: colors.ink700,
        ),
      ),
    );
  }
}
