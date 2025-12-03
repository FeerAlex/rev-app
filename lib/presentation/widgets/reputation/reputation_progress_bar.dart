import 'package:flutter/material.dart';
import '../../../domain/entities/faction.dart';
import '../../../core/utils/reputation_helper.dart';
import '../../../core/constants/reputation_level.dart';
import '../time_to_goal/time_to_reputation_goal_widget.dart';

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
          borderRadius: BorderRadius.circular(6),
          child: Stack(
            children: [
              LinearProgressIndicator(
                value: progress,
                minHeight: 30,
                backgroundColor: Colors.grey[800],
                valueColor: AlwaysStoppedAnimation<Color>(
                  _getColorForLevel(currentLevel),
                ),
              ),
              Positioned.fill(
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
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
                      TimeToReputationGoalWidget(faction: faction),
                    ],
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
        return const Color(0xFF8B6F47); // средний коричневый
      case ReputationLevel.friendliness:
        return const Color(0xFF4A5D23); // темно-зеленый/коричневато-зеленый
      case ReputationLevel.respect:
        return const Color(0xFF4CAF50); // яркий зеленый
      case ReputationLevel.honor:
        return const Color(0xFF00BCD4); // бирюзовый/циан
      case ReputationLevel.adoration:
        return const Color(0xFF2196F3); // средний синий
      case ReputationLevel.deification:
        return const Color(0xFF5E35B1); // темно-фиолетовый/индиго
      case ReputationLevel.maximum:
        return const Color(0xFF7B1FA2); // темно-фиолетовый для максимального
    }
  }
}

