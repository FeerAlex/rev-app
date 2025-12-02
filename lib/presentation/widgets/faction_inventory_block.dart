import 'package:flutter/material.dart';
import '../../../domain/entities/faction.dart';
import '../../../core/constants/factions_list.dart';
import '../../../core/constants/reputation_level.dart';
import 'currency_input_dialog.dart';
import 'faction_decorations_section.dart';

class FactionInventoryBlock extends StatelessWidget {
  final Faction faction;
  final int currency;
  final ReputationLevel currentReputationLevel;
  final int currentLevelExp;
  final bool certificatePurchased;
  final bool decorationRespectPurchased;
  final bool decorationRespectUpgraded;
  final bool decorationHonorPurchased;
  final bool decorationHonorUpgraded;
  final bool decorationAdorationPurchased;
  final bool decorationAdorationUpgraded;
  final ValueChanged<int> onCurrencyChanged;
  final ValueChanged<ReputationLevel> onCurrentLevelChanged;
  final ValueChanged<int> onLevelExpChanged;
  final ValueChanged<bool> onRespectPurchasedChanged;
  final ValueChanged<bool> onRespectUpgradedChanged;
  final ValueChanged<bool> onHonorPurchasedChanged;
  final ValueChanged<bool> onHonorUpgradedChanged;
  final ValueChanged<bool> onAdorationPurchasedChanged;
  final ValueChanged<bool> onAdorationUpgradedChanged;

  const FactionInventoryBlock({
    super.key,
    required this.faction,
    required this.currency,
    required this.currentReputationLevel,
    required this.currentLevelExp,
    required this.certificatePurchased,
    required this.decorationRespectPurchased,
    required this.decorationRespectUpgraded,
    required this.decorationHonorPurchased,
    required this.decorationHonorUpgraded,
    required this.decorationAdorationPurchased,
    required this.decorationAdorationUpgraded,
    required this.onCurrencyChanged,
    required this.onCurrentLevelChanged,
    required this.onLevelExpChanged,
    required this.onRespectPurchasedChanged,
    required this.onRespectUpgradedChanged,
    required this.onHonorPurchasedChanged,
    required this.onHonorUpgradedChanged,
    required this.onAdorationPurchasedChanged,
    required this.onAdorationUpgradedChanged,
  });

  bool _hasCertificate() {
    final template = FactionsList.getTemplateByName(faction.name);
    return template?.hasCertificate ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final hasCertificate = _hasCertificate();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 12,
      children: [
        Row(
          spacing: 8,
          children: [
            Icon(Icons.inventory_2, color: Colors.blue[300], size: 20),
            const Text(
              'Инвентарь',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        Card(
          margin: EdgeInsets.zero,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 12,
              children: [
                // Валюта
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Валюта:',
                      style: TextStyle(fontSize: 14),
                    ),
                    TextButton(
                      onPressed: () async {
                        final result = await showDialog<int>(
                          context: context,
                          builder: (context) => CurrencyInputDialog(
                            initialValue: currency,
                            title: 'Валюта',
                            labelText: 'Введите количество валюты',
                            allowEmpty: false,
                          ),
                        );
                        if (result != null) {
                          onCurrencyChanged(result);
                        }
                      },
                      child: Text(
                        currency.toString(),
                        style: const TextStyle(fontSize: 14),
                      ),
                    ),
                  ],
                ),
                // Текущий уровень репутации
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Текущий уровень:',
                      style: TextStyle(fontSize: 14),
                    ),
                    DropdownButton<ReputationLevel>(
                      value: currentReputationLevel,
                      items: ReputationLevel.values
                          .where((level) => level != ReputationLevel.maximum)
                          .map((level) {
                        return DropdownMenuItem(
                          value: level,
                          child: Text(level.displayName),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value != null) {
                          onCurrentLevelChanged(value);
                        }
                      },
                    ),
                  ],
                ),
                // Опыт на текущем уровне
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Опыт на уровне:',
                      style: TextStyle(fontSize: 14),
                    ),
                    TextButton(
                      onPressed: () async {
                        final result = await showDialog<int>(
                          context: context,
                          builder: (context) => CurrencyInputDialog(
                            initialValue: currentLevelExp,
                            title: 'Опыт на уровне',
                            labelText: 'Введите опыт',
                            allowEmpty: false,
                          ),
                        );
                        if (result != null) {
                          onLevelExpChanged(result);
                        }
                      },
                      child: Text(
                        currentLevelExp.toString(),
                        style: const TextStyle(fontSize: 14),
                      ),
                    ),
                  ],
                ),
                // Сертификат
                if (hasCertificate)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        spacing: 8,
                        children: [
                          Icon(Icons.verified, size: 16, color: Colors.purple[300]),
                          const Text(
                            'Сертификат:',
                            style: TextStyle(fontSize: 14),
                          ),
                        ],
                      ),
                      Text(
                        certificatePurchased ? 'Куплен' : 'Не куплен',
                        style: TextStyle(
                          fontSize: 14,
                          color: certificatePurchased ? Colors.green : Colors.grey,
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ),
        // Украшения
        FactionDecorationsSection(
          decorationRespectPurchased: decorationRespectPurchased,
          decorationRespectUpgraded: decorationRespectUpgraded,
          decorationHonorPurchased: decorationHonorPurchased,
          decorationHonorUpgraded: decorationHonorUpgraded,
          decorationAdorationPurchased: decorationAdorationPurchased,
          decorationAdorationUpgraded: decorationAdorationUpgraded,
          onRespectPurchasedChanged: onRespectPurchasedChanged,
          onRespectUpgradedChanged: onRespectUpgradedChanged,
          onHonorPurchasedChanged: onHonorPurchasedChanged,
          onHonorUpgradedChanged: onHonorUpgradedChanged,
          onAdorationPurchasedChanged: onAdorationPurchasedChanged,
          onAdorationUpgradedChanged: onAdorationUpgradedChanged,
        ),
      ],
    );
  }
}

