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
│   └── utils/                         # Утилиты
│       ├── daily_reset_helper.dart    # Сброс ежедневных отметок
│       └── time_formatter.dart         # Форматирование времени
├── domain/                            # Доменный слой
│   ├── entities/                      # Сущности
│   │   ├── faction.dart
│   │   ├── reputation_level.dart
│   │   └── settings.dart
│   ├── repositories/                  # Интерфейсы репозиториев
│   │   ├── faction_repository.dart
│   │   └── settings_repository.dart
│   └── usecases/                      # Сценарии использования
│       ├── add_faction.dart
│       ├── calculate_time_to_goal.dart
│       ├── delete_faction.dart
│       ├── get_all_factions.dart
│       ├── get_settings.dart
│       ├── reset_daily_flags.dart
│       ├── update_faction.dart
│       └── update_settings.dart
├── data/                               # Слой данных
│   ├── datasources/                   # Источники данных
│   │   ├── faction_dao.dart           # DAO для фракций
│   │   └── settings_dao.dart          # DAO для настроек
│   ├── models/                        # Модели данных
│   │   ├── faction_model.dart
│   │   └── settings_model.dart
│   └── repositories/                  # Реализации репозиториев
│       ├── faction_repository_impl.dart
│       └── settings_repository_impl.dart
└── presentation/                       # Слой представления
    ├── bloc/                          # State Management
    │   ├── faction/
    │   │   ├── faction_bloc.dart
    │   │   ├── faction_event.dart
    │   │   └── faction_state.dart
    │   └── settings/
    │       ├── settings_bloc.dart
    │       ├── settings_event.dart
    │       └── settings_state.dart
    ├── pages/                         # Страницы
    │   ├── faction_detail_page.dart
    │   ├── factions_list_page.dart
    │   ├── factions_page.dart
    │   ├── main_page.dart
    │   ├── map_page.dart
    │   └── settings_page.dart
    └── widgets/                       # Виджеты
        ├── activity_badge.dart
        ├── board_currency_badge.dart
        ├── currency_input_dialog.dart
        ├── faction_activities_list.dart
        ├── faction_activities_section.dart
        ├── faction_basic_info_section.dart
        ├── faction_card.dart
        ├── faction_currency_display.dart
        ├── faction_decorations_section.dart
        ├── faction_name_display.dart
        └── time_to_goal_widget.dart
