# Структура проекта

## Общая структура

```
lib/
├── main.dart                          # Точка входа приложения
├── core/                              # Ядро приложения
│   ├── database/                      # Настройка БД
│   ├── di/                            # Dependency Injection
│   │   └── service_locator.dart       # DI контейнер
│   ├── theme/                         # Тема приложения
│   │   └── app_theme.dart             # Темная тема в стиле игры
│   ├── constants/                     # Константы
│   │   └── app_settings.dart          # Настройки приложения
│   └── utils/                         # Утилиты
│       ├── daily_reset_helper.dart    # Сброс ежедневных отметок
│       └── time_formatter.dart         # Форматирование времени
├── domain/                            # Доменный слой
│   ├── entities/                      # Сущности
│   │   └── faction.dart
│   ├── repositories/                  # Интерфейсы репозиториев
│   │   └── faction_repository.dart
│   └── usecases/                      # Сценарии использования
│       ├── add_faction.dart
│       ├── calculate_time_to_goal.dart
│       ├── delete_faction.dart
│       ├── get_all_factions.dart
│       ├── initialize_factions.dart
│       ├── reset_daily_flags.dart
│       ├── show_faction.dart
│       ├── update_faction.dart
│       └── reorder_factions.dart
├── data/                               # Слой данных
│   ├── datasources/                   # Источники данных
│   │   └── faction_dao.dart           # DAO для фракций
│   ├── models/                        # Модели данных
│   │   └── faction_model.dart
│   └── repositories/                  # Реализации репозиториев
│       └── faction_repository_impl.dart
└── presentation/                       # Слой представления
    ├── bloc/                          # State Management
    │   └── faction/
    │       ├── faction_bloc.dart
    │       ├── faction_event.dart
    │       └── faction_state.dart
    ├── pages/                         # Страницы
    │   ├── faction_detail_page.dart
    │   ├── factions_list_page.dart
    │   ├── factions_page.dart
    │   ├── main_page.dart
    │   └── map_page.dart
    └── widgets/                       # Виджеты
        ├── activity_badge.dart
        ├── work_currency_badge.dart
        ├── currency_input_dialog.dart
        ├── faction_activities_list.dart
        ├── faction_activities_block.dart
        ├── faction_activities_section.dart
        ├── faction_basic_info_section.dart
        ├── faction_card.dart
        ├── faction_certificate_block.dart
        ├── currency_progress_bar.dart
        ├── faction_decorations_section.dart
        ├── faction_name_display.dart
        ├── faction_selection_dialog.dart
        ├── time_to_currency_goal_widget.dart
        └── time_to_reputation_goal_widget.dart
```

## Описание основных компонентов

### Core Layer

#### AppSettings
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

#### FactionsList
Статический список всех доступных фракций игры с предустановленными настройками. Каждая фракция имеет шаблон (`FactionTemplate`) с полями:
- `name` - название фракции
- `hasOrder` - есть ли заказы во фракции
- `hasWork` - есть ли работа во фракции
- `hasCertificate` - есть ли сертификат во фракции
- `orderRewards` - массив наград за заказы (валюта и опыт) (nullable, только для фракций с заказами)

**Использование:** 
- `FactionsList.allFactions` - получить все фракции
- `FactionsList.getTemplateByName(String name)` - получить шаблон фракции по имени
- `FactionsList.createFactionFromTemplate(template)` - создать фракцию из шаблона

**Примечание:** Для фракций с заказами в `orderRewards` хранится массив наград за заказы (валюта и опыт), которые могут варьироваться в разные дни. При расчете времени до цели используется среднее арифметическое валюты и опыта отдельно.

#### ServiceLocator
Централизованный контейнер для управления зависимостями. Инициализирует базу данных (версия 9) и создает экземпляры репозиториев. База данных создается при первом запуске через `FactionDao.createTable()`.

#### DailyResetHelper
Проверяет при запуске приложения, нужно ли сбросить ежедневные отметки (заказы/события). Использует SharedPreferences для хранения даты последнего сброса.

#### TimeFormatter
Форматирует Duration в читаемый формат на русском языке (дни, часы, минуты).

