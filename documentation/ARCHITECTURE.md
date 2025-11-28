# Архитектура приложения

## Обзор

Приложение построено по принципам **Clean Architecture**, что обеспечивает разделение ответственности и независимость слоев.

## Слои архитектуры

### 1. Domain Layer (Доменный слой)

**Расположение:** `lib/domain/`

Самый внутренний слой, не зависящий от внешних библиотек и фреймворков.

#### Entities (Сущности)
- `Faction` - представляет фракцию со всеми её параметрами
- `Settings` - общие настройки приложения
- `ReputationLevel` - enum уровней репутации

#### Repositories (Интерфейсы репозиториев)
- `FactionRepository` - интерфейс для работы с фракциями
- `SettingsRepository` - интерфейс для работы с настройками

#### Use Cases (Сценарии использования)
- `GetAllFactions` - получение всех фракций
- `AddFaction` - добавление новой фракции
- `UpdateFaction` - обновление фракции
- `DeleteFaction` - удаление фракции
- `GetSettings` - получение настроек
- `UpdateSettings` - обновление настроек
- `CalculateTimeToGoal` - расчет времени до достижения цели
- `ResetDailyFlags` - сброс ежедневных отметок
- `ReorderFactions` - изменение порядка фракций

### 2. Data Layer (Слой данных)

**Расположение:** `lib/data/`

Реализует интерфейсы из Domain слоя и работает с базой данных.

#### Models (Модели данных)
- `FactionModel` - модель для маппинга Faction entity в/из базы данных
- `SettingsModel` - модель для маппинга Settings entity в/из базы данных

#### Data Sources (Источники данных)
- `FactionDao` - DAO для работы с таблицей factions в SQLite
- `SettingsDao` - DAO для работы с таблицей settings в SQLite

#### Repositories (Реализации репозиториев)
- `FactionRepositoryImpl` - реализация FactionRepository
- `SettingsRepositoryImpl` - реализация SettingsRepository

### 3. Presentation Layer (Слой представления)

**Расположение:** `lib/presentation/`

Отвечает за UI и управление состоянием.

#### Pages (Страницы)
- `MainPage` - главная страница с Drawer для навигации между разделами
- `FactionsPage` - страница фракций с BottomNavigationBar (Список/Настройки)
- `FactionsListPage` - список всех фракций с возможностью удаления свайпом и изменения порядка (drag-and-drop)
- `FactionDetailPage` - детальная информация и редактирование фракции (оптимизированная версия с компактными секциями)
- `SettingsPage` - страница настроек
- `MapPage` - заглушка для будущей карты ресурсов

#### Widgets (Виджеты)
- `FactionCard` - карточка фракции в списке с отображением времени до цели
- `TimeToGoalWidget` - компактный виджет отображения времени до цели
- `FactionNameDisplay` - отображение названия фракции
- `FactionCurrencyDisplay` - отображение валюты фракции (с возможностью редактирования)
- `FactionActivitiesList` - список активностей фракции
- `ActivityBadge` - бейдж активности
- `BoardCurrencyBadge` - бейдж валюты с доски (с возможностью редактирования)
- `CurrencyInputDialog` - диалог для ввода/редактирования валюты
- `FactionBasicInfoSection` - секция основной информации о фракции
- `FactionActivitiesSection` - секция активностей и сертификата
- `FactionDecorationsSection` - секция украшений

#### BLoC (State Management)
- `FactionBloc` - управление состоянием фракций
  - **Оптимистичные обновления:** При обновлении фракции (`UpdateFactionEvent`) и изменении порядка (`ReorderFactionsEvent`) UI обновляется мгновенно, сохранение в БД происходит в фоне. При ошибке состояние восстанавливается из БД.
  - **Pull-to-refresh:** Поддержка обновления списка через свайп вниз (`RefreshIndicator`)
- `SettingsBloc` - управление состоянием настроек

### 4. Core Layer (Ядро)

**Расположение:** `lib/core/`

Общие утилиты и инфраструктура.

#### Database
- Настройка SQLite базы данных

#### Dependency Injection
- `ServiceLocator` - простой DI контейнер для управления зависимостями

#### Utils
- `TimeFormatter` - форматирование времени в компактный формат (д/ч/м)
- `DailyResetHelper` - помощник для ежедневного сброса отметок

#### Theme
- `AppTheme` - темная тема приложения в стиле игры Revelation Online
  - Цветовая схема с темными фонами
  - Цвета для уровней репутации
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

