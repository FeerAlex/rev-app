# API Документация

## Domain Layer API

### Repositories

#### FactionRepository

Интерфейс для работы с фракциями.

```dart
abstract class FactionRepository {
  Future<List<Faction>> getAllFactions(); // Только видимые
  Future<List<Faction>> getAllFactionsIncludingHidden(); // Все, включая скрытые
  Future<List<Faction>> getHiddenFactions(); // Только скрытые
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
- `getAllFactionsIncludingHidden()` - возвращает все фракции, включая скрытые, отсортированные по полю `displayOrder`
- `getHiddenFactions()` - возвращает только скрытые фракции (`isVisible = false`), отсортированные по полю `displayOrder`
- `getFactionById(int id)` - возвращает фракцию по ID или null
- `addFaction(Faction faction)` - добавляет новую фракцию, возвращает ID
- `updateFaction(Faction faction)` - обновляет существующую фракцию
- `deleteFaction(int id)` - скрывает фракцию (устанавливает `isVisible = false`)
- `resetDailyFlags()` - сбрасывает отметки `orderCompleted` и `workCompleted` для всех фракций
- `reorderFactions(List<int> factionIds)` - изменяет порядок фракций согласно переданному списку ID

#### DateTimeProvider

Интерфейс для работы с датой и временем в московском часовом поясе. Используется для абстракции работы с часовыми поясами из Domain layer.

```dart
abstract class DateTimeProvider {
  DateTime getNowInMoscow();
  DateTime getTodayInMoscow();
  DateTime getStartOfDayInMoscow(DateTime dateTime);
  DateTime toUtc(DateTime dateTime);
}
```

**Методы:**

- `getNowInMoscow()` - возвращает текущее время в московском часовом поясе
- `getTodayInMoscow()` - возвращает начало текущего дня в московском часовом поясе
- `getStartOfDayInMoscow(DateTime dateTime)` - преобразует DateTime в московское время и возвращает начало дня
- `toUtc(DateTime dateTime)` - преобразует DateTime в UTC

**Использование:**
Используется в `DailyResetHelper` для определения необходимости ежедневного сброса отметок. Реализация находится в Data layer (`DateTimeProviderImpl`) и использует библиотеку `timezone` для работы с часовыми поясами.

#### FileExporter

Интерфейс для экспорта файлов. Используется для экспорта базы данных.

```dart
abstract class FileExporter {
  Future<bool> exportFile(String filePath);
}
```

**Методы:**

- `exportFile(String filePath)` - экспортирует файл по указанному пути. Возвращает `true`, если экспорт успешен, `false` в противном случае.

**Использование:**
Используется в `ExportDatabase` use case для экспорта базы данных. Реализация находится в Data layer (`FileExporterImpl`) и использует библиотеку `share_plus` для экспорта файла.

#### FileImporter

Интерфейс для импорта файлов. Используется для импорта базы данных.

```dart
abstract class FileImporter {
  Future<String?> importFile();
}
```

**Методы:**

- `importFile()` - импортирует файл. Возвращает путь к выбранному файлу или `null`, если пользователь отменил выбор.

**Использование:**
Используется в `ImportDatabase` use case для импорта базы данных. Реализация находится в Data layer (`FileImporterImpl`) и использует библиотеку `file_picker` для выбора файла.

#### DatabasePathProvider

Интерфейс для получения пути к базе данных и переинициализации БД после импорта.

```dart
abstract class DatabasePathProvider {
  Future<String> getDatabasePath();
  Future<void> reinitializeDatabase(String importedFilePath);
}
```

**Методы:**

- `getDatabasePath()` - возвращает путь к файлу базы данных
- `reinitializeDatabase(String importedFilePath)` - переинициализирует базу данных с новым файлом. Валидирует импортируемый файл (проверяет, что это валидная SQLite БД с таблицей `factions`), закрывает текущее соединение, копирует импортированный файл на место текущей БД и переоткрывает соединение.

**Использование:**
Используется в `ExportDatabase` и `ImportDatabase` use cases. Реализация находится в Data layer (`DatabasePathProviderImpl`).

#### DatabaseInitializer

Интерфейс для инициализации базы данных (создание таблиц). Используется для абстракции создания таблиц из Domain layer, что позволяет Presentation layer не зависеть от Data layer datasources.

```dart
abstract class DatabaseInitializer {
  Future<void> initializeDatabase(Object db);
}
```

**Методы:**

- `initializeDatabase(Object db)` - инициализирует базу данных, создавая необходимые таблицы. Параметр `db` должен быть экземпляром `Database` из sqflite.

**Использование:**
Используется в `ServiceLocator` для инициализации базы данных при первом запуске и при переинициализации после импорта. Реализация находится в Data layer (`DatabaseInitializerImpl`) и использует `FactionDao.createTable()` для создания таблиц. Это позволяет Presentation layer не зависеть напрямую от Data layer datasources, что соответствует принципам Clean Architecture.

#### QuestionRepository

Интерфейс для работы с вопросами "Клуба знатоков".

```dart
abstract class QuestionRepository {
  Future<List<Question>> getAllQuestions();
  Future<List<Question>> searchQuestions(String query);
}
```

**Методы:**

- `getAllQuestions()` - возвращает список всех вопросов из источника данных
- `searchQuestions(String query)` - выполняет поиск вопросов по запросу. Поиск выполняется одновременно по тексту вопроса и ответа, без учета регистра. Возвращает список вопросов, содержащих запрос в тексте вопроса или ответа

**Использование:**
Используется в use cases `GetAllQuestions` и `SearchQuestions` для работы с вопросами. Реализация находится в Data layer (`QuestionRepositoryImpl`) и использует `QuestionsData` для загрузки данных из JSON файла. Вопросы кэшируются в памяти для быстрого поиска.

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

#### GetHiddenFactions

Получение списка скрытых фракций.

```dart
class GetHiddenFactions {
  Future<List<Faction>> call();
}
```

**Возвращает:** Список скрытых фракций (`isVisible = false`), отсортированный по полю `displayOrder`

**Описание:**
Используется для отображения списка скрытых фракций в диалоге выбора при добавлении новой фракции.

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
  final AppSettingsRepository _settingsRepository;
  final FactionTemplateRepository _templateRepository;
  
  CalculateTimeToCurrencyGoal(
    this._settingsRepository,
    this._templateRepository,
  );
  
  Duration? call(Faction faction);
}
```

