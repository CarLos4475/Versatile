import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:file_picker/file_picker.dart';
import '../../../core/providers/repository_providers.dart';
import '../../../core/services/data_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/database/database_helper.dart';
import '../../../shared/widgets/glass_container.dart';
import '../../../shared/widgets/motion.dart';
import '../../../shared/widgets/screen_header.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  bool _darkMode = false;
  bool _busy = false;

  Future<void> _changeName() async {
    final currentName = await ref.read(settingsRepositoryProvider).getUserName();
    if (!mounted) return;

    final controller = TextEditingController(text: currentName == 'there' ? '' : currentName);
    final result = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.glassBgStrong,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Your name',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.ink900,
            letterSpacing: -0.18,
          ),
        ),
        content: TextField(
          controller: controller,
          autofocus: true,
          textCapitalization: TextCapitalization.words,
          style: const TextStyle(color: AppColors.ink900, fontSize: 16),
          decoration: InputDecoration(
            hintText: 'Enter your name',
            hintStyle: const TextStyle(color: AppColors.ink400),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.bone300, width: 1),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.accent, width: 1.5),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          ),
          onSubmitted: (v) => Navigator.of(ctx).pop(v.trim()),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel', style: TextStyle(color: AppColors.ink400)),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(controller.text.trim()),
            child: const Text(
              'Save',
              style: TextStyle(color: AppColors.accentDeep, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );

    if (result != null && result.isNotEmpty) {
      await ref.read(settingsRepositoryProvider).setUserName(result);
      ref.invalidate(userNameProvider);
    }
  }

  Future<void> _exportData() async {
    setState(() => _busy = true);
    try {
      final json = await DataService.exportJson();
      final dir = await getTemporaryDirectory();
      final timestamp = DateTime.now().toIso8601String().replaceAll(':', '-').substring(0, 19);
      final file = File('${dir.path}/versatile_backup_$timestamp.json');
      await file.writeAsString(json);
      await Share.shareXFiles([XFile(file.path)], text: 'Versatile backup');
    } catch (e) {
      if (mounted) _showError('Export failed: $e');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _importData() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['json'],
    );
    if (result == null || result.files.single.path == null) return;

    setState(() => _busy = true);
    try {
      final content = await File(result.files.single.path!).readAsString();
      await DataService.importJson(content);
      ref.invalidate(userNameProvider);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Data imported successfully')),
        );
      }
    } catch (e) {
      if (mounted) _showError('Import failed: $e');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _wipeData() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.glassBgStrong,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Wipe all data?',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.ink900,
            letterSpacing: -0.18,
          ),
        ),
        content: const Text(
          'This will permanently delete all your routines, sessions, and workout history. This cannot be undone.',
          style: TextStyle(fontSize: 14, color: AppColors.ink500, height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel', style: TextStyle(color: AppColors.ink400)),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text(
              'Wipe',
              style: TextStyle(
                color: Colors.red,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() => _busy = true);
    try {
      await DatabaseHelper.instance.wipeUserData();
      ref.invalidate(userNameProvider);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('All data wiped')),
        );
      }
    } catch (e) {
      if (mounted) _showError('Wipe failed: $e');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: Colors.red.shade700),
    );
  }

  @override
  Widget build(BuildContext context) {
    final userName = ref.watch(userNameProvider).value ?? 'there';

    return Scaffold(
      backgroundColor: AppColors.bgApp,
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ScreenHeader(
                    title: 'Settings',
                    onBack: () => Navigator.of(context).pop(),
                  ),
                  const SizedBox(height: 24),

                  // Profile
                  _SectionLabel('PROFILE'),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 22),
                    child: FadeSlideIn(
                      delay: const Duration(milliseconds: 60),
                      child: GlassContainer(
                        radius: 20,
                        child: _SettingRow(
                          icon: Icons.person_outline,
                          title: 'Name',
                          value: userName == 'there' ? '' : userName,
                          onTap: _changeName,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Appearance
                  _SectionLabel('APPEARANCE'),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 22),
                    child: FadeSlideIn(
                      delay: const Duration(milliseconds: 100),
                      child: GlassContainer(
                        radius: 20,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 4),
                          child: Row(
                            children: [
                              Container(
                                width: 34,
                                height: 34,
                                decoration: BoxDecoration(
                                  color: AppColors.accentTint,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Icon(
                                  Icons.dark_mode_outlined,
                                  size: 18,
                                  color: AppColors.accentDeep,
                                ),
                              ),
                              const SizedBox(width: 14),
                              const Expanded(
                                child: Text(
                                  'Dark mode',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w500,
                                    color: AppColors.ink900,
                                  ),
                                ),
                              ),
                              Switch(
                                value: _darkMode,
                                onChanged: (_) => setState(() => _darkMode = !_darkMode),
                                activeColor: AppColors.accentDeep,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Data
                  _SectionLabel('DATA'),
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
                              title: 'Export data',
                              subtitle: 'Share a JSON backup of all your data',
                              onTap: _busy ? null : _exportData,
                            ),
                            _Divider(),
                            _SettingRow(
                              icon: Icons.download_outlined,
                              title: 'Import data',
                              subtitle: 'Restore from a JSON backup',
                              onTap: _busy ? null : _importData,
                            ),
                            _Divider(),
                            _SettingRow(
                              icon: Icons.delete_outline,
                              title: 'Wipe data',
                              subtitle: 'Delete all routines, sessions and history',
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
                  _SectionLabel('ABOUT'),
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
                              title: 'Version',
                              value: '1.0.0',
                            ),
                            _Divider(),
                            _SettingRow(
                              icon: Icons.code_outlined,
                              title: 'Author',
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
              const Positioned.fill(
                child: ColoredBox(
                  color: Color(0x33000000),
                  child: Center(
                    child: CircularProgressIndicator(color: AppColors.accent),
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
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.06,
          color: AppColors.ink400,
        ),
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const Divider(
      height: 0,
      thickness: 0.5,
      indent: 18,
      endIndent: 18,
      color: AppColors.bone200,
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
    final titleColor = destructive ? Colors.red.shade600 : AppColors.ink900;
    final iconColor = destructive ? Colors.red.shade400 : AppColors.accentDeep;
    final iconBgColor = destructive
        ? Colors.red.withOpacity(0.08)
        : AppColors.accentTint;

    Widget row = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: iconBgColor,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 18, color: iconColor),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: titleColor,
                  ),
                ),
                if (subtitle != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Text(
                      subtitle!,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.ink400,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          if (value != null)
            Text(
              value!,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.ink400,
              ),
            ),
          if (onTap != null)
            const Padding(
              padding: EdgeInsets.only(left: 4),
              child: Icon(Icons.chevron_right, size: 18, color: AppColors.ink300),
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
