import 'package:flutter/material.dart';
import '../../../domain/entities/faction.dart';
import '../../../domain/usecases/calculate_time_to_reputation_goal.dart';
import '../../../core/utils/time_formatter.dart';

class TimeToReputationGoalWidget extends StatefulWidget {
  final Faction? faction;

  const TimeToReputationGoalWidget({
    super.key,
    this.faction,
  });

  @override
  State<TimeToReputationGoalWidget> createState() => _TimeToReputationGoalWidgetState();
}

class _TimeToReputationGoalWidgetState extends State<TimeToReputationGoalWidget> {
  Duration? _timeToGoal;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _calculateTime();
  }

  @override
  void didUpdateWidget(TimeToReputationGoalWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Пересчитываем только если изменилась фракция (id или важные поля, влияющие на расчет)
    final oldFaction = oldWidget.faction;
    final newFaction = widget.faction;
    
    if (oldFaction == null || newFaction == null) {
      if (oldFaction != newFaction) {
        _calculateTime();
      }
      return;
    }
    
    // Проверяем все поля, влияющие на расчет времени до цели по репутации
    if (oldFaction.id != newFaction.id ||
        oldFaction.currentReputationLevel != newFaction.currentReputationLevel ||
        oldFaction.currentLevelExp != newFaction.currentLevelExp ||
        oldFaction.targetReputationLevel != newFaction.targetReputationLevel ||
        oldFaction.ordersEnabled != newFaction.ordersEnabled ||
        oldFaction.workReward != newFaction.workReward) {
      _calculateTime();
    }
  }

  Future<void> _calculateTime() async {
    if (widget.faction == null) return;

    // Не показываем индикатор, если уже есть вычисленное значение (оптимистичное обновление)
    final hadPreviousValue = _timeToGoal != null;
    
    if (!hadPreviousValue) {
      setState(() {
        _isLoading = true;
      });
    }

    try {
      const calculateTimeToGoal = CalculateTimeToReputationGoal();
      final duration = calculateTimeToGoal(widget.faction!);
      setState(() {
        _timeToGoal = duration;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        // Не сбрасываем значение при ошибке, если оно уже было
        if (!hadPreviousValue) {
          _timeToGoal = null;
        }
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Показываем индикатор только при первой загрузке, не при обновлениях
    if (_isLoading && _timeToGoal == null) {
      return SizedBox(
        width: 12,
        height: 12,
        child: CircularProgressIndicator(strokeWidth: 2),
      );
    }

    if (_timeToGoal == null) {
      return Text(
        'Нет данных',
        style: TextStyle(
          fontSize: 10,
          color: Colors.grey[400],
        ),
      );
    }

    final isCompleted = _timeToGoal == Duration.zero;

    return FittedBox(
      fit: BoxFit.scaleDown,
      child: Text(
        isCompleted
            ? 'Цель достигнута'
            : TimeFormatter.formatDuration(_timeToGoal!),
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w500,
          color: isCompleted ? Colors.amber : Colors.white,
          shadows: const [
            Shadow(
              offset: Offset(0, 0),
              blurRadius: 2,
              color: Colors.black,
            ),
          ],
        ),
      ),
    );
  }
}

