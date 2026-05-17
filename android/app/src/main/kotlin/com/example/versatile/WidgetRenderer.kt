package com.example.versatile

import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.graphics.Bitmap
import android.graphics.BlurMaskFilter
import android.graphics.Canvas
import android.graphics.Color
import android.graphics.LinearGradient
import android.graphics.Paint
import android.graphics.Path
import android.graphics.PorterDuff
import android.graphics.PorterDuffColorFilter
import android.graphics.RadialGradient
import android.graphics.RectF
import android.graphics.Shader
import android.os.Build
import android.os.SystemClock
import android.view.View
import android.widget.RemoteViews
import androidx.core.content.res.ResourcesCompat
import androidx.core.graphics.ColorUtils

object WidgetRenderer {

    private const val HOME_WIDGET_PREFS = "HomeWidgetPreferences"
    private const val FLUTTER_PREFIX = "flutter."

    private const val KEY_NEXT_ROUTINE_ID = "next_routine_id"
    private const val KEY_NEXT_ROUTINE_NAME = "next_routine_name"
    private const val KEY_NEXT_ROUTINE_COLOR = "next_routine_color"
    private const val KEY_TODAY_LABEL = "today_label"
    private const val KEY_ACCENT_ARGB = "accent_color_argb"

    private const val ICON_SIZE_MEDIUM_DP = 56
    private const val ICON_SIZE_COMPACT_DP = 48
    private const val DEFAULT_ACCENT = 0xFFD97757.toInt()
    private const val EMPTY_GRAY = 0xFF6B6B72.toInt()
    private const val BG_DARK = 0xFF15161A.toInt()
    private const val BG_MEDIUM_W_DP = 320
    private const val BG_MEDIUM_H_DP = 110
    private const val BG_COMPACT_DP = 160
    private const val BG_CORNER_DP = 24f

    fun render(context: Context, layoutResId: Int): RemoteViews {
        val views = RemoteViews(context.packageName, layoutResId)
        val workoutPrefs = context.getSharedPreferences(
            WorkoutService.PREFS_NAME, Context.MODE_PRIVATE
        )
        val homeWidgetPrefs = context.getSharedPreferences(
            HOME_WIDGET_PREFS, Context.MODE_PRIVATE
        )

        val startedAt = workoutPrefs.getLong(WorkoutService.KEY_STARTED_AT, 0L)
        val activeRoutineId = workoutPrefs.getString(
            WorkoutService.KEY_ROUTINE_ID, null
        )
        val activeRoutineName = workoutPrefs.getString(
            WorkoutService.KEY_ROUTINE_NAME, null
        )

        val isActive = !activeRoutineId.isNullOrEmpty() && startedAt > 0L
        val accent = readInt(homeWidgetPrefs, KEY_ACCENT_ARGB, DEFAULT_ACCENT)
        val activeRoutineColor = workoutPrefs.getInt(
            WorkoutService.KEY_ROUTINE_COLOR, 0
        ).let { if (it == 0) accent else it }

        val isCompact = layoutResId == R.layout.widget_compact
        val iconSizeDp = if (isCompact) ICON_SIZE_COMPACT_DP else ICON_SIZE_MEDIUM_DP

        val (bgW, bgH) = if (isCompact) {
            BG_COMPACT_DP to BG_COMPACT_DP
        } else {
            BG_MEDIUM_W_DP to BG_MEDIUM_H_DP
        }

        // Background colour tracks the routine that's currently relevant:
        // active routine when working out, planned routine when idle, app
        // accent otherwise. The bitmap is rebuilt only when state changes.
        val nextRoutineColorPref = readInt(
            homeWidgetPrefs, KEY_NEXT_ROUTINE_COLOR, accent
        )
        val idleTodayLabel = readString(homeWidgetPrefs, KEY_TODAY_LABEL, "")
        val idleRoutineName = readString(homeWidgetPrefs, KEY_NEXT_ROUTINE_NAME, "")
        val bgColor: Int = when {
            isActive -> activeRoutineColor
            idleTodayLabel.isNotEmpty() -> accent
            idleRoutineName.isNotEmpty() -> nextRoutineColorPref
            else -> accent
        }
        views.setImageViewBitmap(
            R.id.widget_bg,
            buildBackgroundBitmap(context, bgW, bgH, bgColor)
        )

        if (isActive) {
            views.setImageViewBitmap(
                R.id.widget_icon,
                buildIconBitmap(context, iconSizeDp, activeRoutineColor)
            )
            views.setTextViewText(
                R.id.widget_routine_name,
                activeRoutineName ?: context.getString(R.string.notif_title)
            )
            views.setViewVisibility(R.id.widget_idle_subtitle, View.GONE)
            val baseElapsed = SystemClock.elapsedRealtime() -
                (System.currentTimeMillis() - startedAt)
            views.setChronometer(R.id.widget_chronometer, baseElapsed, null, true)
            views.setViewVisibility(R.id.widget_chronometer, View.VISIBLE)
            views.setViewVisibility(R.id.widget_active_row, View.VISIBLE)
            views.setViewVisibility(R.id.widget_start_button, View.GONE)
        } else {
            views.setViewVisibility(R.id.widget_active_row, View.GONE)
            views.setViewVisibility(R.id.widget_chronometer, View.GONE)

            when {
                idleTodayLabel.isNotEmpty() -> {
                    views.setImageViewBitmap(
                        R.id.widget_icon,
                        buildIconBitmap(context, iconSizeDp, accent)
                    )
                    views.setTextViewText(R.id.widget_routine_name, idleTodayLabel)
                    views.setTextViewText(
                        R.id.widget_idle_subtitle,
                        context.getString(R.string.widget_rest_day)
                    )
                    views.setViewVisibility(R.id.widget_idle_subtitle, View.VISIBLE)
                    views.setViewVisibility(R.id.widget_start_button, View.GONE)
                }
                idleRoutineName.isNotEmpty() -> {
                    views.setImageViewBitmap(
                        R.id.widget_icon,
                        buildIconBitmap(context, iconSizeDp, nextRoutineColorPref)
                    )
                    views.setTextViewText(R.id.widget_routine_name, idleRoutineName)
                    views.setTextViewText(
                        R.id.widget_idle_subtitle,
                        context.getString(R.string.widget_today_workout)
                    )
                    views.setViewVisibility(R.id.widget_idle_subtitle, View.VISIBLE)
                    views.setViewVisibility(R.id.widget_start_button, View.VISIBLE)
                }
                else -> {
                    views.setImageViewBitmap(
                        R.id.widget_icon,
                        buildIconBitmap(context, iconSizeDp, EMPTY_GRAY)
                    )
                    views.setTextViewText(
                        R.id.widget_routine_name,
                        context.getString(R.string.widget_no_routine)
                    )
                    views.setTextViewText(
                        R.id.widget_idle_subtitle,
                        context.getString(R.string.widget_create)
                    )
                    views.setViewVisibility(R.id.widget_idle_subtitle, View.VISIBLE)
                    views.setViewVisibility(R.id.widget_start_button, View.GONE)
                }
            }
        }

        attachClickIntent(context, views)
        return views
    }

