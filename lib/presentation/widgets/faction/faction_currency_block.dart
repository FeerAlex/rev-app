import 'package:flutter/material.dart';
import '../currency/currency_input_dialog.dart';
import '../common/help_dialog.dart';
import '../common/block_header.dart';

class FactionCurrencyBlock extends StatelessWidget {
  final int currency;
  final ValueChanged<int> onCurrencyChanged;

  const FactionCurrencyBlock({
    super.key,
    required this.currency,
    required this.onCurrencyChanged,
  });

  void _showHelpDialog(BuildContext context) {
    HelpDialog.show(
      context,
      'О валюте',
      'Блок "Валюта" отображает текущее количество валюты фракции.\n\n'
      'Нажмите на значение валюты, чтобы изменить его. Это значение используется при расчете времени до цели по валюте.',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 12,
      children: [
        BlockHeader(
          icon: Icons.attach_money,
          iconColor: Colors.green[300]!,
          title: 'Валюта',
          onHelpTap: () => _showHelpDialog(context),
        ),
        Card(
          margin: EdgeInsets.zero,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  spacing: 8,
                  children: [
                    Icon(Icons.attach_money, size: 16, color: Colors.green[300]),
                    const Text(
                      'Валюта:',
                      style: TextStyle(fontSize: 14),
                    ),
                  ],
                ),
                TextButton(
                  onPressed: () async {
                    final result = await showDialog<int>(
                      context: context,
                      builder: (context) => CurrencyInputDialog(
                        initialValue: currency,
                        title: 'Валюта',
                        labelText: 'Введите количество валюты',
                        allowEmpty: false,
                      ),
                    );
                    if (result != null) {
                      onCurrencyChanged(result);
                    }
                  },
                  child: Text(
                    currency.toString(),
                    style: const TextStyle(fontSize: 14),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