**Параметры:**
- `faction` - фракция для расчета

**Возвращает:**
- `Duration` - время до достижения цели
- `null` - если расчет невозможен (нет дохода в день или `wantsCertificate = false`)
- `Duration.zero` - если цель уже достигнута

**Логика расчета:**
1. Если `wantsCertificate = false`, возвращается `null` (цель не установлена)
2. Рассчитывается общая стоимость всех некупленных украшений и улучшений (используются константы из `AppSettings.factions`)
3. Добавляется стоимость сертификата (только если не куплен и `wantsCertificate = true`)
4. Вычитается текущая валюта
5. Рассчитывается доход в день:
   - Валюта за заказ (только если `ordersEnabled = true` и фракция имеет заказы согласно статическому списку) - среднее арифметическое валюты из `FactionTemplate.orderReward` для данной фракции
   - Валюта за работу (только если `workReward != null` и `workReward.currency > 0`) - значение из `faction.workReward.currency`
6. Вычисляется время: `(нужная валюта) / (валюта в день)`

**Примечание:** 
- Все стоимости хранятся как константы в `AppSettings.factions`, умножение не используется - применяются готовые суммы
- Расчет учитывает только те активности, которые настроены (заказы включены и фракция имеет заказы, или работа настроена с валютой > 0)
- Если заказы отключены или не настроены, и работа не настроена (оба поля равны 0), возвращается `null` (расчет невозможен)
- Если `wantsCertificate = false`, возвращается `null` (цель не установлена)

#### CalculateTimeToReputationGoal

Расчет времени до достижения целевого уровня отношения.

