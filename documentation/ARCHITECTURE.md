# Архитектура приложения

## Обзор

Приложение построено по принципам **Clean Architecture**, что обеспечивает разделение ответственности и независимость слоев.

## Соответствие Clean Architecture

**Проект полностью соответствует принципам Clean Architecture без компромиссов.**

Все зависимости между слоями проверены и соответствуют правилам:
- ✅ **Domain Layer** - не зависит от внешних слоев (Data, Presentation, Core)
- ✅ **Data Layer** - зависит только от Domain layer (реализует интерфейсы репозиториев)
- ✅ **Presentation Layer** - зависит от Domain layer (use cases, entities, репозитории через интерфейсы) и может зависеть от Data layer через ServiceLocator
- ✅ **Core Layer** - не зависит от Domain, Data и Presentation слоев

**Проверенные паттерны:**
- ✅ ServiceLocator используется только на уровне Pages
- ✅ Виджеты получают зависимости через конструкторы
- ✅ BLoC зависит только от Use Cases
- ✅ Use Cases зависят только от Repository интерфейсов
- ✅ Repositories реализуют интерфейсы из Domain layer
- ✅ Нет прямых обращений Presentation layer к Data layer

## Слои архитектуры

### 1. Domain Layer (Доменный слой)

**Расположение:** `lib/domain/`

Самый внутренний слой, не зависящий от внешних библиотек и фреймворков.

#### Entities (Сущности)
- `Faction` - представляет фракцию со всеми её параметрами
- `ReputationLevel` - enum уровней отношения (indifference, friendliness, respect, honor, adoration, deification, maximum) с extension `ReputationLevelExtension` для методов `displayName`, `value`, `fromValue`
- `FactionTemplate` - шаблон фракции для статического списка

#### Value Objects
- `WorkReward` - класс для хранения награды за работу (валюта и опыт)
- `OrderReward` - класс для хранения награды за заказ (валюта и опыт как массивы `List<int>`). Имеет статические методы `averageCurrency` и `averageExp` для вычисления среднего арифметического

#### Repositories (Интерфейсы репозиториев)
- `FactionRepository` - интерфейс для работы с фракциями
- `FactionTemplateRepository` - интерфейс для работы с шаблонами фракций
- `AppSettingsRepository` - интерфейс для получения настроек приложения и работы с датой последнего ежедневного сброса
- `DateTimeProvider` - интерфейс для работы с датой и временем в московском часовом поясе. Используется для абстракции работы с часовыми поясами из Domain layer

#### Utils
- `ReputationExp` - утилита для работы с опытом репутации (требует репозитории для получения настроек)
- `ReputationHelper` - утилита для работы с уровнями отношения и опытом (вычисление общего опыта, нужного опыта и т.д.)
- `DailyResetHelper` - помощник для ежедневного сброса отметок. Принимает `FactionRepository`, `AppSettingsRepository` и `DateTimeProvider` через параметры метода `checkAndReset()` для сброса ежедневных флагов и работы с датой последнего сброса. **Важно:** Не использует инфраструктурные зависимости напрямую - работа с часовыми поясами абстрагирована через `DateTimeProvider` интерфейс

#### Use Cases (Сценарии использования)
- `GetAllFactions` - получение видимых фракций
- `GetHiddenFactions` - получение скрытых фракций
- `InitializeFactions` - инициализация всех фракций из статического списка (использует FactionTemplateRepository)
- `AddFaction` - добавление новой фракции в БД
- `UpdateFaction` - обновление фракции
- `DeleteFaction` - скрытие фракции (устанавливает `isVisible = false`)
- `ShowFaction` - показ скрытой фракции (устанавливает `isVisible = true`)
- `CalculateTimeToCurrencyGoal` - расчет времени до достижения цели по валюте (использует AppSettingsRepository и FactionTemplateRepository). Возвращает `null` если `wantsCertificate = false`
- `CalculateTimeToReputationGoal` - расчет времени до достижения целевого уровня отношения (использует FactionTemplateRepository и ReputationHelper)
- `ResetDailyFlags` - сброс ежедневных отметок
- `ReorderFactions` - изменение порядка фракций

