import 'package:sqflite/sqflite.dart';

class SettingsDao {
  static const String tableName = 'settings';
  static const String columnId = 'id';
  static const String columnItemPrice = 'item_price';
  static const String columnItemCountRespect = 'item_count_respect';
  static const String columnItemCountHonor = 'item_count_honor';
  static const String columnItemCountAdoration = 'item_count_adoration';
  static const String columnDecorationPriceRespect = 'decoration_price_respect';
  static const String columnDecorationPriceHonor = 'decoration_price_honor';
  static const String columnDecorationPriceAdoration =
      'decoration_price_adoration';
  static const String columnCurrencyPerOrder = 'currency_per_order';
  static const String columnCertificatePrice = 'certificate_price';

  final Database _db;

  SettingsDao(this._db);

  static Future<void> createTable(Database db) async {
    await db.execute('''
      CREATE TABLE $tableName (
        $columnId INTEGER PRIMARY KEY AUTOINCREMENT,
        $columnItemPrice INTEGER NOT NULL DEFAULT 0,
        $columnItemCountRespect INTEGER NOT NULL DEFAULT 1,
        $columnItemCountHonor INTEGER NOT NULL DEFAULT 3,
        $columnItemCountAdoration INTEGER NOT NULL DEFAULT 6,
        $columnDecorationPriceRespect INTEGER NOT NULL DEFAULT 0,
        $columnDecorationPriceHonor INTEGER NOT NULL DEFAULT 0,
        $columnDecorationPriceAdoration INTEGER NOT NULL DEFAULT 0,
        $columnCurrencyPerOrder INTEGER NOT NULL DEFAULT 0,
        $columnCertificatePrice INTEGER NOT NULL DEFAULT 0
      )
    ''');

    // Вставляем дефолтные настройки если их нет
    final existing = await db.query(tableName);
    if (existing.isEmpty) {
      await db.insert(tableName, {
        columnItemPrice: 0,
        columnItemCountRespect: 1,
        columnItemCountHonor: 3,
        columnItemCountAdoration: 6,
        columnDecorationPriceRespect: 0,
        columnDecorationPriceHonor: 0,
        columnDecorationPriceAdoration: 0,
        columnCurrencyPerOrder: 0,
        columnCertificatePrice: 0,
      });
    }
  }

  Future<Map<String, dynamic>?> getSettings() async {
    final results = await _db.query(tableName, limit: 1);
    return results.isNotEmpty ? results.first : null;
  }

  Future<int> updateSettings(Map<String, dynamic> settings) async {
    final id = settings[columnId] as int?;
    if (id != null) {
      return await _db.update(
        tableName,
        settings,
        where: '$columnId = ?',
        whereArgs: [id],
      );
    } else {
      return await _db.insert(tableName, settings);
    }
  }
}