    private fun buildIconBitmap(
        context: Context,
        sizeDp: Int,
        baseColor: Int,
    ): Bitmap {
        val density = context.resources.displayMetrics.density
        val sizePx = (sizeDp * density).toInt().coerceAtLeast(1)
        val bitmap = Bitmap.createBitmap(sizePx, sizePx, Bitmap.Config.ARGB_8888)
        val canvas = Canvas(bitmap)

        val center = sizePx / 2f
        val radius = sizePx / 2f - (2 * density)

        val shadowPaint = Paint(Paint.ANTI_ALIAS_FLAG).apply {
            color = baseColor
            alpha = 70
            maskFilter = BlurMaskFilter(5f * density, BlurMaskFilter.Blur.NORMAL)
        }
        canvas.drawCircle(center, center + (2 * density), radius, shadowPaint)

        val light = adjustLightness(baseColor, 0.07f)
        val deep = adjustLightness(baseColor, -0.10f)
        val gradient = LinearGradient(
            0f, 0f, sizePx.toFloat(), sizePx.toFloat(),
            intArrayOf(light, baseColor, deep),
            floatArrayOf(0f, 0.5f, 1f),
            Shader.TileMode.CLAMP,
        )
        val circlePaint = Paint(Paint.ANTI_ALIAS_FLAG).apply { shader = gradient }
        canvas.drawCircle(center, center, radius, circlePaint)

        val dumbbell = ResourcesCompat.getDrawable(
            context.resources,
            R.drawable.ic_notif_dumbbell,
            null,
        )
        if (dumbbell != null) {
            val iconBox = (sizePx * 0.50f).toInt()
            val left = (sizePx - iconBox) / 2
            val top = (sizePx - iconBox) / 2
            dumbbell.mutate()
            dumbbell.setBounds(left, top, left + iconBox, top + iconBox)
            dumbbell.colorFilter = PorterDuffColorFilter(
                Color.WHITE, PorterDuff.Mode.SRC_IN
            )
            dumbbell.draw(canvas)
        }

        return bitmap
    }

