import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:versatile/l10n/app_localizations.dart';
import 'package:uuid/uuid.dart';
import '../../../core/navigation/app_page_transitions.dart';
import '../../../core/theme/accent_colors.dart';
import '../../../core/theme/app_colors.dart';
import '../../../domain/entities/routine.dart';
import '../../../shared/widgets/motion.dart';
import '../../../shared/widgets/screen_header.dart';
import '../view_models/routines_view_model.dart';
import '../widgets/routine_color_picker.dart';
import '../widgets/routine_icon_picker.dart';
import 'routine_detail_screen.dart';

final _kColors = AccentColors.options.map((o) => o.color).toList();

const _kIcons = [
  Icons.fitness_center,
  Icons.sports_mma_rounded,
  Icons.directions_run,
  Icons.sports_gymnastics_rounded,
  Icons.sports_kabaddi_rounded,
  Icons.whatshot_rounded,
  Icons.monitor_weight_rounded,
  Icons.emoji_events_rounded,
  Icons.shield_rounded,
  Icons.bolt_rounded,
  Icons.sports_esports_rounded,
  Icons.skateboarding_rounded,
  Icons.roller_skating_rounded,
  Icons.album_rounded,
  Icons.headset_rounded,
  Icons.radio_rounded,
  Icons.theater_comedy_rounded,
  Icons.local_pizza_rounded,
  Icons.sports_bar_rounded,
  Icons.cookie_rounded,
  Icons.pets_rounded,
  Icons.auto_awesome_rounded,
  Icons.extension_rounded,
  Icons.favorite_rounded,
];

class CreateRoutineScreen extends ConsumerStatefulWidget {
  const CreateRoutineScreen({super.key});

  @override
  ConsumerState<CreateRoutineScreen> createState() =>
      _CreateRoutineScreenState();
}

class _CreateRoutineScreenState extends ConsumerState<CreateRoutineScreen> {
  final _ctrl = TextEditingController();
  Color _selectedColor = const Color(0xFFD97757);
  IconData _selectedIcon = Icons.fitness_center;
  bool _saving = false;

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final name = _ctrl.text.trim();
    if (name.isEmpty) return;
    setState(() => _saving = true);
    final id = const Uuid().v4();
    final routine = Routine(
      id: id,
      name: name,
      colorValue: _selectedColor.toARGB32(),
      iconCode: _selectedIcon.codePoint,
      exercises: const [],
    );
    await ref.read(routinesProvider.notifier).addRoutine(routine);
    if (!mounted) return;
    Navigator.of(
      context,
    ).pushReplacement(AppRoute(page: RoutineDetailScreen(routineId: id)));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isEs = Localizations.localeOf(context).languageCode == 'es';

    return Scaffold(
      backgroundColor: context.colors.bgApp,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ScreenHeader(
              prefix: isEs ? 'Nueva' : 'New',
              accent: isEs ? 'rutina.' : 'routine.',
              eyebrow: l10n.nameItAndPickColor,
              onBack: () => Navigator.of(context).pop(),
              accentBack: true,
            ),
            const SizedBox(height: 10),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const _GridDivider(),
                    _NameBlock(
                      controller: _ctrl,
                      onSubmit: _save,
                      label: isEs ? 'Nombre' : 'Name',
                      hint: isEs ? 'p. ej. Push Day' : 'e.g. Push Day',
                    ),
                    const _GridDivider(),
                    _ColorBlock(
                      label: l10n.color_label,
                      selectedValue: _selectedColor.toARGB32(),
                      onSelected: (c) => setState(() => _selectedColor = c),
                    ),
                    const _GridDivider(),
                    _IconBlock(
                      label: l10n.icon_label,
                      selectedCode: _selectedIcon.codePoint,
                      onSelected: (i) => setState(() => _selectedIcon = i),
                    ),
                    const _GridDivider(),
                  ],
                ),
              ),
            ),
            _CreateCtaBar(
              label: l10n.createRoutineBtn,
              loading: _saving,
              onTap: _saving ? null : _save,
            ),
          ],
        ),
      ),
    );
  }
}

class _GridDivider extends StatelessWidget {
  const _GridDivider();
  @override
  Widget build(BuildContext context) {
    return Container(height: 0.6, color: context.colors.hairline);
  }
}

class _SectionEyebrow extends StatelessWidget {
  const _SectionEyebrow({required this.text});

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

class _NameBlock extends StatelessWidget {
  const _NameBlock({
    required this.controller,
    required this.onSubmit,
    required this.label,
    required this.hint,
  });

  final TextEditingController controller;
  final VoidCallback onSubmit;
  final String label;
  final String hint;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Padding(
      padding: const EdgeInsets.fromLTRB(22, 22, 22, 22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionEyebrow(text: label),
          const SizedBox(height: 12),
          TextField(
            controller: controller,
            autofocus: true,
            cursorColor: colors.accent,
            style: TextStyle(
              fontSize: 28,
              color: colors.ink900,
              fontWeight: FontWeight.w500,
              letterSpacing: -0.3,
            ),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(
                fontSize: 28,
                color: colors.ink400,
                fontWeight: FontWeight.w400,
                fontStyle: FontStyle.italic,
                letterSpacing: -0.3,
              ),
              border: InputBorder.none,
              isDense: true,
              contentPadding: EdgeInsets.zero,
            ),
            onSubmitted: (_) => onSubmit(),
          ),
        ],
      ),
    );
  }
}

class _ColorBlock extends StatelessWidget {
  const _ColorBlock({
    required this.label,
    required this.selectedValue,
    required this.onSelected,
  });

  final String label;
  final int selectedValue;
  final ValueChanged<Color> onSelected;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(22, 22, 22, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionEyebrow(text: label),
          const SizedBox(height: 16),
          RoutineColorPicker(
            colors: _kColors,
            selectedColorValue: selectedValue,
            onSelected: onSelected,
          ),
        ],
      ),
    );
  }
}

class _IconBlock extends StatelessWidget {
  const _IconBlock({
    required this.label,
    required this.selectedCode,
    required this.onSelected,
  });

  final String label;
  final int selectedCode;
  final ValueChanged<IconData> onSelected;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(22, 22, 22, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionEyebrow(text: label),
          const SizedBox(height: 16),
          RoutineIconPicker(
            icons: _kIcons,
            selectedCode: selectedCode,
            onSelected: onSelected,
          ),
        ],
      ),
    );
  }
}

class _CreateCtaBar extends StatelessWidget {
  const _CreateCtaBar({
    required this.label,
    required this.loading,
    required this.onTap,
  });

  final String label;
  final bool loading;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return PressableScale(
      onTap: onTap,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 180),
        opacity: onTap == null ? 0.58 : 1,
        child: Container(
          width: double.infinity,
          height: 60,
          decoration: BoxDecoration(
            color: colors.accent,
            border: Border(
              top: BorderSide(
                color: colors.accentDeep.withValues(alpha: 0.4),
                width: 0.6,
              ),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (loading)
                const SizedBox(
                  width: 14,
                  height: 14,
                  child: CircularProgressIndicator(
                    strokeWidth: 1.5,
                    color: Colors.white,
                  ),
                )
              else
                const Icon(Icons.check_rounded, color: Colors.white, size: 18),
              const SizedBox(width: 10),
              Text(
                label.toUpperCase(),
                style: const TextStyle(
                  fontSize: 13,
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.4,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
