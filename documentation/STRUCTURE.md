# Структура проекта

## Общая структура

```
lib/
├── main.dart                          # Точка входа приложения (с обработкой ошибок)
├── core/                              # Ядро приложения
│   ├── theme/                         # Тема приложения
│   │   └── app_theme.dart             # Темная тема в стиле игры
│   └── utils/                         # Утилиты
│       └── time_formatter.dart         # Форматирование времени
├── domain/                            # Доменный слой
│   ├── entities/                      # Сущности
│   │   ├── faction.dart
│   │   ├── faction_template.dart
│   │   └── reputation_level.dart
│   ├── repositories/                  # Интерфейсы репозиториев
│   │   ├── faction_repository.dart
│   │   ├── faction_template_repository.dart
│   │   ├── app_settings_repository.dart
│   │   ├── date_time_provider.dart
│   │   ├── file_exporter.dart
│   │   ├── file_importer.dart
│   │   ├── database_path_provider.dart
│   │   └── database_initializer.dart
│   ├── usecases/                      # Сценарии использования
│   │   ├── add_faction.dart
│   │   ├── calculate_time_to_currency_goal.dart
│   │   ├── calculate_time_to_reputation_goal.dart
│   │   ├── delete_faction.dart
│   │   ├── export_database.dart
│   │   ├── get_all_factions.dart
│   │   ├── get_hidden_factions.dart
│   │   ├── import_database.dart
│   │   ├── initialize_factions.dart
│   │   ├── reset_daily_flags.dart
│   │   ├── show_faction.dart
│   │   ├── update_faction.dart
│   │   └── reorder_factions.dart
│   ├── utils/                         # Утилиты
│   │   ├── daily_reset_helper.dart    # Сброс ежедневных отметок
│   │   ├── reputation_exp.dart         # Утилита для работы с опытом репутации
│   │   └── reputation_helper.dart      # Утилита для работы с уровнями отношения
│   └── value_objects/                 # Value Objects
│       ├── order_reward.dart
│       └── work_reward.dart
├── data/                               # Слой данных
│   ├── datasources/                   # Источники данных
│   │   ├── faction_dao.dart           # DAO для фракций
│   │   ├── factions_list.dart        # Статический список фракций
│   │   └── app_settings.dart          # Константы настроек приложения
│   ├── models/                        # Модели данных
│   │   └── faction_model.dart
│   └── repositories/                  # Реализации репозиториев
│       ├── faction_repository_impl.dart
│       ├── faction_template_repository_impl.dart
│       ├── app_settings_repository_impl.dart
│       ├── date_time_provider_impl.dart
│       ├── file_exporter_impl.dart
│       ├── file_importer_impl.dart
│       ├── database_path_provider_impl.dart
│       ├── database_initializer_impl.dart
│       └── repository_factory.dart
└── presentation/                       # Слой представления
    ├── di/                            # Dependency Injection
    │   └── service_locator.dart       # DI контейнер
    ├── bloc/                          # State Management
    │   └── faction/
    │       ├── faction_bloc.dart
    │       ├── faction_event.dart
    │       └── faction_state.dart
    ├── pages/                         # Страницы
    │   ├── faction/                   # Страницы фракций
    │   │   ├── faction_detail_page.dart
    │   │   ├── factions_list_page.dart
    │   │   └── factions_page.dart
    │   ├── main/                      # Главная страница
    │   │   └── main_page.dart
    │   └── map/                       # Страница карты
    │       └── map_page.dart
    └── widgets/                       # Виджеты
        ├── activity/                  # Виджеты активностей
        │   └── activity_badge.dart
        ├── common/                    # Переиспользуемые виджеты
        │   ├── block_header.dart
        │   └── help_dialog.dart
        ├── currency/                  # Виджеты валюты
        │   ├── currency_input_dialog.dart
        │   ├── currency_progress_bar.dart
        │   └── work_currency_badge.dart
        ├── faction/                   # Виджеты фракций
        │   ├── faction_activities_block.dart
        │   ├── faction_activities_list.dart
        │   ├── faction_activities_section.dart
        │   ├── faction_basic_info_section.dart
        │   ├── faction_card.dart
        │   ├── faction_certificate_block.dart
        │   ├── faction_currency_block.dart
        │   ├── faction_decorations_section.dart
        │   ├── faction_goals_block.dart
        │   ├── faction_name_display.dart
        │   ├── faction_reputation_block.dart
        │   ├── faction_selection_dialog.dart
        │   └── tabs/                  # Вкладки страницы редактирования фракции
        │       ├── faction_inventory_tab.dart
        │       └── faction_settings_tab.dart
        ├── reputation/                # Виджеты репутации
        │   └── reputation_progress_bar.dart
        └── time_to_goal/              # Виджеты времени до цели
            ├── time_to_currency_goal_widget.dart
            └── time_to_reputation_goal_widget.dart
```

