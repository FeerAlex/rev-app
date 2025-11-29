import 'package:flutter/material.dart';
import '../../../domain/entities/faction.dart';
import '../../core/utils/reputation_helper.dart';
import '../../core/constants/reputation_level.dart';

/// Виджет для отображения прогресса уровня отношения с progress bar
class ReputationProgressBar extends StatelessWidget {
  final Faction faction;

  const ReputationProgressBar({
    super.key,
    required this.faction,
  });

  @override
  Widget build(BuildContext context) {
    final currentLevel = faction.currentReputationLevel;
    final expInCurrentLevel = faction.currentLevelExp;
    final requiredExpForCurrentLevel = ReputationHelper.getRequiredExpForCurrentLevel(
      currentLevel,
      faction.name,
    );

    final progress = requiredExpForCurrentLevel > 0
        ? (expInCurrentLevel / requiredExpForCurrentLevel).clamp(0.0, 1.0)
        : 1.0;

    return ClipRRect(
          borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(12),
            bottomRight: Radius.circular(12),
          ),
          child: Stack(
            children: [
              LinearProgressIndicator(
                value: progress,
                minHeight: 14,
                backgroundColor: Colors.grey[800],
                valueColor: AlwaysStoppedAnimation<Color>(
                  _getColorForLevel(currentLevel),
                ),
              ),
              Positioned.fill(
                child: Center(
                  child: Text(
                    '$expInCurrentLevel/$requiredExpForCurrentLevel',
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                      shadows: [
                        Shadow(
                          offset: Offset(0, 0),
                          blurRadius: 2,
                          color: Colors.black,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
  }

  Color _getColorForLevel(ReputationLevel level) {
    switch (level) {
      case ReputationLevel.indifference:
        return Colors.grey;
      case ReputationLevel.friendliness:
        return Colors.green;
      case ReputationLevel.respect:
        return Colors.blue;
      case ReputationLevel.honor:
        return Colors.cyan;
      case ReputationLevel.adoration:
        return Colors.purple;
      case ReputationLevel.deification:
        return Colors.orange;
      case ReputationLevel.maximum:
        return Colors.amber;
    }
  }
}

