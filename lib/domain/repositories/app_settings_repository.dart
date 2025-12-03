/// Репозиторий для получения настроек приложения
abstract class AppSettingsRepository {
  /// Получить стоимость улучшения украшения "Уважение"
  int getDecorationUpgradeCostRespect();

  /// Получить стоимость улучшения украшения "Почтение"
  int getDecorationUpgradeCostHonor();

  /// Получить стоимость улучшения украшения "Преклонение"
  int getDecorationUpgradeCostAdoration();

  /// Получить стоимость покупки украшения "Уважение"
  int getDecorationPriceRespect();

  /// Получить стоимость покупки украшения "Почтение"
  int getDecorationPriceHonor();

  /// Получить стоимость покупки украшения "Преклонение"
  int getDecorationPriceAdoration();

  /// Получить стоимость сертификата
  int getCertificatePrice();

  /// Получить требуемый опыт для уровня репутации
  /// [factionName] - имя фракции для определения специальных значений
  /// [level] - уровень репутации
  int getExpForLevel(String factionName, int levelIndex, bool hasSpecialExp);

  /// Получить общий опыт, необходимый для достижения уровня (сумма всех предыдущих уровней)
  /// [factionName] - имя фракции для определения специальных значений
  /// [levelIndex] - индекс уровня репутации (0-5 для уровней до deification)
  int getTotalExpForLevel(String factionName, int levelIndex, bool hasSpecialExp);

  /// Получить дату последнего ежедневного сброса
  /// Возвращает null, если сброс еще не выполнялся
  Future<DateTime?> getLastResetDate();

  /// Сохранить дату последнего ежедневного сброса
  Future<void> saveLastResetDate(DateTime date);
}

