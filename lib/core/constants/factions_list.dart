import '../../domain/entities/faction.dart';
import 'order_reward.dart';
import 'reputation_level.dart';

/// Статический список всех доступных фракций в игре
class FactionsList {
  const FactionsList._();

  /// Фракции с заказами и работой (9 шт)
  static const List<FactionTemplate> factionsWithOrderAndWork = [
    FactionTemplate(name: 'Жители Сулана', hasOrder: true, hasWork: true, hasCertificate: true, orderRewards: [OrderReward(currency: 176, exp: 1100), OrderReward(currency: 176, exp: 1100)]),
    FactionTemplate(name: 'Фалмари', hasOrder: true, hasWork: true, hasCertificate: true, orderRewards: [OrderReward(currency: 90, exp: 900), OrderReward(currency: 105, exp: 1050)]),
    FactionTemplate(name: 'Грибной народ', hasOrder: true, hasWork: true, hasCertificate: true, orderRewards: [OrderReward(currency: 85, exp: 850), OrderReward(currency: 80, exp: 800)]),
    FactionTemplate(name: 'Озёрная деревня', hasOrder: true, hasWork: true, hasCertificate: true, orderRewards: [OrderReward(currency: 60, exp: 600), OrderReward(currency: 60, exp: 600)]),
    FactionTemplate(name: 'Медведи', hasOrder: true, hasWork: true, hasCertificate: true, orderRewards: [OrderReward(currency: 100, exp: 1000), OrderReward(currency: 100, exp: 1000)]),
    FactionTemplate(name: 'Крылатые', hasOrder: true, hasWork: true, hasCertificate: true, orderRewards: [OrderReward(currency: 105, exp: 1050), OrderReward(currency: 125, exp: 1250)]),
    FactionTemplate(name: 'Монастырь Сноу-Шу', hasOrder: true, hasWork: true, hasCertificate: true, orderRewards: [OrderReward(currency: 114, exp: 900), OrderReward(currency: 144, exp: 900)]),
    FactionTemplate(name: 'Северные волки', hasOrder: true, hasWork: true, hasCertificate: true, orderRewards: [OrderReward(currency: 120, exp: 1200), OrderReward(currency: 120, exp: 1200)]),
    FactionTemplate(name: 'Императорская академия', hasOrder: true, hasWork: true, hasCertificate: true, orderRewards: [OrderReward(currency: 66, exp: 1100), OrderReward(currency: 66, exp: 1100)]),
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
      currentReputationLevel: ReputationLevel.indifference,
      currentLevelExp: 0,
      targetReputationLevel: ReputationLevel.maximum,
    );
  }
}

/// Шаблон фракции для статического списка
class FactionTemplate {
  final String name;
  final bool hasOrder;
  final bool hasWork;
  final bool hasCertificate;
  final List<OrderReward>? orderRewards; // Массив наград за заказы (валюта и опыт) (только для фракций с заказами)

  const FactionTemplate({
    required this.name,
    required this.hasOrder,
    required this.hasWork,
    required this.hasCertificate,
    this.orderRewards,
  });
}

