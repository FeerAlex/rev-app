/// Интерфейс для инициализации базы данных
abstract class DatabaseInitializer {
  /// Инициализирует базу данных (создает таблицы)
  /// [db] - объект базы данных
  Future<void> initializeDatabase(Object db);
}

