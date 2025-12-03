import '../value_objects/order_reward.dart';

/// Шаблон фракции для статического списка
class FactionTemplate {
  final String name;
  final bool hasWork;
  final bool hasCertificate;
  final bool hasSpecialExp; // true = специальные значения опыта, false = стандартные
  final OrderReward? orderReward; // Награда за заказы (валюта и опыт)

  const FactionTemplate({
    required this.name,
    required this.hasWork,
    required this.hasCertificate,
    this.hasSpecialExp = false, // По умолчанию стандартные значения
    this.orderReward,
  });
}

