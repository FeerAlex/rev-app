/// Константы настроек приложения
/// Структура организована по функциональности для расширяемости
class AppSettings {
  AppSettings._();

  /// Настройки для фракций
  static const FactionsSettings factions = FactionsSettings._();

  // TODO: Добавить настройки для карты
  // static const MapSettings map = MapSettings._();

  // TODO: Добавить настройки для брактеата
  // static const BracketSettings bracket = BracketSettings._();
}

/// Значения опыта репутации для разных групп фракций
/// Индекс 0 = стандартные значения, индекс 1 = специальные значения
class ReputationExpValues {
  final List<int> indifference;
  final List<int> friendliness;
  final List<int> respect;
  final List<int> honor;
  final List<int> adoration;
  final List<int> deification;

  const ReputationExpValues({
    required this.indifference,
    required this.friendliness,
    required this.respect,
    required this.honor,
    required this.adoration,
    required this.deification,
  });
}

/// Настройки фракций
class FactionsSettings {
  const FactionsSettings._();

  /// Константы опыта репутации: [стандартные, специальные]
  static const reputationExp = ReputationExpValues(
    indifference: [11500, 16000],
    friendliness: [33500, 43000],
    respect: [34000, 41000],
    honor: [73000, 80000],
    adoration: [105000, 115000],
    deification: [170000, 180000],
  );

  /// Стоимость улучшения украшения "Уважение" (3 * 1788 = 5364)
  final int decorationUpgradeCostRespect = 5364;

  /// Стоимость улучшения украшения "Почтение" (4 * 1788 = 7152)
  final int decorationUpgradeCostHonor = 7152;

  /// Стоимость улучшения украшения "Преклонение" (6 * 1788 = 10728)
  final int decorationUpgradeCostAdoration = 10728;

  /// Стоимость покупки украшения "Уважение"
  final int decorationPriceRespect = 7888;

  /// Стоимость покупки украшения "Почтение"
  final int decorationPriceHonor = 9888;

  /// Стоимость покупки украшения "Преклонение"
  final int decorationPriceAdoration = 15888;

  /// Валюта за выполнение работы
  final int currencyPerWork = 100;

  /// Стоимость сертификата
  final int certificatePrice = 7888;
}