```dart
class CalculateTimeToReputationGoal {
  final FactionTemplateRepository _templateRepository;
  final AppSettingsRepository _settingsRepository;
  
  CalculateTimeToReputationGoal(
    this._templateRepository,
    this._settingsRepository,
  );
  
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
1. Если `targetReputationLevel == null`, возвращается `null` (цель не установлена)
2. Вычисляется общий опыт на основе `currentReputationLevel` и `currentLevelExp` через `ReputationHelper.getNeededExp`
3. Вычисляется требуемый опыт для достижения `targetReputationLevel`
4. Рассчитывается опыт в день:
   - Опыт за заказ (только если `ordersEnabled = true` и фракция имеет заказы согласно статическому списку) - среднее арифметическое опыта из `FactionTemplate.orderReward` для данной фракции
   - Опыт за работу (только если `workReward != null` и `workReward.exp > 0`) - значение из `faction.workReward.exp`
4. Вычисляется время: `(нужный опыт) / (опыт в день)`

**Примечание:** 
- Если целевой уровень не установлен (`targetReputationLevel == null`), возвращается `null`
- Расчет учитывает опыт как за заказы, так и за работу (если настроены)
- Расчет учитывает только те источники опыта, которые настроены (заказы включены и фракция имеет заказы, или работа настроена с опытом > 0)

#### ResetDailyFlags

Сброс ежедневных отметок.

```dart
class ResetDailyFlags {
  Future<void> call();
}
```

**Описание:**
Сбрасывает отметки `orderCompleted` и `workCompleted` для всех фракций. Вызывается автоматически при запуске приложения через `DailyResetHelper`, если последний сброс был не сегодня (по московскому времени).

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

#### ExportDatabase

Экспорт базы данных.

```dart
class ExportDatabase {
  final FileExporter _fileExporter;
  final DatabasePathProvider _databasePathProvider;
  
  ExportDatabase(
    this._fileExporter,
    this._databasePathProvider,
  );
  
  Future<bool> call();
}
```

**Возвращает:**
- `true` - если экспорт успешен
- `false` - если произошла ошибка

**Описание:**
Экспортирует файл базы данных `rev_app.db` через системный диалог экспорта. Пользователь может выбрать способ экспорта (сохранить в файловый менеджер, отправить по email, сохранить в облачное хранилище и т.д.). Использует `FileExporter` для экспорта файла и `DatabasePathProvider` для получения пути к БД.

**Использование:**
Вызывается из UI при нажатии на кнопку "Экспорт БД" в меню навигации (Drawer).

#### ImportDatabase

Импорт базы данных.

```dart
class ImportDatabase {
  final FileImporter _fileImporter;
  
  ImportDatabase(this._fileImporter);
  
  Future<String?> call();
}
```

**Возвращает:**
- `String?` - путь к выбранному файлу, если выбор успешен
- `null` - если пользователь отменил выбор файла
- Выбрасывает исключение, если произошла ошибка

**Описание:**
Выбирает файл для импорта базы данных через `FileImporter` (использует file_picker). Возвращает путь к выбранному файлу или `null`, если пользователь отменил выбор.

**Важно:**
- `ImportDatabase` только выбирает файл, но не выполняет валидацию и переинициализацию БД
- Валидация файла и переинициализация БД выполняются в `ServiceLocator.reinitializeDatabase()` через `DatabasePathProvider`
- Процесс импорта в UI включает:
  1. Выбор файла через `ImportDatabase` (возвращает путь к файлу)
  2. Валидацию файла и переинициализацию БД через `ServiceLocator.reinitializeDatabase()`:
     - Валидация: проверка, что это валидная SQLite БД с таблицей `factions`
     - Закрытие текущего соединения с БД
     - Копирование импортированного файла на место текущей БД
     - Переоткрытие соединения с БД
  3. Обновление use cases в BLoC с новыми репозиториями

**Использование:**
Вызывается из UI при нажатии на кнопку "Импорт БД" в меню навигации (Drawer). Перед импортом показывается диалог подтверждения. После выбора файла вызывается `ServiceLocator.reinitializeDatabase()` для валидации и переинициализации БД.

#### GetAllQuestions

Получение всех вопросов "Клуба знатоков".

```dart
class GetAllQuestions {
  final QuestionRepository repository;
  
  GetAllQuestions(this.repository);
  
  Future<List<Question>> call();
}
```

**Возвращает:**
- `Future<List<Question>>` - список всех вопросов из источника данных

**Описание:**
Получает все вопросы из репозитория. Используется для загрузки начального списка вопросов на странице поиска.

#### SearchQuestions

Поиск вопросов по запросу.

```dart
class SearchQuestions {
  final QuestionRepository repository;
  
  SearchQuestions(this.repository);
  
