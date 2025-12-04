import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../../../data/datasources/faction_dao.dart';
import '../../../data/repositories/faction_repository_impl.dart';
import '../../../data/repositories/faction_template_repository_impl.dart';
import '../../../data/repositories/app_settings_repository_impl.dart';
import '../../../data/repositories/date_time_provider_impl.dart';
import '../../../domain/repositories/faction_repository.dart';
import '../../../domain/repositories/faction_template_repository.dart';
import '../../../domain/repositories/app_settings_repository.dart';
import '../../../domain/repositories/date_time_provider.dart';

class ServiceLocator {
  static final ServiceLocator _instance = ServiceLocator._internal();
  factory ServiceLocator() => _instance;
  ServiceLocator._internal();

  Database? _database;
  FactionRepository? _factionRepository;
  FactionTemplateRepository? _factionTemplateRepository;
  AppSettingsRepository? _appSettingsRepository;
  DateTimeProvider? _dateTimeProvider;

  Future<void> init() async {
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, 'rev_app.db');
    
    _database = await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await FactionDao.createTable(db);
      },
    );

    final factionDao = FactionDao(_database!);

    _factionRepository = FactionRepositoryImpl(factionDao);
    _factionTemplateRepository = FactionTemplateRepositoryImpl();
    _appSettingsRepository = AppSettingsRepositoryImpl();
    _dateTimeProvider = DateTimeProviderImpl();
  }

  Database get database => _database!;
  FactionRepository get factionRepository => _factionRepository!;
  FactionTemplateRepository get factionTemplateRepository => _factionTemplateRepository!;
  AppSettingsRepository get appSettingsRepository => _appSettingsRepository!;
  DateTimeProvider get dateTimeProvider => _dateTimeProvider!;
}

