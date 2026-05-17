import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/repository_providers.dart';
import '../../../core/theme/app_colors.dart';
import '../../../domain/entities/monthly_recap.dart';
import '../../../l10n/app_localizations.dart';
import '../../../shared/widgets/motion.dart';
import '../view_models/recap_view_model.dart';
import '../widgets/animated_aurora_background.dart';
import '../widgets/recap_page_dots.dart';
import '../widgets/recap_slides.dart';

class MonthlyRecapScreen extends ConsumerStatefulWidget {
  const MonthlyRecapScreen({
    super.key,
    required this.monthKey,
    this.recapOverride,
  });
  final MonthKey monthKey;
  /// Debug-only: when provided, bypasses the provider lookup so a fixture
  /// recap can be previewed without altering session history or device date.
  final MonthlyRecap? recapOverride;

  @override
  ConsumerState<MonthlyRecapScreen> createState() =>
      _MonthlyRecapScreenState();
}

class _MonthlyRecapScreenState extends ConsumerState<MonthlyRecapScreen> {
  final _controller = PageController();
  int _current = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _markSeenAndClose() async {
    if (widget.recapOverride != null) {
      // Preview mode — don't persist seen state.
      if (mounted) Navigator.of(context).pop();
      return;
    }
    final key =
        '${widget.monthKey.year.toString().padLeft(4, '0')}-'
        '${widget.monthKey.month.toString().padLeft(2, '0')}';
    await ref.read(settingsRepositoryProvider).setRecapSeen(key);
    ref.invalidate(unseenLastRecapProvider);
    if (mounted) Navigator.of(context).pop();
  }

  void _advance(int totalPages) {
    if (_current >= totalPages - 1) {
      _markSeenAndClose();
      return;
    }
    _controller.nextPage(
      duration: const Duration(milliseconds: 320),
      curve: Curves.easeOutCubic,
    );
  }

  void _retreat() {
    if (_current <= 0) return;
    _controller.previousPage(
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    final recap = widget.recapOverride ??
        ref.watch(monthlyRecapProvider(widget.monthKey));
    final colors = context.colors;

    if (recap == null) {
      return Scaffold(
        backgroundColor: colors.bgApp,
        body: SafeArea(
          child: Center(
            child: Text(
              AppLocalizations.of(context)!.recapPastRecapsEmpty,
              style: TextStyle(color: colors.ink500),
            ),
          ),
        ),
      );
    }

    // BalanceSlide only renders when there's tracked push/pull/legs volume.
    // If a month had only Core / Forearms / custom muscles, skip it.
    final hasBalanceData = [
      recap.volumeByCategory['push'] ?? 0,
      recap.volumeByCategory['pull'] ?? 0,
      recap.volumeByCategory['legs'] ?? 0,
    ].any((v) => v > 0);

    final slides = <Widget>[
      IntroSlide(recap: recap),
      SessionsSlide(recap: recap),
      VolumeSlide(recap: recap),
      if (hasBalanceData) BalanceSlide(recap: recap),
      if (recap.topRoutine != null) TopRoutineSlide(recap: recap),
      if (recap.topExercise != null) TopExerciseSlide(recap: recap),
      if (recap.newPR != null) PRSlide(recap: recap),
      OutroSlide(onClose: _markSeenAndClose),
    ];

    return Scaffold(
      backgroundColor: colors.bgApp,
      body: Stack(
        children: [
          const Positioned.fill(child: AnimatedAuroraBackground()),
          PageView(
            controller: _controller,
            onPageChanged: (i) => setState(() => _current = i),
            children: slides,
          ),
          Positioned.fill(
            child: Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    behavior: HitTestBehavior.translucent,
                    onTap: _retreat,
                  ),
                ),
                Expanded(
                  child: GestureDetector(
                    behavior: HitTestBehavior.translucent,
                    onTap: () => _advance(slides.length),
                  ),
                ),
              ],
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(22, 14, 22, 0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: RecapPageDots(
                      currentPage: _current,
                      totalPages: slides.length,
                    ),
                  ),
                  const SizedBox(width: 12),
                  PressableScale(
                    onTap: _markSeenAndClose,
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: colors.glassBg,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: colors.glassBorder,
                          width: 0.5,
                        ),
                        boxShadow: colors.glassShadow,
                      ),
                      child: Icon(
                        Icons.close_rounded,
                        size: 18,
                        color: colors.ink700,
                      ),
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
