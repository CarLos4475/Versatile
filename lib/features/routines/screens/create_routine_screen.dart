import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:versatile/l10n/app_localizations.dart';
import 'package:uuid/uuid.dart';
import '../../../core/navigation/app_page_transitions.dart';
import '../../../core/theme/app_colors.dart';
import '../../../domain/entities/routine.dart';
import '../../../shared/widgets/glass_button.dart';
import '../../../shared/widgets/glass_container.dart';
import '../../../shared/widgets/motion.dart';
import '../../../shared/widgets/screen_header.dart';
import '../view_models/routines_view_model.dart';
import '../widgets/routine_color_picker.dart';
import 'routine_detail_screen.dart';

const _kColors = [
  Color(0xFFD97757),
  Color(0xFFB85432),
  Color(0xFFE89A7E),
  Color(0xFFB48C64),
  Color(0xFF9B7850),
  Color(0xFF4A7B6F),
  Color(0xFF7B5EA7),
  Color(0xFF5E7BA7),
];

const _kIcons = [
  Icons.fitness_center,
  Icons.bolt,
  Icons.timer,
  Icons.favorite,
  Icons.trending_up,
  Icons.directions_run,
  Icons.speed,
  Icons.monitor_weight,
  Icons.rocket_launch,
  Icons.local_fire_department,
  Icons.self_improvement,
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
    return Scaffold(
      backgroundColor: context.colors.bgApp,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ScreenHeader(
              title: l10n.newRoutine,
              subtitle: l10n.nameItAndPickColor,
              onBack: () => Navigator.of(context).pop(),
              accentBack: true,
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.only(bottom: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 24),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 22),
                      child: GlassContainer(
                        radius: 16,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 4,
                        ),
                        child: TextField(
                          controller: _ctrl,
                          autofocus: true,
                          style: TextStyle(
                            fontSize: 16,
                            color: context.colors.ink900,
                            fontWeight: FontWeight.w500,
                          ),
                          decoration: InputDecoration(
                            hintText: l10n.appName == 'Versatile'
                                ? 'e.g. Push Day, Full Body…'
                                : 'ej. Día de empuje, Cuerpo completo…',
                            hintStyle: const TextStyle(
                              fontSize: 16,
                              color: Colors.grey,
                            ),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(
                              vertical: 14,
                            ),
                          ),
                          onSubmitted: (_) => _save(),
                        ),
                      ),
                    ),
                    const SizedBox(height: 28),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 22),
                      child: Text(
                        l10n.color_label,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.06,
                          color: context.colors.ink400,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 22),
                      child: RoutineColorPicker(
                        colors: _kColors,
                        selectedColorValue: _selectedColor.toARGB32(),
                        onSelected: (color) {
                          setState(() => _selectedColor = color);
                        },
                      ),
                    ),
                    const SizedBox(height: 28),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 22),
                      child: Text(
                        l10n.icon_label,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.06,
                          color: context.colors.ink400,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 22),
                      child: Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        children: _kIcons.map((icon) {
                          final active = _selectedIcon == icon;
                          return PressableScale(
                            onTap: () => setState(() => _selectedIcon = icon),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 180),
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: active
                                    ? context.colors.accent
                                    : context.colors.glassBg,
                                borderRadius: BorderRadius.circular(14),
                                border: active
                                    ? Border.all(color: Colors.white, width: 2)
                                    : Border.all(
                                        color: context.colors.glassBorder,
                                        width: 0.5,
                                      ),
                                boxShadow: active
                                    ? [
                                        BoxShadow(
                                          color: context.colors.accentDeep
                                              .withValues(alpha: 0.3),
                                          blurRadius: 12,
                                          offset: const Offset(0, 4),
                                        ),
                                      ]
                                    : null,
                              ),
                              child: Icon(
                                icon,
                                color: active
                                    ? Colors.white
                                    : context.colors.ink700,
                                size: 20,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(22, 0, 22, 24),
              child: GlassButton(
                label: l10n.createRoutineBtn,
                variant: GlassButtonVariant.primary,
                size: GlassButtonSize.lg,
                expand: true,
                loading: _saving,
                onPressed: _saving ? null : _save,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
