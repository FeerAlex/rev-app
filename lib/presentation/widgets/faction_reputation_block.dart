import 'package:flutter/material.dart';
import '../../../core/constants/reputation_level.dart';
import '../widgets/currency_input_dialog.dart';
import '../../../domain/entities/faction.dart';

class FactionReputationBlock extends StatelessWidget {
  final Faction faction;
  final ReputationLevel currentReputationLevel;
  final int currentLevelExp;
  final ReputationLevel targetReputationLevel;
  final ValueChanged<ReputationLevel> onCurrentLevelChanged;
  final ValueChanged<int> onLevelExpChanged;
  final ValueChanged<ReputationLevel> onTargetLevelChanged;

  const FactionReputationBlock({
    super.key,
    required this.faction,
    required this.currentReputationLevel,
    required this.currentLevelExp,
    required this.targetReputationLevel,
    required this.onCurrentLevelChanged,
    required this.onLevelExpChanged,
    required this.onTargetLevelChanged,
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
            Icon(Icons.star, color: Colors.amber[300], size: 20),
            const Text(
              'Репутация',
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Текущий уровень:',
                      style: TextStyle(fontSize: 14),
                    ),
                    DropdownButton<ReputationLevel>(
                      value: currentReputationLevel,
                      items: ReputationLevel.values.map((level) {
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
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Опыт на уровне:',
                      style: TextStyle(fontSize: 14),
                    ),
                    TextButton(
                      onPressed: () async {
                        final result = await showDialog<int>(
                          context: context,
                          builder: (context) => CurrencyInputDialog(
                            initialValue: currentLevelExp,
                            title: 'Опыт на уровне',
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Целевой уровень:',
                      style: TextStyle(fontSize: 14),
                    ),
                    DropdownButton<ReputationLevel>(
                      value: targetReputationLevel,
                      items: ReputationLevel.values.map((level) {
                        return DropdownMenuItem(
                          value: level,
                          child: Text(level.displayName),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value != null) {
                          onTargetLevelChanged(value);
                        }
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

