import '../../domain/entities/faction.dart';
import '../../domain/entities/reputation_level.dart';
import '../../domain/value_objects/work_reward.dart';
import '../datasources/faction_dao.dart';

class FactionModel {
  static Faction fromMap(Map<String, dynamic> map) {
    return Faction(
      id: map[FactionDao.columnId] as int?,
      name: map[FactionDao.columnName] as String,
      currency: map[FactionDao.columnCurrency] as int,
      orderCompleted: (map[FactionDao.columnOrderCompleted] as int) == 1,
      ordersEnabled: (map[FactionDao.columnHasOrder] as int? ?? 1) == 1,
      workReward: () {
        final currency = map[FactionDao.columnWorkCurrency] as int?;
        final exp = map[FactionDao.columnWorkExp] as int?;
        // Всегда создаем WorkReward (даже если оба поля null или 0)
        return WorkReward(
          currency: currency ?? 0,
          exp: exp ?? 0,
        );
      }(),
      workCompleted: (map[FactionDao.columnWorkCompleted] as int? ?? 0) == 1,
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
      isVisible: (map[FactionDao.columnIsVisible] as int? ?? 1) == 1,
      currentReputationLevel: ReputationLevelExtension.fromValue(
        map[FactionDao.columnCurrentReputationLevel] as int? ?? 0,
      ),
      currentLevelExp: map[FactionDao.columnCurrentLevelExp] as int? ?? 0,
      targetReputationLevel: () {
        final value = map[FactionDao.columnTargetReputationLevel] as int?;
        return value != null ? ReputationLevelExtension.fromValue(value) : null;
      }(),
      wantsCertificate: (map[FactionDao.columnWantsCertificate] as int? ?? 0) == 1,
    );
  }

  static Map<String, dynamic> toMap(Faction faction) {
    final map = <String, dynamic>{
      FactionDao.columnName: faction.name,
      FactionDao.columnCurrency: faction.currency,
      FactionDao.columnOrderCompleted: faction.orderCompleted ? 1 : 0,
      FactionDao.columnHasOrder: faction.ordersEnabled ? 1 : 0,
      FactionDao.columnWorkCompleted: faction.workCompleted ? 1 : 0,
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
      FactionDao.columnIsVisible: faction.isVisible ? 1 : 0,
      FactionDao.columnCurrentReputationLevel: faction.currentReputationLevel.value,
      FactionDao.columnCurrentLevelExp: faction.currentLevelExp,
      FactionDao.columnTargetReputationLevel: faction.targetReputationLevel?.value,
      FactionDao.columnWantsCertificate: faction.wantsCertificate ? 1 : 0,
    };

    if (faction.id != null) {
      map[FactionDao.columnId] = faction.id;
    }
    // Всегда сохраняем оба поля (даже если 0)
    map[FactionDao.columnWorkCurrency] = faction.workReward?.currency ?? 0;
    map[FactionDao.columnWorkExp] = faction.workReward?.exp ?? 0;

    return map;
  }
}

