package com.example.versatile

import android.content.Context
import android.content.Intent
import android.os.Build
import android.os.Bundle
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val workoutChannel = "com.example.versatile/workout"

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        requestHighestRefreshRate()
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            workoutChannel
        ).setMethodCallHandler { call, result ->
            when (call.method) {
                "startWorkoutService" -> {
                    val startedAt = (call.argument<Any>("startedAt") as? Number)?.toLong() ?: 0L
                    val routineId = call.argument<String>("routineId") ?: ""
                    val intent = Intent(this, WorkoutService::class.java).apply {
                        putExtra(WorkoutService.KEY_STARTED_AT, startedAt)
                        putExtra(WorkoutService.KEY_ROUTINE_ID, routineId)
                    }
                    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                        startForegroundService(intent)
                    } else {
                        startService(intent)
                    }
                    result.success(null)
                }
                "stopWorkoutService" -> {
                    WorkoutService.clearPrefs(this)
                    stopService(Intent(this, WorkoutService::class.java))
                    result.success(null)
                }
                "getActiveWorkout" -> {
                    if (!WorkoutService.isRunning(this)) {
                        WorkoutService.clearPrefs(this)
                        result.success(null)
                    } else {
                        val prefs = getSharedPreferences(
                            WorkoutService.PREFS_NAME, Context.MODE_PRIVATE
                        )
                        val routineId = prefs.getString(WorkoutService.KEY_ROUTINE_ID, null)
                        val startedAt = prefs.getLong(WorkoutService.KEY_STARTED_AT, 0L)
                        if (routineId == null || startedAt == 0L) {
                            result.success(null)
                        } else {
                            result.success(mapOf(
                                "routineId" to routineId,
                                "startedAt" to startedAt
                            ))
                        }
                    }
                }
                else -> result.notImplemented()
            }
        }
    }

    private fun requestHighestRefreshRate() {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.M) return

        val supportedModes = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
            display?.supportedModes
        } else {
            @Suppress("DEPRECATION")
            windowManager.defaultDisplay.supportedModes
        } ?: return

        val maxRefreshRate = supportedModes.maxOfOrNull { it.refreshRate.toDouble() }?.toFloat()
            ?: return

        val params = window.attributes
        if (params.preferredRefreshRate >= maxRefreshRate) return

        params.preferredRefreshRate = maxRefreshRate
        window.attributes = params
    }
}
