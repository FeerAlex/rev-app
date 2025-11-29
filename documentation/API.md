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

#### CalculateTimeToCurrencyGoal

Расчет времени до достижения цели по валюте (покупка сертификата и украшений).

```dart
class CalculateTimeToCurrencyGoal {
  const CalculateTimeToCurrencyGoal();
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
2. Добавляется стоимость сертификата (если не куплен и `hasCertificate = true`)
3. Вычитается текущая валюта
4. Рассчитывается доход в день:
   - Валюта за заказ (только если `hasOrder = true`) - среднее арифметическое валюты из `FactionTemplate.orderRewards` для данной фракции
   - Валюта за работу (только если `hasWork = true` и `workCurrency != null`) - значение из `faction.workCurrency`
5. Вычисляется время: `(нужная валюта) / (валюта в день)`

**Примечание:** 
- Все стоимости хранятся как константы в `AppSettings.factions`, умножение не используется - применяются готовые суммы
- Расчет учитывает только те активности, которые указаны во фракции (`hasOrder`, `hasWork`)
- Если `hasOrder = false` и `hasWork = false`, возвращается `null` (расчет невозможен)

#### CalculateTimeToReputationGoal

Расчет времени до достижения целевого уровня отношения.

```dart
class CalculateTimeToReputationGoal {
  const CalculateTimeToReputationGoal();
  Duration? call(Faction faction);
}
```

**Параметры:**
- `faction` - фракция для расчета

**Возвращает:**
- `Duration` - время до достижения целевого уровня
- `null` - если расчет невозможен (нет дохода опыта в день)
- `Duration.zero` - если цель уже достигнута

**Логика расчета:**
1. Вычисляется общий опыт на основе `currentReputationLevel` и `currentLevelExp` через `ReputationHelper.getTotalExp`
2. Вычисляется требуемый опыт для достижения `targetReputationLevel` через `ReputationHelper.getTotalExpForTargetLevel`
3. Рассчитывается опыт в день:
   - Опыт за заказ (только если `hasOrder = true`) - среднее арифметическое опыта из `FactionTemplate.orderRewards` для данной фракции
4. Вычисляется время: `(нужный опыт) / (опыт в день)`

**Примечание:** 
- Опыт дается только за заказы, не за работу
- Расчет учитывает только фракции с заказами (`hasOrder = true`)

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
  final ReputationLevel currentReputationLevel; // Текущий уровень отношения (по умолчанию indifference)
  final int currentLevelExp; // Опыт на текущем уровне (от 0 до требуемого для уровня, по умолчанию 0)
  final ReputationLevel targetReputationLevel; // Целевой уровень отношения (по умолчанию maximum)
  
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
  final int currencyPerWork = 100;  // Валюта за выполнение работы
  final int certificatePrice = 7888;
}
```

**Использование:**
```dart
AppSettings.factions.decorationPriceRespect
AppSettings.factions.certificatePrice
```

**Примечание:** 
- Все стоимости хранятся как готовые суммы (не используется умножение). Структура расширяема для будущих функций (карта, брактеат).
- `currencyPerWork` больше не используется для расчета времени до цели - используется значение из `faction.workCurrency`

### FactionTemplate

Шаблон фракции для статического списка всех доступных фракций игры.

```dart
class FactionTemplate {
  final String name;
  final bool hasOrder;
  final bool hasWork;
  final bool hasCertificate;
  final List<OrderReward>? orderRewards; // Массив наград за заказы (валюта и опыт) (только для фракций с заказами)
  
  const FactionTemplate({
    required this.name,
    required this.hasOrder,
    required this.hasWork,
    required this.hasCertificate,
    this.orderRewards,
  });
}
```

**Использование:**
```dart
// Получить все фракции
FactionsList.allFactions

// Получить шаблон фракции по имени
FactionsList.getTemplateByName('Жители Сулана')

// Создать фракцию из шаблона
FactionsList.createFactionFromTemplate(template)
```

**Примечание:** 
- Каждая фракция в статическом списке имеет предустановленные значения `hasOrder`, `hasWork` и `hasCertificate`, которые определяют, какие активности доступны для этой фракции
- Для фракций с заказами (`hasOrder = true`) в поле `orderRewards` хранится массив наград за заказы (валюта и опыт), которые могут варьироваться в разные дни. При расчете времени до цели используется среднее арифметическое валюты и опыта отдельно

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

// Скрытие фракции
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

### ReputationLevel

Enum для уровней отношения к фракции.

```dart
enum ReputationLevel {
  indifference, // Равнодушие
  friendliness, // Дружелюбие
  respect, // Уважение
  honor, // Почтение
  adoration, // Преклонение
  deification, // Обожествление
  maximum, // Максимальный
}
```

**Методы:**
- `displayName` - получить название уровня на русском языке
- `value` - получить числовое значение уровня (для хранения в БД)
- `fromValue(int value)` - создать ReputationLevel из числового значения

### OrderReward

Класс для хранения награды за выполнение заказа (валюта и опыт).

```dart
class OrderReward {
  final int currency;
  final int exp;
  
  const OrderReward({
    required this.currency,
    required this.exp,
  });
  
  static int averageCurrency(List<OrderReward> rewards);
  static int averageExp(List<OrderReward> rewards);
}
```

**Методы:**
- `averageCurrency` - вычислить среднее арифметическое валюты из списка наград
- `averageExp` - вычислить среднее арифметическое опыта из списка наград

### ReputationHelper

Утилита для работы с уровнями отношения и опытом.

```dart
class ReputationHelper {
  static ReputationLevel getCurrentReputationLevel(int totalExp, String factionName);
  static int getExpInCurrentLevel(int totalExp, ReputationLevel currentLevel, String factionName);
  static int getRequiredExpForCurrentLevel(ReputationLevel currentLevel, String factionName);
  static int getTotalExpForTargetLevel(ReputationLevel targetLevel, String factionName);
  static int getTotalExp(ReputationLevel currentLevel, int currentLevelExp, String factionName);
  static int getNeededExp(ReputationLevel currentLevel, int currentLevelExp, ReputationLevel targetLevel, String factionName);
}
```

**Методы:**
- `getCurrentReputationLevel` - вычислить текущий уровень на основе общего опыта (для обратной совместимости)
- `getExpInCurrentLevel` - получить опыт в текущем уровне (от 0 до требуемого для уровня)
- `getRequiredExpForCurrentLevel` - получить требуемый опыт для текущего уровня
- `getTotalExpForTargetLevel` - получить общий опыт, необходимый для достижения целевого уровня
- `getTotalExp` - вычислить общий опыт на основе текущего уровня и опыта на уровне
- `getNeededExp` - вычислить, сколько опыта нужно для достижения целевого уровня

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

**Описание:**
- Инициализирует SQLite базу данных версии 11
- Создает таблицу `factions` при первом запуске через `FactionDao.createTable()`
- Создает экземпляры репозиториев для работы с данными
- Миграции базы данных не используются (приложение на стадии разработки)

