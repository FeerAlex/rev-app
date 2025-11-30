import 'package:flutter/material.dart';
import '../../../domain/entities/faction.dart';
import 'faction_name_display.dart';
import 'faction_activities_list.dart';
import 'currency_progress_bar.dart';
import 'reputation_progress_bar.dart';

class FactionCard extends StatelessWidget {
  final Faction faction;
  final VoidCallback onTap;
  final VoidCallback? onOrderToggle;
  final VoidCallback? onWorkToggle;
  final VoidCallback? onWorkCurrencyTap;
  final VoidCallback? onExpTap;

  const FactionCard({
    super.key,
    required this.faction,
    required this.onTap,
    this.onOrderToggle,
    this.onWorkToggle,
    this.onWorkCurrencyTap,
    this.onExpTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          clipBehavior: Clip.hardEdge,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Строка 1: Название + Активности
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  spacing: 12,
                  children: [
                    Expanded(
                      child: FactionNameDisplay(name: faction.name),
                    ),
                    FactionActivitiesList(
                      faction: faction,
                      onOrderToggle: onOrderToggle != null
                          ? () {
                              onOrderToggle?.call();
                            }
                          : null,
                      onWorkToggle: onWorkToggle != null
                          ? () {
                              onWorkToggle?.call();
                            }
                          : null,
                      onWorkCurrencyTap: onWorkCurrencyTap,
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // Строка 2: Progress bar валюты и опыта рядом друг с другом
                Row(
                  children: [
                    Expanded(
                      child: CurrencyProgressBar(faction: faction),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: GestureDetector(
                        onTap: onExpTap,
                        child: ReputationProgressBar(faction: faction),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