## Описание основных компонентов

### Точка входа (main.dart)

**main.dart** - точка входа приложения с обработкой ошибок при инициализации:

- **Инициализация:**
  - Инициализация Flutter binding
  - Инициализация timezone данных
  - Инициализация ServiceLocator (база данных, репозитории)
  - Инициализация фракций (создание всех 13 фракций, если их еще нет)
  - Проверка и сброс ежедневных отметок

- **Обработка ошибок:**
  - Глобальная обработка ошибок Flutter (`FlutterError.onError`) для логирования ошибок в release режиме
  - Обработка асинхронных ошибок (`PlatformDispatcher.instance.onError`)
  - Try-catch блок для обработки ошибок при инициализации
  - При ошибке инициализации показывается `ErrorApp` вместо черного экрана

- **Компоненты:**
  - `MyApp` - основной виджет приложения с BLoC провайдером. Имеет fallback на `ErrorScreen` при ошибке создания приложения
  - `ErrorApp` - виджет для отображения ошибки при запуске приложения. Используется как fallback, если инициализация не удалась
  - `ErrorScreen` - экран с ошибкой, отображающий сообщение об ошибке, детали ошибки и stack trace (только в debug режиме). Использует темную тему приложения для единообразия

**Важно:** Все компоненты обработки ошибок находятся в `main.dart` и не нарушают архитектуру - они являются частью точки входа приложения.

### Core Layer

**Важно:** Core layer не содержит бизнес-логики и не зависит от Domain, Data и Presentation слоев. Содержит только инфраструктурные компоненты (тема, утилиты форматирования).

#### TimeFormatter
Форматирует Duration в читаемый формат на русском языке (только дни с округлением вверх).

