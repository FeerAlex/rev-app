/// Интерфейс для экспорта файлов
abstract class FileExporter {
  /// Экспортирует файл по указанному пути
  /// Возвращает true, если экспорт успешен, false в противном случае
  Future<bool> exportFile(String filePath);
}

