import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../../core/theme/app_colors.dart';
import '../../../domain/entities/session.dart';
import '../../../l10n/app_localizations.dart';
import '../../../shared/widgets/glass_button.dart';
import '../../../shared/widgets/motion.dart';
import '../../../shared/widgets/screen_header.dart';
import '../../recap/view_models/recap_view_model.dart';
import '../widgets/shareable_session_card.dart';

class ShareSessionScreen extends ConsumerStatefulWidget {
  const ShareSessionScreen({super.key, required this.session});
  final Session session;

  @override
  ConsumerState<ShareSessionScreen> createState() => _ShareSessionScreenState();
}

class _ShareSessionScreenState extends ConsumerState<ShareSessionScreen> {
  final _boundaryKey = GlobalKey();
  bool _sharing = false;

  Future<void> _share() async {
    if (_sharing) return;
    setState(() => _sharing = true);
    try {
      final boundary = _boundaryKey.currentContext!.findRenderObject()
          as RenderRepaintBoundary;
      final image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      final bytes = byteData!.buffer.asUint8List();
      final dir = await getTemporaryDirectory();
      final file = File(
        '${dir.path}/versatile_share_${DateTime.now().millisecondsSinceEpoch}.png',
      );
      await file.writeAsBytes(bytes, flush: true);
      await Share.shareXFiles(
        [XFile(file.path, mimeType: 'image/png')],
      );
    } finally {
      if (mounted) setState(() => _sharing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = context.colors;

    return Scaffold(
      backgroundColor: colors.bgApp,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ScreenHeader(
              title: l10n.shareWorkout,
              subtitle: l10n.sharePreviewSubtitle,
              onBack: () => Navigator.of(context).pop(),
              accentBack: true,
            ),
            const SizedBox(height: 16),
            Expanded(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: FadeSlideIn(
                    delay: const Duration(milliseconds: 60),
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final maxSide = constraints.maxWidth.clamp(
                          0.0,
                          ShareableSessionCard.logicalSize,
                        );
                        return ClipRRect(
                          borderRadius: BorderRadius.circular(28),
                          child: SizedBox(
                            width: maxSide,
                            height: maxSide,
                            child: FittedBox(
                              fit: BoxFit.cover,
                              child: RepaintBoundary(
                                key: _boundaryKey,
                                child: ShareableSessionCard(
                                  session: widget.session,
                                  pr: ref.watch(
                                    sessionPRProvider(widget.session.id),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(22, 0, 22, 28),
              child: FadeSlideIn(
                delay: const Duration(milliseconds: 180),
                child: GlassButton(
                  label: _sharing ? l10n.saving : l10n.share,
                  leading: const Icon(
                    Icons.ios_share_rounded,
                    color: Colors.white,
                    size: 18,
                  ),
                  variant: GlassButtonVariant.primary,
                  size: GlassButtonSize.lg,
                  expand: true,
                  loading: _sharing,
                  onPressed: _sharing ? null : _share,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
