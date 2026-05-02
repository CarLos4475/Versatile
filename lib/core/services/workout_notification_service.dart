import 'package:flutter/services.dart';

class ActiveWorkoutInfo {
  final String routineId;
  final DateTime startedAt;
  final String? progressJson;
  final String? routineName;

  const ActiveWorkoutInfo({
    required this.routineId,
    required this.startedAt,
    this.progressJson,
    this.routineName,
  });
}

class WorkoutNotificationService {
  static const _channel = MethodChannel('com.example.versatile/workout');

  /// Starts the foreground workout service.
  /// [routineName] is shown in the notification title.
  static Future<void> start({
    required DateTime startedAt,
    required String routineId,
    String? routineName,
  }) async {
    try {
      await _channel.invokeMethod('startWorkoutService', {
        'startedAt': startedAt.millisecondsSinceEpoch,
        'routineId': routineId,
        'routineName': routineName ?? '',
      });
    } catch (_) {}
  }

  static Future<void> stop() async {
    try {
      await _channel.invokeMethod('stopWorkoutService');
    } catch (_) {}
  }

  static Future<void> saveProgress(String json) async {
    try {
      await _channel.invokeMethod('saveWorkoutProgress', {'json': json});
    } catch (_) {}
  }

  static Future<ActiveWorkoutInfo?> getActiveWorkout() async {
    try {
      final result = await _channel.invokeMethod<Map<dynamic, dynamic>>(
        'getActiveWorkout',
      );
      if (result == null) return null;
      final routineId = result['routineId'] as String?;
      final startedAt = result['startedAt'];
      if (routineId == null || startedAt == null) return null;
      return ActiveWorkoutInfo(
        routineId: routineId,
        startedAt: DateTime.fromMillisecondsSinceEpoch(
          (startedAt as num).toInt(),
        ),
        progressJson: result['progressJson'] as String?,
        routineName: result['routineName'] as String?,
      );
    } catch (_) {
      return null;
    }
  }
}
