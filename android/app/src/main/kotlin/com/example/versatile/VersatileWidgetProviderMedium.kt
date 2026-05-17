package com.example.versatile

import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context

class VersatileWidgetProviderMedium : AppWidgetProvider() {

    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray
    ) {
        for (id in appWidgetIds) {
            val views = WidgetRenderer.render(context, R.layout.widget_medium)
            appWidgetManager.updateAppWidget(id, views)
        }
    }
}
