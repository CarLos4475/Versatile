import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import 'motion.dart';

/// Magazine-style page header: small eyebrow above, big two-line title
/// (prefix in normal weight + accent in italic accentLight). Pairs with the
/// brutalist grid layout — back/trailing buttons are square, no radius.
///
/// Layout rules:
///  - If `onBack` is provided, it shares a single row with the eyebrow (if
///    present) and trailing button. This avoids dead rows and duplicate
///    trailing when both eyebrow and trailing are used.
///  - If no `onBack` but `trailing` is provided, the trailing button moves
///    inline next to the eyebrow (or sits on a right-aligned row when there's
///    no eyebrow either). This avoids the dead row that happens when only a
///    trailing button is set on tab-level screens.
class ScreenHeader extends StatelessWidget {
  const ScreenHeader({
    super.key,
    required this.prefix,
    required this.accent,
    this.eyebrow,
    this.trailing,
    this.onBack,
    this.accentBack = false,
    this.titleSize,
  });

  final String prefix;
  final String accent;
  final String? eyebrow;
  final Widget? trailing;
  final VoidCallback? onBack;
  final bool accentBack;
  final double? titleSize;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final compact = MediaQuery.sizeOf(context).height < 780;
    final size = titleSize ?? (compact ? 40.0 : 46.0);

    final hasBack = onBack != null;
    final inlineTrailing = !hasBack && trailing != null;
    final hasInlineRow = eyebrow != null || inlineTrailing;

    return FadeSlideIn(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(22, 8, 22, 6),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (hasBack)
              SizedBox(
                height: 44,
                child: Row(
                  children: [
                    PressableScale(
                      onTap: onBack,
                      child: Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          color: accentBack
                              ? colors.accent
                              : colors.ink900.withValues(alpha: 0.04),
                          border: Border.all(
                            color: accentBack
                                ? colors.accentDeep.withValues(alpha: 0.6)
                                : colors.hairline,
                            width: 0.6,
                          ),
                        ),
                        child: Icon(
                          Icons.chevron_left,
                          color: accentBack ? Colors.white : colors.ink700,
                          size: 20,
                        ),
                      ),
                    ),
                    if (eyebrow != null) ...[
                      const SizedBox(width: 12),
                      Expanded(child: _HeaderEyebrow(text: eyebrow!)),
                    ] else
                      const Spacer(),
                    ?trailing,
                  ],
                ),
              ),
            SizedBox(height: hasBack ? 6 : 0),
            if (!hasBack && hasInlineRow)
              SizedBox(
                height: 44,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    if (eyebrow != null)
                      Expanded(child: _HeaderEyebrow(text: eyebrow!))
                    else
                      const Spacer(),
                    ?trailing,
                  ],
                ),
              ),
            SizedBox(height: !hasBack && hasInlineRow ? 10 : 0),
            Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: '$prefix\n',
                    style: TextStyle(
                      fontSize: size,
                      height: 0.94,
                      fontWeight: FontWeight.w500,
                      letterSpacing: -0.05,
                      color: colors.ink900,
                    ),
                  ),
                  TextSpan(
                    text: accent,
                    style: TextStyle(
                      fontSize: size,
                      height: 0.94,
                      fontWeight: FontWeight.w400,
                      fontStyle: FontStyle.italic,
                      letterSpacing: -0.045,
                      color: colors.accentLight,
                    ),
                  ),
                ],
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

class _HeaderEyebrow extends StatelessWidget {
  const _HeaderEyebrow({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Row(
      children: [
        Container(
          width: 22,
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
              fontSize: 10,
              fontWeight: FontWeight.w800,
              color: colors.ink500,
              letterSpacing: 0.18,
            ),
          ),
        ),
      ],
    );
  }
}
