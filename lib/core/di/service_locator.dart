import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../../data/datasources/faction_dao.dart';
import '../../data/repositories/faction_repository_impl.dart';
import '../../domain/repositories/faction_repository.dart';

class ServiceLocator {
  static final ServiceLocator _instance = ServiceLocator._internal();
  factory ServiceLocator() => _instance;
  ServiceLocator._internal();

  Database? _database;
  FactionRepository? _factionRepository;

  Future<void> init() async {
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, 'rev_app.db');
    
    _database = await openDatabase(
      path,
      version: 9,
      onCreate: (db, version) async {
        await FactionDao.createTable(db);
      },
    );

    final factionDao = FactionDao(_database!);

    _factionRepository = FactionRepositoryImpl(factionDao);
  }

  Database get database => _database!;
  FactionRepository get factionRepository => _factionRepository!;
}

