import 'package:flutter/material.dart';
import 'package:versatile/l10n/app_localizations.dart';
import '../../../core/theme/app_colors.dart';
import '../../../domain/entities/session.dart';
import '../../../shared/widgets/motion.dart';
import '../../../core/utils/format_utils.dart';
import '../screens/session_detail_screen.dart';

class HistorySessionCard extends StatelessWidget {
  const HistorySessionCard({super.key, required this.session, this.containerKey});
  final Session session;
  final GlobalKey? containerKey;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final color = Color(session.colorValue);
    final locale = Localizations.localeOf(context).languageCode;
    final colors = context.colors;

    return PressableScale(
      key: containerKey,
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => SessionDetailScreen(session: session),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.fromLTRB(22, 16, 22, 16),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
              ),
              child: Icon(
                IconData(session.iconCode, fontFamily: 'MaterialIcons'),
                color: color,
                size: 18,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    session.routineName,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: colors.ink900,
                      letterSpacing: -0.15,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${FormatUtils.date(session.date, locale: locale)} · ${session.durationMin}m · ${FormatUtils.weight(session.volumeKg)}kg · ${session.exercises?.length ?? 0} ${l10n.exercises}',
                    style: TextStyle(
                      fontSize: 11,
                      color: colors.ink500,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Icon(
              Icons.chevron_right,
              size: 16,
              color: colors.ink400,
            ),
          ],
        ),
      ),
    );
  }
}
