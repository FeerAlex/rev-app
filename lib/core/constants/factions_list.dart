import '../../domain/entities/faction.dart';

/// Статический список всех доступных фракций в игре
class FactionsList {
  const FactionsList._();

  /// Фракции с заказами и работой (9 шт)
  static const List<FactionTemplate> factionsWithOrderAndWork = [
    FactionTemplate(name: 'Жители Сулана', hasOrder: true, hasWork: true, hasCertificate: true, orderCurrencyValues: [176, 176]),
    FactionTemplate(name: 'Фалмари', hasOrder: true, hasWork: true, hasCertificate: true, orderCurrencyValues: [90, 105]),
    FactionTemplate(name: 'Грибной народ', hasOrder: true, hasWork: true, hasCertificate: true, orderCurrencyValues: [85, 80]),
    FactionTemplate(name: 'Озёрная деревня', hasOrder: true, hasWork: true, hasCertificate: true, orderCurrencyValues: [60, 60]),
    FactionTemplate(name: 'Медведи', hasOrder: true, hasWork: true, hasCertificate: true, orderCurrencyValues: [100, 100]),
    FactionTemplate(name: 'Крылатые', hasOrder: true, hasWork: true, hasCertificate: true, orderCurrencyValues: [105, 125]),
    FactionTemplate(name: 'Монастырь Сноу-Шу', hasOrder: true, hasWork: true, hasCertificate: true, orderCurrencyValues: [114, 144]),
    FactionTemplate(name: 'Северные волки', hasOrder: true, hasWork: true, hasCertificate: true, orderCurrencyValues: [120, 120]),
    FactionTemplate(name: 'Императорская академия', hasOrder: true, hasWork: true, hasCertificate: true, orderCurrencyValues: [66, 66]),
  ];

  /// Фракции только с работой (4 шт)
  static const List<FactionTemplate> factionsWithWorkOnly = [
    FactionTemplate(name: 'Кнотты', hasOrder: false, hasWork: true, hasCertificate: true),
    FactionTemplate(name: 'Калахар', hasOrder: false, hasWork: true, hasCertificate: true),
    FactionTemplate(name: 'Астерион', hasOrder: false, hasWork: true, hasCertificate: true),
    FactionTemplate(name: 'Лисы', hasOrder: false, hasWork: true, hasCertificate: true),
  ];

  /// Все фракции
  static List<FactionTemplate> get allFactions => [
        ...factionsWithOrderAndWork,
        ...factionsWithWorkOnly,
      ];

  /// Получить шаблон фракции по имени
  static FactionTemplate? getTemplateByName(String name) {
    try {
      return allFactions.firstWhere((template) => template.name == name);
    } catch (e) {
      return null;
    }
  }

  /// Создает Faction entity из шаблона
  static Faction createFactionFromTemplate(FactionTemplate template) {
    return Faction(
      name: template.name,
      currency: 0,
      hasOrder: template.hasOrder,
      orderCompleted: false,
      workCurrency: template.hasWork ? null : null, // nullable, пользователь введет значение
      hasWork: template.hasWork,
      workCompleted: false,
      hasCertificate: template.hasCertificate,
      certificatePurchased: false,
      decorationRespectPurchased: false,
      decorationRespectUpgraded: false,
      decorationHonorPurchased: false,
      decorationHonorUpgraded: false,
      decorationAdorationPurchased: false,
      decorationAdorationUpgraded: false,
      isVisible: false, // По умолчанию скрыта
      displayOrder: 0,
    );
  }
}

/// Шаблон фракции для статического списка
class FactionTemplate {
  final String name;
  final bool hasOrder;
  final bool hasWork;
  final bool hasCertificate;
  final List<int>? orderCurrencyValues; // Массив значений валюты за заказы (только для фракций с заказами)

  const FactionTemplate({
    required this.name,
    required this.hasOrder,
    required this.hasWork,
    required this.hasCertificate,
    this.orderCurrencyValues,
  });
}

