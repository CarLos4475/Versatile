import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:versatile/l10n/app_localizations.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:file_picker/file_picker.dart';
import 'package:versatile/core/providers/accent_provider.dart';
import 'package:versatile/core/providers/repository_providers.dart';
import 'package:versatile/core/providers/theme_provider.dart';
import 'package:versatile/core/providers/locale_provider.dart';
import 'package:versatile/core/theme/accent_colors.dart';
import 'package:versatile/core/services/data_service.dart';
import 'package:versatile/core/services/sound_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/database/database_helper.dart';
import '../../../shared/widgets/glass_container.dart';
import '../../../shared/widgets/motion.dart';
import '../../../shared/widgets/screen_header.dart';
import '../../exercises/view_models/exercises_view_model.dart';
import '../../home/view_models/home_view_model.dart';
import '../../routines/view_models/routines_view_model.dart';

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

  @override
  void initState() {
    super.initState();
    _soundService = SoundService(ref.read(settingsRepositoryProvider));
    _loadSoundSettings();
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

    final controller = TextEditingController(text: currentName == 'there' ? '' : currentName);
    final l10n = AppLocalizations.of(context)!;

    final newName = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: context.colors.bgFrame,
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
            child: Text(l10n.cancel, style: TextStyle(color: context.colors.ink400)),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(controller.text.trim()),
            child: Text(
              l10n.done,
              style: TextStyle(color: context.colors.accent, fontWeight: FontWeight.w600),
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
        title: Text(l10n.wipeConfirmTitle, style: TextStyle(color: context.colors.ink900)),
        content: Text(
          l10n.wipeConfirmContent,
          style: TextStyle(color: context.colors.ink500, height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(l10n.cancel, style: TextStyle(color: context.colors.ink400)),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(l10n.wipe, style: const TextStyle(color: Colors.red, fontWeight: FontWeight.w600)),
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

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final userName = ref.watch(userNameProvider).value ?? 'there';
    final themeMode = ref.watch(themeModeProvider);
    final locale = ref.watch(localeProvider);
    final accent = ref.watch(accentProvider);

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
                    title: l10n.settings,
                    onBack: () => Navigator.of(context).pop(),
                    accentBack: true,
                  ),
                  const SizedBox(height: 24),

                  // Profile
                  _SectionLabel(l10n.profile),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 22),
                    child: FadeSlideIn(
                      delay: const Duration(milliseconds: 60),
                      child: GlassContainer(
                        radius: 20,
                        child: _SettingRow(
                          icon: Icons.person_outline,
                          title: l10n.userName,
                          value: (userName == 'there' || userName.isEmpty) ? '' : userName,
                          onTap: _changeName,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Appearance
                  _SectionLabel(l10n.appearance),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 22),
                    child: FadeSlideIn(
                      delay: const Duration(milliseconds: 100),
                      child: GlassContainer(
                        radius: 20,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 4),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  Container(
                                    width: 34,
                                    height: 34,
                                    decoration: BoxDecoration(
                                      color: context.colors.accentTint,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Icon(
                                      Icons.palette_outlined,
                                      size: 18,
                                      color: context.colors.accentDeep,
                                    ),
                                  ),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: Text(
                                      l10n.theme,
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w500,
                                        color: context.colors.ink900,
                                      ),
                                    ),
                                  ),
                                  DropdownButtonHideUnderline(
                                    child: DropdownButton<ThemeMode>(
                                      value: themeMode,
                                      icon: Icon(Icons.expand_more, size: 16, color: context.colors.ink400),
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                        color: context.colors.ink700,
                                      ),
                                      dropdownColor: context.colors.bgFrame,
                                      borderRadius: BorderRadius.circular(12),
                                      onChanged: (ThemeMode? newValue) {
                                        if (newValue != null) {
                                          ref.read(themeModeProvider.notifier).setThemeMode(newValue);
                                        }
                                      },
                                      items: [
                                        DropdownMenuItem(
                                          value: ThemeMode.light,
                                          child: Text(l10n.themeLight),
                                        ),
                                        DropdownMenuItem(
                                          value: ThemeMode.dark,
                                          child: Text(l10n.themeDark),
                                        ),
                                        DropdownMenuItem(
                                          value: ThemeMode.system,
                                          child: Text(l10n.themeSystem),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              Divider(color: context.colors.hairline, height: 1),
                              Row(
                                children: [
                                  Container(
                                    width: 34,
                                    height: 34,
                                    decoration: BoxDecoration(
                                      color: context.colors.accentTint,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Icon(
                                      Icons.language_outlined,
                                      size: 18,
                                      color: context.colors.accentDeep,
                                    ),
                                  ),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: Text(
                                      l10n.language,
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w500,
                                        color: context.colors.ink900,
                                      ),
                                    ),
                                  ),
                                  DropdownButtonHideUnderline(
                                    child: DropdownButton<Locale>(
                                      value: locale,
                                      icon: Icon(Icons.expand_more, size: 16, color: context.colors.ink400),
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                        color: context.colors.ink700,
                                      ),
                                      dropdownColor: context.colors.bgFrame,
                                      borderRadius: BorderRadius.circular(12),
                                      onChanged: (Locale? newValue) {
                                        if (newValue != null) {
                                          ref.read(localeProvider.notifier).setLocale(newValue);
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
                              Divider(color: context.colors.hairline, height: 1),
                              const SizedBox(height: 6),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        width: 34,
                                        height: 34,
                                        decoration: BoxDecoration(
                                          color: context.colors.accentTint,
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                        child: Icon(
                                          Icons.color_lens_outlined,
                                          size: 18,
                                          color: context.colors.accentDeep,
                                        ),
                                      ),
                                      const SizedBox(width: 14),
                                      Text(
                                        l10n.accentColor,
                                        style: TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w500,
                                          color: context.colors.ink900,
                                        ),
                                  ),
                                  const SizedBox(height: 6),
                                ],
                                  ),
                                  const SizedBox(height: 10),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: AccentColors.options.map((opt) {
                                      final selected = accent.id == opt.id;
                                      return Padding(
                                        padding: const EdgeInsets.only(right: 8),
                                        child: PressableScale(
                                          onTap: () => ref.read(accentProvider.notifier).setAccent(opt),
                                          child: Container(
                                            width: 30,
                                            height: 30,
                                            decoration: BoxDecoration(
                                              color: opt.color,
                                              shape: BoxShape.circle,
                                              border: selected
                                                  ? Border.all(color: context.colors.ink300, width: 2.5)
                                                  : null,
                                              boxShadow: selected
                                                  ? [
                                                      BoxShadow(
                                                        color: opt.color.withValues(alpha: 0.3),
                                                        blurRadius: 8,
                                                        offset: const Offset(0, 2),
                                                      ),
                                                    ]
                                                  : null,
                                            ),
                                          ),
                                        ),
                                      );
                                    }).toList(),
                                  ),
                                  const SizedBox(height: 6),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Sound
                  _SectionLabel(l10n.sound),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 22),
                    child: FadeSlideIn(
                      delay: const Duration(milliseconds: 130),
                      child: GlassContainer(
                        radius: 20,
                        child: Padding(
                          padding: const EdgeInsets.all(18),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  Container(
                                    width: 34,
                                    height: 34,
                                    decoration: BoxDecoration(
                                      color: context.colors.accentTint,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Icon(
                                      Icons.notifications_active_outlined,
                                      size: 18,
                                      color: context.colors.accentDeep,
                                    ),
                                  ),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: Text(
                                      l10n.restTimerAlert,
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w500,
                                        color: context.colors.ink900,
                                      ),
                                    ),
                                  ),
                                  Switch(
                                    value: _restAlertEnabled,
                                    onChanged: (v) {
                                      setState(() => _restAlertEnabled = v);
                                      _soundService.setAlertEnabled(v);
                                    },
                                    activeColor: context.colors.accent,
                                  ),
                                ],
                              ),
                              Divider(color: context.colors.hairline, height: 1),
                              const SizedBox(height: 6),
                              Row(
                                children: [
                                  const SizedBox(width: 48),
                                  Expanded(
                                    child: InkWell(
                                      onTap: () {
                                        setState(() => _soundType = 'default');
                                        _soundService.setSoundType('default');
                                      },
                                      borderRadius: BorderRadius.circular(10),
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(vertical: 6),
                                        child: Row(
                                          children: [
                                            Icon(
                                              _soundType == 'default'
                                                  ? Icons.radio_button_checked
                                                  : Icons.radio_button_off,
                                              size: 20,
                                              color: _soundType == 'default'
                                                  ? context.colors.accent
                                                  : context.colors.ink300,
                                            ),
                                            const SizedBox(width: 8),
                                            Text(
                                              l10n.defaultSound,
                                              style: TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w500,
                                                color: context.colors.ink700,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  const SizedBox(width: 48),
                                  Expanded(
                                    child: InkWell(
                                      onTap: () {
                                        setState(() => _soundType = 'custom');
                                        _soundService.setSoundType('custom');
                                      },
                                      borderRadius: BorderRadius.circular(10),
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(vertical: 6),
                                        child: Row(
                                          children: [
                                            Icon(
                                              _soundType == 'custom'
                                                  ? Icons.radio_button_checked
                                                  : Icons.radio_button_off,
                                              size: 20,
                                              color: _soundType == 'custom'
                                                  ? context.colors.accent
                                                  : context.colors.ink300,
                                            ),
                                            const SizedBox(width: 8),
                                            Text(
                                              l10n.customSound,
                                              style: TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w500,
                                                color: context.colors.ink700,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              if (_soundType == 'custom') ...[
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    const SizedBox(width: 48),
                                    Expanded(
                                      child: InkWell(
                                        onTap: _pickSoundFile,
                                        borderRadius: BorderRadius.circular(10),
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 12,
                                            vertical: 8,
                                          ),
                                          decoration: BoxDecoration(
                                            color: context.colors.press,
                                            borderRadius: BorderRadius.circular(10),
                                          ),
                                          child: Row(
                                            children: [
                                              Icon(
                                                Icons.audio_file_outlined,
                                                size: 16,
                                                color: context.colors.ink500,
                                              ),
                                              const SizedBox(width: 8),
                                              Expanded(
                                                child: Text(
                                                  _customPath != null
                                                      ? _customPath!.split('/').last
                                                      : l10n.pickSoundFile,
                                                  style: TextStyle(
                                                    fontSize: 13,
                                                    fontWeight: FontWeight.w500,
                                                    color: _customPath != null
                                                        ? context.colors.ink700
                                                        : context.colors.ink400,
                                                  ),
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Data
                  _SectionLabel(l10n.data),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 22),
                    child: FadeSlideIn(
                      delay: const Duration(milliseconds: 140),
                      child: GlassContainer(
                        radius: 20,
                        child: Column(
                          children: [
                            _SettingRow(
                              icon: Icons.upload_outlined,
                              title: l10n.exportData,
                              subtitle: l10n.exportSubtitle,
                              onTap: _busy ? null : _exportData,
                            ),
                            _Divider(),
                            _SettingRow(
                              icon: Icons.download_outlined,
                              title: l10n.importData,
                              subtitle: l10n.importSubtitle,
                              onTap: _busy ? null : _importData,
                            ),
                            _Divider(),
                            _SettingRow(
                              icon: Icons.delete_outline,
                              title: l10n.wipeAllData,
                              subtitle: l10n.wipeSubtitle,
                              onTap: _busy ? null : _wipeData,
                              destructive: true,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // About
                  _SectionLabel(l10n.about),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 22),
                    child: FadeSlideIn(
                      delay: const Duration(milliseconds: 180),
                      child: GlassContainer(
                        radius: 20,
                        child: Column(
                          children: [
                            _SettingRow(
                              icon: Icons.info_outline,
                              title: l10n.version,
                              value: '1.0.0',
                            ),
                            _Divider(),
                            _SettingRow(
                              icon: Icons.code_outlined,
                              title: l10n.author,
                              value: 'CarLos',
                            ),
                          ],
                        ),
                      ),
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
                    child: CircularProgressIndicator(color: context.colors.accent),
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
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 8),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.06,
          color: context.colors.ink400,
        ),
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Divider(
      height: 0,
      thickness: 0.5,
      indent: 18,
      endIndent: 18,
      color: context.colors.bone200,
    );
  }
}

class _SettingRow extends StatelessWidget {
  const _SettingRow({
    required this.icon,
    required this.title,
    this.subtitle,
    this.value,
    this.onTap,
    this.destructive = false,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final String? value;
  final VoidCallback? onTap;
  final bool destructive;

  @override
  Widget build(BuildContext context) {
    Widget row = Padding(
      padding: const EdgeInsets.all(18),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: destructive
                  ? Colors.red.withValues(alpha: 0.1)
                  : context.colors.accentTint,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              size: 18,
              color: destructive ? Colors.red : context.colors.accentDeep,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: context.colors.ink900,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    subtitle!,
                    style: TextStyle(
                      fontSize: 11,
                      color: context.colors.ink400,
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (value != null)
            Text(
              value!,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: context.colors.ink700,
              ),
            ),
          if (onTap != null)
            Padding(
              padding: const EdgeInsets.only(left: 8),
              child: Icon(Icons.chevron_right, size: 18, color: context.colors.ink300),
            ),
        ],
      ),
    );

    if (onTap != null) {
      row = PressableScale(onTap: onTap, child: row);
    }

    return row;
  }
}
