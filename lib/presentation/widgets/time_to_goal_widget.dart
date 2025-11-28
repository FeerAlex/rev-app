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
    // Пересчитываем только если изменилась фракция (id или важные поля, влияющие на расчет)
    final oldFaction = oldWidget.faction;
    final newFaction = widget.faction;
    
    if (oldFaction == null || newFaction == null) {
      if (oldFaction != newFaction) {
        _calculateTime();
      }
      return;
    }
    
    // Проверяем все поля, влияющие на расчет времени до цели
    if (oldFaction.id != newFaction.id ||
        oldFaction.currency != newFaction.currency ||
        oldFaction.orderCompleted != newFaction.orderCompleted ||
        oldFaction.certificatePurchased != newFaction.certificatePurchased ||
        oldFaction.hasOrder != newFaction.hasOrder ||
        oldFaction.hasCertificate != newFaction.hasCertificate ||
        oldFaction.boardCurrency != newFaction.boardCurrency ||
        oldFaction.decorationRespectPurchased != newFaction.decorationRespectPurchased ||
        oldFaction.decorationRespectUpgraded != newFaction.decorationRespectUpgraded ||
        oldFaction.decorationHonorPurchased != newFaction.decorationHonorPurchased ||
        oldFaction.decorationHonorUpgraded != newFaction.decorationHonorUpgraded ||
        oldFaction.decorationAdorationPurchased != newFaction.decorationAdorationPurchased ||
        oldFaction.decorationAdorationUpgraded != newFaction.decorationAdorationUpgraded) {
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
