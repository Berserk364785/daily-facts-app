import 'package:workmanager/workmanager.dart';
import 'facts_service.dart';
import 'notification_service.dart';
import 'widget_service.dart';

const morningTaskName = 'refreshDailyFact';

/// Точка входа для фоновых задач. Должна быть top-level функцией
/// (не методом класса) — таково требование пакета workmanager.
@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    if (task == morningTaskName) {
      final fact = await FactsService().getFactForToday();
      await WidgetService.pushFact(fact);
      await NotificationService.instance.showNow(fact);
    }
    return Future.value(true);
  });
}

Future<void> registerMorningTask() async {
  await Workmanager().initialize(callbackDispatcher, isInDebugMode: false);
  // Периодическая задача — минимальный интервал у workmanager 15 минут,
  // поэтому мы держим лёгкую фоновую проверку и полагаемся на
  // NotificationService.scheduleDaily для точного времени 8:00.
  await Workmanager().registerPeriodicTask(
    'daily-fact-refresh',
    morningTaskName,
    frequency: const Duration(hours: 6),
    constraints: Constraints(networkType: NetworkType.connected),
  );
}
