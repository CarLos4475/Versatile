import 'dart:io';
import 'dart:ui' as ui;

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../../core/theme/app_colors.dart';
import '../../../domain/entities/monthly_recap.dart';
import '../../../domain/entities/session.dart';
import '../../../l10n/app_localizations.dart';
import '../../../shared/widgets/motion.dart';
import '../../../shared/widgets/photo_reposition_dialog.dart';
import '../../../shared/widgets/screen_header.dart';
import '../../recap/view_models/recap_view_model.dart';
import '../widgets/shareable_session_card.dart';

class ShareSessionScreen extends ConsumerStatefulWidget {
  const ShareSessionScreen({
    super.key,
    required this.session,
    this.precomputedPR,
  });
  final Session session;

  /// If supplied, used directly instead of recomputing via [sessionPRProvider].
  /// Set when reaching this screen from the finish-workout flow, where the
  /// active workout already detected the PR in realtime.
  final RecapPersonalRecord? precomputedPR;

  @override
  ConsumerState<ShareSessionScreen> createState() => _ShareSessionScreenState();
}

class _ShareSessionScreenState extends ConsumerState<ShareSessionScreen> {
  final _boundaryKey = GlobalKey();
  final _quoteCtrl = TextEditingController();
  bool _sharing = false;
  String? _userPhotoPath; // volatile temp file
  String _userQuote = '';
  double _photoAlignX = 0.0;
  double _photoAlignY = 0.0;
  double _photoScale = 1.0;

  static const int _quoteMaxLen = 70;
  // Photo strip inside the card is 16:9 — same ratio used by the reposition
  // dialog so the crop window matches the final render exactly.
  static const double _photoAspect = 16 / 9;

  @override
  void dispose() {
    _quoteCtrl.dispose();
    _cleanupPhoto();
    super.dispose();
  }

  Future<void> _cleanupPhoto() async {
    final path = _userPhotoPath;
    if (path == null) return;
    try {
      final f = File(path);
      if (await f.exists()) await f.delete();
    } catch (_) {}
  }

  Future<void> _pickPhoto() async {
    final result =
        await FilePicker.platform.pickFiles(type: FileType.image);
    if (result == null || result.files.isEmpty) return;
    final picked = result.files.single;

    final dir = await getTemporaryDirectory();
    final ext = picked.extension ?? 'jpg';
    final ts = DateTime.now().millisecondsSinceEpoch;
    final destPath = '${dir.path}/share_user_photo_$ts.$ext';
    try {
      final destFile = File(destPath);
      if (picked.bytes != null) {
        await destFile.writeAsBytes(picked.bytes!);
      } else if (picked.path != null) {
        await File(picked.path!).copy(destPath);
      } else {
        return;
      }
    } catch (_) {
      return;
    }

    // Replace previous temp photo if any.
    final previous = _userPhotoPath;
    if (!mounted) return;
    setState(() {
      _userPhotoPath = destPath;
      // Reset transform for the fresh photo.
      _photoAlignX = 0.0;
      _photoAlignY = 0.0;
      _photoScale = 1.0;
    });
    if (previous != null) {
      try {
        final f = File(previous);
        if (await f.exists()) await f.delete();
      } catch (_) {}
    }
  }

  Future<void> _removePhoto() async {
    final path = _userPhotoPath;
    if (path == null) return;
    setState(() {
      _userPhotoPath = null;
      _photoAlignX = 0.0;
      _photoAlignY = 0.0;
      _photoScale = 1.0;
    });
    try {
      final f = File(path);
      if (await f.exists()) await f.delete();
    } catch (_) {}
  }

  Future<void> _editPhoto() async {
    final path = _userPhotoPath;
    if (path == null) return;
    final result = await showDialog<Map<String, double>>(
      context: context,
      builder: (_) => PhotoRepositionDialog(
        imagePath: path,
        initialAlignX: _photoAlignX,
        initialAlignY: _photoAlignY,
        initialScale: _photoScale,
        aspectRatio: _photoAspect,
      ),
    );
    if (result != null && mounted) {
      setState(() {
        _photoAlignX = result['x']!;
        _photoAlignY = result['y']!;
        _photoScale = result['scale']!;
      });
    }
  }

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
    final isEs = Localizations.localeOf(context).languageCode == 'es';

