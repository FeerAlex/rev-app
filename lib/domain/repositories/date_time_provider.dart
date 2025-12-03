/// Провайдер для работы с датой и временем в московском часовом поясе
/// Используется для абстракции работы с часовыми поясами из Domain layer
abstract class DateTimeProvider {
  /// Получить текущее время в московском часовом поясе
  DateTime getNowInMoscow();

  /// Получить начало текущего дня в московском часовом поясе
  DateTime getTodayInMoscow();

  /// Преобразовать DateTime в московское время и получить начало дня
  DateTime getStartOfDayInMoscow(DateTime dateTime);

  /// Преобразовать DateTime в UTC
  DateTime toUtc(DateTime dateTime);
}

