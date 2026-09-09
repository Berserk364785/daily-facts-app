import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/fact.dart';

/// Получает исторические факты дня из Wikipedia REST API (feed/onthisday).
/// Бесплатно, без ключа. Документация:
/// https://ru.wikipedia.org/api/rest_v1/feed/onthisday/events/{mm}/{dd}
class FactsService {
  static const _cacheKey = 'cached_fact_v1';

  Future<DailyFact> getFactForToday({DateTime? forDate}) async {
    final date = forDate ?? DateTime.now();
    try {
      final fact = await _fetchFromWikipedia(date);
      await _cacheFact(fact);
      return fact;
    } catch (_) {
      // Нет сети или API недоступен — пробуем кэш, затем локальный запасной список
      final cached = await _readCache();
      if (cached != null && _isSameDay(cached.date, date)) {
        return cached;
      }
      return _localFallback(date);
    }
  }

  Future<DailyFact> _fetchFromWikipedia(DateTime date) async {
    final mm = date.month.toString().padLeft(2, '0');
    final dd = date.day.toString().padLeft(2, '0');
    final uri = Uri.parse(
      'https://ru.wikipedia.org/api/rest_v1/feed/onthisday/events/$mm/$dd',
    );

    final response = await http
        .get(uri, headers: {'Accept': 'application/json'})
        .timeout(const Duration(seconds: 10));

    if (response.statusCode != 200) {
      throw Exception('Wikipedia API вернул ${response.statusCode}');
    }

    final data = jsonDecode(utf8.decode(response.bodyBytes));
    final events = (data['events'] as List).cast<Map<String, dynamic>>();
    if (events.isEmpty) throw Exception('Пустой список событий');

    // Берём случайное событие, слегка отдавая предпочтение более "богатым"
    // (с картинкой), но не всегда — чтобы было интереснее.
    final withImages = events
        .where((e) => (e['pages'] as List?)?.isNotEmpty == true)
        .toList();
    final pool = withImages.isNotEmpty && Random().nextBool()
        ? withImages
        : events;
    final chosen = pool[Random().nextInt(pool.length)];

    final pages = (chosen['pages'] as List?)?.cast<Map<String, dynamic>>();
    final firstPage = (pages != null && pages.isNotEmpty) ? pages.first : null;
    final thumb = firstPage?['thumbnail']?['source'] as String?;
    final title = firstPage?['normalizedtitle'] as String? ??
        firstPage?['titles']?['normalized'] as String?;

    return DailyFact(
      year: chosen['year'] as int,
      text: (chosen['text'] as String).trim(),
      pageTitle: title,
      thumbnailUrl: thumb,
      date: date,
    );
  }

  Future<void> _cacheFact(DailyFact fact) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_cacheKey, jsonEncode(fact.toJson()));
  }

  Future<DailyFact?> _readCache() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_cacheKey);
    if (raw == null) return null;
    return DailyFact.fromJson(jsonDecode(raw));
  }

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  /// Небольшой офлайн-запас на случай отсутствия сети и пустого кэша,
  /// чтобы экран никогда не был пустым.
  DailyFact _localFallback(DateTime date) {
    const fallbacks = [
      'В этот день люди по всему миру отмечали значимые события — '
          'а конкретные архивы Википедии сейчас недоступны офлайн.',
      'История богата совпадениями: почти на любую дату приходится '
          'важное открытие, рождение или сражение.',
    ];
    return DailyFact(
      year: date.year,
      text: fallbacks[Random().nextInt(fallbacks.length)],
      date: date,
    );
  }
}
