import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tz_data;
import '../models/fact.dart';

/// Отвечает за пуш-уведомления: разовые и ежедневное утреннее напоминание
/// с фактом дня (появляется в т.ч. на экране блокировки — это штатное
/// поведение системных уведомлений на Android и iOS).
class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  final _plugin = FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  static const _channelId = 'daily_fact_channel';
  static const _channelName = 'Факт дня';
  static const _dailyNotificationId = 100;

  Future<void> init() async {
    if (_initialized) return;
    tz_data.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation(await _deviceTimeZoneName()));

    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosInit = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    await _plugin.initialize(
      const InitializationSettings(android: androidInit, iOS: iosInit),
    );

    // Показывать уведомление поверх экрана блокировки максимально заметно
    const androidChannel = AndroidNotificationChannel(
      _channelId,
      _channelName,
      description: 'Ежедневный исторический факт по утрам',
      importance: Importance.high,
      visibility: NotificationVisibility.public,
    );
    await _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(androidChannel);

    _initialized = true;
  }

  Future<bool> requestPermissions() async {
    final androidGranted = await _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
    final iosGranted = await _plugin
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(alert: true, badge: true, sound: true);
    return (androidGranted ?? true) && (iosGranted ?? true);
  }

  /// Планирует ежедневное уведомление на заданное время (по умолчанию 8:00),
  /// которое будет повторяться каждый день.
  Future<void> scheduleDaily({
    required DailyFact fact,
    int hour = 8,
    int minute = 0,
  }) async {
    await init();
    final scheduled = _nextInstanceOf(hour, minute);

    await _plugin.zonedSchedule(
      _dailyNotificationId,
      '📅 ${_formatDate(fact.date)}',
      fact.text,
      scheduled,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          _channelId,
          _channelName,
          importance: Importance.high,
          priority: Priority.high,
          visibility: NotificationVisibility.public,
          styleInformation: BigTextStyleInformation(''),
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  Future<void> showNow(DailyFact fact) async {
    await init();
    await _plugin.show(
      _dailyNotificationId + 1,
      '📅 ${_formatDate(fact.date)}',
      fact.text,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          _channelId,
          _channelName,
          importance: Importance.high,
          priority: Priority.high,
          visibility: NotificationVisibility.public,
          styleInformation: BigTextStyleInformation(''),
        ),
        iOS: DarwinNotificationDetails(),
      ),
    );
  }

  tz.TZDateTime _nextInstanceOf(int hour, int minute) {
    final now = tz.TZDateTime.now(tz.local);
    var scheduled =
        tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);
    if (scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }
    return scheduled;
  }

  String _formatDate(DateTime d) {
    const months = [
      'января', 'февраля', 'марта', 'апреля', 'мая', 'июня',
      'июля', 'августа', 'сентября', 'октября', 'ноября', 'декабря',
    ];
    return '${d.day} ${months[d.month - 1]}';
  }

  Future<String> _deviceTimeZoneName() async {
    // Простой вариант без доп. пакетов: используем смещение UTC.
    // Для точных названий часовых поясов можно добавить flutter_timezone.
    return 'UTC';
  }
}