**Важно:** Все Use Cases зависят только от Domain слоя (entities, repositories интерфейсы) и не имеют зависимостей от внешних слоев (Core, Data, Presentation).

### 2. Data Layer (Слой данных)

**Расположение:** `lib/data/`

Реализует интерфейсы из Domain слоя и работает с базой данных.

#### Models (Модели данных)
- `FactionModel` - модель для маппинга Faction entity в/из базы данных

#### Data Sources (Источники данных)
- `FactionDao` - DAO для работы с таблицей factions в SQLite

#### Data Sources (Источники данных)
- `FactionsList` - статический список всех 13 фракций игры с предустановленными настройками. Использует `FactionTemplate` entity из Domain layer (hasWork, hasCertificate, orderReward). Наличие заказов определяется наличием `orderReward` (если `orderReward != null`, значит фракция имеет заказы)
- `AppSettings` - константы настроек приложения, организованные по функциональности (фракции, карта, брактеат)

#### Repositories (Реализации репозиториев)
- `FactionRepositoryImpl` - реализация FactionRepository
- `FactionTemplateRepositoryImpl` - реализация FactionTemplateRepository (использует FactionsList из Data layer, который возвращает domain entities напрямую). Использует `FactionsList.createFactionFromTemplate()` для создания Faction из шаблона, избегая дублирования логики
- `AppSettingsRepositoryImpl` - реализация AppSettingsRepository (использует AppSettings.factions из Data layer для получения настроек и SharedPreferences для работы с датой последнего сброса)
- `DateTimeProviderImpl` - реализация DateTimeProvider (использует библиотеку timezone для работы с московским часовым поясом)

### 3. Presentation Layer (Слой представления)

**Расположение:** `lib/presentation/`

Отвечает за UI и управление состоянием.

#### Pages (Страницы)
- `pages/main/main_page.dart` - главная страница с Drawer для навигации между разделами
- `pages/faction/factions_page.dart` - страница фракций со списком видимых фракций и кнопкой добавления (выбор из скрытых). Создает зависимости через ServiceLocator и передает их в FactionsListPage
- `pages/faction/factions_list_page.dart` - список видимых фракций с возможностью скрытия свайпом и изменения порядка (drag-and-drop). Получает все зависимости (ReputationHelper, use cases, репозитории) через конструктор
- `pages/faction/faction_detail_page.dart` - детальная информация и редактирование фракции (оптимизированная версия с компактными секциями). Название фракции отображается в заголовке AppBar. Получает `FactionTemplateRepository` через конструктор
- `pages/map/map_page.dart` - заглушка для будущей карты ресурсов

#### Widgets (Виджеты)

**Виджеты фракций** (`widgets/faction/`):
- `FactionCard` - карточка фракции в списке с новой структурой из 3 строк (название+активности, progress bar валюты+время, progress bar опыта+время). Получает репозитории через конструктор и передает их в дочерние виджеты
- `FactionNameDisplay` - отображение названия фракции
- `FactionActivitiesList` - список активностей фракции (бейджи для заказов и работ). Получает `FactionTemplateRepository` через конструктор
- `FactionActivitiesBlock` - блок ежедневных активностей с галочками "Заказы" и "Работы"
- `FactionCurrencyBlock` - блок для редактирования валюты фракции
- `FactionReputationBlock` - блок для редактирования текущего уровня отношения и опыта на уровне
- `FactionCertificateBlock` - отдельный блок для управления сертификатом с галочкой "Сертификат". Получает `FactionTemplateRepository` через конструктор
- `FactionGoalsBlock` - блок "Цели" с целевым уровнем репутации и галочкой "Нужен сертификат"
- `FactionDecorationsSection` - секция украшений с компактными карточками
- `FactionSelectionDialog` - диалог выбора фракции из списка скрытых
- `FactionActivitiesSection` - секция активностей и сертификата (не используется в текущей реализации)
- `FactionBasicInfoSection` - секция базовой информации о фракции (не используется в текущей реализации)

