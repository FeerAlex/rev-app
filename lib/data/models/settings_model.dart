import '../../domain/entities/settings.dart';
import '../datasources/settings_dao.dart';

class SettingsModel {
  static Settings fromMap(Map<String, dynamic> map) {
    return Settings(
      id: map[SettingsDao.columnId] as int?,
      itemPrice: map[SettingsDao.columnItemPrice] as int,
      itemCountRespect: map[SettingsDao.columnItemCountRespect] as int,
      itemCountHonor: map[SettingsDao.columnItemCountHonor] as int,
      itemCountAdoration: map[SettingsDao.columnItemCountAdoration] as int,
      decorationPriceRespect: map[SettingsDao.columnDecorationPriceRespect] as int,
      decorationPriceHonor: map[SettingsDao.columnDecorationPriceHonor] as int,
      decorationPriceAdoration: map[SettingsDao.columnDecorationPriceAdoration] as int,
      currencyPerOrder: map[SettingsDao.columnCurrencyPerOrder] as int,
      certificatePrice: map[SettingsDao.columnCertificatePrice] as int,
    );
  }

  static Map<String, dynamic> toMap(Settings settings) {
    final map = <String, dynamic>{
      SettingsDao.columnItemPrice: settings.itemPrice,
      SettingsDao.columnItemCountRespect: settings.itemCountRespect,
      SettingsDao.columnItemCountHonor: settings.itemCountHonor,
      SettingsDao.columnItemCountAdoration: settings.itemCountAdoration,
      SettingsDao.columnDecorationPriceRespect: settings.decorationPriceRespect,
      SettingsDao.columnDecorationPriceHonor: settings.decorationPriceHonor,
      SettingsDao.columnDecorationPriceAdoration:
          settings.decorationPriceAdoration,
      SettingsDao.columnCurrencyPerOrder: settings.currencyPerOrder,
      SettingsDao.columnCertificatePrice: settings.certificatePrice,
    };

    if (settings.id != null) {
      map[SettingsDao.columnId] = settings.id;
    }

    return map;
  }
}

