import '../repositories/file_importer.dart';

/// Use case для импорта базы данных
class ImportDatabase {
  final FileImporter _fileImporter;

  ImportDatabase(this._fileImporter);

  /// Выбирает файл для импорта
  /// Возвращает путь к выбранному файлу, если выбор успешен
  /// Возвращает null, если пользователь отменил выбор
  /// Выбрасывает исключение, если произошла ошибка
  Future<String?> call() async {
    return await _fileImporter.importFile();
  }
}