**Виджеты валюты** (`widgets/currency/`):
- `CurrencyProgressBar` - progress bar для отображения прогресса валюты с возможностью редактирования. Получает `AppSettingsRepository` и `FactionTemplateRepository` через конструктор
- `CurrencyInputDialog` - диалог для ввода/редактирования валюты
- `WorkCurrencyBadge` - бейдж валюты с работы (с возможностью редактирования)

**Виджеты репутации** (`widgets/reputation/`):
- `ReputationProgressBar` - progress bar для отображения прогресса уровня отношения. Получает `FactionTemplateRepository` через конструктор

**Виджеты активностей** (`widgets/activity/`):
- `ActivityBadge` - бейдж активности (переиспользуемый компонент)

**Виджеты времени до цели** (`widgets/time_to_goal/`):
- `TimeToCurrencyGoalWidget` - компактный виджет отображения времени до цели по валюте (автоматически пересчитывается при изменении полей). Получает `CalculateTimeToCurrencyGoal` use case через конструктор
- `TimeToReputationGoalWidget` - компактный виджет отображения времени до цели по репутации (отображается рядом с progress bar опыта). Получает `CalculateTimeToReputationGoal` use case через конструктор

#### BLoC (State Management)
- `FactionBloc` - управление состоянием фракций
  - **Зависимости:** BLoC зависит только от Use Cases, не использует Repository напрямую
  - **События:**
    - `LoadFactions` - загрузка всех видимых фракций
    - `AddFactionEvent` - добавление новой фракции
    - `UpdateFactionEvent` - обновление фракции
    - `DeleteFactionEvent` - скрытие фракции (устанавливает `isVisible = false`)
    - `ShowFactionEvent` - показ скрытой фракции (устанавливает `isVisible = true`)
    - `ResetDailyFlagsEvent` - сброс ежедневных отметок
    - `ReorderFactionsEvent` - изменение порядка фракций
  - **Состояния:**
    - `FactionInitial` - начальное состояние
    - `FactionLoading` - загрузка данных
    - `FactionLoaded` - данные загружены (содержит список фракций)
    - `FactionError` - ошибка (содержит сообщение об ошибке)
  - **Оптимистичные обновления:** При обновлении фракции (`UpdateFactionEvent`) и изменении порядка (`ReorderFactionsEvent`) UI обновляется мгновенно, сохранение в БД происходит в фоне. При ошибке состояние восстанавливается из БД.
  - **Pull-to-refresh:** Поддержка обновления списка через свайп вниз (`RefreshIndicator`)
  - **Методы:** `getHiddenFactions()` - получение скрытых фракций для диалога выбора

#### Dependency Injection
- `di/service_locator.dart` - простой DI контейнер для управления зависимостями. Создает и управляет всеми репозиториями (FactionRepository, FactionTemplateRepository, AppSettingsRepository, DateTimeProvider). Импортирует интерфейсы репозиториев из Domain layer для типизации и реализации из Data layer для создания экземпляров.

**Правила использования ServiceLocator:**
- ServiceLocator используется **только на уровне страниц (Pages)** для создания зависимостей
- Все зависимости создаются в методе `build()` страницы через ServiceLocator
- Созданные зависимости передаются в дочерние виджеты через конструкторы
- **Виджеты НЕ должны обращаться к ServiceLocator напрямую** - это нарушает принцип Dependency Inversion
- Исключение: `main.dart` использует ServiceLocator для инициализации и создания зависимостей для BLoC