    private fun buildBackgroundBitmap(
        context: Context,
        widthDp: Int,
        heightDp: Int,
        accentColor: Int,
    ): Bitmap {
        val density = context.resources.displayMetrics.density
        val w = (widthDp * density).toInt().coerceAtLeast(1)
        val h = (heightDp * density).toInt().coerceAtLeast(1)
        val bitmap = Bitmap.createBitmap(w, h, Bitmap.Config.ARGB_8888)
        val canvas = Canvas(bitmap)

        // Clip to rounded rect so corners are pre-rounded in the bitmap.
        val corner = BG_CORNER_DP * density
        val path = Path().apply {
            addRoundRect(
                RectF(0f, 0f, w.toFloat(), h.toFloat()),
                corner, corner,
                Path.Direction.CW,
            )
        }
        canvas.clipPath(path)

        // Base linear gradient: dark dominates the first half, easing into a
        // muted accent in the bottom-right corner so the dark background still
        // reads as the dominant tone.
        val accentDeep = adjustLightness(accentColor, -0.22f)
        val basePaint = Paint(Paint.ANTI_ALIAS_FLAG).apply {
            shader = LinearGradient(
                0f, 0f, w.toFloat(), h.toFloat(),
                intArrayOf(BG_DARK, BG_DARK, accentDeep),
                floatArrayOf(0f, 0.55f, 1f),
                Shader.TileMode.CLAMP,
            )
        }
        canvas.drawRect(0f, 0f, w.toFloat(), h.toFloat(), basePaint)

        // Subtle radial glow in the top-right corner so the accent still hints
        // through without overpowering the dark base.
        val accentLight = adjustLightness(accentColor, 0.08f)
        val glowCenterX = w * 0.88f
        val glowCenterY = h * 0.0f
        val glowRadius = (maxOf(w, h)) * 0.55f
        val glowPaint = Paint(Paint.ANTI_ALIAS_FLAG).apply {
            shader = RadialGradient(
                glowCenterX, glowCenterY, glowRadius,
                intArrayOf(
                    withAlpha(accentLight, 70),
                    withAlpha(accentLight, 0),
                ),
                floatArrayOf(0f, 1f),
                Shader.TileMode.CLAMP,
            )
        }
        canvas.drawRect(0f, 0f, w.toFloat(), h.toFloat(), glowPaint)

        return bitmap
    }

    private fun withAlpha(color: Int, alpha: Int): Int {
        return Color.argb(
            alpha.coerceIn(0, 255),
            Color.red(color),
            Color.green(color),
            Color.blue(color),
        )
    }

    private fun adjustLightness(color: Int, delta: Float): Int {
        val hsl = FloatArray(3)
        ColorUtils.colorToHSL(color, hsl)
        hsl[2] = (hsl[2] + delta).coerceIn(0f, 1f)
        return ColorUtils.HSLToColor(hsl)
    }

    private fun attachClickIntent(context: Context, views: RemoteViews) {
        val openIntent = Intent(context, MainActivity::class.java).apply {
            action = Intent.ACTION_MAIN
            addCategory(Intent.CATEGORY_LAUNCHER)
            flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP
        }
        val flags = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        } else {
            PendingIntent.FLAG_UPDATE_CURRENT
        }
        val pending = PendingIntent.getActivity(context, 0, openIntent, flags)
        views.setOnClickPendingIntent(R.id.widget_root, pending)
    }

    private fun readString(
        prefs: android.content.SharedPreferences,
        key: String,
        default: String
    ): String {
        return prefs.getString(FLUTTER_PREFIX + key, null)
            ?: prefs.getString(key, default)
            ?: default
    }

    private fun readInt(
        prefs: android.content.SharedPreferences,
        key: String,
        default: Int
    ): Int {
        val prefixed = FLUTTER_PREFIX + key
        if (prefs.contains(prefixed)) {
            return try {
                prefs.getInt(prefixed, default)
            } catch (_: ClassCastException) {
                try { prefs.getLong(prefixed, default.toLong()).toInt() }
                catch (_: ClassCastException) { default }
            }
        }
        if (prefs.contains(key)) {
            return try {
                prefs.getInt(key, default)
            } catch (_: ClassCastException) {
                try { prefs.getLong(key, default.toLong()).toInt() }
                catch (_: ClassCastException) { default }
            }
        }
        return default
    }
}
