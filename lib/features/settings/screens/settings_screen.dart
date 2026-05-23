import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart' show GlassSwitch;
import 'package:versatile/l10n/app_localizations.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:file_picker/file_picker.dart';
import 'package:versatile/core/providers/accent_provider.dart';
import 'package:versatile/core/providers/repository_providers.dart';
import 'package:versatile/core/providers/theme_provider.dart';
import 'package:versatile/core/providers/locale_provider.dart';
import 'package:versatile/core/providers/editorial_photos_provider.dart';
import 'package:versatile/core/services/data_service.dart';
import 'package:versatile/core/services/sound_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/database/database_helper.dart';
import '../../../shared/widgets/coachmark_overlay.dart';
import '../../../shared/widgets/motion.dart';
import '../../../shared/widgets/photo_reposition_dialog.dart';
import '../../../shared/widgets/screen_header.dart';
import '../../exercises/view_models/exercises_view_model.dart';
import '../../home/view_models/home_view_model.dart';
import '../../programs/screens/programs_screen.dart';
import '../../programs/view_models/programs_view_model.dart';
import '../../recap/screens/past_recaps_screen.dart';
import '../../routines/view_models/routines_view_model.dart';
import '../view_models/profile_stats_view_model.dart';
import '../widgets/accent_swatch_rail.dart';
import '../widgets/active_plan_card.dart';
import '../widgets/data_action.dart';
import '../widgets/profile_hero.dart';
import '../widgets/sound_chip_grid.dart';
import '../widgets/theme_mode_picker.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  bool _busy = false;
  bool _restAlertEnabled = true;
  String _soundType = 'default';
  String? _customPath;
  late final SoundService _soundService;
  final _colorSectionKey = GlobalKey();
  final _soundSectionKey = GlobalKey();
  final _dataSectionKey = GlobalKey();
  bool _coachmarkChecked = false;

  @override
  void initState() {
    super.initState();
    _soundService = SoundService(ref.read(settingsRepositoryProvider));
    _loadSoundSettings();
    // Wait for Navigator.push slide (~300ms) + FadeSlideIn entrance (~420ms)
    // to settle. localToGlobal otherwise reads the in-progress AnimatedSlide
    // offset and the spotlight renders shifted.
    Future.delayed(const Duration(milliseconds: 620), () {
      if (mounted) _checkCoachmark();
    });
  }

  Future<void> _showSectionCoachmark({
    required GlobalKey key,
    required String title,
    required String body,
    required VoidCallback onDone,
    VoidCallback? onSkipAll,
  }) async {
    if (!mounted) return;
    final ctx = key.currentContext;
    if (ctx == null) return;

    await Scrollable.ensureVisible(
      ctx,
      alignment: 0.15,
      duration: const Duration(milliseconds: 320),
      curve: Curves.easeOutCubic,
    );
    if (!mounted) return;
    await WidgetsBinding.instance.endOfFrame;
    if (!mounted) return;

    final l10n = AppLocalizations.of(context)!;
    CoachmarkOverlay.show(
      context: context,
      targetKey: key,
      title: title,
      body: body,
      gotItLabel: l10n.coachmarkGotIt,
      skipLabel: l10n.coachmarkSkipAll,
      onDone: onDone,
      onSkipAll: onSkipAll,
    );
  }

  Future<void> _checkCoachmark() async {
    if (!mounted || _coachmarkChecked) return;
    _coachmarkChecked = true;
    final service = ref.read(coachmarkServiceProvider);
    final shouldColors = await service.shouldShow('settings_colors');
    if (shouldColors && mounted) {
      final l10n = AppLocalizations.of(context)!;
      _showSectionCoachmark(
        key: _colorSectionKey,
        title: l10n.coachmarkSettingsColorsTitle,
        body: l10n.coachmarkSettingsColorsBody,
        onDone: () async {
          await service.markSeen('settings_colors');
          if (mounted) _checkSoundCoachmark();
        },
        onSkipAll: () async {
          await service.markSeen('settings_colors');
          await service.markSeen('settings_sound');
          await service.markSeen('settings_data');
        },
      );
      return;
    }
    _checkSoundCoachmark();
  }

  Future<void> _checkSoundCoachmark() async {
    if (!mounted) return;
    final service = ref.read(coachmarkServiceProvider);
    final should = await service.shouldShow('settings_sound');
    if (should && mounted) {
      final l10n = AppLocalizations.of(context)!;
      _showSectionCoachmark(
        key: _soundSectionKey,
        title: l10n.coachmarkSettingsSoundTitle,
        body: l10n.coachmarkSettingsSoundBody,
        onDone: () async {
          await service.markSeen('settings_sound');
          if (mounted) _checkDataCoachmark();
        },
        onSkipAll: () async {
          await service.markSeen('settings_sound');
          await service.markSeen('settings_data');
        },
      );
      return;
    }
    _checkDataCoachmark();
  }

  Future<void> _checkDataCoachmark() async {
    if (!mounted) return;
    final service = ref.read(coachmarkServiceProvider);
    final should = await service.shouldShow('settings_data');
    if (!should || !mounted) return;
    final l10n = AppLocalizations.of(context)!;
    _showSectionCoachmark(
      key: _dataSectionKey,
      title: l10n.coachmarkSettingsDataTitle,
      body: l10n.coachmarkSettingsDataBody,
      onDone: () => service.markSeen('settings_data'),
    );
  }

  Future<void> _loadSoundSettings() async {
    _restAlertEnabled = await _soundService.isAlertEnabled;
    _soundType = await _soundService.soundType;
    _customPath = await _soundService.customPath;
    if (mounted) setState(() {});
  }

  Future<void> _changeName() async {
    final currentName = await ref.read(settingsRepositoryProvider).getUserName();
    if (!mounted) return;

    final controller = TextEditingController(
      text: currentName == 'there' ? '' : currentName,
    );
    final l10n = AppLocalizations.of(context)!;

    final newName = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: context.colors.bgFrame,
        scrollable: true,
        title: Text(
          l10n.changeName,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: context.colors.ink900,
            letterSpacing: -0.18,
          ),
        ),
        content: TextField(
          controller: controller,
          autofocus: true,
          style: TextStyle(color: context.colors.ink900),
          decoration: InputDecoration(
            hintText: l10n.userName,
            hintStyle: TextStyle(color: context.colors.ink400),
            enabledBorder: UnderlineInputBorder(
              borderSide: Border.all(color: context.colors.hairline).bottom,
            ),
            focusedBorder: UnderlineInputBorder(
              borderSide: Border.all(color: context.colors.accent).bottom,
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(
              l10n.cancel,
              style: TextStyle(color: context.colors.ink400),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(controller.text.trim()),
            child: Text(
              l10n.done,
              style: TextStyle(
                color: context.colors.accent,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );

    if (newName != null && mounted) {
      await ref.read(settingsRepositoryProvider).setUserName(newName);
      ref.invalidate(userNameProvider);
    }
  }

  Future<void> _exportData() async {
    setState(() => _busy = true);
    try {
      final json = await DataService.exportJson();
      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/versatile_backup.json');
      await file.writeAsString(json);
      await Share.shareXFiles([XFile(file.path)], text: 'Versatile Backup');
    } catch (e) {
      if (mounted) _showError('Export failed: $e');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _importData() async {
    final result = await FilePicker.platform.pickFiles();
    if (result == null) return;

    setState(() => _busy = true);
    try {
      final file = File(result.files.single.path!);
      final json = await file.readAsString();
      await DataService.importJson(json);
      _invalidateAll();
    } catch (e) {
      if (mounted) _showError('Import failed: $e');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _wipeData() async {
    final l10n = AppLocalizations.of(context)!;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: context.colors.bgFrame,
        scrollable: true,
        title: Text(
          l10n.wipeConfirmTitle,
          style: TextStyle(color: context.colors.ink900),
        ),
        content: Text(
          l10n.wipeConfirmContent,
          style: TextStyle(color: context.colors.ink500, height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(
              l10n.cancel,
              style: TextStyle(color: context.colors.ink400),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(
              l10n.wipe,
              style: const TextStyle(
                color: Colors.red,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );

    if (ok == true && mounted) {
      setState(() => _busy = true);
      try {
        await DatabaseHelper.instance.wipeUserData();
        _invalidateAll();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(l10n.dataWiped)),
          );
        }
      } catch (e) {
        if (mounted) _showError(l10n.wipeFailed(e.toString()));
      } finally {
        if (mounted) setState(() => _busy = false);
      }
    }
  }

  void _invalidateAll() {
    ref.invalidate(routinesProvider);
    ref.invalidate(exercisesAsyncProvider);
    ref.invalidate(sessionsAsyncProvider);
    ref.invalidate(homeProvider);
    ref.invalidate(profileStatsProvider);
    ref.invalidate(activeProgramProvider);
    ref.invalidate(programsListProvider);
    ref.invalidate(editorialPhotosProvider);
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: Colors.red.shade900),
    );
  }

  Future<void> _pickSoundFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.audio,
      withData: true,
    );
    if (result == null || result.files.isEmpty) return;

    final picked = result.files.single;
    final dir = await getApplicationDocumentsDirectory();
    final soundsDir = Directory('${dir.path}/sounds');
    if (!await soundsDir.exists()) {
      await soundsDir.create(recursive: true);
    }

    final ext = picked.extension ?? 'mp3';
    final destPath = '${soundsDir.path}/custom_alert.$ext';
    final destFile = File(destPath);

    if (picked.bytes != null) {
      await destFile.writeAsBytes(picked.bytes!);
    } else if (picked.path != null) {
      final sourceFile = File(picked.path!);
      await sourceFile.copy(destPath);
    } else {
      return;
    }

    setState(() => _customPath = destPath);
    await _soundService.setCustomPath(destPath);
  }

  void _onSoundTypeChanged(String value) {
    setState(() => _soundType = value);
    _soundService.setSoundType(value);
    if (value == 'custom' && _customPath == null) {
      _pickSoundFile();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isEs = Localizations.localeOf(context).languageCode == 'es';
    final userName = ref.watch(userNameProvider).value ?? 'there';
    final themeMode = ref.watch(themeModeProvider);
    final locale = ref.watch(localeProvider);
    final accent = ref.watch(accentProvider);
    final stats = ref.watch(profileStatsProvider).value;
    final editorialState = ref.watch(editorialPhotosProvider);
    final displayName = (userName == 'there' || userName.isEmpty)
        ? l10n.userName
        : userName;

    return Scaffold(
      backgroundColor: context.colors.bgApp,
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ScreenHeader(
                    prefix: isEs ? 'Hecho' : 'Made',
                    accent: isEs ? 'a tu medida.' : 'yours.',
                    eyebrow: l10n.settings,
                    onBack: () => Navigator.of(context).pop(),
                    accentBack: true,
                  ),

                  // ── Profile ─────────────────────────────────────
                  const SizedBox(height: 18),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 22),
                    child: FadeSlideIn(
                      delay: const Duration(milliseconds: 60),
                      child: ProfileHero(
                        name: displayName,
                        sessionCount: stats?.sessionCount,
                        totalHours: stats?.totalHours,
                        prCount: stats?.prCount,
                        onEdit: _changeName,
                        profileLabel: l10n.profile,
                        sessionsLabel: l10n.profileSessionsLabel,
                        timeLabel: l10n.profileTimeLabel,
                        prsLabel: l10n.profilePrsLabel,
                      ),
                    ),
                  ),

                  // ── Active Plan ─────────────────────────────────
                  const _SectionSpacer(),
                  _SectionEyebrow(label: l10n.planActiveSection),
                  const SizedBox(height: 12),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 22),
                    child: FadeSlideIn(
                      delay: const Duration(milliseconds: 80),
                      child: _ActivePlanSection(),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 22),
                    child: FadeSlideIn(
                      delay: const Duration(milliseconds: 95),
                      child: _RecapsRow(
                        title: l10n.recapPastRecaps,
                        subtitle: l10n.recapPastRecapsSubtitle,
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const PastRecapsScreen(),
                          ),
                        ),
                      ),
                    ),
                  ),

                  // ── Appearance ──────────────────────────────────
                  const _SectionSpacer(),
                  _SectionEyebrow(label: l10n.appearance),
                  const SizedBox(height: 12),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 22),
                    child: FadeSlideIn(
                      delay: const Duration(milliseconds: 110),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _MagSubLabel(label: l10n.theme),
                          const SizedBox(height: 10),
                          ThemeModePicker(
                            value: themeMode,
                            onChanged: (m) => ref
                                .read(themeModeProvider.notifier)
                                .setThemeMode(m),
                            labelLight: l10n.themeLight,
                            labelDark: l10n.themeDark,
                            labelSystem: l10n.themeSystem,
                          ),
                          const SizedBox(height: 18),
                          Row(
                            children: [
                              Expanded(
                                child: _MagSubLabel(label: l10n.accentColor),
                              ),
                              Text(
                                accent.displayName(l10n),
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.18,
                                  color: context.colors.accentDeep,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          KeyedSubtree(
                            key: _colorSectionKey,
                            child: AccentSwatchRail(
                              selected: accent,
                              onChanged: (opt) => ref
                                  .read(accentProvider.notifier)
                                  .setAccent(opt),
                            ),
                          ),
                          const SizedBox(height: 16),
                          _LanguageRow(
                            label: l10n.language,
                            locale: locale,
                            labelEn: l10n.languageEn,
                            labelEs: l10n.languageEs,
                            onChanged: (v) => ref
                                .read(localeProvider.notifier)
                                .setLocale(v),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // ── Editorial Photos ────────────────────────────
                  const _SectionSpacer(),
                  _SectionEyebrow(label: l10n.editorialSection),
                  const SizedBox(height: 12),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 22),
                    child: FadeSlideIn(
                      delay: const Duration(milliseconds: 120),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _EditorialToggleRow(
                            title: l10n.editorialEnable,
                            value: editorialState.enabled,
                            onChanged: (v) {
                              ref.read(editorialPhotosProvider.notifier).setEnabled(v);
                            },
                          ),
                          if (editorialState.enabled) ...[
                            const SizedBox(height: 16),
                            _EditorialPhotoPickerTile(
                              label: l10n.editorialMoodboardLabel,
                              imagePath: editorialState.moodboardPath,
                              quote: editorialState.moodboardQuote,
                              defaultQuote: l10n.editorialDefaultMoodboardQuote,
                              maxQuoteLength: 50,
                              alignX: editorialState.moodboardAlignX,
                              alignY: editorialState.moodboardAlignY,
                              scale: editorialState.moodboardScale,
                              aspectRatio: (MediaQuery.of(context).size.width * 0.6) / 180.0,
                              onPick: () async {
                                final result = await FilePicker.platform.pickFiles(type: FileType.image);
                                if (result != null && result.files.isNotEmpty) {
                                  await ref.read(editorialPhotosProvider.notifier).saveMoodboardPhoto(result.files.single);
                                }
                              },
                              onRemove: () {
                                ref.read(editorialPhotosProvider.notifier).removeMoodboardPhoto();
                              },
                              onQuoteChanged: (val) {
                                ref.read(editorialPhotosProvider.notifier).setMoodboardQuote(val);
                              },
                              onTransformChanged: (x, y, scale) {
                                ref.read(editorialPhotosProvider.notifier).setMoodboardTransform(x, y, scale);
                              },
                              l10n: l10n,
                            ),
                            const SizedBox(height: 16),
                            _EditorialPhotoPickerTile(
                              label: l10n.editorialBackCoverLabel,
                              imagePath: editorialState.backCoverPath,
                              quote: editorialState.backCoverQuote,
                              defaultQuote: l10n.editorialDefaultBackCoverQuote,
                              maxQuoteLength: 80,
                              alignX: editorialState.backCoverAlignX,
                              alignY: editorialState.backCoverAlignY,
                              scale: editorialState.backCoverScale,
                              aspectRatio: MediaQuery.of(context).size.width / 260.0,
                              onPick: () async {
                                final result = await FilePicker.platform.pickFiles(type: FileType.image);
                                if (result != null && result.files.isNotEmpty) {
                                  await ref.read(editorialPhotosProvider.notifier).saveBackCoverPhoto(result.files.single);
                                }
                              },
                              onRemove: () {
                                ref.read(editorialPhotosProvider.notifier).removeBackCoverPhoto();
                              },
                              onQuoteChanged: (val) {
                                ref.read(editorialPhotosProvider.notifier).setBackCoverQuote(val);
                              },
                              onTransformChanged: (x, y, scale) {
                                ref.read(editorialPhotosProvider.notifier).setBackCoverTransform(x, y, scale);
                              },
                              l10n: l10n,
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),

                  // ── Sound ───────────────────────────────────────
                  const _SectionSpacer(),
                  _SectionEyebrow(label: l10n.sound),
                  const SizedBox(height: 12),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 22),
                    child: FadeSlideIn(
                      delay: const Duration(milliseconds: 130),
                      child: KeyedSubtree(
                        key: _soundSectionKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            _AlertRow(
                              title: l10n.restTimerAlert,
                              subtitle: l10n.notificationSubtitle,
                              value: _restAlertEnabled,
                              onChanged: (v) {
                                setState(() => _restAlertEnabled = v);
                                _soundService.setAlertEnabled(v);
                              },
                            ),
                            const SizedBox(height: 10),
                            SoundChipGrid(
                              selected: _soundType,
                              onChanged: _onSoundTypeChanged,
                              defaultLabel: l10n.defaultSound,
                              customLabel: l10n.customSound,
                              customFileName: _soundType == 'custom'
                                  ? (_customPath?.split(
                                          RegExp(r'[\\/]'),
                                        ).last ??
                                        l10n.pickSoundFile)
                                  : null,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // ── Data ────────────────────────────────────────
                  const _SectionSpacer(),
                  _SectionEyebrow(label: l10n.data),
                  const SizedBox(height: 12),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 22),
                    child: FadeSlideIn(
                      delay: const Duration(milliseconds: 150),
                      child: KeyedSubtree(
                        key: _dataSectionKey,
                        child: Column(
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: context.colors.hairline,
                                  width: 0.5,
                                ),
                              ),
                              child: IntrinsicHeight(
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: DataAction(
                                        icon: Icons.upload_outlined,
                                        label: l10n.exportData,
                                        sublabel: l10n.exportSubtitle,
                                        onTap: _busy ? null : _exportData,
                                      ),
                                    ),
                                    Container(
                                      width: 0.5,
                                      color: context.colors.hairline,
                                    ),
                                    Expanded(
                                      child: DataAction(
                                        icon: Icons.download_outlined,
                                        label: l10n.importData,
                                        sublabel: l10n.importSubtitle,
                                        onTap: _busy ? null : _importData,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 10),
                            DestructiveDataAction(
                              icon: Icons.delete_outline,
                              label: l10n.wipeAllData,
                              sublabel: l10n.wipeSubtitle,
                              onTap: _busy ? null : _wipeData,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // ── About footer ────────────────────────────────
                  const SizedBox(height: 36),
                  _AboutFooter(
                    appName: l10n.appName,
                    by: l10n.aboutBy,
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            ),
            if (_busy)
              Positioned.fill(
                child: ColoredBox(
                  color: const Color(0x33000000),
                  child: Center(
                    child: CircularProgressIndicator(
                      color: context.colors.accent,
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

// ═══════════════════════════════════════════════════════════════
// Section helpers
// ═══════════════════════════════════════════════════════════════

class _SectionSpacer extends StatelessWidget {
  const _SectionSpacer();
  @override
  Widget build(BuildContext context) => const SizedBox(height: 30);
}

class _SectionEyebrow extends StatelessWidget {
  const _SectionEyebrow({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 22),
      child: Row(
        children: [
          Container(
            width: 22,
            height: 1,
            color: colors.ink400.withValues(alpha: 0.55),
          ),
          const SizedBox(width: 10),
          Text(
            label.toUpperCase(),
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.18,
              color: colors.ink500,
            ),
          ),
        ],
      ),
    );
  }
}

class _MagSubLabel extends StatelessWidget {
  const _MagSubLabel({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label.toUpperCase(),
      style: TextStyle(
        fontSize: 10,
        fontWeight: FontWeight.w800,
        letterSpacing: 0.18,
        color: context.colors.ink500,
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// Rows
// ═══════════════════════════════════════════════════════════════

class _RecapsRow extends StatelessWidget {
  const _RecapsRow({
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return PressableScale(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
        decoration: BoxDecoration(
          border: Border.all(color: colors.hairline, width: 0.5),
        ),
        child: Row(
          children: [
            Container(
              width: 34,
              height: 34,
              alignment: Alignment.center,
              decoration: BoxDecoration(color: colors.accent),
              child: const Icon(
                Icons.auto_awesome_outlined,
                size: 16,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: colors.ink900,
                      letterSpacing: -0.18,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(fontSize: 11, color: colors.ink500),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              size: 16,
              color: colors.ink900.withValues(alpha: 0.3),
            ),
          ],
        ),
      ),
    );
  }
}

class _LanguageRow extends StatelessWidget {
  const _LanguageRow({
    required this.label,
    required this.locale,
    required this.labelEn,
    required this.labelEs,
    required this.onChanged,
  });

  final String label;
  final Locale locale;
  final String labelEn;
  final String labelEs;
  final ValueChanged<Locale> onChanged;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 8, 8, 8),
      decoration: BoxDecoration(
        border: Border.all(color: colors.hairline, width: 0.5),
      ),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: colors.ink900.withValues(alpha: 0.04),
              border: Border.all(color: colors.hairline, width: 0.6),
            ),
            child: Icon(
              Icons.language_outlined,
              size: 16,
              color: colors.ink700,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: colors.ink900,
              ),
            ),
          ),
          DropdownButtonHideUnderline(
            child: DropdownButton<Locale>(
              value: locale,
              icon: Icon(
                Icons.expand_more,
                size: 16,
                color: colors.ink500,
              ),
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: colors.ink700,
              ),
              dropdownColor: colors.bgFrame,
              borderRadius: BorderRadius.zero,
              onChanged: (Locale? v) {
                if (v != null) onChanged(v);
              },
              items: [
                DropdownMenuItem(
                  value: const Locale('en'),
                  child: Text(labelEn),
                ),
                DropdownMenuItem(
                  value: const Locale('es'),
                  child: Text(labelEs),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AlertRow extends StatelessWidget {
  const _AlertRow({
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
      decoration: BoxDecoration(
        border: Border.all(color: colors.hairline, width: 0.5),
      ),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            alignment: Alignment.center,
            decoration: BoxDecoration(color: colors.accent),
            child: const Icon(
              Icons.notifications_active_outlined,
              size: 16,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: colors.ink900,
                    letterSpacing: -0.18,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(fontSize: 11, color: colors.ink500),
                ),
              ],
            ),
          ),
          GlassSwitch(
            value: value,
            activeColor: colors.accent,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}

class _AboutFooter extends StatelessWidget {
  const _AboutFooter({required this.appName, required this.by});
  final String appName;
  final String by;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 32,
            height: 1,
            color: colors.ink400.withValues(alpha: 0.4),
          ),
          const SizedBox(height: 12),
          Text(
            appName.toUpperCase(),
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.4,
              color: colors.ink500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'v1.0.0',
            style: TextStyle(
              fontSize: 10,
              color: colors.ink400,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
          const SizedBox(height: 8),
          Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: '$by ',
                  style: TextStyle(fontSize: 11, color: colors.ink400),
                ),
                TextSpan(
                  text: 'Carlos',
                  style: TextStyle(
                    fontSize: 11,
                    fontStyle: FontStyle.italic,
                    color: colors.accentDeep,
                    fontWeight: FontWeight.w600,
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

class _ActivePlanSection extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final active = ref.watch(activeProgramProvider).value;
    final routines = ref.watch(routinesProvider).value ?? [];

    void openPrograms() {
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const ProgramsScreen()),
      );
    }

    if (active == null) {
      return ActivePlanCardEmpty(
        title: l10n.noActivePlanTitle,
        subtitle: l10n.noActivePlanSubtitle,
        onTap: openPrograms,
      );
    }

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final start = DateTime(
      active.startDate.year,
      active.startDate.month,
      active.startDate.day,
    );
    final daysSinceStart = today.isBefore(start)
        ? 0
        : today.difference(start).inDays;
    final weeksElapsed = daysSinceStart ~/ 7;
    final weekIndex = weeksElapsed % active.program.weeksCount;

    return ActivePlanCard(
      program: active.program,
      currentWeekIndex: weekIndex,
      todayWeekday: today.weekday,
      routines: routines,
      onTap: openPrograms,
      activeBadgeLabel: l10n.activeBadge,
      weekProgressLabel: l10n.programWeekProgress(
        weekIndex + 1,
        active.program.weeksCount,
      ),
    );
  }
}

class _EditorialToggleRow extends StatelessWidget {
  const _EditorialToggleRow({
    required this.title,
    required this.value,
    required this.onChanged,
  });

  final String title;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
      decoration: BoxDecoration(
        border: Border.all(color: colors.hairline, width: 0.5),
      ),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            alignment: Alignment.center,
            decoration: BoxDecoration(color: colors.accent),
            child: const Icon(
              Icons.camera_alt_outlined,
              size: 16,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: colors.ink900,
                letterSpacing: -0.18,
              ),
            ),
          ),
          GlassSwitch(
            value: value,
            activeColor: colors.accent,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}

class _EditorialPhotoPickerTile extends StatefulWidget {
  const _EditorialPhotoPickerTile({
    required this.label,
    required this.imagePath,
    required this.quote,
    required this.defaultQuote,
    required this.maxQuoteLength,
    required this.alignX,
    required this.alignY,
    required this.scale,
    required this.aspectRatio,
    required this.onPick,
    required this.onRemove,
    required this.onQuoteChanged,
    required this.onTransformChanged,
    required this.l10n,
  });

  final String label;
  final String? imagePath;
  final String quote;
  final String defaultQuote;
  final int maxQuoteLength;
  final double alignX;
  final double alignY;
  final double scale;
  final double aspectRatio;
  final VoidCallback onPick;
  final VoidCallback onRemove;
  final ValueChanged<String> onQuoteChanged;
  final void Function(double x, double y, double scale) onTransformChanged;
  final AppLocalizations l10n;

  @override
  State<_EditorialPhotoPickerTile> createState() => _EditorialPhotoPickerTileState();
}

class _EditorialPhotoPickerTileState extends State<_EditorialPhotoPickerTile> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.quote);
  }

  @override
  void didUpdateWidget(covariant _EditorialPhotoPickerTile oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.quote != widget.quote && _controller.text != widget.quote) {
      _controller.text = widget.quote;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _openReposition() async {
    if (widget.imagePath == null) return;

    final result = await showDialog<Map<String, double>>(
      context: context,
      builder: (ctx) => PhotoRepositionDialog(
        imagePath: widget.imagePath!,
        initialAlignX: widget.alignX,
        initialAlignY: widget.alignY,
        initialScale: widget.scale,
        aspectRatio: widget.aspectRatio,
      ),
    );

    if (result != null) {
      widget.onTransformChanged(
        result['x']!,
        result['y']!,
        result['scale']!,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final fileExists = widget.imagePath != null && File(widget.imagePath!).existsSync();

    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: colors.hairline, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: colors.ink900.withValues(alpha: 0.04),
              border: Border(bottom: BorderSide(color: colors.hairline, width: 0.5)),
            ),
            child: Text(
              widget.label.toUpperCase(),
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.18,
                color: colors.ink700,
              ),
            ),
          ),
          if (fileExists)
            Stack(
              children: [
                AspectRatio(
                  aspectRatio: 16 / 9,
                  child: ClipRect(
                    child: Transform.scale(
                      scale: widget.scale,
                      alignment: Alignment(widget.alignX, widget.alignY),
                      child: Image.file(
                        File(widget.imagePath!),
                        fit: BoxFit.cover,
                        alignment: Alignment(widget.alignX, widget.alignY),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: PressableScale(
                    onTap: _openReposition,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: colors.accent,
                      ),
                      child: const Icon(
                        Icons.edit_outlined,
                        size: 16,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: Container(
                    color: Colors.black.withValues(alpha: 0.6),
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        PressableScale(
                          onTap: widget.onPick,
                          child: Text(
                            widget.l10n.editorialChangeImage.toUpperCase(),
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                        PressableScale(
                          onTap: widget.onRemove,
                          child: Text(
                            widget.l10n.editorialRemoveImage.toUpperCase(),
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              color: Colors.redAccent,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            )
          else
            PressableScale(
              onTap: widget.onPick,
              child: Container(
                height: 100,
                alignment: Alignment.center,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.add_photo_alternate_outlined,
                      size: 24,
                      color: colors.ink400,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      widget.l10n.editorialNoImage,
                      style: TextStyle(
                        fontSize: 12,
                        color: colors.ink500,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          if (fileExists) ...[
            Container(height: 0.5, color: colors.hairline),
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 8, 14, 10),
              child: TextField(
                controller: _controller,
                maxLength: widget.maxQuoteLength,
                style: TextStyle(
                  fontSize: 13,
                  color: colors.ink900,
                ),
                decoration: InputDecoration(
                  hintText: widget.defaultQuote,
                  hintStyle: TextStyle(
                    color: colors.ink400,
                    fontStyle: FontStyle.italic,
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
                onChanged: widget.onQuoteChanged,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