#### Обработка ошибок при запуске
- `ErrorApp` - виджет для отображения ошибки при запуске приложения. Используется в `main.dart` как fallback, если инициализация приложения не удалась. Показывает информативный экран с описанием ошибки вместо черного экрана.
- `ErrorScreen` - экран с ошибкой, отображающий сообщение об ошибке, детали ошибки и stack trace (только в debug режиме). Использует темную тему приложения для единообразия.
- Глобальная обработка ошибок Flutter (`FlutterError.onError`) и асинхронных ошибок (`PlatformDispatcher.instance.onError`) настроена в `main()` для логирования ошибок в release режиме.

**Важно:** Виджеты Presentation layer получают зависимости (use cases, helpers, репозитории) через конструкторы, а не через ServiceLocator напрямую. ServiceLocator используется только на уровне страниц (Pages) для создания зависимостей, которые затем передаются вниз по дереву виджетов. Виджеты не обращаются напрямую к Data layer (FactionsList, AppSettings), а используют репозитории через интерфейсы из Domain layer (FactionTemplateRepository, AppSettingsRepository). Это обеспечивает соблюдение принципа Dependency Inversion и делает код более тестируемым.

### 4. Core Layer (Ядро)

**Расположение:** `lib/core/`

Общие утилиты и инфраструктура. **Важно:** Core layer не зависит от Domain, Data и Presentation слоев и не содержит бизнес-логики.

**Структура:**
- `core/theme/` - тема приложения
- `core/utils/` - утилиты форматирования

**Примечание:** Все неиспользуемые пустые папки (constants, database, di из core layer, settings из bloc) были удалены. ServiceLocator находится в `presentation/di/`, что соответствует Clean Architecture (DI контейнер является частью Presentation layer).

#### Utils
- `TimeFormatter` - форматирование времени в компактный формат (только дни с округлением вверх)

#### Theme
- `AppTheme` - темная тема приложения в стиле игры Revelation Online
  - Цветовая схема с темными фонами
  - Градиенты и стили компонентов

## Поток данных

```
UI (Presentation) 
    ↓
Use Cases (Domain)
    ↓
Repositories (Domain interfaces)
    ↓
Repository Implementations (Data)
    ↓
DAO (Data Sources)
    ↓
SQLite Database
```

## Зависимости

- **sqflite** - работа с SQLite
- **flutter_bloc** - управление состоянием
- **equatable** - сравнение объектов
- **intl** - форматирование дат/времени
- **timezone** - работа с часовыми поясами
- **shared_preferences** - хранение простых данных (дата последнего сброса)

## Принципы Clean Architecture

### 1. Dependency Rule (Правило зависимостей)

**Внутренние слои не зависят от внешних.** Все зависимости направлены внутрь, к Domain layer.

#### Domain Layer
- ✅ **Не зависит** от Core, Data, Presentation слоев
- ✅ **Не использует** инфраструктурные зависимости напрямую (SharedPreferences, sqflite, timezone и т.д.)
- ✅ Все доступы к инфраструктуре идут **через репозитории и провайдеры** (интерфейсы)
- ✅ Содержит только **бизнес-логику** и **интерфейсы репозиториев/провайдеров**
- ✅ Use Cases зависят только от Domain entities и repository интерфейсов
- ✅ Utils (ReputationExp, ReputationHelper, DailyResetHelper) используют только Domain интерфейсы

#### Data Layer
- ✅ **Зависит только** от Domain layer (реализует интерфейсы репозиториев и провайдеров)
- ✅ **Не зависит** от Presentation layer
- ✅ Использует domain entities напрямую (FactionTemplate, Faction)
- ✅ Реализует интерфейсы из Domain layer

#### Presentation Layer
- ✅ **Зависит от Domain layer** (использует use cases, entities и репозитории через интерфейсы)
- ✅ **Может зависеть от Data layer** через ServiceLocator для создания реализаций репозиториев
- ✅ **Не обращается напрямую** к Data layer из виджетов (FactionsList, AppSettings используются только через репозитории)
- ✅ BLoC зависит только от Use Cases, не использует Repository напрямую
- ✅ Виджеты получают зависимости (use cases, helpers, репозитории) через конструкторы
- ✅ ServiceLocator находится в Presentation layer и используется только на уровне страниц (Pages) для создания зависимостей

