import 'package:flutter/material.dart';
import '../../../domain/entities/faction.dart';
import '../../../core/constants/app_settings.dart';
import '../../../core/constants/factions_list.dart';
import '../../../core/constants/order_reward.dart';
import '../time_to_goal/time_to_currency_goal_widget.dart';
import '../common/help_dialog.dart';

/// Виджет для отображения прогресса валюты с progress bar
class CurrencyProgressBar extends StatelessWidget {
  final Faction faction;

  const CurrencyProgressBar({
    super.key,
    required this.faction,
  });

  int _calculateNeededCurrency(Faction faction) {
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

    return totalCost;
  }

  /// Проверяет, есть ли данные для расчета времени до цели
  bool _hasDataForCalculation(Faction faction) {
    // Если сертификат не нужен как цель, нет данных
    if (!faction.wantsCertificate) {
      return false;
    }

    // Рассчитываем валюту в день
    int currencyPerDay = 0;

    // Потенциальный доход от заказа
    final template = FactionsList.getTemplateByName(faction.name);
    if (faction.ordersEnabled && template != null && template.orderReward != null) {
      currencyPerDay += OrderReward.averageCurrency(template.orderReward!);
    }

    // Потенциальный доход от работы
    if (faction.workReward != null && faction.workReward!.currency > 0) {
      currencyPerDay += faction.workReward!.currency;
    }

    // Если нет источников дохода, нет данных
    return currencyPerDay > 0;
  }

  void _showNoDataHelpDialog(BuildContext context, Faction faction) {
    final reasons = <String>[];
    
    if (!faction.wantsCertificate) {
      reasons.add('• Включите галочку "Нужен сертификат" в блоке "Цели"');
    }
    
    final template = FactionsList.getTemplateByName(faction.name);
    final hasOrderReward = template != null && template.orderReward != null;
    final hasWorkCurrency = faction.workReward != null && faction.workReward!.currency > 0;
    
    // Показываем про заказы/работу ТОЛЬКО если не настроено ни то, ни другое
    if (!faction.ordersEnabled && !hasWorkCurrency) {
      if (hasOrderReward) {
        reasons.add('• Включите галочку "Заказы" или укажите валюту за работу в блоке "Ежедневные активности"');
      } else {
        reasons.add('• Укажите валюту за работу в блоке "Ежедневные активности"');
      }
    }
    
    final content = reasons.isEmpty
        ? 'Для расчета времени до цели по валюте необходимо:\n\n'
            '• Установить цель (включить галочку "Нужен сертификат" в блоке "Цели")\n'
            '• Настроить источники дохода (включить заказы или указать валюту за работу)'
        : 'Для расчета времени до цели по валюте необходимо:\n\n${reasons.join('\n')}';
    
    HelpDialog.show(
      context,
      'Нет данных для расчета',
      content,
    );
  }

  @override
  Widget build(BuildContext context) {
    final hasData = _hasDataForCalculation(faction);
    final currentCurrency = faction.currency;
    final neededCurrency = _calculateNeededCurrency(faction);
    final totalCurrency = neededCurrency;
    final isGoalCompleted = currentCurrency >= neededCurrency;
    
    // Если нет данных, показываем иконку запрета
    if (!hasData) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(6),
        child: Container(
          height: 30,
          decoration: BoxDecoration(
            color: Colors.grey[800],
            borderRadius: BorderRadius.circular(6),
          ),
          child: Center(
            child: GestureDetector(
              onTap: () => _showNoDataHelpDialog(context, faction),
              child: Icon(
                Icons.block,
                size: 20,
                color: Colors.grey[600],
              ),
            ),
          ),
        ),
      );
    }

    // Если цель достигнута, показываем иконку успеха
    if (isGoalCompleted) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(6),
        child: Container(
          height: 30,
          decoration: BoxDecoration(
            color: Colors.grey[800],
            borderRadius: BorderRadius.circular(6),
          ),
          child: Center(
            child: Icon(
              Icons.check,
              size: 20,
              color: Colors.green[600],
            ),
          ),
        ),
      );
    }

    final progress = totalCurrency > 0
        ? (currentCurrency / totalCurrency).clamp(0.0, 1.0)
        : 1.0;

    return ClipRRect(
      borderRadius: BorderRadius.circular(6),
      child: Stack(
        children: [
          LinearProgressIndicator(
            value: progress,
            minHeight: 30,
            backgroundColor: Colors.grey[800],
            valueColor: const AlwaysStoppedAnimation<Color>(
              Color(0xFFFF6B35), // оранжевый/акцентный
            ),
          ),
          Positioned.fill(
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '$currentCurrency/$totalCurrency',
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                      shadows: [
                        Shadow(
                          offset: Offset(0, 0),
                          blurRadius: 2,
                          color: Colors.black,
                        ),
                      ],
                    ),
                  ),
                  TimeToCurrencyGoalWidget(faction: faction),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

