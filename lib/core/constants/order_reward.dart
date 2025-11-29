/// Награда за выполнение заказа (валюта и опыт)
class OrderReward {
  final int currency;
  final int exp;

  const OrderReward({
    required this.currency,
    required this.exp,
  });

  /// Вычислить среднее арифметическое валюты из списка наград
  static int averageCurrency(List<OrderReward> rewards) {
    if (rewards.isEmpty) return 0;
    final sum = rewards.fold<int>(0, (acc, reward) => acc + reward.currency);
    return (sum / rewards.length).round();
  }

  /// Вычислить среднее арифметическое опыта из списка наград
  static int averageExp(List<OrderReward> rewards) {
    if (rewards.isEmpty) return 0;
    final sum = rewards.fold<int>(0, (acc, reward) => acc + reward.exp);
    return (sum / rewards.length).round();
  }
}

