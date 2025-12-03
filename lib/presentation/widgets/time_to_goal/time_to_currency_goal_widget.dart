import 'package:flutter/material.dart';
import '../../../domain/entities/faction.dart';
import '../../../domain/usecases/calculate_time_to_currency_goal.dart';
import '../../../core/utils/time_formatter.dart';

class TimeToCurrencyGoalWidget extends StatefulWidget {
  final Faction? faction;

  const TimeToCurrencyGoalWidget({
    super.key,
    this.faction,
  });

  @override
  State<TimeToCurrencyGoalWidget> createState() => _TimeToCurrencyGoalWidgetState();
}

class _TimeToCurrencyGoalWidgetState extends State<TimeToCurrencyGoalWidget> {
  Duration? _timeToGoal;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _calculateTime();
  }

  @override
  void didUpdateWidget(TimeToCurrencyGoalWidget oldWidget) {
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
        oldFaction.ordersEnabled != newFaction.ordersEnabled ||
        oldFaction.certificatePurchased != newFaction.certificatePurchased ||
        oldFaction.hasCertificate != newFaction.hasCertificate ||
        oldFaction.wantsCertificate != newFaction.wantsCertificate ||
        oldFaction.workReward != newFaction.workReward ||
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
      const calculateTimeToGoal = CalculateTimeToCurrencyGoal();
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
              color: isCompleted ? Colors.green : Colors.white,
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

