import 'package:flutter/material.dart';
import '../../../core/constants/reputation_level.dart';

class FactionGoalsBlock extends StatelessWidget {
  final ReputationLevel? targetReputationLevel;
  final bool wantsCertificate;
  final ValueChanged<ReputationLevel?> onTargetLevelChanged;
  final ValueChanged<bool> onWantsCertificateChanged;

  const FactionGoalsBlock({
    super.key,
    required this.targetReputationLevel,
    required this.wantsCertificate,
    required this.onTargetLevelChanged,
    required this.onWantsCertificateChanged,
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
            Icon(Icons.flag, color: Colors.orange[300], size: 20),
            const Text(
              'Цели',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        Card(
          margin: EdgeInsets.zero,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 12,
              children: [
                // Целевой уровень репутации
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Целевой уровень:',
                      style: TextStyle(fontSize: 14),
                    ),
                    DropdownButton<ReputationLevel?>(
                      value: targetReputationLevel,
                      items: [
                        const DropdownMenuItem<ReputationLevel?>(
                          value: null,
                          child: Text('Не нужна'),
                        ),
                        ...ReputationLevel.values.map((level) {
                          return DropdownMenuItem<ReputationLevel?>(
                            value: level,
                            child: Text(level.displayName),
                          );
                        }),
                      ],
                      onChanged: (value) {
                        onTargetLevelChanged(value);
                      },
                    ),
                  ],
                ),
                // Нужен ли сертификат
                CheckboxListTile(
                  dense: true,
                  title: Row(
                    spacing: 8,
                    children: [
                      Icon(Icons.verified, size: 16, color: Colors.purple[300]),
                      const Text('Нужен сертификат', style: TextStyle(fontSize: 14)),
                    ],
                  ),
                  value: wantsCertificate,
                  activeColor: Colors.purple,
                  contentPadding: EdgeInsets.zero,
                  onChanged: (value) {
                    onWantsCertificateChanged(value ?? false);
                  },
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

