import 'package:flutter/material.dart';
import '../currency/currency_input_dialog.dart';

class FactionCurrencyBlock extends StatelessWidget {
  final int currency;
  final ValueChanged<int> onCurrencyChanged;

  const FactionCurrencyBlock({
    super.key,
    required this.currency,
    required this.onCurrencyChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 12,
      children: [
        Row(
          spacing: 8,
          children: [
            Icon(Icons.attach_money, color: Colors.green[300], size: 20),
            const Text(
              'Валюта',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        Card(
          margin: EdgeInsets.zero,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Валюта:',
                  style: TextStyle(fontSize: 14),
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

