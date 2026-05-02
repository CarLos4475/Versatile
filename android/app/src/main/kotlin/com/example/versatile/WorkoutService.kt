package com.example.versatile

import android.app.*
import android.content.Context
import android.content.Intent
import android.content.pm.ServiceInfo
import android.os.Build
import android.os.Handler
import android.os.IBinder
import android.os.Looper

class WorkoutService : Service() {
    private val handler = Handler(Looper.getMainLooper())
    private var startedAtMs = 0L
    private var routineId: String? = null
    private val channelId = "workout_channel"
    private val notifId = 1001

    private val tick = object : Runnable {
        override fun run() {
            updateNotification()
            handler.postDelayed(this, 1000)
        }
    }

    override fun onCreate() {
        super.onCreate()
        createChannel()
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        val prefs = getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)

        if (intent != null) {
            val ts = intent.getLongExtra(KEY_STARTED_AT, 0L)
            startedAtMs = if (ts > 0L) ts else System.currentTimeMillis()
            routineId = intent.getStringExtra(KEY_ROUTINE_ID)
            prefs.edit()
                .putLong(KEY_STARTED_AT, startedAtMs)
                .putString(KEY_ROUTINE_ID, routineId)
                .apply()
        } else {
            // Restarted by system after being killed — restore from prefs
            startedAtMs = prefs.getLong(KEY_STARTED_AT, System.currentTimeMillis())
            routineId = prefs.getString(KEY_ROUTINE_ID, null)
        }

        val notif = buildNotification(elapsedSeconds())
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
            startForeground(notifId, notif, ServiceInfo.FOREGROUND_SERVICE_TYPE_DATA_SYNC)
        } else {
            startForeground(notifId, notif)
        }
        handler.removeCallbacks(tick)
        handler.post(tick)
        return START_STICKY
    }

    override fun onDestroy() {
        handler.removeCallbacks(tick)
        super.onDestroy()
    }

    override fun onBind(intent: Intent?): IBinder? = null

    private fun createChannel() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val channel = NotificationChannel(
                channelId, "Workout", NotificationManager.IMPORTANCE_LOW
            ).apply {
                setShowBadge(false)
                enableVibration(false)
            }
            getSystemService(NotificationManager::class.java).createNotificationChannel(channel)
        }
    }

    private fun elapsedSeconds(): Int =
        ((System.currentTimeMillis() - startedAtMs) / 1000).toInt()

    private fun formatTimer(seconds: Int): String {
        val h = seconds / 3600
        val m = (seconds % 3600) / 60
        val s = seconds % 60
        return if (h > 0) "%d:%02d:%02d".format(h, m, s)
        else "%d:%02d".format(m, s)
    }

    private fun buildNotification(elapsed: Int): Notification {
        val pendingIntent = PendingIntent.getActivity(
            this, 0,
            Intent(this, MainActivity::class.java).apply {
                addFlags(Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP)
            },
            PendingIntent.FLAG_IMMUTABLE or PendingIntent.FLAG_UPDATE_CURRENT
        )
        return if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            Notification.Builder(this, channelId)
                .setContentTitle("Workout in progress")
                .setContentText(formatTimer(elapsed))
                .setSmallIcon(android.R.drawable.ic_media_play)
                .setContentIntent(pendingIntent)
                .setOngoing(true)
                .build()
        } else {
            @Suppress("DEPRECATION")
            Notification.Builder(this)
                .setContentTitle("Workout in progress")
                .setContentText(formatTimer(elapsed))
                .setSmallIcon(android.R.drawable.ic_media_play)
                .setContentIntent(pendingIntent)
                .setOngoing(true)
                .build()
        }
    }

    private fun updateNotification() {
        getSystemService(NotificationManager::class.java)
            .notify(notifId, buildNotification(elapsedSeconds()))
    }

    companion object {
        const val PREFS_NAME = "workout_prefs"
        const val KEY_STARTED_AT = "startedAt"
        const val KEY_ROUTINE_ID = "routineId"
        const val KEY_PROGRESS = "progress"

        fun clearPrefs(context: Context) {
            context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
                .edit().clear().apply()
        }

        @Suppress("DEPRECATION")
        fun isRunning(context: Context): Boolean {
            val am = context.getSystemService(Context.ACTIVITY_SERVICE) as ActivityManager
            return am.getRunningServices(Int.MAX_VALUE).any {
                it.service.className == WorkoutService::class.java.name
            }
        }
    }
}
