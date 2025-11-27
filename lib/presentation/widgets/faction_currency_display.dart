import 'package:flutter/material.dart';

class FactionCurrencyDisplay extends StatelessWidget {
  final int currency;
  final VoidCallback? onTap;

  const FactionCurrencyDisplay({
    super.key,
    required this.currency,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    Widget content = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.monetization_on,
          size: 16,
          color: Colors.amber[300],
        ),
        const SizedBox(width: 4),
        Text(
          currency.toString(),
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
          ),
        ),
      ],
    );

    if (onTap != null) {
      return GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: content,
      );
    }

    return content;
  }
}

