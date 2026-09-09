import 'package:flutter/material.dart';
import '../models/fact.dart';
import '../services/facts_service.dart';
import '../services/notification_service.dart';
import '../services/widget_service.dart';
import '../theme/app_theme.dart';
import '../widgets/fact_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _factsService = FactsService();
  DailyFact? _fact;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    await NotificationService.instance.init();
    await NotificationService.instance.requestPermissions();
    await _load();
    if (_fact != null) {
      await NotificationService.instance.scheduleDaily(fact: _fact!, hour: 8);
      await WidgetService.pushFact(_fact!);
    }
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final fact = await _factsService.getFactForToday();
      setState(() {
        _fact = fact;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Не удалось загрузить факт. Проверьте подключение.';
        _loading = false;
      });
    }
  }

  String _weekday(DateTime d) {
    const days = [
      'понедельник', 'вторник', 'среда', 'четверг',
      'пятница', 'суббота', 'воскресенье',
    ];
    return days[d.weekday - 1];
  }

  String _fullDate(DateTime d) {
    const months = [
      'января', 'февраля', 'марта', 'апреля', 'мая', 'июня',
      'июля', 'августа', 'сентября', 'октября', 'ноября', 'декабря',
    ];
    return '${d.day} ${months[d.month - 1]} ${d.year}';
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          color: AppTheme.amber,
          backgroundColor: AppTheme.ink,
          onRefresh: _load,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 40),
            children: [
              Text(
                _weekday(now).toUpperCase(),
                style: Theme.of(context).textTheme.labelLarge,
              ),
              const SizedBox(height: 6),
              Text(
                _fullDate(now),
                style: Theme.of(context).textTheme.displayLarge,
              ),
              const SizedBox(height: 28),
              if (_loading)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 60),
                  child: Center(
                    child: CircularProgressIndicator(color: AppTheme.amber),
                  ),
                )
              else if (_error != null)
                _ErrorState(message: _error!, onRetry: _load)
              else if (_fact != null)
                FactCard(fact: _fact!),
              const SizedBox(height: 24),
              Center(
                child: TextButton.icon(
                  onPressed: _loading ? null : _load,
                  icon: const Icon(Icons.refresh_rounded, color: AppTheme.amber),
                  label: const Text(
                    'Другой факт',
                    style: TextStyle(color: AppTheme.amber),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _ErrorState({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 40),
      child: Column(
        children: [
          const Icon(Icons.cloud_off_rounded, color: AppTheme.muted, size: 40),
          const SizedBox(height: 12),
          Text(message,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: 12),
          OutlinedButton(onPressed: onRetry, child: const Text('Повторить')),
        ],
      ),
    );
  }
}
