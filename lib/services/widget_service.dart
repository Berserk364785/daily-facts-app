import 'package:home_widget/home_widget.dart';
import '../models/fact.dart';

/// Передаёт факт дня в нативный виджет главного экрана (Android App Widget /
/// iOS WidgetKit). Важно: начиная с Android 5 отдельных "виджетов экрана
/// блокировки" в системе не существует — только виджеты главного экрана.
/// На iOS 16+ полноценный Lock Screen widget возможен, но требует нативного
/// расширения на Swift (см. README, раздел "iOS Lock Screen").
class WidgetService {
  static const _androidWidgetName = 'FactWidgetProvider';
  static const _iOSWidgetName = 'DailyFactWidget';

  static Future<void> pushFact(DailyFact fact) async {
    await HomeWidget.saveWidgetData<String>('widget_date', _formatDate(fact.date));
    await HomeWidget.saveWidgetData<String>('widget_fact', fact.text);
    await HomeWidget.saveWidgetData<String>('widget_year', fact.yearLabel);

    await HomeWidget.updateWidget(
      androidName: _androidWidgetName,
      iOSName: _iOSWidgetName,
    );
  }

  static String _formatDate(DateTime d) {
    const months = [
      'января', 'февраля', 'марта', 'апреля', 'мая', 'июня',
      'июля', 'августа', 'сентября', 'октября', 'ноября', 'декабря',
    ];
    return '${d.day} ${months[d.month - 1]}';
  }
}