  Future<List<Question>> call(String query);
}
```

**Параметры:**
- `query` - текст поискового запроса

**Возвращает:**
- `Future<List<Question>>` - список вопросов, содержащих запрос в тексте вопроса или ответа

**Описание:**
Выполняет поиск вопросов по запросу. Поиск выполняется одновременно по тексту вопроса и ответа, без учета регистра. При пустом запросе возвращает все вопросы.

**Использование:**
Вызывается из UI при изменении текста в поисковой строке на странице "Клуб знатоков". Результаты отображаются в виде карточек с вопросами и ответами.

## Entities

### Faction

```dart
class Faction {
  final int? id;
  final String name;
  final int currency;
  final bool orderCompleted;
  final bool ordersEnabled; // учитывать ли заказы в расчете
  final WorkReward? workReward; // награда за работу (валюта и опыт)
  final bool workCompleted; // выполнена ли работа
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
  final ReputationLevel? targetReputationLevel; // Целевой уровень отношения (null = цель не нужна, по умолчанию null)
  final bool wantsCertificate; // Нужен ли сертификат как цель (по умолчанию false)
  
  Faction copyWith({...});
}
```

### AppSettingsRepository

Интерфейс для получения настроек приложения и работы с датой последнего ежедневного сброса.

```dart
abstract class AppSettingsRepository {
  int getDecorationUpgradeCostRespect();
  int getDecorationUpgradeCostHonor();
  int getDecorationUpgradeCostAdoration();
  int getDecorationPriceRespect();
  int getDecorationPriceHonor();
  int getDecorationPriceAdoration();
  int getCertificatePrice();
  int getExpForLevel(String factionName, int levelIndex, bool hasSpecialExp);
  int getTotalExpForLevel(String factionName, int levelIndex, bool hasSpecialExp);
  Future<DateTime?> getLastResetDate();
  Future<void> saveLastResetDate(DateTime date);
}
```

**Методы:**
- Методы для получения стоимости украшений и сертификата
- Методы для получения опыта репутации (с учетом специальных значений для некоторых фракций)
- Методы для работы с датой последнего ежедневного сброса

**Примечание:** 
- Реализация (`AppSettingsRepositoryImpl`) использует константы из `AppSettings` (Data layer) и SharedPreferences для хранения даты сброса
- Все стоимости хранятся как готовые суммы (не используется умножение)
- Структура расширяема для будущих функций (карта, брактеат)

### FactionTemplateRepository

Интерфейс для работы с шаблонами фракций.

```dart
abstract class FactionTemplateRepository {
  List<FactionTemplate> getAllTemplates();
  FactionTemplate? getTemplateByName(String name);
  Faction createFactionFromTemplate(FactionTemplate template);
}
```

**Методы:**
- `getAllTemplates()` - возвращает список всех шаблонов фракций
- `getTemplateByName(String name)` - возвращает шаблон фракции по имени или null
- `createFactionFromTemplate(FactionTemplate template)` - создает Faction entity из шаблона

**Примечание:** 
- Реализация (`FactionTemplateRepositoryImpl`) использует `FactionsList` из Data layer
- Возвращает domain entities напрямую без конвертации

### FactionTemplate

Шаблон фракции для статического списка всех доступных фракций игры.

```dart
class FactionTemplate {
  final String name;
  final bool hasWork;
  final bool hasCertificate;
  final bool hasSpecialExp;
  final OrderReward? orderReward; // Награда за заказы (валюта и опыт) (nullable, только для фракций с заказами)
  
  const FactionTemplate({
    required this.name,
    required this.hasWork,
    required this.hasCertificate,
    this.hasSpecialExp = false,
    this.orderReward,
  });
}
```

**Поля:**
- `name` - название фракции
- `hasWork` - есть ли работа во фракции
- `hasCertificate` - есть ли сертификат во фракции
- `hasSpecialExp` - есть ли специальные значения опыта для этой фракции
- `orderReward` - награда за заказы (nullable, только для фракций с заказами)

**Примечание:** 
- Каждая фракция в статическом списке имеет предустановленные значения `hasWork` и `hasCertificate`, которые определяют, какие активности доступны для этой фракции
- Для фракций с заказами в поле `orderReward` хранится награда за заказы (валюта и опыт как массивы), которые могут варьироваться в разные дни. При расчете времени до цели используется среднее арифметическое валюты и опыта отдельно
- Наличие заказов определяется наличием `orderReward` (если `orderReward != null`, значит фракция имеет заказы)

### Question

Вопрос и ответ для функционала "Клуб знатоков".

```dart
class Question {
  final int id;
  final String question;
  final String answer;
  
