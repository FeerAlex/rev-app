import '../../domain/entities/faction.dart';
import 'order_reward.dart';
import 'reputation_level.dart';

/// Статический список всех доступных фракций в игре
class FactionsList {
  const FactionsList._();

  /// Фракции с заказами и работой (9 шт)
  static const List<FactionTemplate> factionsWithOrderAndWork = [
    FactionTemplate(name: 'Жители Сулана', hasWork: true, hasCertificate: true, orderReward: OrderReward(currency: [176, 176], exp: [1100, 1100])),
    FactionTemplate(name: 'Фалмари', hasWork: true, hasCertificate: true, orderReward: OrderReward(currency: [90, 105], exp: [900, 1050])),
    FactionTemplate(name: 'Грибной народ', hasWork: true, hasCertificate: true, orderReward: OrderReward(currency: [85, 80], exp: [850, 800])),
    FactionTemplate(name: 'Озёрная деревня', hasWork: true, hasCertificate: true, orderReward: OrderReward(currency: [60, 60], exp: [600, 600])),
    FactionTemplate(name: 'Медведи', hasWork: true, hasCertificate: true, orderReward: OrderReward(currency: [100, 100], exp: [1000, 1000])),
    FactionTemplate(name: 'Крылатые', hasWork: true, hasCertificate: true, orderReward: OrderReward(currency: [105, 125], exp: [1050, 1250])),
    FactionTemplate(name: 'Монастырь Сноу-Шу', hasWork: true, hasCertificate: true, orderReward: OrderReward(currency: [114, 144], exp: [900, 900])),
    FactionTemplate(name: 'Северные волки', hasWork: true, hasCertificate: true, orderReward: OrderReward(currency: [120, 120], exp: [1200, 1200])),
    FactionTemplate(name: 'Императорская академия', hasWork: true, hasCertificate: true, orderReward: OrderReward(currency: [66, 66], exp: [1100, 1100])),
  ];

  /// Фракции только с работой (4 шт)
  static const List<FactionTemplate> factionsWithWorkOnly = [
    FactionTemplate(name: 'Кнотты', hasWork: true, hasCertificate: true),
    FactionTemplate(name: 'Калахар', hasWork: true, hasCertificate: true),
    FactionTemplate(name: 'Астерион', hasWork: true, hasCertificate: true),
    FactionTemplate(name: 'Лисы', hasWork: true, hasCertificate: true),
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
      // Основная информация
      name: template.name,
      currency: 0,

      // Ежедневные активности (заказы и работы)
      orderCompleted: false,
      ordersEnabled: false, // по умолчанию выключено
      workCompleted: false,
      workReward: null, // пользователь введет значение через UI

      // Сертификат
      hasCertificate: template.hasCertificate,
      certificatePurchased: false,

      // Украшения (декорации фракции: Уважение, Почтение, Преклонение)
      decorationAdorationPurchased: false,
      decorationAdorationUpgraded: false,
      decorationHonorPurchased: false,
      decorationHonorUpgraded: false,
      decorationRespectPurchased: false,
      decorationRespectUpgraded: false,

      // Настройки отображения
      displayOrder: 0,
      isVisible: false, // По умолчанию скрыта

      // Репутация (текущий и целевой уровень отношения)
      currentLevelExp: 0,
      currentReputationLevel: ReputationLevel.indifference,
      targetReputationLevel: null, // По умолчанию цель не установлена
      wantsCertificate: false, // По умолчанию сертификат не нужен как цель
    );
  }
}

/// Шаблон фракции для статического списка
class FactionTemplate {
  final String name;
  final bool hasWork;
  final bool hasCertificate;
  final OrderReward? orderReward; // Награда за заказы (валюта и опыт) (nullable, только для фракций с заказами)

  const FactionTemplate({
    required this.name,
    required this.hasWork,
    required this.hasCertificate,
    this.orderReward,
  });
}

