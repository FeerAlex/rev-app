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
      version: 12,
      onCreate: (db, version) async {
        await FactionDao.createTable(db);
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        // Проверяем, какие колонки уже существуют
        final tableInfo = await db.rawQuery('PRAGMA table_info(${FactionDao.tableName})');
        final existingColumns = tableInfo.map((row) => row['name'] as String).toSet();
        
        // Миграция на версию 10: добавляем колонки для опыта и целевого уровня
        if (oldVersion < 10) {
          if (!existingColumns.contains(FactionDao.columnCurrentReputationLevel)) {
            await db.execute('''
              ALTER TABLE ${FactionDao.tableName} 
              ADD COLUMN ${FactionDao.columnCurrentReputationLevel} INTEGER NOT NULL DEFAULT 0
            ''');
          }
          if (!existingColumns.contains(FactionDao.columnCurrentLevelExp)) {
            await db.execute('''
              ALTER TABLE ${FactionDao.tableName} 
              ADD COLUMN ${FactionDao.columnCurrentLevelExp} INTEGER NOT NULL DEFAULT 0
            ''');
          }
          if (!existingColumns.contains(FactionDao.columnTargetReputationLevel)) {
            await db.execute('''
              ALTER TABLE ${FactionDao.tableName} 
              ADD COLUMN ${FactionDao.columnTargetReputationLevel} INTEGER NOT NULL DEFAULT 6
            ''');
          }
        }
        
        // Миграция на версию 11: если была версия 10 с current_exp, заменяем на новые колонки
        if (oldVersion < 11) {
          // Проверяем, есть ли старые колонки, которых не должно быть
          final hasCurrentExp = existingColumns.contains('current_exp');
          
          // Если есть current_exp, но нет новых колонок - добавляем новые
          if (hasCurrentExp && !existingColumns.contains(FactionDao.columnCurrentReputationLevel)) {
            await db.execute('''
              ALTER TABLE ${FactionDao.tableName} 
              ADD COLUMN ${FactionDao.columnCurrentReputationLevel} INTEGER NOT NULL DEFAULT 0
            ''');
          }
          if (hasCurrentExp && !existingColumns.contains(FactionDao.columnCurrentLevelExp)) {
            await db.execute('''
              ALTER TABLE ${FactionDao.tableName} 
              ADD COLUMN ${FactionDao.columnCurrentLevelExp} INTEGER NOT NULL DEFAULT 0
            ''');
          }
          if (!existingColumns.contains(FactionDao.columnTargetReputationLevel)) {
            await db.execute('''
              ALTER TABLE ${FactionDao.tableName} 
              ADD COLUMN ${FactionDao.columnTargetReputationLevel} INTEGER NOT NULL DEFAULT 6
            ''');
          }
        }
        
        // Миграция на версию 12: добавляем wants_certificate и делаем target_reputation_level nullable
        if (oldVersion < 12) {
          if (!existingColumns.contains(FactionDao.columnWantsCertificate)) {
            await db.execute('''
              ALTER TABLE ${FactionDao.tableName} 
              ADD COLUMN ${FactionDao.columnWantsCertificate} INTEGER NOT NULL DEFAULT 0
            ''');
          }
          // Для target_reputation_level: в SQLite нельзя изменить NOT NULL на nullable напрямую
          // Но мы можем просто обрабатывать null при чтении, а при записи использовать значение по умолчанию
          // Существующие значения останутся как есть (NOT NULL), новые записи могут быть NULL
        }
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

