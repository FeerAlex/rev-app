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
| `has_order` | INTEGER NOT NULL DEFAULT 0 | Учитывать ли заказы в расчете (0/1, хранит значение `ordersEnabled` из entity Faction). **Важно:** это поле хранит настройку пользователя, а не наличие заказов во фракции. Наличие заказов определяется статическим списком фракций (`FactionTemplate.orderReward != null`) |
| `order_completed` | INTEGER NOT NULL DEFAULT 0 | Выполнен ли заказ (0/1) |
| `work_currency` | INTEGER | Валюта с работы (может быть NULL или 0) |
| `work_exp` | INTEGER | Опыт с работы (может быть NULL или 0) |
| `has_work` | INTEGER NOT NULL DEFAULT 0 | Есть ли работа во фракции (0/1, определяется статическим списком) |
| `work_completed` | INTEGER NOT NULL DEFAULT 0 | Выполнена ли работа (0/1) |
| `has_certificate` | INTEGER NOT NULL DEFAULT 0 | Есть ли сертификат во фракции (0/1) |
| `certificate_purchased` | INTEGER NOT NULL DEFAULT 0 | Куплен ли сертификат (0/1) |
| `decoration_respect_purchased` | INTEGER NOT NULL DEFAULT 0 | Куплено украшение "Уважение" (0/1) |
| `decoration_respect_upgraded` | INTEGER NOT NULL DEFAULT 0 | Улучшено украшение "Уважение" (0/1) |
| `decoration_honor_purchased` | INTEGER NOT NULL DEFAULT 0 | Куплено украшение "Почтение" (0/1) |
| `decoration_honor_upgraded` | INTEGER NOT NULL DEFAULT 0 | Улучшено украшение "Почтение" (0/1) |
| `decoration_adoration_purchased` | INTEGER NOT NULL DEFAULT 0 | Куплено украшение "Преклонение" (0/1) |
| `decoration_adoration_upgraded` | INTEGER NOT NULL DEFAULT 0 | Улучшено украшение "Преклонение" (0/1) |
| `display_order` | INTEGER NOT NULL DEFAULT 0 | Порядок отображения фракций |
| `is_visible` | INTEGER NOT NULL DEFAULT 1 | Видимость фракции в списке (0/1) |
| `current_reputation_level` | INTEGER NOT NULL DEFAULT 0 | Текущий уровень отношения (0-6, соответствует ReputationLevel) |
| `current_level_exp` | INTEGER NOT NULL DEFAULT 0 | Опыт на текущем уровне (от 0 до требуемого для уровня) |
| `target_reputation_level` | INTEGER DEFAULT NULL | Целевой уровень отношения (0-6, соответствует ReputationLevel, NULL = цель не нужна) |
| `wants_certificate` | INTEGER NOT NULL DEFAULT 0 | Нужен ли сертификат как цель (0/1) |

**Индексы:** нет

**Ограничения:** нет

**Сортировка:** По умолчанию фракции сортируются по полю `display_order` (ASC), затем по `id` (ASC)

**Примечание:** 
- Настройки приложения (цены, валюты) хранятся как константы в коде (`lib/core/constants/app_settings.dart`), а не в базе данных
- Поле `has_order` используется для хранения `ordersEnabled` (учитывать ли заказы в расчете), а не для определения наличия заказов во фракции. Наличие заказов определяется статическим списком фракций (`FactionTemplate.orderReward != null`)
- Поля `has_work` и `has_certificate` определяются статическим списком фракций (`FactionTemplate`) и настраиваются для каждой фракции при создании
- Поля `work_currency` и `work_exp` хранят значения валюты и опыта за работу. Если оба поля равны 0 или NULL, работа не учитывается в расчетах. `WorkReward` всегда создается при вводе значений (даже если оба поля равны 0)

## SQL запросы создания таблиц

### Создание таблицы `factions`

```sql
CREATE TABLE factions (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  name TEXT NOT NULL,
  currency INTEGER NOT NULL DEFAULT 0,
  has_order INTEGER NOT NULL DEFAULT 0,
  order_completed INTEGER NOT NULL DEFAULT 0,
  work_currency INTEGER,
  work_exp INTEGER,
  has_work INTEGER NOT NULL DEFAULT 0,
  work_completed INTEGER NOT NULL DEFAULT 0,
  has_certificate INTEGER NOT NULL DEFAULT 0,
  certificate_purchased INTEGER NOT NULL DEFAULT 0,
  decoration_respect_purchased INTEGER NOT NULL DEFAULT 0,
  decoration_respect_upgraded INTEGER NOT NULL DEFAULT 0,
  decoration_honor_purchased INTEGER NOT NULL DEFAULT 0,
  decoration_honor_upgraded INTEGER NOT NULL DEFAULT 0,
  decoration_adoration_purchased INTEGER NOT NULL DEFAULT 0,
  decoration_adoration_upgraded INTEGER NOT NULL DEFAULT 0,
  display_order INTEGER NOT NULL DEFAULT 0,
  is_visible INTEGER NOT NULL DEFAULT 1,
  current_reputation_level INTEGER NOT NULL DEFAULT 0,
  current_level_exp INTEGER NOT NULL DEFAULT 0,
  target_reputation_level INTEGER DEFAULT NULL,
  wants_certificate INTEGER NOT NULL DEFAULT 0
)
```

## Расположение базы данных

База данных хранится в стандартном месте для приложений Flutter:
- **Android:** `/data/data/<package_name>/databases/rev_app.db`
- **iOS:** `Documents/rev_app.db`

Путь определяется автоматически через `getDatabasesPath()` из пакета `sqflite`.

## Версия базы данных

**Текущая версия БД:** 12

База данных создается при первом запуске приложения через метод `FactionDao.createTable()`. Все колонки создаются сразу при создании таблицы.

**Миграции:**
- Версия 12: Добавлена колонка `wants_certificate`, поле `target_reputation_level` сделано nullable

**Примечание:** При обновлении с версии 11 на 12 автоматически добавляется колонка `wants_certificate` и изменяется `target_reputation_level` на nullable.

## Резервное копирование

База данных хранится локально на устройстве. Для резервного копирования можно:
1. Скопировать файл базы данных напрямую с устройства
2. Экспортировать данные через функционал приложения (если будет добавлен)