#### AppTheme
Темная тема приложения, стилизованная под игру Revelation Online:
- Темные фоны (#1A1A1A, #0F0F0F, #2A2A2A)
- Акцентные цвета (оранжевый #FF6B35, синий #4A90E2)
- Градиенты для визуальных эффектов
- Стилизованные карточки, кнопки, поля ввода

### Domain Layer

#### Utils

**DailyResetHelper**
Проверяет при запуске приложения, нужно ли сбросить ежедневные отметки (заказы/события). Принимает `FactionRepository`, `AppSettingsRepository` и `DateTimeProvider` через параметры метода `checkAndReset()` для сброса ежедневных флагов и работы с датой последнего сброса. **Важно:** Не использует инфраструктурные зависимости напрямую - все доступы к инфраструктуре идут через репозитории и провайдеры, что соответствует принципам Clean Architecture.

**ReputationExp**
Утилита для работы с опытом репутации. Требует репозитории для получения настроек.

**ReputationHelper**
Утилита для работы с уровнями отношения и опытом (вычисление общего опыта, нужного опыта и т.д.).

#### Entities

**Faction**
- `id` - уникальный идентификатор
- `name` - название фракции
- `currency` - текущее количество валюты (int)
- `orderCompleted` - выполнено ли задание заказа
- `ordersEnabled` - учитывать ли заказы в расчете (bool, по умолчанию false). **Важно:** это настройка пользователя, а не наличие заказов во фракции. Наличие заказов определяется статическим списком фракций (`FactionTemplate.orderReward != null`)
- `workReward` - награда за работу (WorkReward?, содержит валюту и опыт). Если null или оба поля равны 0, работа не учитывается в расчетах
- `workCompleted` - выполнена ли работа
- `hasCertificate` - есть ли сертификат во фракции (определяется статическим списком)
- `certificatePurchased` - куплен ли сертификат
- `displayOrder` - порядок отображения фракций (int, по умолчанию 0)
- `isVisible` - видимость фракции в списке (bool, по умолчанию true)
- `currentReputationLevel` - текущий уровень отношения (ReputationLevel, по умолчанию indifference)
- `currentLevelExp` - опыт на текущем уровне (int, от 0 до требуемого для уровня, по умолчанию 0)
- `targetReputationLevel` - целевой уровень отношения (ReputationLevel?, null = цель не нужна, по умолчанию null)
- `wantsCertificate` - нужен ли сертификат как цель (bool, по умолчанию false)
- Флаги для каждого украшения (куплено/улучшено)

### Data Layer

#### Data Sources (Источники данных)

**FactionDao**
- `createTable()` - создание таблицы factions
- `getAllFactions()` - получение всех фракций, отсортированных по `displayOrder`
- `getFactionById()` - получение фракции по ID
- `insertFaction()` - добавление новой фракции
- `updateFaction()` - обновление фракции
- `deleteFaction()` - скрытие фракции (устанавливает `isVisible = false`)
- `resetDailyFlags()` - сброс ежедневных отметок (orderCompleted и workCompleted)
- `updateFactionOrder()` - обновление порядка одной фракции
- `updateFactionsOrder()` - массовое обновление порядка фракций

**FactionsList**
Статический список всех доступных фракций игры с предустановленными настройками. Использует `FactionTemplate` entity из Domain layer. Каждая фракция имеет шаблон с полями:
- `name` - название фракции
- `hasWork` - есть ли работа во фракции
- `hasCertificate` - есть ли сертификат во фракции
- `hasSpecialExp` - есть ли специальные значения опыта
- `orderReward` - награда за заказы (валюта и опыт как массивы `List<int>`) (nullable, только для фракций с заказами)

**Использование:** 
- `FactionsList.allFactions` - получить все фракции (возвращает `List<FactionTemplate>` из Domain layer)
- `FactionsList.getTemplateByName(String name)` - получить шаблон фракции по имени (возвращает `FactionTemplate?` из Domain layer)
- `FactionsList.createFactionFromTemplate(template)` - создать фракцию из шаблона

**Примечание:** 
- Наличие заказов определяется наличием `orderReward` (если `orderReward != null`, значит фракция имеет заказы)
- Для фракций с заказами в `orderReward` хранятся массивы значений валюты и опыта, которые могут варьироваться в разные дни. При расчете времени до цели используется среднее арифметическое валюты и опыта отдельно через статические методы `OrderReward.averageCurrency` и `OrderReward.averageExp`
- `FactionsList` использует domain entity `FactionTemplate` напрямую, без дублирования

**AppSettings**
Константы настроек приложения, организованные по функциональности. Структура расширяема для будущих функций (карта, брактеат).

**FactionsSettings:**
- `decorationUpgradeCostRespect = 5364` (3 * 1788)
- `decorationUpgradeCostHonor = 7152` (4 * 1788)
- `decorationUpgradeCostAdoration = 10728` (6 * 1788)
- `decorationPriceRespect = 7888`
- `decorationPriceHonor = 9888`
- `decorationPriceAdoration = 15888`
- `currencyPerWork = 100` - валюта за выполнение работы
- `certificatePrice = 7888`

**Использование:** `AppSettings.factions.decorationPriceRespect`

#### Models

Модели выполняют маппинг между entities и данными базы данных (Map<String, dynamic>).

#### Repositories (Реализации репозиториев)

**FactionRepositoryImpl**
Реализация интерфейса `FactionRepository` из Domain layer. Использует `FactionDao` для работы с базой данных.

**FactionTemplateRepositoryImpl**
Реализация интерфейса `FactionTemplateRepository` из Domain layer. Использует `FactionsList` из Data layer для получения шаблонов фракций. Возвращает domain entities напрямую без конвертации, так как `FactionsList` уже использует domain entity `FactionTemplate`. Для создания `Faction` из шаблона использует `FactionsList.createFactionFromTemplate()`, избегая дублирования логики.

**AppSettingsRepositoryImpl**
Реализация интерфейса `AppSettingsRepository` из Domain layer. Использует `AppSettings.factions` из Data layer для получения настроек приложения. Использует SharedPreferences для работы с датой последнего ежедневного сброса (методы `getLastResetDate()` и `saveLastResetDate()`).

**DateTimeProviderImpl**
Реализация интерфейса `DateTimeProvider` из Domain layer. Использует библиотеку `timezone` для работы с московским часовым поясом. Предоставляет методы для получения текущего времени в московском часовом поясе, начала дня и преобразования дат. Используется в `DailyResetHelper` для определения необходимости ежедневного сброса отметок.

**FileExporterImpl**
Реализация интерфейса `FileExporter` из Domain layer. Использует библиотеку `share_plus` для экспорта файла базы данных. Предоставляет метод `exportFile()` для экспорта файла по указанному пути.

**FileImporterImpl**
Реализация интерфейса `FileImporter` из Domain layer. Использует библиотеку `file_picker` для выбора файла при импорте базы данных. Предоставляет метод `importFile()` для выбора файла пользователем. Обрабатывает различные случаи (прямой путь к файлу, файлы из облачных хранилищ через bytes). **Важно:** Валидация файла (проверка, что это валидная SQLite БД с таблицей `factions`) выполняется в `DatabasePathProvider.reinitializeDatabase()`, а не в `FileImporter`.

**DatabasePathProviderImpl**
Реализация интерфейса `DatabasePathProvider` из Domain layer. Управляет путями к базе данных и переинициализацией БД после импорта. Валидирует импортируемые файлы (проверяет наличие таблицы factions) и обеспечивает корректное переключение между базами данных. Использует `DatabaseInitializer` через интерфейс из Domain layer для создания таблиц при переинициализации БД.

**DatabaseInitializerImpl**
Реализация интерфейса `DatabaseInitializer` из Domain layer. Использует `FactionDao.createTable()` для создания таблиц базы данных. Позволяет Presentation layer не зависеть напрямую от Data layer datasources, что соответствует принципам Clean Architecture.

#### Factory (Фабрика репозиториев)

**RepositoryFactory**
Фабрика для создания репозиториев в Data layer. Инкапсулирует создание репозиториев с их зависимостями внутри Data layer, что позволяет Presentation layer (ServiceLocator) создавать репозитории без прямого знания о datasources (FactionDao). Предоставляет статический метод `createFactionRepository(Database db)` для создания `FactionRepositoryImpl` с `FactionDao`. **Важно:** Фабрика обеспечивает соблюдение принципов Clean Architecture и Dependency Inversion, скрывая детали реализации Data layer от Presentation layer.

### Presentation Layer

#### Dependency Injection

**ServiceLocator**
Централизованный контейнер для управления зависимостями. Расположен в `presentation/di/service_locator.dart`. Инициализирует базу данных (версия 1) и создает экземпляры репозиториев и провайдеров (FactionRepository, FactionTemplateRepository, AppSettingsRepository, DateTimeProvider, FileExporter, FileImporter, DatabasePathProvider, DatabaseInitializer). База данных создается при первом запуске через `DatabaseInitializer` (используется интерфейс из Domain layer, реализация из Data layer). **Важно:** ServiceLocator использует `DatabaseInitializer` через интерфейс из Domain layer и `RepositoryFactory` для создания репозиториев, что позволяет избежать прямых зависимостей от Data layer datasources (FactionDao) и соответствует принципам Clean Architecture. Импортирует интерфейсы репозиториев из Domain layer для типизации и реализации из Data layer для создания экземпляров. Используется на уровне страниц для создания зависимостей, которые затем передаются в виджеты через конструкторы. Предоставляет методы `getDatabasePath()` для получения пути к БД и `reinitializeDatabase()` для переинициализации БД после импорта (валидация файла, закрытие текущего соединения, копирование импортированного файла, переоткрытие соединения).

#### BLoC

**FactionBloc**
- `LoadFactions` - загрузка всех видимых фракций
- `AddFactionEvent` - добавление фракции
- `UpdateFactionEvent` - обновление фракции (с оптимистичным обновлением UI)
- `DeleteFactionEvent` - скрытие фракции (устанавливает `isVisible = false`)
- `ShowFactionEvent` - показ скрытой фракции (устанавливает `isVisible = true`)
- `ResetDailyFlagsEvent` - сброс ежедневных отметок
- `ReorderFactionsEvent` - изменение порядка фракций (с оптимистичным обновлением UI)
- `getHiddenFactions()` - метод для получения скрытых фракций (используется в диалоге выбора)

#### Pages

**MainPage**
Главная страница с Drawer для навигации между разделами:
1. Фракции - открывает FactionsPage
2. Карта - открывает MapPage

**FactionsPage**
Страница фракций, отображающая список всех фракций. Имеет FloatingActionButton для добавления новой фракции. Создает все необходимые зависимости через ServiceLocator (ReputationHelper, use cases, репозитории) и передает их в FactionsListPage через конструктор.

**FactionsListPage**
Отображает список всех фракций с возможностью:
- Скрытия свайпом (с подтверждением)
- Изменения порядка через drag-and-drop (ReorderableListView)
- Редактирования валюты и валюты с работы через диалоги
- Переключения статуса заказов и сертификата через бейджи/иконки
- Обновления списка через pull-to-refresh (RefreshIndicator)

Получает все зависимости через конструктор (ReputationHelper, CalculateTimeToCurrencyGoal, CalculateTimeToReputationGoal, AppSettingsRepository, FactionTemplateRepository). Не использует ServiceLocator напрямую, что обеспечивает соблюдение принципа Dependency Inversion.

**FactionDetailPage**
Страница редактирования фракции с нижней навигацией (BottomNavigationBar). Название фракции отображается в заголовке AppBar. Кнопка сохранения находится в AppBar. Получает `FactionTemplateRepository` через конструктор для проверки наличия заказов/работы/сертификата (не обращается напрямую к Data layer).

Страница разделена на две вкладки (реализованы в `widgets/faction/tabs/`):

**Вкладка "Настройки" (index 0) - `FactionSettingsTab`:**
- Ежедневные активности (блок `FactionActivitiesBlock` с галочкой "Заказы" и полями ввода для работы)
- Цели (блок `FactionGoalsBlock` с целевым уровнем репутации и галочкой "Нужен сертификат")

**Вкладка "Инвентарь" (index 1) - `FactionInventoryTab`:**
- Валюта (блок `FactionCurrencyBlock` для редактирования валюты)
- Репутация (блок `FactionReputationBlock` с текущим уровнем отношения и опытом на уровне)
- Сертификат (блок `FactionCertificateBlock`)
- Украшения (блок `FactionDecorationsSection` с тремя украшениями)

**Условия отображения блоков:**
- **FactionReputationBlock:** Отображается только если `targetReputationLevel != null` (установлен целевой уровень репутации). Позволяет редактировать текущий уровень репутации и опыт
- **FactionCurrencyBlock, FactionDecorationsSection, FactionCertificateBlock:** Отображаются только если `wantsCertificate == true` (нужен сертификат как цель). Эти блоки связаны с целью по валюте (покупка украшений и сертификата)

**Примечание:** 
- Валюту можно редактировать из карточки фракции или во вкладке "Инвентарь"
- Для фракций без заказов (определяется по статическому списку) галочка "Заказы" не отображается
- Для фракций без работы (определяется по статическому списку) поля ввода для работы не отображаются
- Для фракций без сертификата (определяется по статическому списку) галочка "Сертификат" не отображается во вкладке "Инвентарь"
- В списке целевых уровней репутации отображаются только уровни выше текущего уровня
- При изменении текущего уровня, если целевой уровень стал ниже или равен текущему, он автоматически переключается на следующий доступный уровень

**MapPage**
Заглушка для будущей функциональности карты ресурсов.

#### Widgets

**FactionCard**
Основная карточка фракции в списке. Структура из 3 строк:
- Строка 1: Название фракции (`FactionNameDisplay`) и список активностей (`FactionActivitiesList`)
- Строка 2: Progress bar валюты (`CurrencyProgressBar`) и время до цели по валюте (`TimeToCurrencyGoalWidget`)
- Строка 3: Progress bar опыта (`ReputationProgressBar`) и время до цели по репутации (`TimeToReputationGoalWidget`)
- Получает `AppSettingsRepository` и `FactionTemplateRepository` через конструктор и передает их в дочерние виджеты

**Условия отображения:**
- **Строка с progress bars (строка 2):** Отображается только если установлена хотя бы одна цель:
  - `wantsCertificate == true` (нужен сертификат как цель)
  - ИЛИ `targetReputationLevel != null` (установлен целевой уровень репутации)
  - Если обе цели не установлены, строка с progress bars не отображается
- **CurrencyProgressBar:** Отображается только если `wantsCertificate == true`. Показывает прогресс по валюте для покупки украшений и сертификата
- **ReputationProgressBar:** Отображается только если `targetReputationLevel != null`. Показывает прогресс по опыту репутации до целевого уровня

**FactionNameDisplay**
Виджет отображения названия фракции с заданным стилем (жирный, 18px, белый).

**CurrencyProgressBar**
Виджет для отображения прогресса валюты с progress bar:
- Отображает текущую валюту/нужную валюту в формате "текущая/нужная" (например, "5000/15000") внутри полоски
- Progress bar с оранжевым/акцентным цветом
- Кликабельный - при клике открывает `CurrencyInputDialog` для редактирования валюты
- Использует ту же логику расчета нужной валюты, что и `CalculateTimeToCurrencyGoal`
- Получает `AppSettingsRepository` и `FactionTemplateRepository` через конструктор (не обращается напрямую к Data layer)

**FactionActivitiesList**
Виджет отображения списка активностей в виде бейджей:
- **Заказ** - отображается только если `ordersEnabled == true` и фракция имеет заказы согласно статическому списку, кликабельно для переключения статуса `orderCompleted`
- **Работа** - отображается только если фракция имеет работу согласно статическому списку и `workReward != null` с хотя бы одним полем > 0, показывает валюту с работы (если указана) или "Работа", кликабельно для переключения статуса `workCompleted`
- Получает `FactionTemplateRepository` через конструктор для проверки наличия заказов/работы (не обращается напрямую к Data layer)

Бейджи всегда видны: заполненные, если активность выполнена, с контуром, если не выполнена.

**ActivityBadge**
Переиспользуемый виджет бейджа активности с:
- Настраиваемым текстом и цветом
- Сплошным фоном при выполнении (без прозрачности)
- Белым текстом при выполнении
- Контуром при невыполнении
- Компактным размером

**TimeToCurrencyGoalWidget**
Компактный виджет расчета и отображения времени до достижения цели по валюте. Отображается в карточке фракции во второй строке справа от progress bar валюты. Имеет:
- Компактный формат отображения
- Индикатор загрузки (только при первой загрузке)
- Оптимистичное обновление - показывает предыдущее значение при пересчете
- Сообщения при отсутствии данных
- Автоматический пересчет при изменении полей, влияющих на расчет (currency, ordersEnabled, workReward, wantsCertificate, украшения и т.д.)
- Использует среднее арифметическое валюты из `FactionTemplate.orderReward` для расчета валюты за заказы
- Использует `faction.workReward.currency` для расчета валюты за работу
- Возвращает `null` если `wantsCertificate = false` (цель не установлена)

**TimeToReputationGoalWidget**
Компактный виджет расчета и отображения времени до достижения цели по репутации. Отображается в карточке фракции справа от progress bar опыта. Имеет:
- Компактный формат отображения (только текст, без иконок)
- Индикатор загрузки (только при первой загрузке)
- Оптимистичное обновление - показывает предыдущее значение при пересчете
- Сообщения при отсутствии данных
- Автоматический пересчет при изменении полей, влияющих на расчет (currentReputationLevel, currentLevelExp, targetReputationLevel, ordersEnabled, workReward)
- Использует среднее арифметическое опыта из `FactionTemplate.orderReward` для расчета опыта за заказы
- Использует `faction.workReward.exp` для расчета опыта за работу

**ReputationProgressBar**
Виджет для отображения прогресса уровня отношения с progress bar:
- Отображает опыт на текущем уровне в формате "текущий/требуемый" (например, "5000/43000") внутри полоски
- Progress bar с цветом, соответствующим уровню отношения
- Прижимается к краям карточки снизу
- Использует `faction.currentReputationLevel` и `faction.currentLevelExp` напрямую
- Получает `FactionTemplateRepository` через конструктор для проверки наличия заказов (не обращается напрямую к Data layer)

**HelpDialog**
Переиспользуемый компонент для отображения модалки помощи:
- Единый стиль для всех модалок помощи в приложении
- Параметры: `title` (заголовок), `content` (текст помощи)
- Статический метод `show()` для удобного вызова

**FactionCurrencyBlock**
Блок для редактирования валюты фракции, используется во вкладке "Инвентарь":
- Позволяет редактировать валюту через диалог
- Отображает текущее значение валюты
- Имеет иконку помощи с пояснением о валюте

**FactionReputationBlock**
Блок для редактирования текущего уровня отношения и опыта на уровне, используется во вкладке "Инвентарь":
- Позволяет выбрать текущий уровень отношения через Dropdown (без "Максимальный")
- Позволяет редактировать текущий опыт через диалог
- Имеет иконку помощи с пояснением о репутации

**FactionGoalsBlock**
Блок "Цели" для настройки целей во вкладке "Настройки":
- Позволяет выбрать целевой уровень отношения через Dropdown (только уровни выше текущего, опция "Не нужна")
- Позволяет указать, нужен ли сертификат как цель через чекбокс
- Имеет иконку помощи с пояснением о целях

**FactionCertificateBlock**
Блок для отметки покупки сертификата, используется во вкладке "Инвентарь":
- Отображается только для фракций с сертификатом (определяется по статическому списку)
- Позволяет отметить, куплен ли сертификат
- Имеет иконку помощи с пояснением о сертификате
- Получает `FactionTemplateRepository` через конструктор для проверки наличия сертификата (не обращается напрямую к Data layer)

**FactionDecorationsSection**
Секция украшений с компактными карточками для каждого украшения (Уважение, Почтение, Преклонение):
- Используется во вкладке "Инвентарь"
- Позволяет отметить, куплено и улучшено ли каждое украшение
- Имеет иконку помощи с пояснением об украшениях

**FactionSelectionDialog**
Диалог выбора фракции из списка скрытых фракций. Отображает:
- Список всех скрытых фракций
- Информацию о типе фракции (с заказами и работой / только с работой)
- При выборе фракции показывает её в списке (устанавливает `isVisible = true`)
- Отображение времени в формате "Xд" (только дни, округление вверх)
- Использует `FittedBox` с `BoxFit.scaleDown` для предотвращения переполнения

**Дополнительные виджеты:**
- `HelpDialog` - переиспользуемый компонент для отображения модалки помощи. Используется во всех блоках с иконками помощи (расположен в `widgets/common/`)
- `WorkCurrencyBadge` - бейдж для отображения валюты с работы, кликабельно для редактирования (расположен в `widgets/currency/`)
- `CurrencyInputDialog` - универсальный диалог для ввода/редактирования валюты (поддерживает пустые значения для валюты с работы, расположен в `widgets/currency/`)
- `FactionActivitiesBlock` - блок ежедневных активностей с галочками "Заказы" и "Работы". Имеет параметры `showOrderCheckbox` и `showWorkInput` для управления видимостью элементов (скрываются для фракций без соответствующих активностей согласно статическому списку). Имеет иконку помощи с пояснением (расположен в `widgets/faction/`)
- `FactionCurrencyBlock` - блок для редактирования валюты фракции. Используется во вкладке "Инвентарь". Имеет иконку помощи с пояснением (расположен в `widgets/faction/`)
- `FactionReputationBlock` - блок для редактирования текущего уровня отношения и текущего опыта. Используется во вкладке "Инвентарь". Имеет иконку помощи с пояснением (расположен в `widgets/faction/`)
- `FactionGoalsBlock` - блок "Цели" с целевым уровнем репутации и галочкой "Нужен сертификат". Используется во вкладке "Настройки". Имеет иконку помощи с пояснением (расположен в `widgets/faction/`)
- `FactionCertificateBlock` - блок для отметки покупки сертификата. Используется во вкладке "Инвентарь". Имеет иконку помощи с пояснением (расположен в `widgets/faction/`)
- `FactionDecorationsSection` - секция украшений с компактными карточками для каждого украшения (Уважение, Почтение, Преклонение). Используется во вкладке "Инвентарь". Имеет иконку помощи с пояснением (расположен в `widgets/faction/`)
- `FactionSelectionDialog` - диалог выбора фракции из списка скрытых фракций для добавления в видимый список (расположен в `widgets/faction/`)
- `FactionActivitiesSection` - секция активностей и сертификата (не используется в текущей реализации, но присутствует в коде, расположен в `widgets/faction/`)
- `FactionBasicInfoSection` - секция базовой информации о фракции (не используется в текущей реализации, но присутствует в коде, расположен в `widgets/faction/`)

