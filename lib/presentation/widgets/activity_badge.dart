import 'package:flutter/material.dart';

class ActivityBadge extends StatelessWidget {
  final String text;
  final Color color;
  final bool isCompleted;
  final VoidCallback? onTap;

  const ActivityBadge({
    super.key,
    required this.text,
    required this.color,
    this.isCompleted = true,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    Widget badge = Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: isCompleted ? color : Colors.transparent,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
          color: color,
          width: 1,
        ),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: isCompleted ? Colors.white : color,
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

