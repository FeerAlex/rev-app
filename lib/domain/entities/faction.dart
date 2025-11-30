import '../../core/constants/reputation_level.dart';

class Faction {
  final int? id;
  final String name;
  final int currency;
  final bool orderCompleted;
  final bool ordersEnabled; // учитывать ли заказы в расчете
  final int? workCurrency; // null если работы нет
  final bool hasWork; // учитывать ли работу в калькуляторе
  final bool workCompleted; // выполнена ли работа
  final bool hasCertificate;
  final bool certificatePurchased;
  final bool decorationRespectPurchased;
  final bool decorationRespectUpgraded;
  final bool decorationHonorPurchased;
  final bool decorationHonorUpgraded;
  final bool decorationAdorationPurchased;
  final bool decorationAdorationUpgraded;
  final int displayOrder; // порядок отображения
  final bool isVisible; // видимость фракции в списке
  final ReputationLevel currentReputationLevel; // текущий уровень отношения
  final int currentLevelExp; // опыт на текущем уровне (от 0 до требуемого для уровня)
  final ReputationLevel targetReputationLevel; // целевой уровень отношения

  const Faction({
    this.id,
    required this.name,
    required this.currency,
    required this.orderCompleted,
    this.ordersEnabled = true,
    this.workCurrency,
    required this.hasWork,
    required this.workCompleted,
    required this.hasCertificate,
    required this.certificatePurchased,
    required this.decorationRespectPurchased,
    required this.decorationRespectUpgraded,
    required this.decorationHonorPurchased,
    required this.decorationHonorUpgraded,
    required this.decorationAdorationPurchased,
    required this.decorationAdorationUpgraded,
    this.displayOrder = 0,
    this.isVisible = true,
    this.currentReputationLevel = ReputationLevel.indifference,
    this.currentLevelExp = 0,
    this.targetReputationLevel = ReputationLevel.maximum,
  });

  Faction copyWith({
    int? id,
    String? name,
    int? currency,
    bool? orderCompleted,
    bool? ordersEnabled,
    int? workCurrency,
    bool? hasWork,
    bool? workCompleted,
    bool? hasCertificate,
    bool? certificatePurchased,
    bool? decorationRespectPurchased,
    bool? decorationRespectUpgraded,
    bool? decorationHonorPurchased,
    bool? decorationHonorUpgraded,
    bool? decorationAdorationPurchased,
    bool? decorationAdorationUpgraded,
    int? displayOrder,
    bool? isVisible,
    ReputationLevel? currentReputationLevel,
    int? currentLevelExp,
    ReputationLevel? targetReputationLevel,
  }) {
    return Faction(
      id: id ?? this.id,
      name: name ?? this.name,
      currency: currency ?? this.currency,
      orderCompleted: orderCompleted ?? this.orderCompleted,
      ordersEnabled: ordersEnabled ?? this.ordersEnabled,
      workCurrency: workCurrency ?? this.workCurrency,
      hasWork: hasWork ?? this.hasWork,
      workCompleted: workCompleted ?? this.workCompleted,
      hasCertificate: hasCertificate ?? this.hasCertificate,
      certificatePurchased: certificatePurchased ?? this.certificatePurchased,
      decorationRespectPurchased:
          decorationRespectPurchased ?? this.decorationRespectPurchased,
      decorationRespectUpgraded:
          decorationRespectUpgraded ?? this.decorationRespectUpgraded,
      decorationHonorPurchased:
          decorationHonorPurchased ?? this.decorationHonorPurchased,
      decorationHonorUpgraded:
          decorationHonorUpgraded ?? this.decorationHonorUpgraded,
      decorationAdorationPurchased:
          decorationAdorationPurchased ?? this.decorationAdorationPurchased,
      decorationAdorationUpgraded:
          decorationAdorationUpgraded ?? this.decorationAdorationUpgraded,
      displayOrder: displayOrder ?? this.displayOrder,
      isVisible: isVisible ?? this.isVisible,
      currentReputationLevel: currentReputationLevel ?? this.currentReputationLevel,
      currentLevelExp: currentLevelExp ?? this.currentLevelExp,
      targetReputationLevel: targetReputationLevel ?? this.targetReputationLevel,
    );
  }
}

