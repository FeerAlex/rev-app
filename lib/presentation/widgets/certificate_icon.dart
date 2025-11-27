import 'package:flutter/material.dart';

class CertificateIcon extends StatelessWidget {
  final bool isPurchased;
  final VoidCallback? onTap;

  const CertificateIcon({
    super.key,
    required this.isPurchased,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    Widget icon = Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: isPurchased ? Colors.purple : Colors.transparent,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
          color: Colors.purple,
          width: 1,
        ),
      ),
      child: Icon(
        Icons.verified,
        size: 14,
        color: isPurchased ? Colors.white : Colors.purple,
      ),
    );

    if (onTap != null) {
      return GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: icon,
      );
    }

    return icon;
  }
}

