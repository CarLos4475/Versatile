import 'package:flutter/services.dart';

class ActiveWorkoutInfo {
  final String routineId;
  final DateTime startedAt;
  const ActiveWorkoutInfo({required this.routineId, required this.startedAt});
}

class WorkoutNotificationService {
  static const _channel = MethodChannel('com.example.versatile/workout');

  static Future<void> start({
    required DateTime startedAt,
    required String routineId,
  }) async {
    try {
      await _channel.invokeMethod('startWorkoutService', {
        'startedAt': startedAt.millisecondsSinceEpoch,
        'routineId': routineId,
      });
    } catch (_) {}
  }

  static Future<void> stop() async {
    try {
      await _channel.invokeMethod('stopWorkoutService');
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
      );
    } catch (_) {
      return null;
    }
  }
}
