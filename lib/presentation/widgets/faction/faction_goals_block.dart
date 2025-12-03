import 'package:flutter/material.dart';
import '../../../domain/entities/reputation_level.dart';
import '../common/help_dialog.dart';
import '../common/block_header.dart';

class FactionGoalsBlock extends StatelessWidget {
  final ReputationLevel currentReputationLevel;
  final ReputationLevel? targetReputationLevel;
  final bool wantsCertificate;
  final ValueChanged<ReputationLevel?> onTargetLevelChanged;
  final ValueChanged<bool> onWantsCertificateChanged;

  const FactionGoalsBlock({
    super.key,
    required this.currentReputationLevel,
    required this.targetReputationLevel,
    required this.wantsCertificate,
    required this.onTargetLevelChanged,
    required this.onWantsCertificateChanged,
  });

  void _showHelpDialog(BuildContext context) {
    HelpDialog.show(
      context,
      'О целях',
          'Блок "Цели" позволяет указать, к чему вы стремитесь во фракции.\n\n'
          '• Целевой уровень репутации - выберите уровень отношения, которого хотите достичь, или "Не нужна", если не ставите цель по репутации. В списке отображаются только уровни выше текущего.\n\n'
          '• Нужен сертификат - включите галочку, если хотите купить сертификат. Это учитывается при расчете времени до цели по валюте.\n\n'
          'Если целевой уровень не установлен и сертификат не нужен, расчет времени до цели по репутации и валюте не выполняется.',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 12,
      children: [
        BlockHeader(
          icon: Icons.flag,
          iconColor: Colors.orange[300]!,
          title: 'Цели',
          onHelpTap: () => _showHelpDialog(context),
        ),
        Column(
          spacing: 8,
          children: [
            // Целевой уровень репутации
            Card(
              margin: EdgeInsets.zero,
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      spacing: 8,
                      children: [
                        Icon(Icons.star, size: 16, color: Colors.orange[300]),
                        const Text(
                          'Уровень репутации:',
                          style: TextStyle(fontSize: 14),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: Colors.grey[600]!,
                          width: 1,
                        ),
                        color: Colors.grey[850],
                      ),
                      child: DropdownButton<ReputationLevel?>(
                        value: targetReputationLevel,
                        items: [
                          const DropdownMenuItem<ReputationLevel?>(
                            value: null,
                            child: Text('Не нужна'),
                          ),
                          ...ReputationLevel.values
                              .where((level) => level.value > currentReputationLevel.value)
                              .map((level) {
                            return DropdownMenuItem<ReputationLevel?>(
                              value: level,
                              child: Text(level.displayName),
                            );
                          }),
                        ],
                        onChanged: (value) {
                          onTargetLevelChanged(value);
                        },
                        isDense: true,
                        isExpanded: false,
                        underline: const SizedBox.shrink(),
                        icon: Icon(
                          Icons.arrow_drop_down,
                          color: Colors.grey[400],
                          size: 24,
                        ),
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.white,
                        ),
                        dropdownColor: Colors.grey[900],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Нужен ли сертификат
            Card(
              margin: EdgeInsets.zero,
              child: CheckboxListTile(
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
                contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
                onChanged: (value) {
                  onWantsCertificateChanged(value ?? false);
                },
              ),
            ),
          ],
        ),
      ],
    );
  }
}

