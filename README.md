# Факт дня — Flutter приложение

Каждое утро показывает исторический факт, связанный с текущей датой
(источник — Wikipedia REST API, раздел "В этот день").

## Что уже реализовано

- 🎨 Тёмная "редакционная" тема (амбер + пергамент), анимации появления карточки
- 📰 Факт дня из `ru.wikipedia.org/api/rest_v1/feed/onthisday/events/{mm}/{dd}`, с офлайн-кэшем
- 🔔 Push-уведомление каждое утро в 8:00 с датой и фактом (`flutter_local_notifications`)
- ⏱ Фоновое обновление факта каждые 6 часов (`workmanager`), чтобы уведомление и виджет были свежими
- 🧩 Нативный виджет главного экрана Android (Kotlin `AppWidgetProvider`), синхронизируется через `home_widget`

## ⚠️ Важное уточнение про "экран блокировки"

Начиная с Android 5.0 у системы **нет API для виджетов на экране блокировки** —
Google убрал эту возможность. Реалистичные варианты того, что вы просили:

1. **Уведомление на экране блокировки** — уже сделано. Ежедневный пуш в 8:00
   с датой и фактом отображается прямо на заблокированном экране
   (`NotificationVisibility.public` в `notification_service.dart`).
2. **Виджет главного экрана** — тоже сделан (см. `android/.../FactWidgetProvider.kt`).
   Пользователь долгим тапом по рабочему столу добавляет виджет — он не на
   лок-скрине, но всегда на виду.
3. **iOS Lock Screen Widget** (только iOS 16+) — технически возможен, но
   требует отдельного нативного расширения на **Swift/WidgetKit**, которое
   нельзя написать на чистом Dart/Flutter. Если нужен именно iOS-лок-скрин —
   скажите, я добавлю каркас WidgetKit-расширения отдельным шагом.

Если два первых пункта решают задачу — ничего дополнительно делать не нужно.

## Настройка проекта локально

Так как это готовая структура файлов (а не собранный проект), нужно:

```bash
flutter create --org com.example --project-name daily_facts_app .
# ^ это создаст недостающие платформенные файлы (ios/, полный android/),
#   не перезаписывая уже добавленные lib/ и кастомные android/ файлы
flutter pub get
```

Затем вручную:

1. Откройте `android/app/src/main/AndroidManifest.xml` и добавьте блоки
   из `android/MANIFEST_ADDITIONS.xml` (разрешения + регистрация виджета).
2. Проверьте, что `applicationId` в `android/app/build.gradle` совпадает с
   пакетом `com.example.dailyfacts` (или поменяйте путь папки Kotlin-файла).
3. Замените иконку `@mipmap/ic_launcher`, если нужен свой логотип.

## Известная особенность вашего окружения

По прошлому опыту с FitPulse на Windows/VS Code: сборка Flutter/Android
упиралась в конфликты версий JDK/Gradle/AGP и блокировку загрузки Gradle
Distribution в России. Рекомендация: собирать через **Codemagic** или
**GitHub Actions** (облачная сборка), либо через Android Studio с уже
настроенным JDK 17 — это обходит локальные проблемы с сетью и тулчейном.

## Структура

```
lib/
  models/fact.dart              — модель факта
  services/facts_service.dart   — загрузка факта + офлайн-кэш
  services/notification_service.dart — пуши, в т.ч. ежедневные
  services/widget_service.dart  — синхронизация с нативным виджетом
  services/background_tasks.dart— фоновая задача (workmanager)
  theme/app_theme.dart          — визуальная тема
  widgets/fact_card.dart        — карточка факта с анимацией
  screens/home_screen.dart      — главный экран
  main.dart                     — точка входа

android/app/src/main/kotlin/.../FactWidgetProvider.kt — нативный виджет
android/app/src/main/res/layout/fact_widget.xml        — разметка виджета
android/app/src/main/res/xml/fact_widget_info.xml      — метаданные виджета
android/MANIFEST_ADDITIONS.xml                          — что добавить в манифест
```
