import 'package:flutter/material.dart';
import '../../../domain/entities/faction.dart';
import '../../../domain/entities/reputation_level.dart';
import 'faction_name_display.dart';
import 'faction_currency_display.dart';
import 'faction_activities_list.dart';
import 'time_to_goal_widget.dart';

class FactionCard extends StatelessWidget {
  final Faction faction;
  final VoidCallback onTap;
  final VoidCallback? onOrderToggle;
  final VoidCallback? onWorkCurrencyTap;
  final VoidCallback? onCurrencyTap;

  const FactionCard({
    super.key,
    required this.faction,
    required this.onTap,
    this.onOrderToggle,
    this.onWorkCurrencyTap,
    this.onCurrencyTap,
  });

  @override
  Widget build(BuildContext context) {
    final reputationColor = faction.reputationLevel.color;
    
    return Card(
      margin: EdgeInsets.zero,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          clipBehavior: Clip.hardEdge,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border(
              left: BorderSide(
                color: reputationColor,
                width: 4,
              ),
            ),
          ),
          padding: const EdgeInsets.only(top: 8, left: 10, right: 10, bottom: 14),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      spacing: 8,
                      children: [
                        FactionNameDisplay(name: faction.name),
                        FactionCurrencyDisplay(
                          currency: faction.currency,
                          onTap: onCurrencyTap,
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      spacing: 12,
                      children: [
                        FactionActivitiesList(
                          faction: faction,
                          onOrderToggle: onOrderToggle != null
                              ? () {
                                  onOrderToggle?.call();
                                }
                              : null,
                          onWorkCurrencyTap: onWorkCurrencyTap,
                        ),
                        TimeToGoalWidget(faction: faction),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

