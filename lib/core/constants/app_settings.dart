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

/// Настройки фракций
class FactionsSettings {
  const FactionsSettings._();

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

  /// Валюта за выполнение заказа
  final int currencyPerOrder = 100;

  /// Валюта за выполнение работы
  final int currencyPerWork = 100;

  /// Стоимость сертификата
  final int certificatePrice = 7888;
}

