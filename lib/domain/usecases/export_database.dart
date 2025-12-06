import '../repositories/file_exporter.dart';
import '../repositories/database_path_provider.dart';

/// Use case для экспорта базы данных
class ExportDatabase {
  final FileExporter _fileExporter;
  final DatabasePathProvider _databasePathProvider;

  ExportDatabase(this._fileExporter, this._databasePathProvider);

  /// Экспортирует базу данных
  /// Возвращает true, если экспорт успешен, false в противном случае
  /// Выбрасывает исключение, если произошла ошибка
  Future<bool> call() async {
    final databasePath = await _databasePathProvider.getDatabasePath();
    return await _fileExporter.exportFile(databasePath);
  }
}

