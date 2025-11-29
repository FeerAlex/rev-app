import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/entities/faction.dart';
import '../../core/constants/app_settings.dart';
import 'currency_input_dialog.dart';
import '../bloc/faction/faction_bloc.dart';
import '../bloc/faction/faction_event.dart';

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

  @override
  Widget build(BuildContext context) {
    final currentCurrency = faction.currency;
    final neededCurrency = _calculateNeededCurrency(faction);
    final totalCurrency = neededCurrency;

    final progress = totalCurrency > 0
        ? (currentCurrency / totalCurrency).clamp(0.0, 1.0)
        : 1.0;

    return GestureDetector(
      onTap: () async {
        final bloc = context.read<FactionBloc>();
        final initialValue = faction.currency;
        final result = await showDialog<int>(
          context: context,
          builder: (context) => CurrencyInputDialog(
            initialValue: initialValue,
            title: 'Валюта фракции',
            labelText: 'Введите валюту',
            allowEmpty: false,
          ),
        );
        if (result != null && result != initialValue) {
          final updatedFaction = faction.copyWith(currency: result);
          bloc.add(UpdateFactionEvent(updatedFaction));
        }
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(6),
        child: Stack(
          children: [
            LinearProgressIndicator(
              value: progress,
              minHeight: 14,
              backgroundColor: Colors.grey[800],
              valueColor: const AlwaysStoppedAnimation<Color>(
                Color(0xFFFF6B35), // оранжевый/акцентный
              ),
            ),
            Positioned.fill(
              child: Center(
                child: Text(
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
              ),
            ),
          ],
        ),
      ),
    );
  }
}