    return Scaffold(
      backgroundColor: colors.bgApp,
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ScreenHeader(
              prefix: isEs ? 'Comparte' : 'Share',
              accent: isEs ? 'el entreno.' : 'your workout.',
              eyebrow: l10n.sharePreviewSubtitle,
              onBack: () => Navigator.of(context).pop(),
              accentBack: true,
            ),
            const SizedBox(height: 16),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 22),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    FadeSlideIn(
                      delay: const Duration(milliseconds: 60),
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          final hasPhoto = _userPhotoPath != null;
                          final hasQuote = _userQuote.trim().isNotEmpty;
                          final cardW = ShareableSessionCard.logicalWidth;
                          final cardH = ShareableSessionCard.logicalHeightFor(
                            hasPhoto: hasPhoto,
                            hasQuote: hasQuote,
                          );
                          final maxW =
                              constraints.maxWidth.clamp(0.0, cardW);
                          final previewH = maxW * (cardH / cardW);
                          return Center(
                            child: SizedBox(
                              width: maxW,
                              height: previewH,
                              child: FittedBox(
                                fit: BoxFit.cover,
                                child: RepaintBoundary(
                                  key: _boundaryKey,
                                  child: ShareableSessionCard(
                                    session: widget.session,
                                    pr: widget.precomputedPR ??
                                        ref.watch(
                                          sessionPRProvider(widget.session.id),
                                        ),
                                    userPhotoPath: _userPhotoPath,
                                    userQuote: hasQuote ? _userQuote : null,
                                    photoAlignX: _photoAlignX,
                                    photoAlignY: _photoAlignY,
                                    photoScale: _photoScale,
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 18),
                    FadeSlideIn(
                      delay: const Duration(milliseconds: 120),
                      child: _CustomizePanel(
                        photoPath: _userPhotoPath,
                        quote: _userQuote,
                        quoteCtrl: _quoteCtrl,
                        onPickPhoto: _pickPhoto,
                        onEditPhoto: _editPhoto,
                        onRemovePhoto: _removePhoto,
                        onQuoteChanged: (val) {
                          setState(() => _userQuote = val);
                        },
                        photoLabel: isEs ? 'AÑADIR FOTO' : 'ADD PHOTO',
                        photoChangeLabel: isEs ? 'CAMBIAR' : 'CHANGE',
                        photoCaption: isEs
                            ? 'Volátil · solo para este compartido'
                            : 'Volatile · this share only',
                        quoteHint: isEs ? 'Frase opcional…' : 'Optional quote…',
                        quoteMaxLen: _quoteMaxLen,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(22, 16, 22, 22),
              child: FadeSlideIn(
                delay: const Duration(milliseconds: 180),
                child: _MagazineShareButton(
                  label: _sharing ? l10n.saving : l10n.share,
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

class _CustomizePanel extends StatelessWidget {
  const _CustomizePanel({
    required this.photoPath,
    required this.quote,
    required this.quoteCtrl,
    required this.onPickPhoto,
    required this.onEditPhoto,
    required this.onRemovePhoto,
    required this.onQuoteChanged,
    required this.photoLabel,
    required this.photoChangeLabel,
    required this.photoCaption,
    required this.quoteHint,
    required this.quoteMaxLen,
  });

  final String? photoPath;
  final String quote;
  final TextEditingController quoteCtrl;
  final VoidCallback onPickPhoto;
  final VoidCallback onEditPhoto;
  final VoidCallback onRemovePhoto;
  final ValueChanged<String> onQuoteChanged;
  final String photoLabel;
  final String photoChangeLabel;
  final String photoCaption;
  final String quoteHint;
  final int quoteMaxLen;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final hasPhoto = photoPath != null;

    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: colors.hairline, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Photo row
          PressableScale(
            onTap: hasPhoto ? null : onPickPhoto,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 12,
              ),
              child: Row(
                children: [
                  Container(
                    width: 30,
                    height: 30,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: hasPhoto
                          ? colors.accentTint
                          : colors.ink900.withValues(alpha: 0.04),
                      border: Border.all(
                        color: hasPhoto
                            ? colors.accent.withValues(alpha: 0.4)
                            : colors.hairline,
                        width: 0.6,
                      ),
                    ),
                    child: Icon(
                      hasPhoto
                          ? Icons.image_outlined
                          : Icons.add_photo_alternate_outlined,
                      size: 15,
                      color: hasPhoto ? colors.accentDeep : colors.ink500,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          photoLabel,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.18,
                            color: colors.ink700,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          photoCaption,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                            color: colors.ink400,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (hasPhoto) ...[
                    PressableScale(
                      onTap: onPickPhoto,
                      child: Text(
                        photoChangeLabel,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.5,
                          color: colors.accentDeep,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    PressableScale(
                      onTap: onEditPhoto,
                      child: Container(
                        width: 28,
                        height: 28,
                        alignment: Alignment.center,
                        color: colors.accent,
                        child: const Icon(
                          Icons.edit_outlined,
                          size: 14,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    PressableScale(
                      onTap: onRemovePhoto,
                      child: Container(
                        width: 28,
                        height: 28,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Colors.redAccent.withValues(alpha: 0.7),
                            width: 0.8,
                          ),
                        ),
                        child: const Icon(
                          Icons.close_rounded,
                          size: 14,
                          color: Colors.redAccent,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          Container(height: 0.5, color: colors.hairline),
          // Quote row
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 6, 14, 10),
            child: TextField(
              controller: quoteCtrl,
              maxLength: quoteMaxLen,
              maxLines: 2,
              minLines: 1,
              textInputAction: TextInputAction.done,
              inputFormatters: [
                FilteringTextInputFormatter.deny(RegExp(r'[\n\r]')),
              ],
              style: GoogleFonts.playfairDisplay(
                fontSize: 14,
                fontStyle: FontStyle.italic,
                color: colors.ink900,
              ),
              decoration: InputDecoration(
                hintText: quoteHint,
                hintStyle: GoogleFonts.playfairDisplay(
                  fontSize: 14,
                  fontStyle: FontStyle.italic,
                  color: colors.ink400,
                ),
                counterStyle: TextStyle(
                  fontSize: 9,
                  color: colors.ink400,
                ),
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(vertical: 6),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: colors.hairline, width: 0.5),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: colors.accent, width: 1.0),
                ),
              ),
              onChanged: onQuoteChanged,
            ),
          ),
        ],
      ),
    );
  }
}

class _MagazineShareButton extends StatelessWidget {
  const _MagazineShareButton({
    required this.label,
    required this.loading,
    required this.onPressed,
  });

  final String label;
  final bool loading;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final enabled = onPressed != null;
    return PressableScale(
      onTap: enabled ? onPressed : () {},
      child: Container(
        width: double.infinity,
        height: 56,
        alignment: Alignment.center,
        color: enabled ? colors.accent : colors.accent.withValues(alpha: 0.4),
        child: loading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.ios_share_rounded,
                    color: Colors.white,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    label.toUpperCase(),
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.18,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
