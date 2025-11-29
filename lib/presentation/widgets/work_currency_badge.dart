import 'package:flutter/material.dart';

class WorkCurrencyBadge extends StatelessWidget {
  final int? workCurrency;
  final VoidCallback? onTap;

  const WorkCurrencyBadge({
    super.key,
    this.workCurrency,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final hasValue = workCurrency != null && workCurrency! > 0;
    final text = hasValue ? workCurrency.toString() : 'Работа';
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

