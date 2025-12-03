import 'package:flutter/material.dart';
import '../../../domain/entities/faction.dart';
import '../../../core/constants/factions_list.dart';

class FactionCertificateBlock extends StatelessWidget {
  final Faction faction;
  final bool certificatePurchased;
  final ValueChanged<bool> onCertificatePurchasedChanged;

  const FactionCertificateBlock({
    super.key,
    required this.faction,
    required this.certificatePurchased,
    required this.onCertificatePurchasedChanged,
  });

  bool _hasCertificate() {
    final template = FactionsList.getTemplateByName(faction.name);
    return template?.hasCertificate ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final hasCertificate = _hasCertificate();

    if (!hasCertificate) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 12,
      children: [
        Row(
          spacing: 8,
          children: [
            Icon(Icons.verified, color: Colors.purple[300], size: 20),
            const Text(
              'Сертификат',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        Card(
          margin: EdgeInsets.zero,
          child: CheckboxListTile(
            dense: true,
            title: Row(
              spacing: 8,
              children: [
                Icon(Icons.verified, size: 16, color: Colors.purple[300]),
                const Text('Сертификат', style: TextStyle(fontSize: 14)),
              ],
            ),
            value: certificatePurchased,
            activeColor: Colors.purple,
            contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
            onChanged: (value) {
              onCertificatePurchasedChanged(value ?? false);
            },
          ),
        ),
      ],
    );
  }
}
