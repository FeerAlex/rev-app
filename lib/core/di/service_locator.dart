import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../../data/datasources/faction_dao.dart';
import '../../data/datasources/settings_dao.dart';
import '../../data/repositories/faction_repository_impl.dart';
import '../../data/repositories/settings_repository_impl.dart';
import '../../domain/repositories/faction_repository.dart';
import '../../domain/repositories/settings_repository.dart';

class ServiceLocator {
  static final ServiceLocator _instance = ServiceLocator._internal();
  factory ServiceLocator() => _instance;
  ServiceLocator._internal();

  Database? _database;
  FactionRepository? _factionRepository;
  SettingsRepository? _settingsRepository;

  Future<void> init() async {
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, 'rev_app.db');
    
    _database = await openDatabase(
      path,
      version: 6,
      onCreate: (db, version) async {
        await FactionDao.createTable(db);
        await SettingsDao.createTable(db);
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          // Добавляем новую колонку для hasOrder
          // SQLite не поддерживает NOT NULL с DEFAULT в ALTER TABLE, поэтому добавляем как nullable
          await db.execute(
            'ALTER TABLE ${FactionDao.tableName} ADD COLUMN ${FactionDao.columnHasOrder} INTEGER',
          );
          // Устанавливаем значения по умолчанию для существующих записей
          await db.update(
            FactionDao.tableName,
            {
              FactionDao.columnHasOrder: 0,
            },
          );
        }
        if (oldVersion < 3) {
          // Миграция типов колонок settings с REAL на INTEGER
          // SQLite не поддерживает изменение типа колонки, поэтому пересоздаем таблицу
          await db.execute('''
            CREATE TABLE ${SettingsDao.tableName}_new (
              ${SettingsDao.columnId} INTEGER PRIMARY KEY AUTOINCREMENT,
              ${SettingsDao.columnItemPrice} INTEGER NOT NULL DEFAULT 0,
              ${SettingsDao.columnItemCountRespect} INTEGER NOT NULL DEFAULT 1,
              ${SettingsDao.columnItemCountHonor} INTEGER NOT NULL DEFAULT 3,
              ${SettingsDao.columnItemCountAdoration} INTEGER NOT NULL DEFAULT 6,
              ${SettingsDao.columnDecorationPriceRespect} INTEGER NOT NULL DEFAULT 0,
              ${SettingsDao.columnDecorationPriceHonor} INTEGER NOT NULL DEFAULT 0,
              ${SettingsDao.columnDecorationPriceAdoration} INTEGER NOT NULL DEFAULT 0,
              ${SettingsDao.columnCurrencyPerOrder} INTEGER NOT NULL DEFAULT 0,
              ${SettingsDao.columnCertificatePrice} INTEGER NOT NULL DEFAULT 0
            )
          ''');
          
          // Копируем данные, преобразуя REAL в INTEGER
          await db.execute('''
            INSERT INTO ${SettingsDao.tableName}_new (
              ${SettingsDao.columnId},
              ${SettingsDao.columnItemPrice},
              ${SettingsDao.columnItemCountRespect},
              ${SettingsDao.columnItemCountHonor},
              ${SettingsDao.columnItemCountAdoration},
              ${SettingsDao.columnDecorationPriceRespect},
              ${SettingsDao.columnDecorationPriceHonor},
              ${SettingsDao.columnDecorationPriceAdoration},
              ${SettingsDao.columnCurrencyPerOrder},
              ${SettingsDao.columnCertificatePrice}
            )
            SELECT 
              ${SettingsDao.columnId},
              CAST(${SettingsDao.columnItemPrice} AS INTEGER),
              ${SettingsDao.columnItemCountRespect},
              ${SettingsDao.columnItemCountHonor},
              ${SettingsDao.columnItemCountAdoration},
              CAST(${SettingsDao.columnDecorationPriceRespect} AS INTEGER),
              CAST(${SettingsDao.columnDecorationPriceHonor} AS INTEGER),
              CAST(${SettingsDao.columnDecorationPriceAdoration} AS INTEGER),
              CAST(${SettingsDao.columnCurrencyPerOrder} AS INTEGER),
              CAST(${SettingsDao.columnCertificatePrice} AS INTEGER)
            FROM ${SettingsDao.tableName}
          ''');
          
          // Удаляем старую таблицу
          await db.execute('DROP TABLE ${SettingsDao.tableName}');
          
          // Переименовываем новую таблицу
          await db.execute('ALTER TABLE ${SettingsDao.tableName}_new RENAME TO ${SettingsDao.tableName}');
          
          // Миграция типов колонок factions (currency и workCurrency) с REAL на INTEGER, если они были REAL
          // Проверяем, есть ли колонки с типом REAL (через pragma table_info)
          final tableInfo = await db.rawQuery('PRAGMA table_info(${FactionDao.tableName})');
          bool needsCurrencyMigration = false;
          bool needsWorkCurrencyMigration = false;
          
          for (var column in tableInfo) {
            final columnName = column['name'] as String;
            final columnType = column['type'] as String;
            if (columnName == FactionDao.columnCurrency && columnType.toUpperCase().contains('REAL')) {
              needsCurrencyMigration = true;
            }
            // Проверяем старую колонку board_currency для миграции
            if (columnName == 'board_currency' && columnType.toUpperCase().contains('REAL')) {
              needsWorkCurrencyMigration = true;
            }
          }
          
          if (needsCurrencyMigration || needsWorkCurrencyMigration) {
            // Пересоздаем таблицу factions
            await db.execute('''
              CREATE TABLE ${FactionDao.tableName}_new (
                ${FactionDao.columnId} INTEGER PRIMARY KEY AUTOINCREMENT,
                ${FactionDao.columnName} TEXT NOT NULL,
                ${FactionDao.columnCurrency} INTEGER NOT NULL DEFAULT 0,
                ${FactionDao.columnReputationLevel} INTEGER NOT NULL DEFAULT 0,
                ${FactionDao.columnHasOrder} INTEGER NOT NULL DEFAULT 0,
                ${FactionDao.columnOrderCompleted} INTEGER NOT NULL DEFAULT 0,
                ${FactionDao.columnWorkCurrency} INTEGER,
                ${FactionDao.columnHasCertificate} INTEGER NOT NULL DEFAULT 0,
                ${FactionDao.columnCertificatePurchased} INTEGER NOT NULL DEFAULT 0,
                ${FactionDao.columnDecorationRespectPurchased} INTEGER NOT NULL DEFAULT 0,
                ${FactionDao.columnDecorationRespectUpgraded} INTEGER NOT NULL DEFAULT 0,
                ${FactionDao.columnDecorationHonorPurchased} INTEGER NOT NULL DEFAULT 0,
                ${FactionDao.columnDecorationHonorUpgraded} INTEGER NOT NULL DEFAULT 0,
                ${FactionDao.columnDecorationAdorationPurchased} INTEGER NOT NULL DEFAULT 0,
                ${FactionDao.columnDecorationAdorationUpgraded} INTEGER NOT NULL DEFAULT 0
              )
            ''');
            
            // Копируем данные, преобразуя REAL в INTEGER
            final currencyColumn = needsCurrencyMigration 
                ? 'CAST(${FactionDao.columnCurrency} AS INTEGER)'
                : FactionDao.columnCurrency;
            final workCurrencyColumn = needsWorkCurrencyMigration
                ? 'CAST(board_currency AS INTEGER)'
                : 'board_currency';
            
            await db.execute('''
              INSERT INTO ${FactionDao.tableName}_new (
                ${FactionDao.columnId},
                ${FactionDao.columnName},
                ${FactionDao.columnCurrency},
                ${FactionDao.columnReputationLevel},
                ${FactionDao.columnHasOrder},
                ${FactionDao.columnOrderCompleted},
                ${FactionDao.columnWorkCurrency},
                ${FactionDao.columnHasCertificate},
                ${FactionDao.columnCertificatePurchased},
                ${FactionDao.columnDecorationRespectPurchased},
                ${FactionDao.columnDecorationRespectUpgraded},
                ${FactionDao.columnDecorationHonorPurchased},
                ${FactionDao.columnDecorationHonorUpgraded},
                ${FactionDao.columnDecorationAdorationPurchased},
                ${FactionDao.columnDecorationAdorationUpgraded}
              )
              SELECT 
                ${FactionDao.columnId},
                ${FactionDao.columnName},
                $currencyColumn,
                ${FactionDao.columnReputationLevel},
                COALESCE(${FactionDao.columnHasOrder}, 0),
                ${FactionDao.columnOrderCompleted},
                $workCurrencyColumn,
                ${FactionDao.columnHasCertificate},
                ${FactionDao.columnCertificatePurchased},
                ${FactionDao.columnDecorationRespectPurchased},
                ${FactionDao.columnDecorationRespectUpgraded},
                ${FactionDao.columnDecorationHonorPurchased},
                ${FactionDao.columnDecorationHonorUpgraded},
                ${FactionDao.columnDecorationAdorationPurchased},
                ${FactionDao.columnDecorationAdorationUpgraded}
              FROM ${FactionDao.tableName}
            ''');
            
            // Удаляем старую таблицу
            await db.execute('DROP TABLE ${FactionDao.tableName}');
            
            // Переименовываем новую таблицу
            await db.execute('ALTER TABLE ${FactionDao.tableName}_new RENAME TO ${FactionDao.tableName}');
          }
        }
        if (oldVersion < 4) {
          // Добавляем колонку order для сортировки фракций
          // SQLite не поддерживает NOT NULL с DEFAULT в ALTER TABLE, поэтому добавляем как nullable
          // order - зарезервированное слово, поэтому используем обратные кавычки
          await db.execute(
            'ALTER TABLE ${FactionDao.tableName} ADD COLUMN `order` INTEGER',
          );
          // Устанавливаем порядок для существующих записей на основе id
          final factions = await db.query(FactionDao.tableName);
          final batch = db.batch();
          for (int i = 0; i < factions.length; i++) {
            batch.update(
              FactionDao.tableName,
              {'`order`': i},
              where: '${FactionDao.columnId} = ?',
              whereArgs: [factions[i][FactionDao.columnId]],
            );
          }
          await batch.commit(noResult: true);
        }
        if (oldVersion < 5) {
          // Переименовываем колонку order в display_order
          // SQLite не поддерживает ALTER TABLE RENAME COLUMN напрямую, поэтому пересоздаем таблицу
          await db.execute('''
            CREATE TABLE ${FactionDao.tableName}_new (
              ${FactionDao.columnId} INTEGER PRIMARY KEY AUTOINCREMENT,
              ${FactionDao.columnName} TEXT NOT NULL,
              ${FactionDao.columnCurrency} INTEGER NOT NULL DEFAULT 0,
              ${FactionDao.columnReputationLevel} INTEGER NOT NULL DEFAULT 0,
              ${FactionDao.columnHasOrder} INTEGER NOT NULL DEFAULT 0,
              ${FactionDao.columnOrderCompleted} INTEGER NOT NULL DEFAULT 0,
              ${FactionDao.columnWorkCurrency} INTEGER,
              ${FactionDao.columnHasCertificate} INTEGER NOT NULL DEFAULT 0,
              ${FactionDao.columnCertificatePurchased} INTEGER NOT NULL DEFAULT 0,
              ${FactionDao.columnDecorationRespectPurchased} INTEGER NOT NULL DEFAULT 0,
              ${FactionDao.columnDecorationRespectUpgraded} INTEGER NOT NULL DEFAULT 0,
              ${FactionDao.columnDecorationHonorPurchased} INTEGER NOT NULL DEFAULT 0,
              ${FactionDao.columnDecorationHonorUpgraded} INTEGER NOT NULL DEFAULT 0,
              ${FactionDao.columnDecorationAdorationPurchased} INTEGER NOT NULL DEFAULT 0,
              ${FactionDao.columnDecorationAdorationUpgraded} INTEGER NOT NULL DEFAULT 0,
              ${FactionDao.columnDisplayOrder} INTEGER NOT NULL DEFAULT 0
            )
          ''');
          
          // Копируем данные из старой таблицы в новую
          await db.execute('''
            INSERT INTO ${FactionDao.tableName}_new (
              ${FactionDao.columnId},
              ${FactionDao.columnName},
              ${FactionDao.columnCurrency},
              ${FactionDao.columnReputationLevel},
              ${FactionDao.columnHasOrder},
              ${FactionDao.columnOrderCompleted},
              ${FactionDao.columnWorkCurrency},
              ${FactionDao.columnHasCertificate},
              ${FactionDao.columnCertificatePurchased},
              ${FactionDao.columnDecorationRespectPurchased},
              ${FactionDao.columnDecorationRespectUpgraded},
              ${FactionDao.columnDecorationHonorPurchased},
              ${FactionDao.columnDecorationHonorUpgraded},
              ${FactionDao.columnDecorationAdorationPurchased},
              ${FactionDao.columnDecorationAdorationUpgraded},
              ${FactionDao.columnDisplayOrder}
            )
            SELECT 
              ${FactionDao.columnId},
              ${FactionDao.columnName},
              ${FactionDao.columnCurrency},
              ${FactionDao.columnReputationLevel},
              ${FactionDao.columnHasOrder},
              ${FactionDao.columnOrderCompleted},
              board_currency,
              ${FactionDao.columnHasCertificate},
              ${FactionDao.columnCertificatePurchased},
              ${FactionDao.columnDecorationRespectPurchased},
              ${FactionDao.columnDecorationRespectUpgraded},
              ${FactionDao.columnDecorationHonorPurchased},
              ${FactionDao.columnDecorationHonorUpgraded},
              ${FactionDao.columnDecorationAdorationPurchased},
              ${FactionDao.columnDecorationAdorationUpgraded},
              COALESCE(`order`, 0)
            FROM ${FactionDao.tableName}
          ''');
          
          // Удаляем старую таблицу
          await db.execute('DROP TABLE ${FactionDao.tableName}');
          
          // Переименовываем новую таблицу
          await db.execute('ALTER TABLE ${FactionDao.tableName}_new RENAME TO ${FactionDao.tableName}');
        }
        if (oldVersion < 6) {
          // Переименовываем колонку board_currency в work_currency
          // SQLite не поддерживает ALTER TABLE RENAME COLUMN напрямую, поэтому пересоздаем таблицу
          await db.execute('''
            CREATE TABLE ${FactionDao.tableName}_new (
              ${FactionDao.columnId} INTEGER PRIMARY KEY AUTOINCREMENT,
              ${FactionDao.columnName} TEXT NOT NULL,
              ${FactionDao.columnCurrency} INTEGER NOT NULL DEFAULT 0,
              ${FactionDao.columnReputationLevel} INTEGER NOT NULL DEFAULT 0,
              ${FactionDao.columnHasOrder} INTEGER NOT NULL DEFAULT 0,
              ${FactionDao.columnOrderCompleted} INTEGER NOT NULL DEFAULT 0,
              ${FactionDao.columnWorkCurrency} INTEGER,
              ${FactionDao.columnHasCertificate} INTEGER NOT NULL DEFAULT 0,
              ${FactionDao.columnCertificatePurchased} INTEGER NOT NULL DEFAULT 0,
              ${FactionDao.columnDecorationRespectPurchased} INTEGER NOT NULL DEFAULT 0,
              ${FactionDao.columnDecorationRespectUpgraded} INTEGER NOT NULL DEFAULT 0,
              ${FactionDao.columnDecorationHonorPurchased} INTEGER NOT NULL DEFAULT 0,
              ${FactionDao.columnDecorationHonorUpgraded} INTEGER NOT NULL DEFAULT 0,
              ${FactionDao.columnDecorationAdorationPurchased} INTEGER NOT NULL DEFAULT 0,
              ${FactionDao.columnDecorationAdorationUpgraded} INTEGER NOT NULL DEFAULT 0,
              ${FactionDao.columnDisplayOrder} INTEGER NOT NULL DEFAULT 0
            )
          ''');
          
          // Копируем данные из старой таблицы в новую, переименовывая колонку
          await db.execute('''
            INSERT INTO ${FactionDao.tableName}_new (
              ${FactionDao.columnId},
              ${FactionDao.columnName},
              ${FactionDao.columnCurrency},
              ${FactionDao.columnReputationLevel},
              ${FactionDao.columnHasOrder},
              ${FactionDao.columnOrderCompleted},
              ${FactionDao.columnWorkCurrency},
              ${FactionDao.columnHasCertificate},
              ${FactionDao.columnCertificatePurchased},
              ${FactionDao.columnDecorationRespectPurchased},
              ${FactionDao.columnDecorationRespectUpgraded},
              ${FactionDao.columnDecorationHonorPurchased},
              ${FactionDao.columnDecorationHonorUpgraded},
              ${FactionDao.columnDecorationAdorationPurchased},
              ${FactionDao.columnDecorationAdorationUpgraded},
              ${FactionDao.columnDisplayOrder}
            )
            SELECT 
              ${FactionDao.columnId},
              ${FactionDao.columnName},
              ${FactionDao.columnCurrency},
              ${FactionDao.columnReputationLevel},
              ${FactionDao.columnHasOrder},
              ${FactionDao.columnOrderCompleted},
              board_currency,
              ${FactionDao.columnHasCertificate},
              ${FactionDao.columnCertificatePurchased},
              ${FactionDao.columnDecorationRespectPurchased},
              ${FactionDao.columnDecorationRespectUpgraded},
              ${FactionDao.columnDecorationHonorPurchased},
              ${FactionDao.columnDecorationHonorUpgraded},
              ${FactionDao.columnDecorationAdorationPurchased},
              ${FactionDao.columnDecorationAdorationUpgraded},
              ${FactionDao.columnDisplayOrder}
            FROM ${FactionDao.tableName}
          ''');
          
          // Удаляем старую таблицу
          await db.execute('DROP TABLE ${FactionDao.tableName}');
          
          // Переименовываем новую таблицу
          await db.execute('ALTER TABLE ${FactionDao.tableName}_new RENAME TO ${FactionDao.tableName}');
        }
      },
    );

    final factionDao = FactionDao(_database!);
    final settingsDao = SettingsDao(_database!);

    _factionRepository = FactionRepositoryImpl(factionDao);
    _settingsRepository = SettingsRepositoryImpl(settingsDao);
  }

  Database get database => _database!;
  FactionRepository get factionRepository => _factionRepository!;
  SettingsRepository get settingsRepository => _settingsRepository!;
}