  const Question({
    required this.id,
    required this.question,
    required this.answer,
  });
}
```

**Поля:**
- `id` - уникальный идентификатор вопроса
- `question` - текст вопроса
- `answer` - текст ответа

**Использование:**
Используется для хранения вопросов и ответов из ивента "Клуб знатоков" игры Revelation Online. Вопросы загружаются из JSON файла `assets/questions.json` через `QuestionsData` и кэшируются в памяти через `QuestionRepositoryImpl`.

### WorkReward

Награда за выполнение работы (валюта и опыт).

```dart
class WorkReward {
  final int currency;
  final int exp;
  
  const WorkReward({
    required this.currency,
    required this.exp,
  });
}
```

**Использование:**
- `WorkReward` всегда создается при вводе значений в поля работы (даже если оба поля равны 0)
- Если оба поля равны 0, работа не учитывается в расчетах
- Можно указать только валюту, только опыт, или оба значения
- В расчетах учитывается только если соответствующее поле > 0

### OrderReward

Награда за выполнение заказа (валюта и опыт как массивы).

```dart
class OrderReward {
  final List<int> currency;
  final List<int> exp;
  
  const OrderReward({
    required this.currency,
    required this.exp,
  });
  
  static int averageCurrency(OrderReward reward);
  static int averageExp(OrderReward reward);
}
```

**Использование:**
- Хранит массивы значений валюты и опыта, которые могут варьироваться в разные дни
- При расчете времени до цели используется среднее арифметическое через методы `averageCurrency` и `averageExp`

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

// Показ скрытой фракции
class ShowFactionEvent extends FactionEvent {
  final Faction faction;
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

## Presentation Layer Widgets API

### HelpDialog

Переиспользуемый компонент для отображения модалки помощи.

```dart
class HelpDialog extends StatelessWidget {
  final String title;
  final String content;
  
  const HelpDialog({
    super.key,
    required this.title,
    required this.content,
  });
  
  static void show(BuildContext context, String title, String content);
}
```

**Параметры:**
- `title` - заголовок модалки
- `content` - текст помощи

**Методы:**
- `show(context, title, content)` - статический метод для удобного вызова модалки

**Использование:**
```dart
HelpDialog.show(
  context,
  'О валюте',
  'Текст помощи...',
);
```

**Описание:**
Единый компонент для всех модалок помощи в приложении. Используется во всех блоках с иконками помощи (`FactionCurrencyBlock`, `FactionReputationBlock`, `FactionCertificateBlock`, `FactionDecorationsSection`, `FactionActivitiesBlock`, `FactionGoalsBlock`).

### CurrencyInputDialog

Универсальный диалог для ввода/редактирования валюты.

```dart
class CurrencyInputDialog extends StatefulWidget {
  final int? initialValue;
  final String title;
  final String labelText;
  final String? hintText;
  final bool allowEmpty;
  
  const CurrencyInputDialog({
    super.key,
    this.initialValue,
    required this.title,
    required this.labelText,
    this.hintText,
    this.allowEmpty = false,
  });
}
```

**Параметры:**
- `initialValue` - начальное значение валюты (опционально)
- `title` - заголовок диалога
- `labelText` - текст метки поля ввода
- `hintText` - текст подсказки (опционально)
- `allowEmpty` - разрешить пустое значение (по умолчанию false)

**Особенности:**
- Автоматически выделяет весь текст при фокусе для быстрой замены
- Поддерживает только числовой ввод (фильтрует нецифровые символы)
- Возвращает `int?` при закрытии (null при отмене, значение при сохранении)

**Использование:**
```dart
final result = await showDialog<int>(
  context: context,
  builder: (context) => CurrencyInputDialog(
    initialValue: currency,
    title: 'Валюта',
    labelText: 'Введите количество валюты',
    allowEmpty: false,
  ),
);
if (result != null) {
  onCurrencyChanged(result);
}
```

**Описание:**
Универсальный диалог для ввода валюты, используемый в различных местах приложения. Поддерживает как обязательный ввод (для основной валюты фракции), так и опциональный (для валюты с работы).

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

extension ReputationLevelExtension on ReputationLevel {
  String get displayName;
  int get value;
  static ReputationLevel fromValue(int value);
}
```

