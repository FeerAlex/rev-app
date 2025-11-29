# API Документация

## Domain Layer API

### Repositories

#### FactionRepository

Интерфейс для работы с фракциями.

```dart
abstract class FactionRepository {
  Future<List<Faction>> getAllFactions();
  Future<Faction?> getFactionById(int id);
  Future<int> addFaction(Faction faction);
  Future<void> updateFaction(Faction faction);
  Future<void> deleteFaction(int id);
  Future<void> resetDailyFlags();
  Future<void> reorderFactions(List<int> factionIds);
}
```

**Методы:**

- `getAllFactions()` - возвращает список видимых фракций (`isVisible = true`), отсортированный по полю `displayOrder`
- `getAllFactionsIncludingHidden()` - возвращает все фракции, включая скрытые
- `getHiddenFactions()` - возвращает только скрытые фракции (`isVisible = false`)
- `getFactionById(int id)` - возвращает фракцию по ID или null
- `addFaction(Faction faction)` - добавляет новую фракцию, возвращает ID
- `updateFaction(Faction faction)` - обновляет существующую фракцию
- `deleteFaction(int id)` - скрывает фракцию (устанавливает `isVisible = false`)
- `resetDailyFlags()` - сбрасывает отметки заказов для всех фракций
- `reorderFactions(List<int> factionIds)` - изменяет порядок фракций согласно переданному списку ID

### Use Cases

#### GetAllFactions

Получение всех фракций.

```dart
class GetAllFactions {
  Future<List<Faction>> call();
}
```

#### AddFaction

Добавление новой фракции.

```dart
class AddFaction {
  Future<int> call(Faction faction);
}
```

**Параметры:**
- `faction` - фракция для добавления (id должен быть null)

**Возвращает:** ID созданной фракции

#### UpdateFaction

Обновление существующей фракции.

```dart
class UpdateFaction {
  Future<void> call(Faction faction);
}
```

**Параметры:**
- `faction` - фракция с обновленными данными (id обязателен)

**Описание:**
Обновляет фракцию в базе данных. В BLoC реализовано с оптимистичным обновлением UI - изменения отображаются мгновенно, сохранение в БД происходит в фоне. При ошибке состояние восстанавливается из БД.

#### DeleteFaction

Скрытие фракции (устанавливает `isVisible = false`).

```dart
class DeleteFaction {
  Future<void> call(int id);
}
```

**Параметры:**
- `id` - ID фракции для скрытия

**Описание:**
Фракция не удаляется из базы данных, а только скрывается из списка. Её можно снова показать через `ShowFaction`.

#### ShowFaction

Показ скрытой фракции (устанавливает `isVisible = true`).

```dart
class ShowFaction {
  Future<void> call(Faction faction);
}
```

**Параметры:**
- `faction` - фракция для показа

#### InitializeFactions

Инициализация всех фракций из статического списка.

```dart
class InitializeFactions {
  Future<void> call();
}
```

**Описание:**
Создает все 13 фракций из статического списка в базе данных, если их еще нет. Все фракции создаются с `isVisible = false`. Вызывается при первом запуске приложения.

#### CalculateTimeToGoal

Расчет времени до достижения цели (покупка сертификата).

```dart
class CalculateTimeToGoal {
  const CalculateTimeToGoal();
  Duration? call(Faction faction);
}
```

**Параметры:**
- `faction` - фракция для расчета

**Возвращает:**
- `Duration` - время до достижения цели
- `null` - если расчет невозможен (нет дохода в день)
- `Duration.zero` - если цель уже достигнута

**Логика расчета:**
1. Рассчитывается общая стоимость всех некупленных украшений и улучшений (используются константы из `AppSettings.factions`)
2. Добавляется стоимость сертификата (если не куплен)
3. Вычитается текущая валюта
4. Рассчитывается доход в день (заказы + работа)
5. Вычисляется время: `(нужная валюта) / (валюта в день)`

**Примечание:** Все стоимости хранятся как константы в `AppSettings.factions`, умножение не используется - применяются готовые суммы.

#### ResetDailyFlags

Сброс ежедневных отметок.

```dart
class ResetDailyFlags {
  Future<void> call();
}
```

Сбрасывает отметки `orderCompleted` для всех фракций.

#### ReorderFactions

Изменение порядка фракций.

```dart
class ReorderFactions {
  Future<void> call(List<int> factionIds);
}
```

**Параметры:**
- `factionIds` - список ID фракций в новом порядке

**Описание:**
Обновляет поле `displayOrder` для каждой фракции согласно её позиции в переданном списке. Используется для сохранения порядка после drag-and-drop в UI. Реализовано с оптимистичным обновлением UI - порядок обновляется мгновенно, сохранение в БД происходит в фоне.

