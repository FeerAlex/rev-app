import 'dart:math';
import '../entities/faction.dart';
import '../../core/constants/app_settings.dart';
import '../../core/constants/factions_list.dart';
import '../../core/constants/order_reward.dart';

class CalculateTimeToCurrencyGoal {
  const CalculateTimeToCurrencyGoal();

  Duration? call(Faction faction) {

    // Рассчитываем общую стоимость
    int totalCost = 0;

    // Украшение уважение
    if (!faction.decorationRespectPurchased) {
      totalCost += AppSettings.factions.decorationPriceRespect;
    }
    if (!faction.decorationRespectUpgraded) {
      totalCost += AppSettings.factions.decorationUpgradeCostRespect;
    }

    // Украшение почтение
    if (!faction.decorationHonorPurchased) {
      totalCost += AppSettings.factions.decorationPriceHonor;
    }
    if (!faction.decorationHonorUpgraded) {
      totalCost += AppSettings.factions.decorationUpgradeCostHonor;
    }

    // Украшение преклонение
    if (!faction.decorationAdorationPurchased) {
      totalCost += AppSettings.factions.decorationPriceAdoration;
    }
    if (!faction.decorationAdorationUpgraded) {
      totalCost += AppSettings.factions.decorationUpgradeCostAdoration;
    }

    // Сертификат (только если нужен как цель)
    if (!faction.certificatePurchased && faction.wantsCertificate) {
      totalCost += AppSettings.factions.certificatePrice;
    }

    // Рассчитываем сколько валюты нужно
    final neededCurrency = totalCost - faction.currency;
    if (neededCurrency <= 0) {
      return Duration.zero;
    }

    // Рассчитываем валюту в день
    int currencyPerDay = 0;
    
    // Потенциальный доход от заказа (только если заказы включены и фракция имеет заказы согласно статическому списку)
    final template = FactionsList.getTemplateByName(faction.name);
    if (faction.ordersEnabled && template != null && template.orderReward != null) {
      // Вычисляем среднее арифметическое валюты из награды за заказы
      currencyPerDay += OrderReward.averageCurrency(template.orderReward!);
    }

    // Потенциальный доход от работы
    if (faction.workReward != null && faction.workReward!.currency > 0) {
      currencyPerDay += faction.workReward!.currency;
    }

    // Если нет дохода в день, вернуть null
    if (currencyPerDay <= 0) {
      return null;
    }

    // Рассчитываем дни
    final days = neededCurrency / currencyPerDay;
    final totalMinutes = (days * 24 * 60).round();
    return Duration(minutes: max(0, totalMinutes));
  }
}
