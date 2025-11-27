import 'reputation_level.dart';

class Faction {
  final int? id;
  final String name;
  final int currency;
  final ReputationLevel reputationLevel;
  final bool hasOrder; // есть ли заказы во фракции
  final bool orderCompleted;
  final int? boardCurrency; // null если доски нет
  final bool hasCertificate;
  final bool certificatePurchased;
  final bool decorationRespectPurchased;
  final bool decorationRespectUpgraded;
  final bool decorationHonorPurchased;
  final bool decorationHonorUpgraded;
  final bool decorationAdorationPurchased;
  final bool decorationAdorationUpgraded;
  final int displayOrder; // порядок отображения

  const Faction({
    this.id,
    required this.name,
    required this.currency,
    required this.reputationLevel,
    required this.hasOrder,
    required this.orderCompleted,
    this.boardCurrency,
    required this.hasCertificate,
    required this.certificatePurchased,
    required this.decorationRespectPurchased,
    required this.decorationRespectUpgraded,
    required this.decorationHonorPurchased,
    required this.decorationHonorUpgraded,
    required this.decorationAdorationPurchased,
    required this.decorationAdorationUpgraded,
    this.displayOrder = 0,
  });

  Faction copyWith({
    int? id,
    String? name,
    int? currency,
    ReputationLevel? reputationLevel,
    bool? hasOrder,
    bool? orderCompleted,
    int? boardCurrency,
    bool? hasCertificate,
    bool? certificatePurchased,
    bool? decorationRespectPurchased,
    bool? decorationRespectUpgraded,
    bool? decorationHonorPurchased,
    bool? decorationHonorUpgraded,
    bool? decorationAdorationPurchased,
    bool? decorationAdorationUpgraded,
    int? displayOrder,
  }) {
    return Faction(
      id: id ?? this.id,
      name: name ?? this.name,
      currency: currency ?? this.currency,
      reputationLevel: reputationLevel ?? this.reputationLevel,
      hasOrder: hasOrder ?? this.hasOrder,
      orderCompleted: orderCompleted ?? this.orderCompleted,
      boardCurrency: boardCurrency ?? this.boardCurrency,
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
    );
  }
}

