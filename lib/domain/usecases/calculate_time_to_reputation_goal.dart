import 'dart:math';
import '../entities/faction.dart';
import '../repositories/faction_template_repository.dart';
import '../repositories/app_settings_repository.dart';
import '../value_objects/order_reward.dart';
import '../utils/reputation_exp.dart';
import '../utils/reputation_helper.dart';

/// Расчет времени до достижения целевого уровня отношения
class CalculateTimeToReputationGoal {
  final FactionTemplateRepository _templateRepository;
  final AppSettingsRepository _settingsRepository;
  late final ReputationHelper _reputationHelper;

  CalculateTimeToReputationGoal(
    this._templateRepository,
    this._settingsRepository,
  ) {
    final reputationExp = ReputationExp(_settingsRepository, _templateRepository);
    _reputationHelper = ReputationHelper(reputationExp);
  }

  Duration? call(Faction faction) {
    // Если цель не установлена, возвращаем null
    if (faction.targetReputationLevel == null) {
      return null;
    }

    // Вычисляем, сколько опыта нужно для достижения целевого уровня
    final neededExp = _reputationHelper.getNeededExp(
      faction.currentReputationLevel,
      faction.currentLevelExp,
      faction.targetReputationLevel!,
      faction.name,
    );

    // Если цель уже достигнута
    if (neededExp <= 0) {
      return Duration.zero;
    }

    // Рассчитываем опыт в день
    final expPerDay = _calculateExpPerDay(faction);
    if (expPerDay <= 0) {
      return null;
    }

    // Рассчитываем время до цели
    final days = neededExp / expPerDay;
    final totalMinutes = (days * 24 * 60).round();
    return Duration(minutes: max(0, totalMinutes));
  }

  /// Рассчитывает опыт в день из всех доступных источников дохода
  int _calculateExpPerDay(Faction faction) {
    int expPerDay = 0;

    // Потенциальный доход от заказа (только если заказы включены и фракция имеет заказы согласно статическому списку)
    final template = _templateRepository.getTemplateByName(faction.name);
    if (faction.ordersEnabled && template != null && template.orderReward != null) {
      // Вычисляем среднее арифметическое опыта из награды за заказы
      expPerDay += OrderReward.averageExp(template.orderReward!);
    }

    // Потенциальный доход от работы
    if (faction.workReward != null && faction.workReward!.exp > 0) {
      expPerDay += faction.workReward!.exp;
    }

    return expPerDay;
  }
}

