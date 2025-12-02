import 'package:flutter/material.dart';
import '../../../domain/entities/faction.dart';
import '../../../core/constants/factions_list.dart';
import 'activity_badge.dart';

class FactionActivitiesList extends StatelessWidget {
  final Faction faction;
  final VoidCallback? onOrderToggle;
  final VoidCallback? onWorkToggle;
  final VoidCallback? onWorkCurrencyTap;

  const FactionActivitiesList({
    super.key,
    required this.faction,
    this.onOrderToggle,
    this.onWorkToggle,
    this.onWorkCurrencyTap,
  });

  @override
  Widget build(BuildContext context) {
    final List<Widget> badges = [];
    final template = FactionsList.getTemplateByName(faction.name);

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
      final hasCurrency = reward.currency != null && reward.currency! > 0;
      final hasExp = reward.exp != null && reward.exp! > 0;
      
      String text;
      if (hasCurrency && hasExp) {
        text = '${reward.currency}/${reward.exp}';
      } else if (hasCurrency) {
        text = reward.currency.toString();
      } else if (hasExp) {
        text = reward.exp.toString();
      } else {
        text = 'Работа';
      }
      
      badges.add(
        Padding(
          padding: const EdgeInsets.only(right: 8),
          child: ActivityBadge(
            text: text,
            color: Colors.amber,
            isCompleted: faction.workCompleted,
            onTap: onWorkToggle,
          ),
        ),
      );
    }

    if (badges.isEmpty) {
      return const SizedBox.shrink();
    }

    return Row(
      children: badges,
    );
  }
}

