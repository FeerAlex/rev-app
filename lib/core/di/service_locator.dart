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
              ${FactionDao.columnDisplayOrder} INTEGER NOT NULL DEFAULT 0,
              ${FactionDao.columnIsVisible} INTEGER NOT NULL DEFAULT 1
            )
          ''');
          
          // Копируем данные из старой таблицы в новую, переименовывая колонку
          await db.execute('''
            INSERT INTO ${FactionDao.tableName}_new (
              ${FactionDao.columnId},
              ${FactionDao.columnName},
              ${FactionDao.columnCurrency},
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
              ${FactionDao.columnDisplayOrder},
              ${FactionDao.columnIsVisible}
            )
            SELECT 
              ${FactionDao.columnId},
              ${FactionDao.columnName},
              ${FactionDao.columnCurrency},
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
              ${FactionDao.columnDisplayOrder},
              1
            FROM ${FactionDao.tableName}
          ''');
          
          // Удаляем старую таблицу
          await db.execute('DROP TABLE ${FactionDao.tableName}');
          
          // Переименовываем новую таблицу
          await db.execute('ALTER TABLE ${FactionDao.tableName}_new RENAME TO ${FactionDao.tableName}');
        }
        
        if (oldVersion < 7) {
          // Удаление колонки reputation_level
          // SQLite не поддерживает ALTER TABLE DROP COLUMN напрямую, поэтому пересоздаем таблицу
          await db.execute('''
            CREATE TABLE ${FactionDao.tableName}_new (
              ${FactionDao.columnId} INTEGER PRIMARY KEY AUTOINCREMENT,
              ${FactionDao.columnName} TEXT NOT NULL,
              ${FactionDao.columnCurrency} INTEGER NOT NULL DEFAULT 0,
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
              ${FactionDao.columnDisplayOrder} INTEGER NOT NULL DEFAULT 0,
              ${FactionDao.columnIsVisible} INTEGER NOT NULL DEFAULT 1
            )
          ''');
          
          // Копируем данные из старой таблицы в новую, исключая reputation_level
          await db.execute('''
            INSERT INTO ${FactionDao.tableName}_new (
              ${FactionDao.columnId},
              ${FactionDao.columnName},
              ${FactionDao.columnCurrency},
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
              ${FactionDao.columnDisplayOrder},
              ${FactionDao.columnIsVisible}
            )
            SELECT 
              ${FactionDao.columnId},
              ${FactionDao.columnName},
              ${FactionDao.columnCurrency},
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
              ${FactionDao.columnDisplayOrder},
              1
            FROM ${FactionDao.tableName}
          ''');
          
          // Удаляем старую таблицу
          await db.execute('DROP TABLE ${FactionDao.tableName}');
          
          // Переименовываем новую таблицу
          await db.execute('ALTER TABLE ${FactionDao.tableName}_new RENAME TO ${FactionDao.tableName}');
        }
        
        if (oldVersion < 8) {
          // Добавление колонки is_visible
          await db.execute('''
            ALTER TABLE ${FactionDao.tableName} 
            ADD COLUMN ${FactionDao.columnIsVisible} INTEGER NOT NULL DEFAULT 1
          ''');
        }
        
        if (oldVersion < 9) {
          // Добавление колонок has_work и work_completed
          await db.execute('''
            ALTER TABLE ${FactionDao.tableName} 
            ADD COLUMN ${FactionDao.columnHasWork} INTEGER NOT NULL DEFAULT 0
          ''');
          await db.execute('''
            ALTER TABLE ${FactionDao.tableName} 
            ADD COLUMN ${FactionDao.columnWorkCompleted} INTEGER NOT NULL DEFAULT 0
          ''');
          // Устанавливаем has_work = 1 для фракций, у которых есть workCurrency
          await db.execute('''
            UPDATE ${FactionDao.tableName} 
            SET ${FactionDao.columnHasWork} = 1 
            WHERE ${FactionDao.columnWorkCurrency} IS NOT NULL AND ${FactionDao.columnWorkCurrency} > 0
          ''');
        }
      },
    );

    final factionDao = FactionDao(_database!);

    _factionRepository = FactionRepositoryImpl(factionDao);
  }

  Database get database => _database!;
  FactionRepository get factionRepository => _factionRepository!;
}

