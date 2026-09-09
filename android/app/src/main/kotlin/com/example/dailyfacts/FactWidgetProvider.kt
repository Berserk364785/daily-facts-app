package com.example.dailyfacts

import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetPlugin

/**
 * Виджет главного экрана Android. Читает данные, которые Flutter-код
 * записывает через HomeWidget.saveWidgetData(...) в services/widget_service.dart.
 *
 * Примечание: отдельного API "Lock Screen Widget" в Android нет начиная
 * с версии 5.0 — виджеты живут только на главном экране. Пользователь может
 * добавить этот виджет на главный экран долгим тапом → "Виджеты".
 */
class FactWidgetProvider : AppWidgetProvider() {
    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray
    ) {
        val prefs = HomeWidgetPlugin.getData(context)
        val date = prefs.getString("widget_date", "—")
        val year = prefs.getString("widget_year", "")
        val fact = prefs.getString("widget_fact", "Откройте приложение, чтобы загрузить факт дня")

        for (widgetId in appWidgetIds) {
            val views = RemoteViews(context.packageName, R.layout.fact_widget)
            views.setTextViewText(R.id.widget_date, date)
            views.setTextViewText(R.id.widget_year, year)
            views.setTextViewText(R.id.widget_fact, fact)
            appWidgetManager.updateAppWidget(widgetId, views)
        }
    }
}
