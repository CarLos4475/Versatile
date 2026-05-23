import 'dart:io';
import 'dart:math' as math;
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
import '../widgets/magazine_collage_share_card.dart';
import '../widgets/magazine_cover_share_card.dart';
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

/// Static descriptor for a share variant. Defines the page label, logical
/// canvas size (so the preview can size each PageView page to its natural
/// aspect), and whether the variant requires a user photo before it can be
/// shared. The card itself is built per-page inside the PageView.
class _ShareVariantSpec {
  const _ShareVariantSpec({
    required this.id,
    required this.labelEn,
    required this.labelEs,
    this.requiresPhoto = false,
    this.requiresPhoto2 = false,
  });

  final String id;
  final String labelEn;
  final String labelEs;
  final bool requiresPhoto;
  final bool requiresPhoto2;
}

const List<_ShareVariantSpec> _kVariants = [
  _ShareVariantSpec(
    id: 'issue',
    labelEn: 'ISSUE',
    labelEs: 'NÚMERO',
  ),
  _ShareVariantSpec(
    id: 'cover',
    labelEn: 'COVER',
    labelEs: 'PORTADA',
    requiresPhoto: true,
  ),
  _ShareVariantSpec(
    id: 'collage',
    labelEn: 'COLLAGE',
    labelEs: 'COLLAGE',
    requiresPhoto: true,
    requiresPhoto2: true,
  ),
];

class _ShareSessionScreenState extends ConsumerState<ShareSessionScreen> {
  late final List<GlobalKey> _boundaryKeys = List.generate(
    _kVariants.length,
    (_) => GlobalKey(),
  );
  final _quoteCtrl = TextEditingController();
  final _pageController = PageController();
  int _variantIndex = 0;
  bool _sharing = false;
  String? _userPhotoPath; // volatile temp file
  String? _userPhoto2Path; // volatile temp file (collage secondary)
  String _userQuote = '';
  double _photoAlignX = 0.0;
  double _photoAlignY = 0.0;
  double _photoScale = 1.0;
  double _photo2AlignX = 0.0;
  double _photo2AlignY = 0.0;
  double _photo2Scale = 1.0;

  static const int _quoteMaxLen = 70;
  // Photo strip inside the Issue card is 16:9 — same ratio used by the
  // reposition dialog so the crop window matches the final render exactly.
  static const double _photoAspect = 16 / 9;
  // Secondary photo in the Collage variant is roughly 4:5 (portrait).
  static const double _photo2Aspect = 4 / 5;

  @override
  void dispose() {
    _quoteCtrl.dispose();
    _pageController.dispose();
    _cleanupPhoto(_userPhotoPath);
    _cleanupPhoto(_userPhoto2Path);
    super.dispose();
  }

  bool get _activeVariantBlocked {
    final spec = _kVariants[_variantIndex];
    if (spec.requiresPhoto &&
        !MagazineCoverShareCard.hasUsablePhoto(_userPhotoPath)) {
      return true;
    }
    if (spec.requiresPhoto2 &&
        !MagazineCoverShareCard.hasUsablePhoto(_userPhoto2Path)) {
      return true;
    }
    return false;
  }

  Future<void> _cleanupPhoto(String? path) async {
    if (path == null) return;
    try {
      final f = File(path);
      if (await f.exists()) await f.delete();
    } catch (_) {}
  }

