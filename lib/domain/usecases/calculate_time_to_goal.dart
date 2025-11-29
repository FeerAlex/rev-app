import 'dart:math';
import '../entities/faction.dart';
import '../../core/constants/app_settings.dart';

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
    // Учитываем потенциальный доход от заказов (если они есть во фракции)
    // и валюту с доски (если указана)
    int currencyPerDay = 0;
    
    // Потенциальный доход от заказа (если заказы есть во фракции)
    if (faction.hasOrder) {
      currencyPerDay += AppSettings.factions.currencyPerOrder;
    }
    
    // Валюта с работы (если указана)
    if (faction.workCurrency != null && faction.workCurrency! > 0) {
      currencyPerDay += faction.workCurrency!;
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

