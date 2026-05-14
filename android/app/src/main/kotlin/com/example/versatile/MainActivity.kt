package com.example.versatile

import android.Manifest
import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.content.pm.PackageManager
import android.media.AudioAttributes
import android.media.AudioFocusRequest
import android.media.AudioManager
import android.media.MediaPlayer
import android.media.Ringtone
import android.media.RingtoneManager
import android.os.Build
import android.os.Bundle
import android.os.Handler
import android.os.Looper
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val workoutChannel = "com.example.versatile/workout"
    private val notifPermissionCode = 1001

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        requestHighestRefreshRate()
        requestNotificationPermissionIfNeeded()
    }

    private fun requestNotificationPermissionIfNeeded() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
            if (ContextCompat.checkSelfPermission(
                    this, Manifest.permission.POST_NOTIFICATIONS
                ) != PackageManager.PERMISSION_GRANTED
            ) {
                ActivityCompat.requestPermissions(
                    this,
                    arrayOf(Manifest.permission.POST_NOTIFICATIONS),
                    notifPermissionCode
                )
            }
        }
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            workoutChannel
        ).setMethodCallHandler { call, result ->
            when (call.method) {
                "startWorkoutService" -> {
                    val startedAt   = (call.argument<Any>("startedAt") as? Number)?.toLong() ?: 0L
                    val routineId   = call.argument<String>("routineId") ?: ""
                    val routineName = call.argument<String>("routineName") ?: ""
                    val subtitle    = call.argument<String>("subtitle") ?: ""
                    val intent = Intent(this, WorkoutService::class.java).apply {
                        putExtra(WorkoutService.KEY_STARTED_AT,   startedAt)
                        putExtra(WorkoutService.KEY_ROUTINE_ID,   routineId)
                        putExtra(WorkoutService.KEY_ROUTINE_NAME, routineName)
                        putExtra(WorkoutService.KEY_SUBTITLE,     subtitle)
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
                "saveWorkoutProgress" -> {
                    val json = call.argument<String>("json") ?: ""
                    val prefs = getSharedPreferences(WorkoutService.PREFS_NAME, Context.MODE_PRIVATE)
                    prefs.edit().putString(WorkoutService.KEY_PROGRESS, json).apply()
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
                        val routineId   = prefs.getString(WorkoutService.KEY_ROUTINE_ID,   null)
                        val startedAt   = prefs.getLong(WorkoutService.KEY_STARTED_AT,     0L)
                        val progress    = prefs.getString(WorkoutService.KEY_PROGRESS,     null)
                        val routineName = prefs.getString(WorkoutService.KEY_ROUTINE_NAME, null)
                        if (routineId == null || startedAt == 0L) {
                            result.success(null)
                        } else {
                            result.success(mapOf(
                                "routineId"   to routineId,
                                "startedAt"   to startedAt,
                                "progressJson" to progress,
                                "routineName"  to routineName
                            ))
                        }
                    }
                }
                "showRestAlert" -> {
                    val exerciseName = call.argument<String>("exerciseName") ?: ""
                    showRestAlertNotification(exerciseName)
                    result.success(null)
                }
                else -> result.notImplemented()
            }
        }
    }

    // v2 = silent channel; the old "rest_alert_channel" (with sound) is deleted
    // on first run so users don't get double audio from the OS + our player.
    private val restAlertChannelId = "rest_alert_v2"
    private var restAlertNotifId = 2001
    private var activeRingtone: Ringtone? = null
    private var activePlayer: MediaPlayer? = null
    private var activeFocusRequest: AudioFocusRequest? = null

    private fun showRestAlertNotification(exerciseName: String) {
        val nm = getSystemService(NotificationManager::class.java)

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            nm.deleteNotificationChannel("rest_alert_channel")
            val channel = NotificationChannel(
                restAlertChannelId,
                getString(R.string.rest_alert_channel_name),
                NotificationManager.IMPORTANCE_HIGH
            ).apply {
                description = getString(R.string.rest_alert_channel_desc)
                setSound(null, null)   // silent — we play the sound ourselves
                enableVibration(true)
            }
            nm.createNotificationChannel(channel)
        }

        val openIntent = PendingIntent.getActivity(
            this, 0,
            Intent(this, MainActivity::class.java).apply {
                action = WorkoutService.ACTION_OPEN
                addFlags(Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP)
            },
            PendingIntent.FLAG_IMMUTABLE or PendingIntent.FLAG_UPDATE_CURRENT
        )

        val title = getString(R.string.rest_complete)
        val content = if (exerciseName.isNotBlank())
            getString(R.string.next_exercise, exerciseName)
        else
            getString(R.string.rest_complete)

        val notif = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            Notification.Builder(this, restAlertChannelId)
                .setContentTitle(title)
                .setContentText(content)
                .setSmallIcon(R.drawable.ic_notif_dumbbell)
                .setContentIntent(openIntent)
                .setAutoCancel(true)
                .setTimeoutAfter(5000)
                .build()
        } else {
            @Suppress("DEPRECATION")
            Notification.Builder(this)
                .setContentTitle(title)
                .setContentText(content)
                .setSmallIcon(R.drawable.ic_notif_dumbbell)
                .setContentIntent(openIntent)
                .setAutoCancel(true)
                .build()
        }

        nm.notify(restAlertNotifId, notif)
        restAlertNotifId++

        playRestAlertSound()
    }

    private fun playRestAlertSound() {
        val uri = RingtoneManager.getDefaultUri(RingtoneManager.TYPE_NOTIFICATION)

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.P) {
            // API 28+: use MediaPlayer for onCompletionListener callback
            val am = getSystemService(AudioManager::class.java)
            val audioAttrs = AudioAttributes.Builder()
                .setUsage(AudioAttributes.USAGE_NOTIFICATION)
                .setContentType(AudioAttributes.CONTENT_TYPE_SONIFICATION)
                .build()

            activeFocusRequest?.let { am.abandonAudioFocusRequest(it) }

            val focusRequest = AudioFocusRequest
                .Builder(AudioManager.AUDIOFOCUS_GAIN_TRANSIENT_MAY_DUCK)
                .setAudioAttributes(audioAttrs)
                .setAcceptsDelayedFocusGain(false)
                .setOnAudioFocusChangeListener { }
                .build()

            activeFocusRequest = focusRequest
            am.requestAudioFocus(focusRequest)

            activePlayer?.release()
            val player = MediaPlayer().apply {
                setDataSource(this@MainActivity, uri)
                setAudioAttributes(audioAttrs)
                setOnCompletionListener {
                    am.abandonAudioFocusRequest(focusRequest)
                    activeFocusRequest = null
                    activePlayer = null
                    release()
                }
                prepare()
                start()
            }
            activePlayer = player

        } else if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            // API 26-27: Ringtone has no completion callback; timed fallback
            val ringtone = RingtoneManager.getRingtone(this, uri) ?: return
            val am = getSystemService(AudioManager::class.java)
            val audioAttrs = AudioAttributes.Builder()
                .setUsage(AudioAttributes.USAGE_NOTIFICATION)
                .setContentType(AudioAttributes.CONTENT_TYPE_SONIFICATION)
                .build()
            ringtone.audioAttributes = audioAttrs

            activeFocusRequest?.let { am.abandonAudioFocusRequest(it) }

            val focusRequest = AudioFocusRequest
                .Builder(AudioManager.AUDIOFOCUS_GAIN_TRANSIENT_MAY_DUCK)
                .setAudioAttributes(audioAttrs)
                .setAcceptsDelayedFocusGain(false)
                .setOnAudioFocusChangeListener { }
                .build()

            activeFocusRequest = focusRequest
            am.requestAudioFocus(focusRequest)

            activeRingtone?.stop()
            activeRingtone = ringtone
            ringtone.play()

            Handler(Looper.getMainLooper()).postDelayed({
                am.abandonAudioFocusRequest(focusRequest)
                activeFocusRequest = null
                activeRingtone = null
            }, 3000L)
        } else {
            // Pre-O: play without focus management (legacy path)
            val ringtone = RingtoneManager.getRingtone(this, uri) ?: return
            ringtone.play()
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