#### AppTheme
Темная тема приложения, стилизованная под игру Revelation Online:
- Темные фоны (#1A1A1A, #0F0F0F, #2A2A2A)
- Акцентные цвета (оранжевый #FF6B35, синий #4A90E2)
- Градиенты для визуальных эффектов
- Стилизованные карточки, кнопки, поля ввода

### Domain Layer

#### Entities

**Faction**
- `id` - уникальный идентификатор
- `name` - название фракции
- `currency` - текущее количество валюты (int)
- `hasOrder` - есть ли заказы во фракции (по умолчанию false)
- `orderCompleted` - выполнено ли задание заказа
- `workCurrency` - валюта с работы (null если работы нет, int)
- `hasWork` - учитывать ли работу в калькуляторе (по умолчанию false)
- `workCompleted` - выполнена ли работа
- `hasCertificate` - есть ли сертификат во фракции
- `certificatePurchased` - куплен ли сертификат
- `displayOrder` - порядок отображения фракций (int, по умолчанию 0)
- `isVisible` - видимость фракции в списке (bool, по умолчанию true)
- `currentReputationLevel` - текущий уровень отношения (ReputationLevel, по умолчанию indifference)
- `currentLevelExp` - опыт на текущем уровне (int, от 0 до требуемого для уровня, по умолчанию 0)
- `targetReputationLevel` - целевой уровень отношения (ReputationLevel, по умолчанию maximum)
- Флаги для каждого украшения (куплено/улучшено)

### Data Layer

#### DAO (Data Access Objects)

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

#### Models

Модели выполняют маппинг между entities и данными базы данных (Map<String, dynamic>).

### Presentation Layer

#### BLoC

**FactionBloc**
- `LoadFactions` - загрузка всех фракций
- `AddFactionEvent` - добавление фракции
- `UpdateFactionEvent` - обновление фракции
- `DeleteFactionEvent` - скрытие фракции
- `ResetDailyFlagsEvent` - сброс ежедневных отметок
- `ReorderFactionsEvent` - изменение порядка фракций (с оптимистичным обновлением UI)
- `UpdateFactionEvent` - обновление фракции (с оптимистичным обновлением UI)

#### Pages

**MainPage**
Главная страница с Drawer для навигации между разделами:
1. Фракции - открывает FactionsPage
2. Карта - открывает MapPage

**FactionsPage**
Страница фракций, отображающая список всех фракций. Имеет FloatingActionButton для добавления новой фракции.

**FactionsListPage**
Отображает список всех фракций с возможностью:
- Скрытия свайпом (с подтверждением)
- Изменения порядка через drag-and-drop (ReorderableListView)
- Редактирования валюты и валюты с работы через диалоги
- Переключения статуса заказов и сертификата через бейджи/иконки
- Обновления списка через pull-to-refresh (RefreshIndicator)

**FactionDetailPage**
Страница редактирования фракции. Название фракции отображается в заголовке AppBar.
Оптимизированная страница редактирования фракции. Содержит:
- Репутация (блок `FactionReputationBlock` для управления уровнем и опытом)
- Ежедневные активности (блок с галочками "Заказы" и "Работы" через `FactionActivitiesBlock`)
- Сертификат (отдельный блок `FactionCertificateBlock` с галочкой "Сертификат")
- Украшения (компактные карточки с чекбоксами через `FactionDecorationsSection`)

**Примечание:** 
- Валюту и валюту с работы можно редактировать из карточки фракции, поэтому они не отображаются на этой странице
- Для фракций без заказов (определяется по статическому списку) галочка "Заказы" не отображается
- Для фракций без работы (определяется по статическому списку) галочка "Работы" не отображается
- Для фракций без сертификата (определяется по статическому списку) галочка "Сертификат" не отображается

**MapPage**
Заглушка для будущей функциональности карты ресурсов.

#### Widgets

**FactionCard**
Основная карточка фракции в списке. Структура из 3 строк:
- Строка 1: Название фракции (`FactionNameDisplay`) и список активностей (`FactionActivitiesList`)
- Строка 2: Progress bar валюты (`CurrencyProgressBar`) и время до цели по валюте (`TimeToCurrencyGoalWidget`)
- Строка 3: Progress bar опыта (`ReputationProgressBar`) и время до цели по репутации (`TimeToReputationGoalWidget`)

**FactionNameDisplay**
Виджет отображения названия фракции с заданным стилем (жирный, 18px, белый).

**CurrencyProgressBar**
Виджет для отображения прогресса валюты с progress bar:
- Отображает текущую валюту/нужную валюту в формате "текущая/нужная" (например, "5000/15000") внутри полоски
- Progress bar с оранжевым/акцентным цветом
- Кликабельный - при клике открывает `CurrencyInputDialog` для редактирования валюты
- Использует ту же логику расчета нужной валюты, что и `CalculateTimeToCurrencyGoal`

**FactionActivitiesList**
Виджет отображения списка активностей в виде бейджей:
- **Заказ** - отображается только если `hasOrder == true`, кликабельно для переключения статуса `orderCompleted`
- **Работа** - отображается только если `hasWork == true`, показывает валюту с работы (если указана) или "Работа", кликабельно для переключения статуса `workCompleted`

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
- Автоматический пересчет при изменении полей, влияющих на расчет (currency, hasOrder, hasWork, hasCertificate, украшения и т.д.)
- Использует среднее арифметическое валюты из `FactionTemplate.orderRewards` для расчета валюты за заказы
- Использует `faction.workCurrency` для расчета валюты за работу

**TimeToReputationGoalWidget**
Компактный виджет расчета и отображения времени до достижения цели по репутации. Отображается в карточке фракции справа от progress bar опыта. Имеет:
- Компактный формат отображения (только текст, без иконок)
- Индикатор загрузки (только при первой загрузке)
- Оптимистичное обновление - показывает предыдущее значение при пересчете
- Сообщения при отсутствии данных
- Автоматический пересчет при изменении полей, влияющих на расчет (currentReputationLevel, currentLevelExp, targetReputationLevel, hasOrder)
- Использует среднее арифметическое опыта из `FactionTemplate.orderRewards` для расчета опыта за заказы

**ReputationProgressBar**
Виджет для отображения прогресса уровня отношения с progress bar:
- Отображает опыт на текущем уровне в формате "текущий/требуемый" (например, "5000/43000") внутри полоски
- Progress bar с цветом, соответствующим уровню отношения
- Прижимается к краям карточки снизу
- Использует `faction.currentReputationLevel` и `faction.currentLevelExp` напрямую

**FactionReputationBlock**
Блок для управления репутацией на странице деталей фракции:
- Позволяет выбрать текущий уровень отношения через Dropdown (без "Максимальный")
- Позволяет редактировать опыт на текущем уровне
- Позволяет выбрать целевой уровень отношения

**FactionSelectionDialog**
Диалог выбора фракции из списка скрытых фракций. Отображает:
- Список всех скрытых фракций
- Информацию о типе фракции (с заказами и работой / только с работой)
- При выборе фракции показывает её в списке (устанавливает `isVisible = true`)
- Отображение времени в формате "Xд" (только дни, округление вверх)
- Использует `FittedBox` с `BoxFit.scaleDown` для предотвращения переполнения

**Дополнительные виджеты:**
- `WorkCurrencyBadge` - бейдж для отображения валюты с работы, кликабельно для редактирования
- `CurrencyInputDialog` - универсальный диалог для ввода/редактирования валюты (поддерживает пустые значения для валюты с работы)
- `FactionActivitiesBlock` - блок ежедневных активностей с галочками "Заказы" и "Работы". Имеет параметры `showOrderCheckbox` и `showWorkCheckbox` для управления видимостью галочек (скрываются для фракций без соответствующих активностей согласно статическому списку)
- `FactionCertificateBlock` - отдельный блок для управления сертификатом с галочкой "Сертификат". Имеет параметр `showCertificateCheckbox` для управления видимостью галочки (скрывается для фракций без сертификата согласно статическому списку)
- `FactionDecorationsSection` - секция украшений с компактными карточками для каждого украшения (Уважение, Почтение, Преклонение)
- `FactionSelectionDialog` - диалог выбора фракции из списка скрытых фракций для добавления в видимый список

