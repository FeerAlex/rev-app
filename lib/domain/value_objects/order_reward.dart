/// Награда за выполнение заказа (валюта и опыт)
class OrderReward {
  final List<int> currency;
  final List<int> exp;

  const OrderReward({
    required this.currency,
    required this.exp,
  });

  /// Вычислить среднее арифметическое валюты
  static int averageCurrency(OrderReward reward) {
    if (reward.currency.isEmpty) return 0;
    final sum = reward.currency.fold<int>(0, (acc, value) => acc + value);
    return (sum / reward.currency.length).round();
  }

  /// Вычислить среднее арифметическое опыта
  static int averageExp(OrderReward reward) {
    if (reward.exp.isEmpty) return 0;
    final sum = reward.exp.fold<int>(0, (acc, value) => acc + value);
    return (sum / reward.exp.length).round();
  }
}

