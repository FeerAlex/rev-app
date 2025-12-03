import 'package:flutter/material.dart';
import '../../../domain/entities/reputation_level.dart';
import '../currency/currency_input_dialog.dart';
import '../common/help_dialog.dart';
import '../common/block_header.dart';

class FactionReputationBlock extends StatelessWidget {
  final ReputationLevel currentReputationLevel;
  final int currentLevelExp;
  final ValueChanged<ReputationLevel> onCurrentLevelChanged;
  final ValueChanged<int> onLevelExpChanged;

  const FactionReputationBlock({
    super.key,
    required this.currentReputationLevel,
    required this.currentLevelExp,
    required this.onCurrentLevelChanged,
    required this.onLevelExpChanged,
  });

  void _showHelpDialog(BuildContext context) {
    HelpDialog.show(
      context,
      'О репутации',
      'Блок "Репутация" отображает текущий уровень репутации и опыт на текущем уровне.\n\n'
      '• Текущий уровень - выберите ваш текущий уровень репутации во фракции.\n\n'
      '• Текущий опыт - нажмите на значение, чтобы изменить количество опыта на текущем уровне. Это значение используется при расчете времени до цели по репутации.',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 12,
      children: [
        BlockHeader(
          icon: Icons.star,
          iconColor: Colors.amber[300]!,
          title: 'Репутация',
          onHelpTap: () => _showHelpDialog(context),
        ),
        Column(
          spacing: 8,
          children: [
            // Текущий уровень репутации
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
                        Icon(Icons.star, size: 16, color: Colors.amber[300]),
                        const Text(
                          'Текущий уровень:',
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
                      child: DropdownButton<ReputationLevel>(
                        value: currentReputationLevel,
                        items: ReputationLevel.values
                            .where((level) => level != ReputationLevel.maximum)
                            .map((level) {
                          return DropdownMenuItem(
                            value: level,
                            child: Text(level.displayName),
                          );
                        }).toList(),
                        onChanged: (value) {
                          if (value != null) {
                            onCurrentLevelChanged(value);
                          }
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
            // Опыт на текущем уровне
            Card(
              margin: EdgeInsets.zero,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      spacing: 8,
                      children: [
                        Icon(Icons.trending_up, size: 16, color: Colors.blue[300]),
                        const Text(
                          'Текущий опыт:',
                          style: TextStyle(fontSize: 14),
                        ),
                      ],
                    ),
                    TextButton(
                      onPressed: () async {
                        final result = await showDialog<int>(
                          context: context,
                          builder: (context) => CurrencyInputDialog(
                            initialValue: currentLevelExp,
                            title: 'Текущий опыт',
                            labelText: 'Введите опыт',
                            allowEmpty: false,
                          ),
                        );
                        if (result != null) {
                          onLevelExpChanged(result);
                        }
                      },
                      child: Text(
                        currentLevelExp.toString(),
                        style: const TextStyle(fontSize: 14),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

