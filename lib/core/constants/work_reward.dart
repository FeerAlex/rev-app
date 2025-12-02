/// Награда за выполнение работы (валюта и опыт)
class WorkReward {
  final int? currency;
  final int? exp;

  const WorkReward({
    this.currency,
    this.exp,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WorkReward &&
          runtimeType == other.runtimeType &&
          currency == other.currency &&
          exp == other.exp;

  @override
  int get hashCode => (currency?.hashCode ?? 0) ^ (exp?.hashCode ?? 0);
}

