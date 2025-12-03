import 'dart:math';
import '../entities/faction.dart';
import '../../core/constants/app_settings.dart';
import '../../core/constants/factions_list.dart';
import '../../core/constants/order_reward.dart';

class CalculateTimeToCurrencyGoal {
  const CalculateTimeToCurrencyGoal();

  Duration? call(Faction faction) {
    // Если сертификат не нужен как цель, расчет не выполняется
    if (!faction.wantsCertificate) {
      return null;
    }

    // Рассчитываем общую стоимость всех некупленных украшений, улучшений и сертификата
    final totalCost = _calculateTotalCost(faction);

    // Рассчитываем сколько валюты нужно
    final neededCurrency = totalCost - faction.currency;
    if (neededCurrency <= 0) {
      return Duration.zero;
    }

    // Рассчитываем валюту в день
    final currencyPerDay = _calculateCurrencyPerDay(faction);
    if (currencyPerDay <= 0) {
      return null;
    }

    // Рассчитываем время до цели
    final days = neededCurrency / currencyPerDay;
    final totalMinutes = (days * 24 * 60).round();
    return Duration(minutes: max(0, totalMinutes));
  }

  /// Рассчитывает общую стоимость всех некупленных украшений, улучшений и сертификата
  int _calculateTotalCost(Faction faction) {
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

    // Сертификат (только если нужен как цель и не куплен)
    if (!faction.certificatePurchased && faction.wantsCertificate) {
      totalCost += AppSettings.factions.certificatePrice;
    }

    return totalCost;
  }

  /// Рассчитывает валюту в день из всех доступных источников дохода
  int _calculateCurrencyPerDay(Faction faction) {
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

    return currencyPerDay;
  }
}