## Entities

### Faction

```dart
class Faction {
  final int? id;
  final String name;
  final int currency;
  final bool hasOrder;
  final bool orderCompleted;
  final int? workCurrency;
  final bool hasCertificate;
  final bool certificatePurchased;
  final bool decorationRespectPurchased;
  final bool decorationRespectUpgraded;
  final bool decorationHonorPurchased;
  final bool decorationHonorUpgraded;
  final bool decorationAdorationPurchased;
  final bool decorationAdorationUpgraded;
  final int displayOrder; // Порядок отображения (по умолчанию 0)
  final bool isVisible; // Видимость фракции в списке (по умолчанию true)
  
  Faction copyWith({...});
}
```

### AppSettings

Константы настроек приложения, организованные по функциональности.

```dart
class AppSettings {
  static const FactionsSettings factions = FactionsSettings._();
  // TODO: map, bracket для будущих функций
}

class FactionsSettings {
  const FactionsSettings._();
  
  final int decorationUpgradeCostRespect = 5364;  // 3 * 1788
  final int decorationUpgradeCostHonor = 7152;  // 4 * 1788
  final int decorationUpgradeCostAdoration = 10728;  // 6 * 1788
  final int decorationPriceRespect = 7888;
  final int decorationPriceHonor = 9888;
  final int decorationPriceAdoration = 15888;
  final int currencyPerOrder = 100;
  final int certificatePrice = 7888;
}
```

**Использование:**
```dart
AppSettings.factions.decorationPriceRespect
AppSettings.factions.currencyPerOrder
```

**Примечание:** Все стоимости хранятся как готовые суммы (не используется умножение). Структура расширяема для будущих функций (карта, брактеат).

## Presentation Layer API

### BLoC Events

#### FactionBloc Events

```dart
// Загрузка всех фракций
class LoadFactions extends FactionEvent;

// Добавление фракции
class AddFactionEvent extends FactionEvent {
  final Faction faction;
}

// Обновление фракции
class UpdateFactionEvent extends FactionEvent {
  final Faction faction;
}

// Удаление фракции
class DeleteFactionEvent extends FactionEvent {
  final int id;
}

// Сброс ежедневных отметок
class ResetDailyFlagsEvent extends FactionEvent;

// Изменение порядка фракций
class ReorderFactionsEvent extends FactionEvent {
  final List<int> factionIds;
}
```

### BLoC States

#### FactionBloc States

```dart
// Начальное состояние
class FactionInitial extends FactionState;

// Загрузка
class FactionLoading extends FactionState;

// Загружено
class FactionLoaded extends FactionState {
  final List<Faction> factions;
}

// Ошибка
class FactionError extends FactionState {
  final String message;
}
```

## Utils API

### TimeFormatter

```dart
class TimeFormatter {
  static String formatDuration(Duration duration);
}
```

Форматирует Duration в компактный формат с сокращениями.

**Пример:**
```dart
TimeFormatter.formatDuration(Duration(days: 2, hours: 5, minutes: 30));
// "2 д 5 ч 30 м"
```

**Формат:** Использует сокращения "д" (дни), "ч" (часы), "м" (минуты) вместо полных слов для компактности.

### AppTheme

```dart
class AppTheme {
  static const Color darkBackground;
  static const Color darkerBackground;
  static const Color cardBackground;
  static const Color textPrimary;
  static const Color textSecondary;
  static const Color accentOrange;
  static const Color accentBlue;
  
  static ThemeData get darkTheme;
}
```

Предоставляет темную тему приложения в стиле игры Revelation Online.

**Основные цвета:**
- `darkBackground`: `#1A1A1A`
- `darkerBackground`: `#0F0F0F`
- `cardBackground`: `#2A2A2A`
- `accentOrange`: `#FF6B35`
- `accentBlue`: `#4A90E2`

**Методы:**
- `darkTheme` - геттер для получения полной темы Material

### DailyResetHelper

```dart
class DailyResetHelper {
  static Future<void> checkAndReset();
}
```

Проверяет и сбрасывает ежедневные отметки при необходимости. Должен вызываться при запуске приложения.

## ServiceLocator

```dart
class ServiceLocator {
  static final ServiceLocator _instance = ServiceLocator._internal();
  factory ServiceLocator() => _instance;
  
  Future<void> init();
  Database get database;
  FactionRepository get factionRepository;
}
```

**Использование:**
```dart
// Инициализация (в main.dart)
await ServiceLocator().init();

// Получение репозитория
final factionRepo = ServiceLocator().factionRepository;
```

