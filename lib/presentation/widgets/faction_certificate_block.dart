import 'package:flutter/material.dart';

class FactionCertificateBlock extends StatelessWidget {
  final bool hasCertificate;
  final bool showCertificateCheckbox;
  final ValueChanged<bool>? onHasCertificateChanged;

  const FactionCertificateBlock({
    super.key,
    required this.hasCertificate,
    this.showCertificateCheckbox = true,
    this.onHasCertificateChanged,
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
            Icon(Icons.verified, color: Colors.purple[300], size: 20),
            const Text(
              'Сертификат',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        if (showCertificateCheckbox)
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
              value: hasCertificate,
              activeColor: Colors.purple,
              contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
              onChanged: onHasCertificateChanged != null
                  ? (value) {
                      onHasCertificateChanged!(value ?? false);
                    }
                  : null,
            ),
          ),
      ],
    );
  }
}

