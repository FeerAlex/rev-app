class Faction {
  final int? id;
  final String name;
  final int currency;
  final bool hasOrder; // есть ли заказы во фракции
  final bool orderCompleted;
  final int? workCurrency; // null если работы нет
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

  const Faction({
    this.id,
    required this.name,
    required this.currency,
    required this.hasOrder,
    required this.orderCompleted,
    this.workCurrency,
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
  });

  Faction copyWith({
    int? id,
    String? name,
    int? currency,
    bool? hasOrder,
    bool? orderCompleted,
    int? workCurrency,
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
  }) {
    return Faction(
      id: id ?? this.id,
      name: name ?? this.name,
      currency: currency ?? this.currency,
      hasOrder: hasOrder ?? this.hasOrder,
      orderCompleted: orderCompleted ?? this.orderCompleted,
      workCurrency: workCurrency ?? this.workCurrency,
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
    );
  }
}

