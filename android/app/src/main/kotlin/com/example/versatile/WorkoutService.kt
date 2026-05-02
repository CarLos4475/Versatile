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
    private var routineName: String? = null
    private val channelId = "workout_channel"
    private val notifId = 1001

    // Action intent for the "Open" button on the notification
    companion object {
        const val PREFS_NAME        = "workout_prefs"
        const val KEY_STARTED_AT    = "startedAt"
        const val KEY_ROUTINE_ID    = "routineId"
        const val KEY_ROUTINE_NAME  = "routineName"
        const val KEY_PROGRESS      = "progress"
        const val ACTION_OPEN       = "com.example.versatile.ACTION_OPEN_WORKOUT"

        @Volatile
        private var _isRunning = false

        fun isRunning(context: Context): Boolean = _isRunning

        fun clearPrefs(context: Context) {
            context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
                .edit().clear().apply()
        }
    }

    // ── Tick every second to refresh elapsed time ──────────────────────────────

    private val tick = object : Runnable {
        override fun run() {
            updateNotification()
            handler.postDelayed(this, 1000)
        }
    }

    // ── Lifecycle ──────────────────────────────────────────────────────────────

    override fun onCreate() {
        super.onCreate()
        createChannel()
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        val prefs = getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)

        if (intent != null) {
            val ts = intent.getLongExtra(KEY_STARTED_AT, 0L)
            startedAtMs  = if (ts > 0L) ts else System.currentTimeMillis()
            routineId    = intent.getStringExtra(KEY_ROUTINE_ID)
            routineName  = intent.getStringExtra(KEY_ROUTINE_NAME)

            prefs.edit()
                .putLong(KEY_STARTED_AT, startedAtMs)
                .putString(KEY_ROUTINE_ID, routineId)
                .putString(KEY_ROUTINE_NAME, routineName)
                .apply()
        } else {
            // Restarted by system — restore from prefs
            startedAtMs = prefs.getLong(KEY_STARTED_AT, 0L)
            routineId   = prefs.getString(KEY_ROUTINE_ID, null)
            routineName = prefs.getString(KEY_ROUTINE_NAME, null)

            if (startedAtMs == 0L || routineId.isNullOrEmpty()) {
                stopSelf()
                return START_NOT_STICKY
            }
        }

        _isRunning = true
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
        _isRunning = false
        handler.removeCallbacks(tick)
        super.onDestroy()
    }

    override fun onBind(intent: Intent?): IBinder? = null

    // ── Notification channel (created once) ───────────────────────────────────

    private fun createChannel() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val channel = NotificationChannel(
                channelId,
                getString(R.string.notif_channel_name),
                NotificationManager.IMPORTANCE_LOW
            ).apply {
                description = getString(R.string.notif_channel_desc)
                setShowBadge(false)
                enableVibration(false)
                enableLights(false)
            }
            getSystemService(NotificationManager::class.java)
                .createNotificationChannel(channel)
        }
    }

    // ── Helpers ────────────────────────────────────────────────────────────────

    private fun elapsedSeconds(): Int =
        ((System.currentTimeMillis() - startedAtMs) / 1000).toInt()

    /** Format as M:SS or H:MM:SS */
    private fun formatTimer(seconds: Int): String {
        val h = seconds / 3600
        val m = (seconds % 3600) / 60
        val s = seconds % 60
        return if (h > 0) "%d:%02d:%02d".format(h, m, s)
        else "%d:%02d".format(m, s)
    }

    // ── Build the notification ─────────────────────────────────────────────────

    private fun buildNotification(elapsed: Int): Notification {
        // Tap → open the app
        val openIntent = PendingIntent.getActivity(
            this, 0,
            Intent(this, MainActivity::class.java).apply {
                action = ACTION_OPEN
                addFlags(Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP)
            },
            PendingIntent.FLAG_IMMUTABLE or PendingIntent.FLAG_UPDATE_CURRENT
        )

        // "Open" action button
        val actionPending = PendingIntent.getActivity(
            this, 1,
            Intent(this, MainActivity::class.java).apply {
                action = ACTION_OPEN
                addFlags(Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP)
            },
            PendingIntent.FLAG_IMMUTABLE or PendingIntent.FLAG_UPDATE_CURRENT
        )

        // Title: routine name if known, else generic localized string
        val title = routineName?.takeIf { it.isNotBlank() }
            ?: getString(R.string.notif_title)

        // Content: elapsed time  ·  motivational subtitle
        val timer    = formatTimer(elapsed)
        val subtitle = getString(R.string.notif_subtitle)
        val content  = "$timer  ·  $subtitle"

        val actionLabel = getString(R.string.notif_action_open)

        return if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            Notification.Builder(this, channelId)
                .setContentTitle(title)
                .setContentText(content)
                .setSmallIcon(R.drawable.ic_notif_dumbbell)
                .setContentIntent(openIntent)
                .setOngoing(true)
                .setShowWhen(false)
                .addAction(
                    Notification.Action.Builder(
                        null,
                        actionLabel,
                        actionPending
                    ).build()
                )
                .build()
        } else {
            @Suppress("DEPRECATION")
            Notification.Builder(this)
                .setContentTitle(title)
                .setContentText(content)
                .setSmallIcon(R.drawable.ic_notif_dumbbell)
                .setContentIntent(openIntent)
                .setOngoing(true)
                .setShowWhen(false)
                .addAction(0, actionLabel, actionPending)
                .build()
        }
    }

    private fun updateNotification() {
        getSystemService(NotificationManager::class.java)
            .notify(notifId, buildNotification(elapsedSeconds()))
    }
}
