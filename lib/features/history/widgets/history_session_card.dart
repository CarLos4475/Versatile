import 'package:flutter/material.dart';
import 'package:versatile/l10n/app_localizations.dart';
import '../../../core/theme/app_colors.dart';
import '../../../domain/entities/session.dart';
import '../../../shared/widgets/glass_container.dart';
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

    return GlassContainer(
      key: containerKey,
      radius: 18,
      padding: const EdgeInsets.all(16),
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => SessionDetailScreen(session: session),
          ),
        );
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  IconData(session.iconCode, fontFamily: 'MaterialIcons'),
                  color: color,
                  size: 16,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      session.routineName,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: context.colors.ink900,
                      ),
                    ),
                    Text(
                      FormatUtils.date(session.date, locale: locale),
                      style: TextStyle(
                        fontSize: 11,
                        color: context.colors.ink500,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right,
                size: 16,
                color: context.colors.ink300,
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              _Stat(
                label: l10n.duration,
                value: '${session.durationMin}m',
              ),
              const SizedBox(width: 16),
              _Stat(
                label: l10n.volume,
                value: '${FormatUtils.weight(session.volumeKg)}kg',
              ),
              const SizedBox(width: 16),
              _Stat(
                label: l10n.exercises,
                value: '${session.exercises?.length ?? 0}',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: TextStyle(
            fontSize: 9,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.05,
            color: context.colors.ink400,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: context.colors.ink700,
          ),
        ),
      ],
    );
  }
}
