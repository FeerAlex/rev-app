import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/settings/settings_bloc.dart';
import '../bloc/settings/settings_event.dart';
import '../bloc/settings/settings_state.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  late TextEditingController _itemPriceController;
  late TextEditingController _itemCountRespectController;
  late TextEditingController _itemCountHonorController;
  late TextEditingController _itemCountAdorationController;
  late TextEditingController _decorationPriceRespectController;
  late TextEditingController _decorationPriceHonorController;
  late TextEditingController _decorationPriceAdorationController;
  late TextEditingController _currencyPerOrderController;
  late TextEditingController _certificatePriceController;

  @override
  void initState() {
    super.initState();
    _itemPriceController = TextEditingController();
    _itemCountRespectController = TextEditingController();
    _itemCountHonorController = TextEditingController();
    _itemCountAdorationController = TextEditingController();
    _decorationPriceRespectController = TextEditingController();
    _decorationPriceHonorController = TextEditingController();
    _decorationPriceAdorationController = TextEditingController();
    _currencyPerOrderController = TextEditingController();
    _certificatePriceController = TextEditingController();
  }

  @override
  void dispose() {
    _itemPriceController.dispose();
    _itemCountRespectController.dispose();
    _itemCountHonorController.dispose();
    _itemCountAdorationController.dispose();
    _decorationPriceRespectController.dispose();
    _decorationPriceHonorController.dispose();
    _decorationPriceAdorationController.dispose();
    _currencyPerOrderController.dispose();
    _certificatePriceController.dispose();
    super.dispose();
  }

  void _loadSettings(SettingsLoaded state) {
    final settings = state.settings;
    _itemPriceController.text = settings.itemPrice.toString();
    _itemCountRespectController.text = settings.itemCountRespect.toString();
    _itemCountHonorController.text = settings.itemCountHonor.toString();
    _itemCountAdorationController.text = settings.itemCountAdoration.toString();
    _decorationPriceRespectController.text =
        settings.decorationPriceRespect.toString();
    _decorationPriceHonorController.text =
        settings.decorationPriceHonor.toString();
    _decorationPriceAdorationController.text =
        settings.decorationPriceAdoration.toString();
    _currencyPerOrderController.text = settings.currencyPerOrder.toString();
    _certificatePriceController.text = settings.certificatePrice.toString();
  }

  void _saveSettings() {
    final currentState = state;
    if (currentState == null) return;
    
    final settings = currentState.settings;
    final updatedSettings = settings.copyWith(
      itemPrice: int.tryParse(_itemPriceController.text) ?? 0,
      itemCountRespect:
          int.tryParse(_itemCountRespectController.text) ?? 1,
      itemCountHonor: int.tryParse(_itemCountHonorController.text) ?? 3,
      itemCountAdoration:
          int.tryParse(_itemCountAdorationController.text) ?? 6,
      decorationPriceRespect:
          int.tryParse(_decorationPriceRespectController.text) ?? 0,
      decorationPriceHonor:
          int.tryParse(_decorationPriceHonorController.text) ?? 0,
      decorationPriceAdoration:
          int.tryParse(_decorationPriceAdorationController.text) ?? 0,
      currencyPerOrder:
          int.tryParse(_currencyPerOrderController.text) ?? 0,
      certificatePrice:
          int.tryParse(_certificatePriceController.text) ?? 0,
    );

    context.read<SettingsBloc>().add(UpdateSettingsEvent(updatedSettings));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Настройки сохранены')),
    );
  }

  SettingsLoaded? get state {
    final blocState = context.read<SettingsBloc>().state;
    return blocState is SettingsLoaded ? blocState : null;
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingsBloc, SettingsState>(
      builder: (context, state) {
        if (state is SettingsLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (state is SettingsError) {
          return Center(child: Text('Ошибка: ${state.message}'));
        }
        if (state is SettingsLoaded) {
          // Загружаем значения в контроллеры при первой загрузке
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (_itemPriceController.text.isEmpty) {
              _loadSettings(state);
            }
          });

            return Scaffold(
              body: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Итемки',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _itemPriceController,
                      decoration: const InputDecoration(
                        labelText: 'Цена 1 итемки',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Количество итемок для улучшения',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _itemCountRespectController,
                      decoration: const InputDecoration(
                        labelText: 'Для украшения "Уважение"',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _itemCountHonorController,
                      decoration: const InputDecoration(
                        labelText: 'Для украшения "Почтение"',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _itemCountAdorationController,
                      decoration: const InputDecoration(
                        labelText: 'Для украшения "Преклонение"',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Стоимость украшений',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _decorationPriceRespectController,
                      decoration: const InputDecoration(
                        labelText: 'Украшение "Уважение"',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _decorationPriceHonorController,
                      decoration: const InputDecoration(
                        labelText: 'Украшение "Почтение"',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _decorationPriceAdorationController,
                      decoration: const InputDecoration(
                        labelText: 'Украшение "Преклонение"',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Валюта за активности',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _currencyPerOrderController,
                      decoration: const InputDecoration(
                        labelText: 'Валюта за заказ',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Сертификат',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _certificatePriceController,
                      decoration: const InputDecoration(
                        labelText: 'Стоимость сертификата',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    ),
                  ],
                ),
              ),
              bottomNavigationBar: SafeArea(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  child: ElevatedButton(
                    onPressed: _saveSettings,
                    child: const Text('Сохранить настройки'),
                  ),
                ),
              ),
            );
          }
          return const SizedBox.shrink();
        },
      );
  }
}

