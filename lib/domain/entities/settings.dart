class Settings {
  final int? id;
  final int itemPrice; // цена 1 итемки
  final int itemCountRespect; // кол-во итемок для украшения уважение
  final int itemCountHonor; // кол-во итемок для украшения почтение
  final int itemCountAdoration; // кол-во итемок для украшения преклонение
  final int decorationPriceRespect; // стоимость украшения уважение
  final int decorationPriceHonor; // стоимость украшения почтение
  final int decorationPriceAdoration; // стоимость украшения преклонение
  final int currencyPerOrder; // валюта за заказ
  final int certificatePrice; // стоимость сертификата

  const Settings({
    this.id,
    required this.itemPrice,
    required this.itemCountRespect,
    required this.itemCountHonor,
    required this.itemCountAdoration,
    required this.decorationPriceRespect,
    required this.decorationPriceHonor,
    required this.decorationPriceAdoration,
    required this.currencyPerOrder,
    required this.certificatePrice,
  });

  Settings copyWith({
    int? id,
    int? itemPrice,
    int? itemCountRespect,
    int? itemCountHonor,
    int? itemCountAdoration,
    int? decorationPriceRespect,
    int? decorationPriceHonor,
    int? decorationPriceAdoration,
    int? currencyPerOrder,
    int? certificatePrice,
  }) {
    return Settings(
      id: id ?? this.id,
      itemPrice: itemPrice ?? this.itemPrice,
      itemCountRespect: itemCountRespect ?? this.itemCountRespect,
      itemCountHonor: itemCountHonor ?? this.itemCountHonor,
      itemCountAdoration: itemCountAdoration ?? this.itemCountAdoration,
      decorationPriceRespect:
          decorationPriceRespect ?? this.decorationPriceRespect,
      decorationPriceHonor: decorationPriceHonor ?? this.decorationPriceHonor,
      decorationPriceAdoration:
          decorationPriceAdoration ?? this.decorationPriceAdoration,
      currencyPerOrder: currencyPerOrder ?? this.currencyPerOrder,
      certificatePrice: certificatePrice ?? this.certificatePrice,
    );
  }

  static Settings get defaultSettings => const Settings(
        itemPrice: 0,
        itemCountRespect: 1,
        itemCountHonor: 3,
        itemCountAdoration: 6,
        decorationPriceRespect: 0,
        decorationPriceHonor: 0,
        decorationPriceAdoration: 0,
        currencyPerOrder: 0,
        certificatePrice: 0,
      );
}

