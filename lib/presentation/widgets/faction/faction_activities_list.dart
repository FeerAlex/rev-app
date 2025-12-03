import 'package:flutter/material.dart';
import '../../../domain/entities/faction.dart';
import '../../../domain/repositories/faction_template_repository.dart';
import '../activity/activity_badge.dart';

class FactionActivitiesList extends StatelessWidget {
  final Faction faction;
  final FactionTemplateRepository factionTemplateRepository;
  final VoidCallback? onOrderToggle;
  final VoidCallback? onWorkToggle;
  final VoidCallback? onWorkCurrencyTap;

  const FactionActivitiesList({
    super.key,
    required this.faction,
    required this.factionTemplateRepository,
    this.onOrderToggle,
    this.onWorkToggle,
    this.onWorkCurrencyTap,
  });

  @override
  Widget build(BuildContext context) {
    final List<Widget> badges = [];
    final template = factionTemplateRepository.getTemplateByName(faction.name);

    if (faction.ordersEnabled && template?.orderReward != null) {
      badges.add(
        Padding(
          padding: const EdgeInsets.only(right: 8),
          child: ActivityBadge(
            text: 'Заказ',
            color: Colors.green,
            isCompleted: faction.orderCompleted,
            onTap: onOrderToggle,
          ),
        ),
      );
    }

    if (faction.workReward != null) {
      final reward = faction.workReward!;
      final hasCurrency = reward.currency > 0;
      final hasExp = reward.exp > 0;
      
      // Показываем чипс только если хотя бы одно поле > 0
      if (hasCurrency || hasExp) {
        badges.add(
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ActivityBadge(
              text: 'Работа',
              color: Colors.amber,
              isCompleted: faction.workCompleted,
              onTap: onWorkToggle,
            ),
          ),
        );
      }
    }

    if (badges.isEmpty) {
      return const SizedBox.shrink();
    }

    return Row(
      children: badges,
    );
  }
}

