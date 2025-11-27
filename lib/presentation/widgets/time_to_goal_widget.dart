import 'package:flutter/material.dart';
import '../../../domain/entities/faction.dart';
import '../../../domain/usecases/calculate_time_to_goal.dart';
import '../../../core/di/service_locator.dart';
import '../../../core/utils/time_formatter.dart';

class TimeToGoalWidget extends StatefulWidget {
  final Faction? faction;

  const TimeToGoalWidget({
    super.key,
    this.faction,
  });

  @override
  State<TimeToGoalWidget> createState() => _TimeToGoalWidgetState();
}

class _TimeToGoalWidgetState extends State<TimeToGoalWidget> {
  Duration? _timeToGoal;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _calculateTime();
  }

  @override
  void didUpdateWidget(TimeToGoalWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Пересчитываем только если изменилась фракция (id или важные поля)
    if (oldWidget.faction?.id != widget.faction?.id ||
        oldWidget.faction?.currency != widget.faction?.currency ||
        oldWidget.faction?.orderCompleted != widget.faction?.orderCompleted ||
        oldWidget.faction?.certificatePurchased != widget.faction?.certificatePurchased) {
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
      final serviceLocator = ServiceLocator();
      final calculateTimeToGoal = CalculateTimeToGoal(
        serviceLocator.factionRepository,
        serviceLocator.settingsRepository,
      );
      final duration = await calculateTimeToGoal(widget.faction!);
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
      return Row(
        children: [
          Icon(Icons.access_time, size: 14, color: Colors.grey[400]),
          const SizedBox(width: 4),
          Text(
            'Нет данных',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[400],
            ),
          ),
        ],
      );
    }

    final isCompleted = _timeToGoal == Duration.zero;

    return FittedBox(
      fit: BoxFit.scaleDown,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isCompleted ? Icons.check_circle : Icons.access_time,
            size: 14,
            color: isCompleted ? Colors.green : const Color(0xFFFF6B35),
          ),
          const SizedBox(width: 4),
          Text(
            isCompleted
                ? 'Цель достигнута'
                : TimeFormatter.formatDuration(_timeToGoal!),
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: isCompleted ? Colors.green : Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
