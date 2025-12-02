import 'package:flutter/material.dart';
import '../../../core/constants/work_reward.dart';

class WorkRewardBadge extends StatelessWidget {
  final WorkReward? workReward;
  final VoidCallback? onTap;

  const WorkRewardBadge({
    super.key,
    this.workReward,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final hasValue = workReward != null;
    final text = hasValue 
        ? '${workReward!.currency}/${workReward!.exp}'
        : 'Работа';
    final color = Colors.amber;

    Widget badge = Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
          color: color,
          width: 1,
        ),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w500,
        ),
      ),
    );

    if (onTap != null) {
      return GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: badge,
      );
    }

    return badge;
  }
}

