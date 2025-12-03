# Архитектура приложения

## Обзор

Приложение построено по принципам **Clean Architecture**, что обеспечивает разделение ответственности и независимость слоев.

## Слои архитектуры

### 1. Domain Layer (Доменный слой)

**Расположение:** `lib/domain/`

Самый внутренний слой, не зависящий от внешних библиотек и фреймворков.

#### Entities (Сущности)
- `Faction` - представляет фракцию со всеми её параметрами

#### Repositories (Интерфейсы репозиториев)
- `FactionRepository` - интерфейс для работы с фракциями

#### Use Cases (Сценарии использования)
- `GetAllFactions` - получение видимых фракций
- `InitializeFactions` - инициализация всех фракций из статического списка
- `AddFaction` - добавление новой фракции в БД
- `UpdateFaction` - обновление фракции
- `DeleteFaction` - скрытие фракции (устанавливает `isVisible = false`)
- `ShowFaction` - показ скрытой фракции (устанавливает `isVisible = true`)
- `CalculateTimeToCurrencyGoal` - расчет времени до достижения цели по валюте (использует константы из AppSettings и среднее арифметическое валюты из FactionTemplate.orderRewards для заказов)
- `CalculateTimeToReputationGoal` - расчет времени до достижения целевого уровня отношения (использует среднее арифметическое опыта из FactionTemplate.orderRewards для заказов)
- `ResetDailyFlags` - сброс ежедневных отметок
- `ReorderFactions` - изменение порядка фракций

### 2. Data Layer (Слой данных)

**Расположение:** `lib/data/`

Реализует интерфейсы из Domain слоя и работает с базой данных.

#### Models (Модели данных)
- `FactionModel` - модель для маппинга Faction entity в/из базы данных

#### Data Sources (Источники данных)
- `FactionDao` - DAO для работы с таблицей factions в SQLite

#### Repositories (Реализации репозиториев)
- `FactionRepositoryImpl` - реализация FactionRepository

### 3. Presentation Layer (Слой представления)

**Расположение:** `lib/presentation/`

Отвечает за UI и управление состоянием.

#### Pages (Страницы)
- `pages/main/main_page.dart` - главная страница с Drawer для навигации между разделами
- `pages/faction/factions_page.dart` - страница фракций со списком видимых фракций и кнопкой добавления (выбор из скрытых)
- `pages/faction/factions_list_page.dart` - список видимых фракций с возможностью скрытия свайпом и изменения порядка (drag-and-drop)
- `pages/faction/faction_detail_page.dart` - детальная информация и редактирование фракции (оптимизированная версия с компактными секциями). Название фракции отображается в заголовке AppBar.
- `pages/map/map_page.dart` - заглушка для будущей карты ресурсов

#### Widgets (Виджеты)

**Виджеты фракций** (`widgets/faction/`):
- `FactionCard` - карточка фракции в списке с новой структурой из 3 строк (название+активности, progress bar валюты+время, progress bar опыта+время)
- `FactionNameDisplay` - отображение названия фракции
- `FactionActivitiesList` - список активностей фракции (бейджи для заказов и работ)
- `FactionActivitiesBlock` - блок ежедневных активностей с галочками "Заказы" и "Работы"
- `FactionCurrencyBlock` - блок для редактирования валюты фракции
- `FactionReputationBlock` - блок для редактирования текущего уровня отношения и опыта на уровне
- `FactionCertificateBlock` - отдельный блок для управления сертификатом с галочкой "Сертификат"
- `FactionGoalsBlock` - блок "Цели" с целевым уровнем репутации и галочкой "Нужен сертификат"
- `FactionDecorationsSection` - секция украшений с компактными карточками
- `FactionSelectionDialog` - диалог выбора фракции из списка скрытых
- `FactionActivitiesSection` - секция активностей и сертификата (не используется в текущей реализации)
- `FactionBasicInfoSection` - секция базовой информации о фракции (не используется в текущей реализации)

**Виджеты валюты** (`widgets/currency/`):
- `CurrencyProgressBar` - progress bar для отображения прогресса валюты с возможностью редактирования
- `CurrencyInputDialog` - диалог для ввода/редактирования валюты
- `WorkCurrencyBadge` - бейдж валюты с работы (с возможностью редактирования)

**Виджеты репутации** (`widgets/reputation/`):
- `ReputationProgressBar` - progress bar для отображения прогресса уровня отношения

**Виджеты активностей** (`widgets/activity/`):
- `ActivityBadge` - бейдж активности (переиспользуемый компонент)

**Виджеты времени до цели** (`widgets/time_to_goal/`):
- `TimeToCurrencyGoalWidget` - компактный виджет отображения времени до цели по валюте (автоматически пересчитывается при изменении полей)
- `TimeToReputationGoalWidget` - компактный виджет отображения времени до цели по репутации (отображается рядом с progress bar опыта)

#### BLoC (State Management)
- `FactionBloc` - управление состоянием фракций
  - **Оптимистичные обновления:** При обновлении фракции (`UpdateFactionEvent`) и изменении порядка (`ReorderFactionsEvent`) UI обновляется мгновенно, сохранение в БД происходит в фоне. При ошибке состояние восстанавливается из БД.
  - **Pull-to-refresh:** Поддержка обновления списка через свайп вниз (`RefreshIndicator`)

### 4. Core Layer (Ядро)

**Расположение:** `lib/core/`

Общие утилиты и инфраструктура.

#### Constants
- `AppSettings` - константы настроек приложения, организованные по функциональности (фракции, карта, брактеат)
- `FactionsList` - статический список всех 13 фракций игры с предустановленными настройками через `FactionTemplate` (hasOrder, hasWork, hasCertificate, orderRewards)
- `ReputationLevel` - enum уровней отношения (indifference, friendliness, respect, honor, adoration, deification, maximum)
- `OrderReward` - класс для хранения награды за заказ (валюта и опыт)
- `ReputationExp` - константы опыта, требуемого для достижения уровней отношения

#### Database
- Настройка SQLite базы данных

#### Dependency Injection
- `ServiceLocator` - простой DI контейнер для управления зависимостями

#### Utils
- `TimeFormatter` - форматирование времени в компактный формат (только дни с округлением вверх)
- `DailyResetHelper` - помощник для ежедневного сброса отметок
- `ReputationHelper` - утилита для работы с уровнями отношения и опытом (вычисление общего опыта, нужного опыта и т.д.)

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

## Принципы

1. **Dependency Rule**: Внутренние слои не зависят от внешних
2. **Single Responsibility**: Каждый класс имеет одну ответственность
3. **Separation of Concerns**: Разделение бизнес-логики и UI
4. **Testability**: Каждый слой можно тестировать независимо

