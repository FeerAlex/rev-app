import '../../domain/entities/faction.dart';

/// Статический список всех доступных фракций в игре
class FactionsList {
  const FactionsList._();

  /// Фракции с заказами и работой (9 шт)
  static const List<FactionTemplate> factionsWithOrderAndWork = [
    FactionTemplate(name: 'Жители Сулана', hasOrder: true, hasWork: true),
    FactionTemplate(name: 'Фалмари', hasOrder: true, hasWork: true),
    FactionTemplate(name: 'Грибной народ', hasOrder: true, hasWork: true),
    FactionTemplate(name: 'Озёрная деревня', hasOrder: true, hasWork: true),
    FactionTemplate(name: 'Медведи', hasOrder: true, hasWork: true),
    FactionTemplate(name: 'Крылатые', hasOrder: true, hasWork: true),
    FactionTemplate(name: 'Монастырь Сноу-Шу', hasOrder: true, hasWork: true),
    FactionTemplate(name: 'Северные волки', hasOrder: true, hasWork: true),
    FactionTemplate(name: 'Императорская академия', hasOrder: true, hasWork: true),
  ];

  /// Фракции только с работой (4 шт)
  static const List<FactionTemplate> factionsWithWorkOnly = [
    FactionTemplate(name: 'Кнотты', hasOrder: false, hasWork: true),
    FactionTemplate(name: 'Калахар', hasOrder: false, hasWork: true),
    FactionTemplate(name: 'Астерион', hasOrder: false, hasWork: true),
    FactionTemplate(name: 'Лисы', hasOrder: false, hasWork: true),
  ];

  /// Все фракции
  static List<FactionTemplate> get allFactions => [
        ...factionsWithOrderAndWork,
        ...factionsWithWorkOnly,
      ];

  /// Создает Faction entity из шаблона
  static Faction createFactionFromTemplate(FactionTemplate template) {
    return Faction(
      name: template.name,
      currency: 0,
      hasOrder: template.hasOrder,
      orderCompleted: false,
      workCurrency: template.hasWork ? null : null, // nullable, пользователь введет значение
      hasCertificate: false,
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

  const FactionTemplate({
    required this.name,
    required this.hasOrder,
    required this.hasWork,
  });
}