```

## Описание основных компонентов

### Core Layer

#### ServiceLocator
Централизованный контейнер для управления зависимостями. Инициализирует базу данных и создает экземпляры репозиториев.

#### DailyResetHelper
Проверяет при запуске приложения, нужно ли сбросить ежедневные отметки (заказы/события). Использует SharedPreferences для хранения даты последнего сброса.

#### TimeFormatter
Форматирует Duration в читаемый формат на русском языке (дни, часы, минуты).

#### AppTheme
Темная тема приложения, стилизованная под игру Revelation Online:
- Темные фоны (#1A1A1A, #0F0F0F, #2A2A2A)
- Акцентные цвета (оранжевый #FF6B35, синий #4A90E2)
- Цвета для каждого уровня репутации
- Градиенты для визуальных эффектов
- Стилизованные карточки, кнопки, поля ввода

### Domain Layer

#### Entities

**Faction**
- `id` - уникальный идентификатор
- `name` - название фракции
- `currency` - текущее количество валюты (int)
- `reputationLevel` - уровень репутации
- `hasOrder` - есть ли заказы во фракции (по умолчанию false)
- `orderCompleted` - выполнено ли задание заказа
- `boardCurrency` - валюта с доски (null если доски нет, int)
- `hasCertificate` - есть ли сертификат во фракции
- `certificatePurchased` - куплен ли сертификат
- `displayOrder` - порядок отображения фракций (int, по умолчанию 0)
- Флаги для каждого украшения (куплено/улучшено)

**Settings**
- `itemPrice` - цена одной итемки (int)
- `itemCountRespect/Honor/Adoration` - количество итемок для улучшения каждого украшения (int)
- `decorationPriceRespect/Honor/Adoration` - стоимость каждого украшения (int)
- `currencyPerOrder` - валюта за заказ (int)
- `certificatePrice` - стоимость сертификата (int)

**ReputationLevel**
Enum с 6 уровнями репутации от равнодушия до обожествления. Каждый уровень имеет:
- Отображаемое имя на русском языке
- Числовое значение (0-5)
- Цвет для визуального отображения (extension `ReputationLevelColorExtension`)
  - Равнодушие: бледно-коричневый (#A1887F)
  - Дружелюбие: темно-зеленый (#388E3C)
  - Уважение: зеленый (#4CAF50)
  - Почтение: бирюзовый (#26A69A)
  - Преклонение: синий (#2196F3)
  - Обожествление: фиолетовый (#9C27B0)

### Data Layer

#### DAO (Data Access Objects)

**FactionDao**
- `createTable()` - создание таблицы factions
- `getAllFactions()` - получение всех фракций, отсортированных по `displayOrder`
- `getFactionById()` - получение фракции по ID
- `insertFaction()` - добавление новой фракции
- `updateFaction()` - обновление фракции
- `deleteFaction()` - удаление фракции
- `resetDailyFlags()` - сброс ежедневных отметок
- `updateFactionOrder()` - обновление порядка одной фракции
- `updateFactionsOrder()` - массовое обновление порядка фракций

**SettingsDao**
- `createTable()` - создание таблицы settings
- `getSettings()` - получение настроек
- `updateSettings()` - обновление настроек

#### Models

Модели выполняют маппинг между entities и данными базы данных (Map<String, dynamic>).

### Presentation Layer

#### BLoC

**FactionBloc**
- `LoadFactions` - загрузка всех фракций
- `AddFactionEvent` - добавление фракции
- `UpdateFactionEvent` - обновление фракции
- `DeleteFactionEvent` - удаление фракции
- `ResetDailyFlagsEvent` - сброс ежедневных отметок
- `ReorderFactionsEvent` - изменение порядка фракций (с оптимистичным обновлением UI)
- `UpdateFactionEvent` - обновление фракции (с оптимистичным обновлением UI)

**SettingsBloc**
- `LoadSettings` - загрузка настроек
- `UpdateSettingsEvent` - обновление настроек

#### Pages

**MainPage**
Главная страница с Drawer для навигации между разделами:
1. Фракции - открывает FactionsPage
2. Карта - открывает MapPage

**FactionsPage**
Страница фракций с BottomNavigationBar, содержащая две вкладки:
1. Список - FactionsListPage
2. Настройки - SettingsPage
Имеет FloatingActionButton для добавления новой фракции (только на вкладке "Список").

**FactionsListPage**
Отображает список всех фракций с возможностью:
- Удаления свайпом (с подтверждением)
- Изменения порядка через drag-and-drop (ReorderableListView)
- Редактирования валюты и валюты с доски через диалоги
- Переключения статуса заказов и сертификата через бейджи/иконки
- Обновления списка через pull-to-refresh (RefreshIndicator)

**FactionDetailPage**
Оптимизированная страница редактирования/создания фракции. Содержит:
- Основную информацию (название, уровень репутации)
- Активности и сертификат (горизонтальные чекбоксы)
- Украшения (компактные карточки с чекбоксами)

**Примечание:** Валюту и валюту с доски можно редактировать из карточки фракции, поэтому они не отображаются на этой странице.

**SettingsPage**
Страница редактирования общих настроек приложения.

**MapPage**
Заглушка для будущей функциональности карты ресурсов.

#### Widgets

**FactionCard**
Основная карточка фракции в списке. Объединяет компоненты:
- Цветная полоса слева, соответствующая уровню репутации
- Название фракции (`FactionNameDisplay`)
- Отображение валюты (`FactionCurrencyDisplay`) - кликабельно для редактирования
- Список активностей (`FactionActivitiesList`) - Заказ и Доска
- Компактное отображение времени до цели (`TimeToGoalWidget`)

**FactionNameDisplay**
Виджет отображения названия фракции с заданным стилем (жирный, 18px, белый).

**FactionCurrencyDisplay**
Виджет отображения валюты фракции с иконкой монеты и числовым значением. Поддерживает редактирование через `onTap` callback, который открывает `CurrencyInputDialog`.

**FactionActivitiesList**
Виджет отображения списка активностей в виде бейджей:
- **Заказ** - отображается только если `hasOrder == true`, кликабельно для переключения статуса
- **Доска** (`BoardCurrencyBadge`) - всегда отображается, показывает валюту с доски или "Доска", кликабельно для редактирования

Бейджи всегда видны: заполненные, если активность выполнена, с контуром, если не выполнена.

**ActivityBadge**
Переиспользуемый виджет бейджа активности с:
- Настраиваемым текстом и цветом
- Сплошным фоном при выполнении (без прозрачности)
- Белым текстом при выполнении
- Контуром при невыполнении
- Компактным размером

**TimeToGoalWidget**
Компактный виджет расчета и отображения времени до достижения цели. Отображается в карточке фракции. Имеет:
- Компактный формат отображения
- Индикатор загрузки (только при первой загрузке)
- Оптимистичное обновление - показывает предыдущее значение при пересчете
- Сообщения при отсутствии данных
- Отображение времени в формате "X д Y ч Z м" (сокращения)
- Использует `FittedBox` с `BoxFit.scaleDown` для предотвращения переполнения

**Дополнительные виджеты:**
- `BoardCurrencyBadge` - бейдж для отображения валюты с доски, кликабельно для редактирования
- `CurrencyInputDialog` - универсальный диалог для ввода/редактирования валюты (поддерживает пустые значения для валюты с доски)
- `FactionBasicInfoSection` - секция основной информации о фракции
- `FactionActivitiesSection` - секция активностей и сертификата с горизонтальными чекбоксами
- `FactionDecorationsSection` - секция украшений с компактными карточками

