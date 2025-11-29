import 'package:flutter/material.dart';
import '../../../domain/entities/faction.dart';
import 'activity_badge.dart';
import 'work_currency_badge.dart';

class FactionActivitiesList extends StatelessWidget {
  final Faction faction;
  final VoidCallback? onOrderToggle;
  final VoidCallback? onWorkCurrencyTap;

  const FactionActivitiesList({
    super.key,
    required this.faction,
    this.onOrderToggle,
    this.onWorkCurrencyTap,
  });

  @override
  Widget build(BuildContext context) {
    final List<Widget> badges = [];

    if (faction.hasOrder) {
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

    badges.add(
      WorkCurrencyBadge(
        workCurrency: faction.workCurrency,
        onTap: onWorkCurrencyTap,
      ),
    );

    if (badges.isEmpty) {
      return const SizedBox.shrink();
    }

    return Row(
      children: badges,
    );
  }
}

