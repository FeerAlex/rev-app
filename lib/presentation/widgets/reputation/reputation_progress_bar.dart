import 'package:flutter/material.dart';
import '../../../domain/entities/faction.dart';
import '../../../domain/entities/reputation_level.dart';
import '../../../domain/usecases/calculate_time_to_reputation_goal.dart';
import '../../../domain/repositories/faction_template_repository.dart';
import '../../../domain/value_objects/order_reward.dart';
import '../../../domain/utils/reputation_helper.dart';
import '../time_to_goal/time_to_reputation_goal_widget.dart';
import '../common/help_dialog.dart';

/// Виджет для отображения прогресса уровня отношения с progress bar
class ReputationProgressBar extends StatelessWidget {
  final Faction faction;
  final ReputationHelper reputationHelper;
  final CalculateTimeToReputationGoal calculateTimeToReputationGoal;
  final FactionTemplateRepository factionTemplateRepository;

  const ReputationProgressBar({
    super.key,
    required this.faction,
    required this.reputationHelper,
    required this.calculateTimeToReputationGoal,
    required this.factionTemplateRepository,
  });

  /// Проверяет, есть ли данные для расчета времени до цели
  bool _hasDataForCalculation(Faction faction) {
    // Если цель не установлена, нет данных
    if (faction.targetReputationLevel == null) {
      return false;
    }

    // Рассчитываем опыт в день
    int expPerDay = 0;

    // Потенциальный доход от заказа
    final template = factionTemplateRepository.getTemplateByName(faction.name);
    if (faction.ordersEnabled && template != null && template.orderReward != null) {
      expPerDay += OrderReward.averageExp(template.orderReward!);
    }

    // Потенциальный доход от работы
    if (faction.workReward != null && faction.workReward!.exp > 0) {
      expPerDay += faction.workReward!.exp;
    }

    // Если нет источников дохода, нет данных
    return expPerDay > 0;
  }

  void _showNoDataHelpDialog(BuildContext context, Faction faction) {
    final reasons = <String>[];
    
    if (faction.targetReputationLevel == null) {
      reasons.add('• Установите целевой уровень репутации в блоке "Цели"');
    }
    
    final template = factionTemplateRepository.getTemplateByName(faction.name);
    final hasOrderReward = template != null && template.orderReward != null;
    final hasWorkExp = faction.workReward != null && faction.workReward!.exp > 0;
    
    // Показываем про заказы/работу ТОЛЬКО если не настроено ни то, ни другое
    if (!faction.ordersEnabled && !hasWorkExp) {
      if (hasOrderReward) {
        reasons.add('• Включите галочку "Заказы" или укажите опыт за работу в блоке "Ежедневные активности"');
      } else {
        reasons.add('• Укажите опыт за работу в блоке "Ежедневные активности"');
      }
    }
    
    final content = reasons.isEmpty
        ? 'Для расчета времени до цели по репутации необходимо:\n\n'
            '• Установить целевой уровень репутации в блоке "Цели"\n'
            '• Настроить источники опыта (включить заказы или указать опыт за работу)'
        : 'Для расчета времени до цели по репутации необходимо:\n\n${reasons.join('\n')}';
    
    HelpDialog.show(
      context,
      'Нет данных для расчета',
      content,
    );
  }

  /// Проверяет, достигнута ли цель
  bool _isGoalCompleted(Faction faction) {
    if (faction.targetReputationLevel == null) {
      return false;
    }

    final neededExp = reputationHelper.getNeededExp(
      faction.currentReputationLevel,
      faction.currentLevelExp,
      faction.targetReputationLevel!,
      faction.name,
    );

    return neededExp <= 0;
  }

  @override
  Widget build(BuildContext context) {
    final hasData = _hasDataForCalculation(faction);
    final isGoalCompleted = _isGoalCompleted(faction);

    // Если нет данных, показываем иконку запрета
    if (!hasData) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(6),
        child: Container(
          height: 30,
          decoration: BoxDecoration(
            color: Colors.grey[800],
            borderRadius: BorderRadius.circular(6),
          ),
          child: Center(
            child: GestureDetector(
              onTap: () => _showNoDataHelpDialog(context, faction),
              child: Icon(
                Icons.block,
                size: 20,
                color: Colors.grey[600],
              ),
            ),
          ),
        ),
      );
    }

    // Если цель достигнута, показываем иконку успеха
    if (isGoalCompleted) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(6),
        child: Container(
          height: 30,
          decoration: BoxDecoration(
            color: Colors.grey[800],
            borderRadius: BorderRadius.circular(6),
          ),
          child: Center(
            child: Icon(
              Icons.check,
              size: 20,
              color: Colors.green[600],
            ),
          ),
        ),
      );
    }

    final currentLevel = faction.currentReputationLevel;
    final expInCurrentLevel = faction.currentLevelExp;
    final requiredExpForCurrentLevel = reputationHelper.getRequiredExpForCurrentLevel(
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
                      TimeToReputationGoalWidget(
                        faction: faction,
                        calculateTimeToReputationGoal: calculateTimeToReputationGoal,
                      ),
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