  Future<String?> _copyPickedToTemp() async {
    final result =
        await FilePicker.platform.pickFiles(type: FileType.image);
    if (result == null || result.files.isEmpty) return null;
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
        return null;
      }
    } catch (_) {
      return null;
    }
    return destPath;
  }

  Future<void> _pickPhoto() async {
    final destPath = await _copyPickedToTemp();
    if (destPath == null || !mounted) return;
    final previous = _userPhotoPath;
    setState(() {
      _userPhotoPath = destPath;
      _photoAlignX = 0.0;
      _photoAlignY = 0.0;
      _photoScale = 1.0;
    });
    await _cleanupPhoto(previous);
  }

  Future<void> _pickPhoto2() async {
    final destPath = await _copyPickedToTemp();
    if (destPath == null || !mounted) return;
    final previous = _userPhoto2Path;
    setState(() {
      _userPhoto2Path = destPath;
      _photo2AlignX = 0.0;
      _photo2AlignY = 0.0;
      _photo2Scale = 1.0;
    });
    await _cleanupPhoto(previous);
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
    await _cleanupPhoto(path);
  }

  Future<void> _removePhoto2() async {
    final path = _userPhoto2Path;
    if (path == null) return;
    setState(() {
      _userPhoto2Path = null;
      _photo2AlignX = 0.0;
      _photo2AlignY = 0.0;
      _photo2Scale = 1.0;
    });
    await _cleanupPhoto(path);
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

  Future<void> _editPhoto2() async {
    final path = _userPhoto2Path;
    if (path == null) return;
    final result = await showDialog<Map<String, double>>(
      context: context,
      builder: (_) => PhotoRepositionDialog(
        imagePath: path,
        initialAlignX: _photo2AlignX,
        initialAlignY: _photo2AlignY,
        initialScale: _photo2Scale,
        aspectRatio: _photo2Aspect,
      ),
    );
    if (result != null && mounted) {
      setState(() {
        _photo2AlignX = result['x']!;
        _photo2AlignY = result['y']!;
        _photo2Scale = result['scale']!;
      });
    }
  }

  Future<void> _share() async {
    if (_sharing || _activeVariantBlocked) return;
    setState(() => _sharing = true);
    try {
      final boundary = _boundaryKeys[_variantIndex].currentContext!
          .findRenderObject() as RenderRepaintBoundary;
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

  /// Logical height of a variant's card given the current extras (photo +
  /// quote). Used to size the PageView's frame so each variant displays at
  /// its natural aspect.
  double _variantLogicalHeight(int idx) {
    switch (_kVariants[idx].id) {
      case 'cover':
        return MagazineCoverShareCard.logicalHeight;
      case 'collage':
        return MagazineCollageShareCard.logicalHeight;
      case 'issue':
      default:
        return ShareableSessionCard.logicalHeightFor(
          hasPhoto: _userPhotoPath != null,
          hasQuote: _userQuote.trim().isNotEmpty,
        );
    }
  }

  Widget _buildVariantCard(int idx) {
    final pr = widget.precomputedPR ??
        ref.watch(sessionPRProvider(widget.session.id));
    final accent = Theme.of(context).extension<AppColors>()!.accent;
    switch (_kVariants[idx].id) {
      case 'cover':
        return MagazineCoverShareCard(
          session: widget.session,
          accentColor: accent,
          pr: pr,
          userPhotoPath: _userPhotoPath,
          photoAlignX: _photoAlignX,
          photoAlignY: _photoAlignY,
          photoScale: _photoScale,
        );
      case 'collage':
        return MagazineCollageShareCard(
          session: widget.session,
          accentColor: accent,
          pr: pr,
          heroPhotoPath: _userPhotoPath,
          heroAlignX: _photoAlignX,
          heroAlignY: _photoAlignY,
          heroScale: _photoScale,
          secondaryPhotoPath: _userPhoto2Path,
          secondaryAlignX: _photo2AlignX,
          secondaryAlignY: _photo2AlignY,
          secondaryScale: _photo2Scale,
        );
      case 'issue':
      default:
        return ShareableSessionCard(
          session: widget.session,
          accentColor: accent,
          pr: pr,
          userPhotoPath: _userPhotoPath,
          userQuote: _userQuote.trim().isEmpty ? null : _userQuote,
          photoAlignX: _photoAlignX,
          photoAlignY: _photoAlignY,
          photoScale: _photoScale,
        );
    }
  }

  double _variantLogicalWidth(int idx) {
    switch (_kVariants[idx].id) {
      case 'cover':
        return MagazineCoverShareCard.logicalWidth;
      case 'collage':
        return MagazineCollageShareCard.logicalWidth;
      case 'issue':
      default:
        return ShareableSessionCard.logicalWidth;
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
                          // Frame height = tallest variant at the current
                          // preview width, so the PageView doesn't reflow
                          // mid-swipe. Each page centers its own card.
                          double maxPreviewH = 0;
                          for (var i = 0; i < _kVariants.length; i++) {
                            final cardW = _variantLogicalWidth(i);
                            final cardH = _variantLogicalHeight(i);
                            final w = constraints.maxWidth.clamp(0.0, cardW);
                            maxPreviewH =
                                math.max(maxPreviewH, w * (cardH / cardW));
                          }
                          return SizedBox(
                            height: maxPreviewH,
                            child: PageView.builder(
                              controller: _pageController,
                              itemCount: _kVariants.length,
                              onPageChanged: (i) =>
                                  setState(() => _variantIndex = i),
                              itemBuilder: (context, i) {
                                final cardW = _variantLogicalWidth(i);
                                final cardH = _variantLogicalHeight(i);
                                final w =
                                    constraints.maxWidth.clamp(0.0, cardW);
                                final previewH = w * (cardH / cardW);
                                return Center(
                                  child: SizedBox(
                                    width: w,
                                    height: previewH,
                                    child: FittedBox(
                                      fit: BoxFit.cover,
                                      child: RepaintBoundary(
                                        key: _boundaryKeys[i],
                                        child: _buildVariantCard(i),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 14),
                    _VariantIndicator(
                      total: _kVariants.length,
                      current: _variantIndex,
                      label: Localizations.localeOf(context).languageCode == 'es'
                          ? _kVariants[_variantIndex].labelEs
                          : _kVariants[_variantIndex].labelEn,
                    ),
                    const SizedBox(height: 18),
                    FadeSlideIn(
                      delay: const Duration(milliseconds: 120),
                      child: _CustomizePanel(
                        photoPath: _userPhotoPath,
                        photo2Path: _userPhoto2Path,
                        showPhoto2Slot:
                            _kVariants[_variantIndex].requiresPhoto2,
                        showQuoteField:
                            _kVariants[_variantIndex].id == 'issue',
                        quote: _userQuote,
                        quoteCtrl: _quoteCtrl,
                        onPickPhoto: _pickPhoto,
                        onEditPhoto: _editPhoto,
                        onRemovePhoto: _removePhoto,
                        onPickPhoto2: _pickPhoto2,
                        onEditPhoto2: _editPhoto2,
                        onRemovePhoto2: _removePhoto2,
                        onQuoteChanged: (val) {
                          setState(() => _userQuote = val);
                        },
                        photoLabel: _kVariants[_variantIndex].requiresPhoto2
                            ? (isEs ? 'FOTO 1' : 'PHOTO 1')
                            : (isEs ? 'AÑADIR FOTO' : 'ADD PHOTO'),
                        photo2Label: isEs ? 'FOTO 2' : 'PHOTO 2',
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (_activeVariantBlocked) ...[
                      Text(
                        _kVariants[_variantIndex].requiresPhoto2
                            ? l10n.shareNeedsTwoPhotos
                            : l10n.shareNeedsPhoto,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.18,
                          color: colors.ink500,
                        ),
                      ),
                      const SizedBox(height: 10),
                    ],
                    _MagazineShareButton(
                      label: _sharing ? l10n.saving : l10n.share,
                      loading: _sharing,
                      onPressed: (_sharing || _activeVariantBlocked)
                          ? null
                          : _share,
                    ),
                  ],
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
    required this.photo2Path,
    required this.showPhoto2Slot,
    required this.showQuoteField,
    required this.quote,
    required this.quoteCtrl,
    required this.onPickPhoto,
    required this.onEditPhoto,
    required this.onRemovePhoto,
    required this.onPickPhoto2,
    required this.onEditPhoto2,
    required this.onRemovePhoto2,
    required this.onQuoteChanged,
    required this.photoLabel,
    required this.photo2Label,
    required this.photoChangeLabel,
    required this.photoCaption,
    required this.quoteHint,
    required this.quoteMaxLen,
  });

  final String? photoPath;
  final String? photo2Path;
  final bool showPhoto2Slot;
  final bool showQuoteField;
  final String quote;
  final TextEditingController quoteCtrl;
  final VoidCallback onPickPhoto;
  final VoidCallback onEditPhoto;
  final VoidCallback onRemovePhoto;
  final VoidCallback onPickPhoto2;
  final VoidCallback onEditPhoto2;
  final VoidCallback onRemovePhoto2;
  final ValueChanged<String> onQuoteChanged;
  final String photoLabel;
  final String photo2Label;
  final String photoChangeLabel;
  final String photoCaption;
  final String quoteHint;
  final int quoteMaxLen;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: colors.hairline, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _PhotoRow(
            photoPath: photoPath,
            label: photoLabel,
            caption: photoCaption,
            changeLabel: photoChangeLabel,
            onPick: onPickPhoto,
            onEdit: onEditPhoto,
            onRemove: onRemovePhoto,
          ),
          if (showPhoto2Slot) ...[
            Container(height: 0.5, color: colors.hairline),
            _PhotoRow(
              photoPath: photo2Path,
              label: photo2Label,
              caption: photoCaption,
              changeLabel: photoChangeLabel,
              onPick: onPickPhoto2,
              onEdit: onEditPhoto2,
              onRemove: onRemovePhoto2,
            ),
          ],
          if (showQuoteField) ...[
            Container(height: 0.5, color: colors.hairline),
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
                  color: colors.ink900,
                ),
                decoration: InputDecoration(
                  hintText: quoteHint,
                  hintStyle: GoogleFonts.playfairDisplay(
                    fontSize: 14,
                    color: colors.ink400,
                  ),
                  counterStyle: TextStyle(
                    fontSize: 9,
                    color: colors.ink400,
                  ),
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(vertical: 6),
                  enabledBorder: UnderlineInputBorder(
                    borderSide:
                        BorderSide(color: colors.hairline, width: 0.5),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide:
                        BorderSide(color: colors.accent, width: 1.0),
                  ),
                ),
                onChanged: onQuoteChanged,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _PhotoRow extends StatelessWidget {
  const _PhotoRow({
    required this.photoPath,
    required this.label,
    required this.caption,
    required this.changeLabel,
    required this.onPick,
    required this.onEdit,
    required this.onRemove,
  });

  final String? photoPath;
  final String label;
  final String caption;
  final String changeLabel;
  final VoidCallback onPick;
  final VoidCallback onEdit;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final hasPhoto = photoPath != null;

    return PressableScale(
      onTap: hasPhoto ? null : onPick,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
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
                    label,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.18,
                      color: colors.ink700,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    caption,
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
                onTap: onPick,
                child: Text(
                  changeLabel,
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
                onTap: onEdit,
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
                onTap: onRemove,
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

/// Magazine-style page indicator. Shows tiny ink squares (one per variant),
/// highlights the active one, and writes the variant's label + folio
/// ("01 / N") on either side.
class _VariantIndicator extends StatelessWidget {
  const _VariantIndicator({
    required this.total,
    required this.current,
    required this.label,
  });

  final int total;
  final int current;
  final String label;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.6,
            color: colors.ink700,
          ),
        ),
        const SizedBox(width: 14),
        for (var i = 0; i < total; i++) ...[
          if (i > 0) const SizedBox(width: 6),
          Container(
            width: i == current ? 14 : 6,
            height: 6,
            color: i == current
                ? colors.accent
                : colors.ink400.withValues(alpha: 0.45),
          ),
        ],
        const SizedBox(width: 14),
        Text(
          '${(current + 1).toString().padLeft(2, '0')} / ${total.toString().padLeft(2, '0')}',
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.4,
            color: colors.ink500,
            fontFeatures: const [FontFeature.tabularFigures()],
          ),
        ),
      ],
    );
  }
}
