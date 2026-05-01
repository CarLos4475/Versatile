import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../../core/theme/app_colors.dart';
import '../../../domain/entities/routine.dart';
import '../../../shared/widgets/glass_button.dart';
import '../../../shared/widgets/glass_container.dart';
import '../../../shared/widgets/screen_header.dart';
import '../view_models/routines_view_model.dart';
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

class CreateRoutineScreen extends ConsumerStatefulWidget {
  const CreateRoutineScreen({super.key});

  @override
  ConsumerState<CreateRoutineScreen> createState() =>
      _CreateRoutineScreenState();
}

class _CreateRoutineScreenState extends ConsumerState<CreateRoutineScreen> {
  final _ctrl = TextEditingController();
  Color _selectedColor = const Color(0xFFD97757);
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
      exercises: const [],
    );
    await ref.read(routinesProvider.notifier).addRoutine(routine);
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => RoutineDetailScreen(routineId: id),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgApp,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ScreenHeader(
              title: 'New Routine',
              subtitle: 'Name it and pick a color',
              onBack: () => Navigator.of(context).pop(),
            ),
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 22),
              child: GlassContainer(
                radius: 16,
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: TextField(
                  controller: _ctrl,
                  autofocus: true,
                  style: const TextStyle(
                    fontSize: 16,
                    color: AppColors.ink900,
                    fontWeight: FontWeight.w500,
                  ),
                  decoration: const InputDecoration(
                    hintText: 'e.g. Push Day, Full Body…',
                    hintStyle:
                        TextStyle(fontSize: 16, color: AppColors.ink400),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(vertical: 14),
                  ),
                  onSubmitted: (_) => _save(),
                ),
              ),
            ),
            const SizedBox(height: 28),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 22),
              child: Text(
                'COLOR',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.06,
                  color: AppColors.ink400,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 22),
              child: Wrap(
                spacing: 12,
                runSpacing: 12,
                children: _kColors.map((c) {
                  final active = _selectedColor == c;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedColor = c),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: c,
                        shape: BoxShape.circle,
                        border: active
                            ? Border.all(color: Colors.white, width: 3)
                            : null,
                        boxShadow: active
                            ? [
                                BoxShadow(
                                  color: c.withOpacity(0.5),
                                  blurRadius: 14,
                                  offset: const Offset(0, 4),
                                ),
                              ]
                            : null,
                      ),
                      child: active
                          ? const Icon(Icons.check,
                              color: Colors.white, size: 20)
                          : null,
                    ),
                  );
                }).toList(),
              ),
            ),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.fromLTRB(22, 0, 22, 24),
              child: GlassButton(
                label: 'Create Routine',
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
