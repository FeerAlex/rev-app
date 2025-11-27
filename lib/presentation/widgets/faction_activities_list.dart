import 'package:flutter/material.dart';
import '../../../domain/entities/faction.dart';
import 'activity_badge.dart';
import 'board_currency_badge.dart';

class FactionActivitiesList extends StatelessWidget {
  final Faction faction;
  final VoidCallback? onOrderToggle;
  final VoidCallback? onBoardCurrencyTap;

  const FactionActivitiesList({
    super.key,
    required this.faction,
    this.onOrderToggle,
    this.onBoardCurrencyTap,
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
      BoardCurrencyBadge(
        boardCurrency: faction.boardCurrency,
        onTap: onBoardCurrencyTap,
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

