import 'dart:math';
import '../entities/faction.dart';
import '../../core/constants/app_settings.dart';
import '../../core/constants/factions_list.dart';
import '../../core/constants/order_reward.dart';

class CalculateTimeToGoal {
  const CalculateTimeToGoal();

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

    // Сертификат
    if (!faction.certificatePurchased && faction.hasCertificate) {
      totalCost += AppSettings.factions.certificatePrice;
    }

    // Рассчитываем сколько валюты нужно
    final neededCurrency = totalCost - faction.currency;
    if (neededCurrency <= 0) {
      return Duration.zero;
    }

    // Рассчитываем валюту в день
    // Учитываем потенциальный доход от заказов (если они есть во фракции согласно статическому списку)
    // и валюту с работы (если указана)
    int currencyPerDay = 0;
    
    // Потенциальный доход от заказа (только если фракция имеет заказы согласно статическому списку)
    // Если hasOrder = false, валюту с заказов не учитываем
    if (faction.hasOrder) {
      final template = FactionsList.getTemplateByName(faction.name);
      if (template != null && template.orderRewards != null && template.orderRewards!.isNotEmpty) {
        // Вычисляем среднее арифметическое валюты из массива наград за заказы
        currencyPerDay += OrderReward.averageCurrency(template.orderRewards!);
      } else {
        // Fallback значение, если шаблон не найден или массив пустой
        currencyPerDay += 100;
      }
    }
    
    // Потенциальный доход от работы (только если hasWork = true)
    // Если hasWork = false, валюту с работы не учитываем
    if (faction.hasWork) {
      currencyPerDay += AppSettings.factions.currencyPerWork;
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

