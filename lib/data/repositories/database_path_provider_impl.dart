import 'dart:io';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import '../../domain/repositories/database_path_provider.dart';
import '../../domain/repositories/database_initializer.dart';

/// Реализация DatabasePathProvider
class DatabasePathProviderImpl implements DatabasePathProvider {
  Database? _database;
  final String? _databasePath;
  final DatabaseInitializer _databaseInitializer;
  final Function(Database)? _onDatabaseUpdated;

  DatabasePathProviderImpl(
    this._database,
    this._databasePath,
    this._databaseInitializer, [
    this._onDatabaseUpdated,
  ]);
  
  /// Получить текущее соединение с БД
  Database? get database => _database;

  @override
  Future<String> getDatabasePath() async {
    if (_databasePath != null) {
      return _databasePath;
    }
    final databasesPath = await getDatabasesPath();
    return path.join(databasesPath, 'rev_app.db');
  }

  @override
  Future<void> reinitializeDatabase(String importedFilePath) async {
    try {
      // Валидация файла
      final importedFile = File(importedFilePath);
      if (!await importedFile.exists()) {
        throw Exception('Импортированный файл не существует');
      }

      // Валидация: пытаемся открыть файл как SQLite БД
      final testDb = await openDatabase(
        importedFilePath,
        version: 1,
        readOnly: true,
      );
      
      // Проверяем наличие таблицы factions
      final tables = await testDb.rawQuery(
        "SELECT name FROM sqlite_master WHERE type='table' AND name='factions'",
      );
      await testDb.close();

      if (tables.isEmpty) {
        throw Exception('Файл не содержит таблицу factions');
      }

      // Закрываем текущее соединение с БД
      Database? oldDatabase = _database;
      
      if (oldDatabase != null && oldDatabase.isOpen) {
        try {
          await oldDatabase.close();
        } catch (e) {
          // Игнорируем ошибки при закрытии
        }
      }
      
      _database = null;

      // Получаем путь к текущей БД
      final currentDbPath = await getDatabasePath();

      // Копируем импортированный файл на место текущей БД
      final currentDbFile = File(currentDbPath);
      if (await currentDbFile.exists()) {
        await currentDbFile.delete();
      }
      await importedFile.copy(currentDbPath);

      // Удаляем временный файл, если он был создан
      try {
        final tempDir = await getTemporaryDirectory();
        if (importedFilePath.startsWith(tempDir.path)) {
          await importedFile.delete();
        }
      } catch (e) {
        // Игнорируем ошибки при удалении временного файла
      }

      // Переоткрываем соединение с БД
      _database = await openDatabase(
        currentDbPath,
        version: 1,
        onCreate: (db, version) async {
          await _databaseInitializer.initializeDatabase(db);
        },
      );
      
      // Обновляем ссылку на БД в ServiceLocator
      final onDatabaseUpdated = _onDatabaseUpdated;
      if (onDatabaseUpdated != null) {
        onDatabaseUpdated(_database!);
      }
    } catch (e) {
      // В случае ошибки пытаемся восстановить соединение
      if (_database == null) {
        try {
          final databasesPath = await getDatabasesPath();
          final dbPath = path.join(databasesPath, 'rev_app.db');
          _database = await openDatabase(
            dbPath,
            version: 1,
            onCreate: (db, version) async {
              await _databaseInitializer.initializeDatabase(db);
            },
          );
        } catch (restoreError) {
          // Игнорируем ошибки при восстановлении
        }
      }
      rethrow;
    }
  }
}

