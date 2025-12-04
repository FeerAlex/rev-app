import 'package:flutter/material.dart';
import '../../../domain/entities/faction.dart';
import '../../../domain/usecases/calculate_time_to_currency_goal.dart';
import '../../../domain/usecases/calculate_time_to_reputation_goal.dart';
import '../../../domain/repositories/app_settings_repository.dart';
import '../../../domain/repositories/faction_template_repository.dart';
import '../../../domain/utils/reputation_helper.dart';
import 'faction_name_display.dart';
import 'faction_activities_list.dart';
import '../currency/currency_progress_bar.dart';
import '../reputation/reputation_progress_bar.dart';

class FactionCard extends StatelessWidget {
  final Faction faction;
  final VoidCallback onTap;
  final VoidCallback? onOrderToggle;
  final VoidCallback? onWorkToggle;
  final VoidCallback? onExpTap;
  final ReputationHelper reputationHelper;
  final CalculateTimeToCurrencyGoal calculateTimeToCurrencyGoal;
  final CalculateTimeToReputationGoal calculateTimeToReputationGoal;
  final AppSettingsRepository appSettingsRepository;
  final FactionTemplateRepository factionTemplateRepository;

  const FactionCard({
    super.key,
    required this.faction,
    required this.onTap,
    required this.reputationHelper,
    required this.calculateTimeToCurrencyGoal,
    required this.calculateTimeToReputationGoal,
    required this.appSettingsRepository,
    required this.factionTemplateRepository,
    this.onOrderToggle,
    this.onWorkToggle,
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
              spacing: 12,
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
                      factionTemplateRepository: factionTemplateRepository,
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
                    ),
                  ],
                ),
                // Строка 2: Progress bar валюты и опыта рядом друг с другом
                if (faction.wantsCertificate || faction.targetReputationLevel != null) ...[
                  Row(
                    spacing: 8,
                    children: [
                      if (faction.wantsCertificate)
                        Expanded(
                          child: CurrencyProgressBar(
                            faction: faction,
                            calculateTimeToCurrencyGoal: calculateTimeToCurrencyGoal,
                            appSettingsRepository: appSettingsRepository,
                            factionTemplateRepository: factionTemplateRepository,
                          ),
                        ),
                      if (faction.targetReputationLevel != null)
                        Expanded(
                          child: GestureDetector(
                            onTap: onExpTap,
                            child: ReputationProgressBar(
                              faction: faction,
                              reputationHelper: reputationHelper,
                              calculateTimeToReputationGoal: calculateTimeToReputationGoal,
                              factionTemplateRepository: factionTemplateRepository,
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

