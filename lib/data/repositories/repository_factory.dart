import 'package:sqflite/sqflite.dart';
import '../../domain/repositories/faction_repository.dart';
import '../datasources/faction_dao.dart';
import 'faction_repository_impl.dart';

/// Фабрика для создания репозиториев
/// Инкапсулирует создание репозиториев с их зависимостями внутри Data layer
class RepositoryFactory {
  const RepositoryFactory._();

  /// Создает FactionRepository с необходимыми зависимостями
  static FactionRepository createFactionRepository(Database database) {
    final factionDao = FactionDao(database);
    return FactionRepositoryImpl(factionDao);
  }
}

