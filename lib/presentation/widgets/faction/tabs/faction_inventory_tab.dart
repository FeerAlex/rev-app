import 'package:flutter/material.dart';
import '../../../../domain/entities/faction.dart';
import '../../../../domain/entities/reputation_level.dart';
import '../../../../domain/repositories/faction_template_repository.dart';
import '../faction_reputation_block.dart';
import '../faction_currency_block.dart';
import '../faction_decorations_section.dart';
import '../faction_certificate_block.dart';

/// Виджет вкладки "Инвентарь" на странице деталей фракции
class FactionInventoryTab extends StatelessWidget {
  final ReputationLevel? targetReputationLevel;
  final bool wantsCertificate;
  final ReputationLevel currentReputationLevel;
  final int currentLevelExp;
  final int currency;
  final bool decorationRespectPurchased;
  final bool decorationRespectUpgraded;
  final bool decorationHonorPurchased;
  final bool decorationHonorUpgraded;
  final bool decorationAdorationPurchased;
  final bool decorationAdorationUpgraded;
  final bool certificatePurchased;
  final Faction faction;
  final FactionTemplateRepository factionTemplateRepository;
  final ValueChanged<ReputationLevel> onCurrentLevelChanged;
  final ValueChanged<int> onLevelExpChanged;
  final ValueChanged<int> onCurrencyChanged;
  final ValueChanged<bool> onRespectPurchasedChanged;
  final ValueChanged<bool> onRespectUpgradedChanged;
  final ValueChanged<bool> onHonorPurchasedChanged;
  final ValueChanged<bool> onHonorUpgradedChanged;
  final ValueChanged<bool> onAdorationPurchasedChanged;
  final ValueChanged<bool> onAdorationUpgradedChanged;
  final ValueChanged<bool> onCertificatePurchasedChanged;
  final bool Function() areAllDecorationsPurchasedAndUpgraded;

  const FactionInventoryTab({
    super.key,
    required this.targetReputationLevel,
    required this.wantsCertificate,
    required this.currentReputationLevel,
    required this.currentLevelExp,
    required this.currency,
    required this.decorationRespectPurchased,
    required this.decorationRespectUpgraded,
    required this.decorationHonorPurchased,
    required this.decorationHonorUpgraded,
    required this.decorationAdorationPurchased,
    required this.decorationAdorationUpgraded,
    required this.certificatePurchased,
    required this.faction,
    required this.factionTemplateRepository,
    required this.onCurrentLevelChanged,
    required this.onLevelExpChanged,
    required this.onCurrencyChanged,
    required this.onRespectPurchasedChanged,
    required this.onRespectUpgradedChanged,
    required this.onHonorPurchasedChanged,
    required this.onHonorUpgradedChanged,
    required this.onAdorationPurchasedChanged,
    required this.onAdorationUpgradedChanged,
    required this.onCertificatePurchasedChanged,
    required this.areAllDecorationsPurchasedAndUpgraded,
  });

  void _handleCertificatePurchasedChanged(BuildContext context, bool value) {
    if (value == true) {
      // Проверяем, что все украшения куплены и улучшены
      if (!areAllDecorationsPurchasedAndUpgraded()) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Невозможно купить сертификат'),
            content: const Text(
              'Для покупки сертификата необходимо купить и улучшить все украшения фракции:\n\n'
              '• Уважение\n'
              '• Почтение\n'
              '• Преклонение',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Понятно'),
              ),
            ],
          ),
        );
        return;
      }
    }
    onCertificatePurchasedChanged(value);
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 24,
        children: [
          if (targetReputationLevel != null)
            FactionReputationBlock(
              currentReputationLevel: currentReputationLevel,
              currentLevelExp: currentLevelExp,
              onCurrentLevelChanged: onCurrentLevelChanged,
              onLevelExpChanged: onLevelExpChanged,
            ),
          if (wantsCertificate) ...[
            FactionCurrencyBlock(
              currency: currency,
              onCurrencyChanged: onCurrencyChanged,
            ),
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
            FactionCertificateBlock(
              faction: faction,
              factionTemplateRepository: factionTemplateRepository,
              certificatePurchased: certificatePurchased,
              onCertificatePurchasedChanged: (value) =>
                  _handleCertificatePurchasedChanged(context, value),
            ),
          ],
        ],
      ),
    );
  }
}

