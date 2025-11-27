import 'package:flutter/material.dart';

class FactionActivitiesSection extends StatelessWidget {
  final bool hasOrder;
  final bool hasCertificate;
  final ValueChanged<bool> onHasOrderChanged;
  final ValueChanged<bool> onHasCertificateChanged;

  const FactionActivitiesSection({
    super.key,
    required this.hasOrder,
    required this.hasCertificate,
    required this.onHasOrderChanged,
    required this.onHasCertificateChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 12,
      children: [
        Row(
          spacing: 8,
          children: [
            Icon(Icons.info_outline, color: Colors.blue[300], size: 20),
            const Text(
              'Активности и сертификат',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        Row(
          spacing: 8,
          children: [
            Expanded(
              child: Card(
                margin: EdgeInsets.zero,
                child: CheckboxListTile(
                  title: Row(
                    spacing: 8,
                    children: [
                      Icon(Icons.shopping_cart, size: 18, color: Colors.green[300]),
                      const Text('Заказы'),
                    ],
                  ),
                  value: hasOrder,
                  activeColor: Colors.green,
                  contentPadding: const EdgeInsets.only(left: 8),
                  onChanged: (value) {
                    onHasOrderChanged(value ?? false);
                  },
                ),
              ),
            ),
            Expanded(
              child: Card(
                margin: EdgeInsets.zero,
                child: CheckboxListTile(
                  title: Row(
                    spacing: 8,
                    children: [
                      Icon(Icons.verified, size: 18, color: Colors.purple[300]),
                      const Flexible(
                        child: Text(
                          'Сертификат',
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(fontSize: 14),
                        ),
                      ),
                    ],
                  ),
                  value: hasCertificate,
                  activeColor: Colors.purple,
                  contentPadding: const EdgeInsets.only(left: 8),
                  onChanged: (value) {
                    onHasCertificateChanged(value ?? false);
                  },
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