**Методы (через extension `ReputationLevelExtension`):**
- `displayName` - получить название уровня на русском языке
- `value` - получить числовое значение уровня (для хранения в БД)
- `fromValue(int value)` - статический метод для создания ReputationLevel из числового значения

### OrderReward

Класс для хранения награды за выполнение заказа (валюта и опыт как массивы).

```dart
class OrderReward {
  final List<int> currency;
  final List<int> exp;
  
  const OrderReward({
    required this.currency,
    required this.exp,
  });
  
  static int averageCurrency(OrderReward reward);
  static int averageExp(OrderReward reward);
}
```

**Методы (статические):**
- `averageCurrency(OrderReward reward)` - вычислить среднее арифметическое валюты из массива наград
- `averageExp(OrderReward reward)` - вычислить среднее арифметическое опыта из массива наград

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
// "3д"
```

**Формат:** Отображает только количество дней с округлением вверх. Если есть остаток времени (часы или минуты), добавляется 1 день. Использует сокращение "д" для компактности.

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
  static Future<void> checkAndReset(
    FactionRepository factionRepository,
    AppSettingsRepository appSettingsRepository,
    DateTimeProvider dateTimeProvider,
  );
}
```

Проверяет и сбрасывает ежедневные отметки при необходимости. Должен вызываться при запуске приложения.

**Параметры:**
- `factionRepository` - репозиторий для работы с фракциями (для сброса ежедневных флагов)
- `appSettingsRepository` - репозиторий для работы с настройками (для получения и сохранения даты последнего сброса)
- `dateTimeProvider` - провайдер для работы с датой и временем в московском часовом поясе

**Описание:**
Сравнивает текущую дату в московском часовом поясе с датой последнего сброса. Если последний сброс был не сегодня, сбрасывает ежедневные отметки (`orderCompleted` и `workCompleted`) для всех фракций и сохраняет текущую дату как дату последнего сброса. Работа с часовыми поясами абстрагирована через `DateTimeProvider` интерфейс, что обеспечивает соблюдение принципов Clean Architecture.

## ServiceLocator

```dart
class ServiceLocator {
  static final ServiceLocator _instance = ServiceLocator._internal();
  factory ServiceLocator() => _instance;
  
  Future<void> init();
  Future<String> getDatabasePath();
  Future<void> reinitializeDatabase(String importedFilePath);
  
  Database get database;
  FactionRepository get factionRepository;
  FactionTemplateRepository get factionTemplateRepository;
  AppSettingsRepository get appSettingsRepository;
  DateTimeProvider get dateTimeProvider;
  FileExporter get fileExporter;
  FileImporter get fileImporter;
  DatabasePathProvider get databasePathProvider;
}
```

**Использование:**
```dart
// Инициализация (в main.dart)
await ServiceLocator().init();

// Получение репозиториев и провайдеров
final factionRepo = ServiceLocator().factionRepository;
final templateRepo = ServiceLocator().factionTemplateRepository;
final settingsRepo = ServiceLocator().appSettingsRepository;
final dateTimeProvider = ServiceLocator().dateTimeProvider;
final fileExporter = ServiceLocator().fileExporter;
final fileImporter = ServiceLocator().fileImporter;
final databasePathProvider = ServiceLocator().databasePathProvider;

// Получение пути к БД
final dbPath = await ServiceLocator().getDatabasePath();

// Переинициализация БД после импорта
await ServiceLocator().reinitializeDatabase(importedFilePath);
```

**Описание:**
- Инициализирует SQLite базу данных версии 1
- Создает таблицу `factions` при первом запуске через `FactionDao.createTable()`
- Создает экземпляры репозиториев и провайдеров для работы с данными
- Singleton паттерн - один экземпляр на все приложение
- Используется только на уровне страниц (Pages) для создания зависимостей

**Методы:**
- `getDatabasePath()` - возвращает путь к файлу базы данных
- `reinitializeDatabase(String importedFilePath)` - переинициализирует базу данных с новым файлом после импорта:
  - Валидирует импортируемый файл (проверяет, что это валидная SQLite БД с таблицей `factions`)
  - Закрывает текущее соединение с БД
  - Копирует импортированный файл на место текущей БД
  - Переоткрывает соединение с БД
  - Обновляет все репозитории с новым соединением

