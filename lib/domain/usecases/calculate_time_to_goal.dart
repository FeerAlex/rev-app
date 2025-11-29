import 'dart:math';
import '../entities/faction.dart';
import '../repositories/faction_repository.dart';
import '../repositories/settings_repository.dart';

class CalculateTimeToGoal {
  final FactionRepository factionRepository;
  final SettingsRepository settingsRepository;

  CalculateTimeToGoal(this.factionRepository, this.settingsRepository);

  Future<Duration?> call(Faction faction) async {
    final settings = await settingsRepository.getSettings();

    // Рассчитываем общую стоимость
    int totalCost = 0;

    // Украшение уважение
    if (!faction.decorationRespectPurchased) {
      totalCost += settings.decorationPriceRespect;
    }
    if (!faction.decorationRespectUpgraded) {
      totalCost += settings.itemCountRespect * settings.itemPrice;
    }

    // Украшение почтение
    if (!faction.decorationHonorPurchased) {
      totalCost += settings.decorationPriceHonor;
    }
    if (!faction.decorationHonorUpgraded) {
      totalCost += settings.itemCountHonor * settings.itemPrice;
    }

    // Украшение преклонение
    if (!faction.decorationAdorationPurchased) {
      totalCost += settings.decorationPriceAdoration;
    }
    if (!faction.decorationAdorationUpgraded) {
      totalCost += settings.itemCountAdoration * settings.itemPrice;
    }

    // Сертификат
    if (!faction.certificatePurchased && faction.hasCertificate) {
      totalCost += settings.certificatePrice;
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
    if (faction.hasOrder && settings.currencyPerOrder > 0) {
      currencyPerDay += settings.currencyPerOrder;
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

