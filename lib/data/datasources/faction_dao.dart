import 'package:sqflite/sqflite.dart';

class FactionDao {
  static const String tableName = 'factions';
  static const String columnId = 'id';
  static const String columnName = 'name';
  static const String columnCurrency = 'currency';
  static const String columnHasOrder = 'has_order';
  static const String columnOrderCompleted = 'order_completed';
  static const String columnWorkCurrency = 'work_currency';
  static const String columnWorkExp = 'work_exp';
  static const String columnHasWork = 'has_work';
  static const String columnWorkCompleted = 'work_completed';
  static const String columnHasCertificate = 'has_certificate';
  static const String columnCertificatePurchased = 'certificate_purchased';
  static const String columnDecorationRespectPurchased =
      'decoration_respect_purchased';
  static const String columnDecorationRespectUpgraded =
      'decoration_respect_upgraded';
  static const String columnDecorationHonorPurchased =
      'decoration_honor_purchased';
  static const String columnDecorationHonorUpgraded =
      'decoration_honor_upgraded';
  static const String columnDecorationAdorationPurchased =
      'decoration_adoration_purchased';
  static const String columnDecorationAdorationUpgraded =
      'decoration_adoration_upgraded';
  static const String columnDisplayOrder = 'display_order';
  static const String columnIsVisible = 'is_visible';
  static const String columnCurrentReputationLevel = 'current_reputation_level';
  static const String columnCurrentLevelExp = 'current_level_exp';
  static const String columnTargetReputationLevel = 'target_reputation_level';
  static const String columnWantsCertificate = 'wants_certificate';

  final Database _db;

  FactionDao(this._db);

  static Future<void> createTable(Database db) async {
    await db.execute('''
      CREATE TABLE $tableName (
        $columnId INTEGER PRIMARY KEY AUTOINCREMENT,
        $columnName TEXT NOT NULL,
        $columnCurrency INTEGER NOT NULL DEFAULT 0,
        $columnHasOrder INTEGER NOT NULL DEFAULT 0,
        $columnOrderCompleted INTEGER NOT NULL DEFAULT 0,
        $columnWorkCurrency INTEGER,
        $columnWorkExp INTEGER,
        $columnHasWork INTEGER NOT NULL DEFAULT 0,
        $columnWorkCompleted INTEGER NOT NULL DEFAULT 0,
        $columnHasCertificate INTEGER NOT NULL DEFAULT 0,
        $columnCertificatePurchased INTEGER NOT NULL DEFAULT 0,
        $columnDecorationRespectPurchased INTEGER NOT NULL DEFAULT 0,
        $columnDecorationRespectUpgraded INTEGER NOT NULL DEFAULT 0,
        $columnDecorationHonorPurchased INTEGER NOT NULL DEFAULT 0,
        $columnDecorationHonorUpgraded INTEGER NOT NULL DEFAULT 0,
        $columnDecorationAdorationPurchased INTEGER NOT NULL DEFAULT 0,
        $columnDecorationAdorationUpgraded INTEGER NOT NULL DEFAULT 0,
        $columnDisplayOrder INTEGER NOT NULL DEFAULT 0,
        $columnIsVisible INTEGER NOT NULL DEFAULT 1,
        $columnCurrentReputationLevel INTEGER NOT NULL DEFAULT 0,
        $columnCurrentLevelExp INTEGER NOT NULL DEFAULT 0,
        $columnTargetReputationLevel INTEGER DEFAULT NULL,
        $columnWantsCertificate INTEGER NOT NULL DEFAULT 0
      )
    ''');
  }

  Future<List<Map<String, dynamic>>> getAllFactions() async {
    return await _db.query(
      tableName,
      where: '$columnIsVisible = ?',
      whereArgs: [1],
      orderBy: '$columnDisplayOrder ASC, $columnId ASC',
    );
  }

  /// Получить все фракции, включая скрытые
  Future<List<Map<String, dynamic>>> getAllFactionsIncludingHidden() async {
    return await _db.query(
      tableName,
      orderBy: '$columnDisplayOrder ASC, $columnId ASC',
    );
  }

  /// Получить только скрытые фракции
  Future<List<Map<String, dynamic>>> getHiddenFactions() async {
    return await _db.query(
      tableName,
      where: '$columnIsVisible = ?',
      whereArgs: [0],
      orderBy: '$columnName ASC',
    );
  }

  Future<Map<String, dynamic>?> getFactionById(int id) async {
    final results = await _db.query(
      tableName,
      where: '$columnId = ?',
      whereArgs: [id],
    );
    return results.isNotEmpty ? results.first : null;
  }

  Future<int> insertFaction(Map<String, dynamic> faction) async {
    return await _db.insert(tableName, faction);
  }

  Future<int> updateFaction(Map<String, dynamic> faction) async {
    final id = faction[columnId] as int;
    // Создаем копию map без id, чтобы не пытаться обновить PRIMARY KEY
    final updateData = Map<String, dynamic>.from(faction)..remove(columnId);
    
    // Явно проверяем, что orderCompleted присутствует в updateData
    if (!updateData.containsKey(columnOrderCompleted)) {
      throw Exception('orderCompleted field is missing in update data for faction $id');
    }
    
    // Обновляем фракцию
    final result = await _db.update(
      tableName,
      updateData,
      where: '$columnId = ?',
      whereArgs: [id],
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    
    // Проверяем, что обновление произошло и значение сохранилось
    if (result > 0) {
      final updated = await getFactionById(id);
      if (updated != null) {
        final savedOrderCompleted = (updated[columnOrderCompleted] as int) == 1;
        final expectedOrderCompleted = (updateData[columnOrderCompleted] as int) == 1;
        if (savedOrderCompleted != expectedOrderCompleted) {
          throw Exception('orderCompleted was not saved correctly for faction $id. Expected: $expectedOrderCompleted, Got: $savedOrderCompleted');
        }
      }
    }
    
    return result;
  }

  Future<int> deleteFaction(int id) async {
    return await _db.delete(
      tableName,
      where: '$columnId = ?',
      whereArgs: [id],
    );
  }

  Future<int> resetDailyFlags() async {
    return await _db.update(
      tableName,
      {
        columnOrderCompleted: 0,
        columnWorkCompleted: 0,
      },
    );
  }

  Future<void> updateFactionOrder(int id, int order) async {
    await _db.update(
      tableName,
      {columnDisplayOrder: order},
      where: '$columnId = ?',
      whereArgs: [id],
    );
  }

  Future<void> updateFactionsOrder(List<Map<String, int>> orders) async {
    final batch = _db.batch();
    for (final order in orders) {
      batch.update(
        tableName,
        {columnDisplayOrder: order['order']!},
        where: '$columnId = ?',
        whereArgs: [order['id']!],
      );
    }
    await batch.commit(noResult: true);
  }
}

