import 'dart:io' show Platform;
import 'package:flutter/foundation.dart';
import 'package:home_widget/home_widget.dart';

import '../../domain/entities/routine.dart';

class WidgetSyncService {
  WidgetSyncService._();

  static const _kNextRoutineId = 'next_routine_id';
  static const _kNextRoutineName = 'next_routine_name';
  static const _kNextRoutineColor = 'next_routine_color';
  static const _kTodayLabel = 'today_label';
  static const _kAccentArgb = 'accent_color_argb';

  static const _kAndroidPackage = 'com.example.versatile';
  static const _kMediumProvider = 'VersatileWidgetProviderMedium';
  static const _kCompactProvider = 'VersatileWidgetProviderCompact';

  static Future<void> sync({
    Routine? nextRoutine,
    String? todayLabel,
    int? accentArgb,
  }) async {
    if (!_isSupported) return;
    try {
      await HomeWidget.saveWidgetData<String?>(
        _kNextRoutineId,
        nextRoutine?.id,
      );
      await HomeWidget.saveWidgetData<String?>(
        _kNextRoutineName,
        nextRoutine?.name,
      );
      await HomeWidget.saveWidgetData<int?>(
        _kNextRoutineColor,
        nextRoutine?.colorValue,
      );
      await HomeWidget.saveWidgetData<String?>(_kTodayLabel, todayLabel);
      if (accentArgb != null) {
        await HomeWidget.saveWidgetData<int>(_kAccentArgb, accentArgb);
      }
      await _updateWidgets();
    } catch (e, st) {
      // Widget sync is best-effort; never crash the app.
      debugPrint('WidgetSyncService.sync failed: $e\n$st');
    }
  }

  static Future<void> _updateWidgets() async {
    await HomeWidget.updateWidget(
      androidName: _kMediumProvider,
      qualifiedAndroidName: '$_kAndroidPackage.$_kMediumProvider',
    );
    await HomeWidget.updateWidget(
      androidName: _kCompactProvider,
      qualifiedAndroidName: '$_kAndroidPackage.$_kCompactProvider',
    );
  }

  static bool get _isSupported {
    if (kIsWeb) return false;
    try {
      return Platform.isAndroid;
    } catch (_) {
      return false;
    }
  }
}
