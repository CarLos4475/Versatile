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
import 'package:versatile/core/services/data_service.dart';
import 'package:versatile/core/services/sound_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/database/database_helper.dart';
import '../../../shared/widgets/coachmark_overlay.dart';
import '../../../shared/widgets/glass_container.dart';
import '../../../shared/widgets/motion.dart';
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
    WidgetsBinding.instance.addPostFrameCallback((_) => _checkCoachmark());
  }

  Future<void> _checkCoachmark() async {
    if (!mounted || _coachmarkChecked) return;
    _coachmarkChecked = true;
    final service = ref.read(coachmarkServiceProvider);
    final shouldColors = await service.shouldShow('settings_colors');
    if (shouldColors && mounted) {
      final l10n = AppLocalizations.of(context)!;
      CoachmarkOverlay.show(
        context: context,
        targetKey: _colorSectionKey,
        title: l10n.coachmarkSettingsColorsTitle,
        body: l10n.coachmarkSettingsColorsBody,
        gotItLabel: l10n.coachmarkGotIt,
        skipLabel: l10n.coachmarkSkipAll,
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
      CoachmarkOverlay.show(
        context: context,
        targetKey: _soundSectionKey,
        title: l10n.coachmarkSettingsSoundTitle,
        body: l10n.coachmarkSettingsSoundBody,
        gotItLabel: l10n.coachmarkGotIt,
        skipLabel: l10n.coachmarkSkipAll,
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
    CoachmarkOverlay.show(
      context: context,
      targetKey: _dataSectionKey,
      title: l10n.coachmarkSettingsDataTitle,
      body: l10n.coachmarkSettingsDataBody,
      gotItLabel: l10n.coachmarkGotIt,
      skipLabel: l10n.coachmarkSkipAll,
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
    final userName = ref.watch(userNameProvider).value ?? 'there';
    final themeMode = ref.watch(themeModeProvider);
    final locale = ref.watch(localeProvider);
    final accent = ref.watch(accentProvider);
    final stats = ref.watch(profileStatsProvider).value;
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
                    prefix: Localizations.localeOf(context).languageCode == 'es'
                        ? 'Hecho'
                        : 'Made',
                    accent: Localizations.localeOf(context).languageCode == 'es'
                        ? 'a tu medida.'
                        : 'yours.',
                    eyebrow: l10n.settings,
                    onBack: () => Navigator.of(context).pop(),
                    accentBack: true,
                  ),

                  // Profile hero
                  const SizedBox(height: 20),
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
                        sessionsLabel: l10n.profileSessionsLabel.toUpperCase(),
                        timeLabel: l10n.profileTimeLabel.toUpperCase(),
                        prsLabel: l10n.profilePrsLabel.toUpperCase(),
                      ),
                    ),
                  ),

                  // Plan activo
                  _SectionLabel(l10n.planActiveSection),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 22),
                    child: FadeSlideIn(
                      delay: const Duration(milliseconds: 80),
                      child: _ActivePlanSection(),
                    ),
                  ),

                  // Past recaps row (kept for discoverability)
                  const SizedBox(height: 10),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 22),
                    child: FadeSlideIn(
                      delay: const Duration(milliseconds: 95),
                      child: PressableScale(
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const PastRecapsScreen(),
                          ),
                        ),
                        child: GlassContainer(
                          radius: 14,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 12,
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 32,
                                height: 32,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  color: context.colors.accentTint,
                                ),
                                child: Icon(
                                  Icons.auto_awesome_outlined,
                                  size: 16,
                                  color: context.colors.accentDeep,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      l10n.recapPastRecaps,
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: context.colors.ink900,
                                      ),
                                    ),
                                    const SizedBox(height: 1),
                                    Text(
                                      l10n.recapPastRecapsSubtitle,
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
                        ),
                      ),
                    ),
                  ),

                  // Appearance
                  _SectionLabel(l10n.appearance),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 22),
                    child: FadeSlideIn(
                      delay: const Duration(milliseconds: 110),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          GlassContainer(
                            radius: 16,
                            padding: const EdgeInsets.all(14),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  l10n.theme,
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 0.6,
                                    color: context.colors.ink500,
                                  ),
                                ),
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
                                Padding(
                                  padding: const EdgeInsets.only(
                                    top: 14,
                                    bottom: 10,
                                  ),
                                  child: Divider(
                                    color: context.colors.hairline.withValues(
                                      alpha: 0.4,
                                    ),
                                    height: 0.5,
                                  ),
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      l10n.accentColor,
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                        letterSpacing: 0.6,
                                        color: context.colors.ink500,
                                      ),
                                    ),
                                    Text(
                                      accent.displayName(l10n),
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                        color: context.colors.accentDeep,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                KeyedSubtree(
                                  key: _colorSectionKey,
                                  child: AccentSwatchRail(
                                    selected: accent,
                                    onChanged: (opt) => ref
                                        .read(accentProvider.notifier)
                                        .setAccent(opt),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 8),
                          GlassContainer(
                            radius: 16,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 10,
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 32,
                                  height: 32,
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    color: context.colors.accentTint,
                                  ),
                                  child: Icon(
                                    Icons.language_outlined,
                                    size: 16,
                                    color: context.colors.accentDeep,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    l10n.language,
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      color: context.colors.ink900,
                                    ),
                                  ),
                                ),
                                DropdownButtonHideUnderline(
                                  child: DropdownButton<Locale>(
                                    value: locale,
                                    icon: Icon(
                                      Icons.expand_more,
                                      size: 16,
                                      color: context.colors.ink400,
                                    ),
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500,
                                      color: context.colors.ink700,
                                    ),
                                    dropdownColor: context.colors.bgFrame,
                                    borderRadius: BorderRadius.circular(12),
                                    onChanged: (Locale? v) {
                                      if (v != null) {
                                        ref
                                            .read(localeProvider.notifier)
                                            .setLocale(v);
                                      }
                                    },
                                    items: [
                                      DropdownMenuItem(
                                        value: const Locale('en'),
                                        child: Text(l10n.languageEn),
                                      ),
                                      DropdownMenuItem(
                                        value: const Locale('es'),
                                        child: Text(l10n.languageEs),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Sound
                  _SectionLabel(l10n.sound),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 22),
                    child: FadeSlideIn(
                      delay: const Duration(milliseconds: 130),
                      child: KeyedSubtree(
                        key: _soundSectionKey,
                        child: GlassContainer(
                          radius: 16,
                          padding: const EdgeInsets.all(14),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  Container(
                                    width: 36,
                                    height: 36,
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(11),
                                      color: context.colors.accentTint,
                                    ),
                                    child: Icon(
                                      Icons.notifications_active_outlined,
                                      size: 18,
                                      color: context.colors.accentDeep,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          l10n.restTimerAlert,
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                            color: context.colors.ink900,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          l10n.notificationSubtitle,
                                          style: TextStyle(
                                            fontSize: 11,
                                            color: context.colors.ink500,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  GlassSwitch(
                                    value: _restAlertEnabled,
                                    activeColor: context.colors.accent,
                                    onChanged: (v) {
                                      setState(() => _restAlertEnabled = v);
                                      _soundService.setAlertEnabled(v);
                                    },
                                  ),
                                ],
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
                                child: Divider(
                                  color: context.colors.hairline.withValues(
                                    alpha: 0.4,
                                  ),
                                  height: 0.5,
                                ),
                              ),
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
                  ),

                  // Data
                  _SectionLabel(l10n.data),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 22),
                    child: FadeSlideIn(
                      delay: const Duration(milliseconds: 150),
                      child: KeyedSubtree(
                        key: _dataSectionKey,
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: DataAction(
                                    icon: Icons.upload_outlined,
                                    label: l10n.exportData,
                                    sublabel: l10n.exportSubtitle,
                                    onTap: _busy ? null : _exportData,
                                  ),
                                ),
                                const SizedBox(width: 8),
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
                            const SizedBox(height: 8),
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

                  // About footer
                  const SizedBox(height: 28),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 22),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          l10n.appName,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: context.colors.ink500,
                          ),
                        ),
                        _Sep(),
                        Text(
                          'v1.0.0',
                          style: TextStyle(
                            fontSize: 11,
                            color: context.colors.ink400,
                            fontFeatures: const [FontFeature.tabularFigures()],
                          ),
                        ),
                        _Sep(),
                        Text(
                          '${l10n.aboutBy} ',
                          style: TextStyle(
                            fontSize: 11,
                            color: context.colors.ink400,
                          ),
                        ),
                        Text(
                          'Carlos',
                          style: TextStyle(
                            fontSize: 11,
                            color: context.colors.accentDeep,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
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

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.label);
  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(26, 22, 24, 10),
      child: Text(
        label.toUpperCase(),
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          letterSpacing: 1.1,
          color: context.colors.ink400,
        ),
      ),
    );
  }
}

class _Sep extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6),
      child: Text(
        '·',
        style: TextStyle(
          fontSize: 12,
          color: context.colors.ink400,
        ),
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
