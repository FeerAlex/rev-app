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
- `MainPage` - главная страница с Drawer для навигации между разделами
- `FactionsPage` - страница фракций со списком видимых фракций и кнопкой добавления (выбор из скрытых)
- `FactionsListPage` - список видимых фракций с возможностью скрытия свайпом и изменения порядка (drag-and-drop)
- `FactionDetailPage` - детальная информация и редактирование фракции (оптимизированная версия с компактными секциями). Название фракции отображается в заголовке AppBar.
- `MapPage` - заглушка для будущей карты ресурсов

#### Widgets (Виджеты)
- `FactionCard` - карточка фракции в списке с отображением времени до цели
- `TimeToGoalWidget` - компактный виджет отображения времени до цели по валюте (автоматически пересчитывается при изменении полей)
- `TimeToReputationGoalWidget` - компактный виджет отображения времени до цели по репутации (отображается рядом с progress bar опыта)
- `FactionNameDisplay` - отображение названия фракции
- `FactionCurrencyDisplay` - отображение валюты фракции (с возможностью редактирования)
- `FactionActivitiesList` - список активностей фракции (бейджи для заказов и работ)
- `ActivityBadge` - бейдж активности (переиспользуемый компонент)
- `WorkCurrencyBadge` - бейдж валюты с работы (с возможностью редактирования)
- `CurrencyInputDialog` - диалог для ввода/редактирования валюты
- `FactionActivitiesBlock` - блок ежедневных активностей с галочками "Заказы" и "Работы"
- `FactionCertificateBlock` - отдельный блок для управления сертификатом с галочкой "Сертификат"
- `FactionDecorationsSection` - секция украшений с компактными карточками
- `FactionSelectionDialog` - диалог выбора фракции из списка скрытых

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
- `TimeFormatter` - форматирование времени в компактный формат (д/ч/м)
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

