/// Интерфейс для получения пути к базе данных
abstract class DatabasePathProvider {
  /// Возвращает путь к файлу базы данных
  Future<String> getDatabasePath();
  
  /// Переинициализирует базу данных с новым файлом
  /// [importedFilePath] - путь к импортированному файлу БД
  Future<void> reinitializeDatabase(String importedFilePath);
}