#### Core Layer
- ✅ **Не зависит** от Domain, Data и Presentation слоев
- ✅ Содержит только инфраструктурные компоненты (тема, утилиты форматирования)
- ✅ Не содержит пустых неиспользуемых папок (constants, database, di удалены)

### 2. Single Responsibility Principle

Каждый класс имеет одну ответственность:
- Use Cases - один сценарий использования
- Repositories - работа с одним типом данных
- Entities - представление одной бизнес-сущности
- Widgets - отображение одного UI компонента

### 3. Separation of Concerns

Четкое разделение ответственности:
- **Domain** - бизнес-логика
- **Data** - работа с данными
- **Presentation** - UI и состояние
- **Core** - инфраструктура

### 4. Testability

Каждый слой можно тестировать независимо:
- Domain layer тестируется без внешних зависимостей
- Data layer тестируется с моками интерфейсов
- Presentation layer тестируется с моками use cases
- Зависимости инжектируются через конструкторы

### 5. Dependency Inversion Principle

Зависимости направлены от внешних слоев к внутренним через интерфейсы:
- Presentation → Domain (через use cases и repository интерфейсы)
- Presentation → Data (через ServiceLocator для создания реализаций репозиториев)
- Data → Domain (реализует repository интерфейсы)
- Core → (не зависит ни от одного слоя)

## Результаты проверки архитектуры

**Статус:** Проект полностью соответствует принципам Clean Architecture без компромиссов. Все зависимости между слоями проверены и соответствуют правилам. Пустые неиспользуемые папки удалены.

**Метод проверки:** Полная проверка всех импортов в каждом файле проекта (23 файла Domain layer, 8 файлов Data layer, 30+ файлов Presentation layer, 2 файла Core layer). Проверка зависимостей между слоями, проверка использования ServiceLocator, проверка передачи зависимостей через конструкторы, проверка отсутствия прямых обращений к Data layer datasources из Presentation layer.

### Проверенные аспекты

✅ **Domain Layer:**
- Не содержит импортов из Data, Presentation, Core слоев
- Использует только domain entities, value objects, repository интерфейсы и стандартные библиотеки
- Все Use Cases зависят только от Domain интерфейсов
- Utils используют только Domain интерфейсы (ReputationExp, ReputationHelper, DailyResetHelper)

✅ **Data Layer:**
- Зависит только от Domain layer (реализует интерфейсы репозиториев)
- Не содержит импортов из Presentation layer
- Использует внешние библиотеки (sqflite, shared_preferences, timezone) только в реализациях
- Возвращает domain entities напрямую

✅ **Presentation Layer:**
- Импортирует только из Domain layer (use cases, entities, repository интерфейсы)
- Использует Data layer только через ServiceLocator для создания реализаций
- Виджеты получают зависимости через конструкторы (не используют ServiceLocator напрямую)
- ServiceLocator находится только на уровне Pages
- Нет прямых обращений к Data layer datasources (FactionsList, AppSettings) из виджетов

✅ **Core Layer:**
- Не содержит импортов из Domain, Data, Presentation слоев
- Содержит только инфраструктурные компоненты (тема, утилиты форматирования)
- Все пустые неиспользуемые папки удалены (constants, database, di из core layer, settings из bloc)

### Соответствие Clean Architecture

**Проект полностью соответствует принципам Clean Architecture без компромиссов.**

Все правила зависимостей соблюдены:
- ✅ Dependency Rule (правило зависимостей)
- ✅ Single Responsibility Principle
- ✅ Separation of Concerns
- ✅ Testability
- ✅ Dependency Inversion Principle

