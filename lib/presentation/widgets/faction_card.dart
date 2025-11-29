import 'package:flutter/material.dart';
import '../../../domain/entities/faction.dart';
import 'faction_name_display.dart';
import 'faction_currency_display.dart';
import 'faction_activities_list.dart';
import 'time_to_goal_widget.dart';
import 'time_to_reputation_goal_widget.dart';
import 'reputation_progress_bar.dart';

class FactionCard extends StatelessWidget {
  final Faction faction;
  final VoidCallback onTap;
  final VoidCallback? onOrderToggle;
  final VoidCallback? onWorkToggle;
  final VoidCallback? onWorkCurrencyTap;
  final VoidCallback? onCurrencyTap;
  final VoidCallback? onExpTap;

  const FactionCard({
    super.key,
    required this.faction,
    required this.onTap,
    this.onOrderToggle,
    this.onWorkToggle,
    this.onWorkCurrencyTap,
    this.onCurrencyTap,
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 8, left: 10, right: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
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
                    const SizedBox(height: 12),
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
                          onWorkToggle: onWorkToggle != null
                              ? () {
                                  onWorkToggle?.call();
                                }
                              : null,
                          onWorkCurrencyTap: onWorkCurrencyTap,
                        ),
                        TimeToGoalWidget(faction: faction),
                      ],
                    ),
                    const SizedBox(height: 12),
                  ],
                ),
              ),
              Stack(
                children: [
                  GestureDetector(
                    onTap: onExpTap,
                    child: ReputationProgressBar(faction: faction),
                  ),
                  Positioned(
                    right: 10,
                    top: 0,
                    bottom: 0,
                    child: Center(
                      child: TimeToReputationGoalWidget(faction: faction),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

