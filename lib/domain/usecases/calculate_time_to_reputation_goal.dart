import 'dart:math';
import '../entities/faction.dart';
import '../../core/constants/factions_list.dart';
import '../../core/constants/order_reward.dart';
import '../../core/utils/reputation_helper.dart';

/// Расчет времени до достижения целевого уровня отношения
class CalculateTimeToReputationGoal {
  const CalculateTimeToReputationGoal();

  Duration? call(Faction faction) {
    // Вычисляем, сколько опыта нужно для достижения целевого уровня
    final neededExp = ReputationHelper.getNeededExp(
      faction.currentReputationLevel,
      faction.currentLevelExp,
      faction.targetReputationLevel,
      faction.name,
    );

    // Если цель уже достигнута
    if (neededExp <= 0) {
      return Duration.zero;
    }

    // Рассчитываем опыт в день
    int expPerDay = 0;

    // Потенциальный доход от заказа (только если фракция имеет заказы)
    final template = FactionsList.getTemplateByName(faction.name);
    if (template != null && template.orderReward != null) {
      // Вычисляем среднее арифметическое опыта из награды за заказы
      expPerDay += OrderReward.averageExp(template.orderReward!);
    }

    // Если нет дохода опыта в день, вернуть null
    if (expPerDay <= 0) {
      return null;
    }

    // Рассчитываем дни
    final days = neededExp / expPerDay;
    final totalMinutes = (days * 24 * 60).round();
    return Duration(minutes: max(0, totalMinutes));
  }
}

