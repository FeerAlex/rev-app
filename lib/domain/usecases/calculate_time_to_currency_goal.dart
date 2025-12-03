import 'dart:math';
import '../entities/faction.dart';
import '../repositories/app_settings_repository.dart';
import '../repositories/faction_template_repository.dart';
import '../value_objects/order_reward.dart';

class CalculateTimeToCurrencyGoal {
  final AppSettingsRepository _settingsRepository;
  final FactionTemplateRepository _templateRepository;

  CalculateTimeToCurrencyGoal(
    this._settingsRepository,
    this._templateRepository,
  );

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
      totalCost += _settingsRepository.getDecorationPriceRespect();
    }
    if (!faction.decorationRespectUpgraded) {
      totalCost += _settingsRepository.getDecorationUpgradeCostRespect();
    }

    // Украшение почтение
    if (!faction.decorationHonorPurchased) {
      totalCost += _settingsRepository.getDecorationPriceHonor();
    }
    if (!faction.decorationHonorUpgraded) {
      totalCost += _settingsRepository.getDecorationUpgradeCostHonor();
    }

    // Украшение преклонение
    if (!faction.decorationAdorationPurchased) {
      totalCost += _settingsRepository.getDecorationPriceAdoration();
    }
    if (!faction.decorationAdorationUpgraded) {
      totalCost += _settingsRepository.getDecorationUpgradeCostAdoration();
    }

    // Сертификат (только если нужен как цель и не куплен)
    if (!faction.certificatePurchased && faction.wantsCertificate) {
      totalCost += _settingsRepository.getCertificatePrice();
    }

    return totalCost;
  }

  /// Рассчитывает валюту в день из всех доступных источников дохода
  int _calculateCurrencyPerDay(Faction faction) {
    int currencyPerDay = 0;

    // Потенциальный доход от заказа (только если заказы включены и фракция имеет заказы согласно статическому списку)
    final template = _templateRepository.getTemplateByName(faction.name);
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
