# Схема базы данных

## Обзор

Приложение использует **SQLite** для локального хранения данных. База данных создается автоматически при первом запуске приложения.

## Таблицы

### Таблица: `factions`

Хранит информацию о всех фракциях.

| Поле | Тип | Описание |
|------|-----|----------|
| `id` | INTEGER PRIMARY KEY | Уникальный идентификатор фракции |
| `name` | TEXT NOT NULL | Название фракции |
| `currency` | INTEGER NOT NULL DEFAULT 0 | Текущее количество валюты |
| `reputation_level` | INTEGER NOT NULL DEFAULT 0 | Уровень репутации (0-5) |
| `has_order` | INTEGER NOT NULL DEFAULT 0 | Есть ли заказы во фракции (0/1) |
| `order_completed` | INTEGER NOT NULL DEFAULT 0 | Выполнен ли заказ (0/1) |
| `work_currency` | INTEGER | Валюта с работы (NULL если работы нет) |
| `has_certificate` | INTEGER NOT NULL DEFAULT 0 | Есть ли сертификат (0/1) |
| `certificate_purchased` | INTEGER NOT NULL DEFAULT 0 | Куплен ли сертификат (0/1) |
| `decoration_respect_purchased` | INTEGER NOT NULL DEFAULT 0 | Куплено украшение "Уважение" (0/1) |
| `decoration_respect_upgraded` | INTEGER NOT NULL DEFAULT 0 | Улучшено украшение "Уважение" (0/1) |
| `decoration_honor_purchased` | INTEGER NOT NULL DEFAULT 0 | Куплено украшение "Почтение" (0/1) |
| `decoration_honor_upgraded` | INTEGER NOT NULL DEFAULT 0 | Улучшено украшение "Почтение" (0/1) |
| `decoration_adoration_purchased` | INTEGER NOT NULL DEFAULT 0 | Куплено украшение "Преклонение" (0/1) |
| `decoration_adoration_upgraded` | INTEGER NOT NULL DEFAULT 0 | Улучшено украшение "Преклонение" (0/1) |
| `display_order` | INTEGER NOT NULL DEFAULT 0 | Порядок отображения фракций |

**Индексы:** нет

**Ограничения:** нет

**Сортировка:** По умолчанию фракции сортируются по полю `display_order` (ASC), затем по `id` (ASC)

**Примечание:** Настройки приложения (цены, валюты) хранятся как константы в коде (`lib/core/constants/app_settings.dart`), а не в базе данных.

## SQL запросы создания таблиц

### Создание таблицы `factions`

```sql
CREATE TABLE factions (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  name TEXT NOT NULL,
  currency INTEGER NOT NULL DEFAULT 0,
  reputation_level INTEGER NOT NULL DEFAULT 0,
  has_order INTEGER NOT NULL DEFAULT 0,
  order_completed INTEGER NOT NULL DEFAULT 0,
  work_currency INTEGER,
  has_certificate INTEGER NOT NULL DEFAULT 0,
  certificate_purchased INTEGER NOT NULL DEFAULT 0,
  decoration_respect_purchased INTEGER NOT NULL DEFAULT 0,
  decoration_respect_upgraded INTEGER NOT NULL DEFAULT 0,
  decoration_honor_purchased INTEGER NOT NULL DEFAULT 0,
  decoration_honor_upgraded INTEGER NOT NULL DEFAULT 0,
  decoration_adoration_purchased INTEGER NOT NULL DEFAULT 0,
  decoration_adoration_upgraded INTEGER NOT NULL DEFAULT 0,
  display_order INTEGER NOT NULL DEFAULT 0
)
```

## Расположение базы данных

База данных хранится в стандартном месте для приложений Flutter:
- **Android:** `/data/data/<package_name>/databases/rev_app.db`
- **iOS:** `Documents/rev_app.db`

Путь определяется автоматически через `getDatabasesPath()` из пакета `sqflite`.

## Миграции

Приложение поддерживает миграции базы данных через `onUpgrade` в `ServiceLocator`. При изменении версии базы данных выполняется автоматическое обновление схемы.

**Текущая версия БД:** 6

**Миграции:**
- Версия 1 → 2: Добавлены колонки `has_order` в таблицу `factions` (по умолчанию 1)
- Версия 2 → 3: 
  - Миграция типов данных с REAL на INTEGER для всех полей валюты в таблице `factions`
  - Изменение значения по умолчанию для `has_order` с 1 на 0
- Версия 3 → 4: 
  - Добавлена колонка `order` (INTEGER) в таблицу `factions` для сортировки фракций
  - Для существующих записей устанавливается порядок на основе `id`
  - Примечание: `order` - зарезервированное слово в SQLite, поэтому используется обратное экранирование в SQL-запросах
- Версия 4 → 5:
  - Переименована колонка `order` в `display_order` для избежания конфликта с зарезервированным словом SQLite
  - Таблица пересоздается с новым именем колонки, данные копируются из старой таблицы
- Версия 5 → 6:
  - Переименована колонка `board_currency` в `work_currency`
  - Таблица пересоздается с новым именем колонки, данные копируются из старой таблицы

## Резервное копирование

База данных хранится локально на устройстве. Для резервного копирования можно:
1. Скопировать файл базы данных напрямую с устройства
2. Экспортировать данные через функционал приложения (если будет добавлен)

