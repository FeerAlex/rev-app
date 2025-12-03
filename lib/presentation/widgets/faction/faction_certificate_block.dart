import 'package:flutter/material.dart';
import '../../../domain/entities/faction.dart';
import '../../../core/constants/factions_list.dart';
import '../common/help_dialog.dart';
import '../common/block_header.dart';

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

  void _showHelpDialog(BuildContext context) {
    HelpDialog.show(
      context,
      'О сертификате',
      'Блок "Сертификат" позволяет отметить, куплен ли сертификат фракции.\n\n'
      'Сертификат необходим для некоторых достижений и учитывается при расчете времени до цели по валюте.',
    );
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
        BlockHeader(
          icon: Icons.verified,
          iconColor: Colors.purple[300]!,
          title: 'Сертификат',
          onHelpTap: () => _showHelpDialog(context),
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
