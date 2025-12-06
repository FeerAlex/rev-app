import 'package:sqflite/sqflite.dart';
import '../../domain/repositories/database_initializer.dart';
import '../datasources/faction_dao.dart';

/// Реализация DatabaseInitializer
class DatabaseInitializerImpl implements DatabaseInitializer {
  @override
  Future<void> initializeDatabase(Object db) async {
    if (db is! Database) {
      throw ArgumentError('db must be a Database instance');
    }
    await FactionDao.createTable(db);
  }
}

