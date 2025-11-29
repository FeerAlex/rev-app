import '../../domain/entities/faction.dart';
import '../datasources/faction_dao.dart';

class FactionModel {
  static Faction fromMap(Map<String, dynamic> map) {
    return Faction(
      id: map[FactionDao.columnId] as int?,
      name: map[FactionDao.columnName] as String,
      currency: map[FactionDao.columnCurrency] as int,
      hasOrder: (map[FactionDao.columnHasOrder] as int? ?? 0) == 1,
      orderCompleted: (map[FactionDao.columnOrderCompleted] as int) == 1,
      workCurrency: map[FactionDao.columnWorkCurrency] as int?,
      hasCertificate: (map[FactionDao.columnHasCertificate] as int) == 1,
      certificatePurchased:
          (map[FactionDao.columnCertificatePurchased] as int) == 1,
      decorationRespectPurchased:
          (map[FactionDao.columnDecorationRespectPurchased] as int) == 1,
      decorationRespectUpgraded:
          (map[FactionDao.columnDecorationRespectUpgraded] as int) == 1,
      decorationHonorPurchased:
          (map[FactionDao.columnDecorationHonorPurchased] as int) == 1,
      decorationHonorUpgraded:
          (map[FactionDao.columnDecorationHonorUpgraded] as int) == 1,
      decorationAdorationPurchased:
          (map[FactionDao.columnDecorationAdorationPurchased] as int) == 1,
      decorationAdorationUpgraded:
          (map[FactionDao.columnDecorationAdorationUpgraded] as int) == 1,
      displayOrder: map[FactionDao.columnDisplayOrder] as int? ?? 0,
    );
  }

  static Map<String, dynamic> toMap(Faction faction) {
    final map = <String, dynamic>{
      FactionDao.columnName: faction.name,
      FactionDao.columnCurrency: faction.currency,
      FactionDao.columnHasOrder: faction.hasOrder ? 1 : 0,
      FactionDao.columnOrderCompleted: faction.orderCompleted ? 1 : 0,
      FactionDao.columnHasCertificate: faction.hasCertificate ? 1 : 0,
      FactionDao.columnCertificatePurchased: faction.certificatePurchased ? 1 : 0,
      FactionDao.columnDecorationRespectPurchased:
          faction.decorationRespectPurchased ? 1 : 0,
      FactionDao.columnDecorationRespectUpgraded:
          faction.decorationRespectUpgraded ? 1 : 0,
      FactionDao.columnDecorationHonorPurchased:
          faction.decorationHonorPurchased ? 1 : 0,
      FactionDao.columnDecorationHonorUpgraded:
          faction.decorationHonorUpgraded ? 1 : 0,
      FactionDao.columnDecorationAdorationPurchased:
          faction.decorationAdorationPurchased ? 1 : 0,
      FactionDao.columnDecorationAdorationUpgraded:
          faction.decorationAdorationUpgraded ? 1 : 0,
      FactionDao.columnDisplayOrder: faction.displayOrder,
    };

    if (faction.id != null) {
      map[FactionDao.columnId] = faction.id;
    }
    if (faction.workCurrency != null) {
      map[FactionDao.columnWorkCurrency] = faction.workCurrency;
    }

    return map;
  }
}

