import 'package:flutter/material.dart';
import '../common/help_dialog.dart';

class FactionDecorationsSection extends StatelessWidget {
  final bool decorationRespectPurchased;
  final bool decorationRespectUpgraded;
  final bool decorationHonorPurchased;
  final bool decorationHonorUpgraded;
  final bool decorationAdorationPurchased;
  final bool decorationAdorationUpgraded;
  final ValueChanged<bool> onRespectPurchasedChanged;
  final ValueChanged<bool> onRespectUpgradedChanged;
  final ValueChanged<bool> onHonorPurchasedChanged;
  final ValueChanged<bool> onHonorUpgradedChanged;
  final ValueChanged<bool> onAdorationPurchasedChanged;
  final ValueChanged<bool> onAdorationUpgradedChanged;

  const FactionDecorationsSection({
    super.key,
    required this.decorationRespectPurchased,
    required this.decorationRespectUpgraded,
    required this.decorationHonorPurchased,
    required this.decorationHonorUpgraded,
    required this.decorationAdorationPurchased,
    required this.decorationAdorationUpgraded,
    required this.onRespectPurchasedChanged,
    required this.onRespectUpgradedChanged,
    required this.onHonorPurchasedChanged,
    required this.onHonorUpgradedChanged,
    required this.onAdorationPurchasedChanged,
    required this.onAdorationUpgradedChanged,
  });

  void _showHelpDialog(BuildContext context) {
    HelpDialog.show(
      context,
      'Об украшениях',
      'Блок "Украшения" позволяет отметить, какие украшения фракции куплены и улучшены.\n\n'
      '• Куплено - отметьте, если украшение куплено.\n\n'
      '• Улучшено - отметьте, если украшение улучшено. Доступно только для купленных украшений.\n\n'
      'Украшения учитываются при расчете стоимости сертификата и времени до цели по валюте.',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          spacing: 8,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(Icons.star, color: Colors.amber[300], size: 20),
            const Text(
              'Украшения',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            GestureDetector(
              onTap: () => _showHelpDialog(context),
              child: Icon(
                Icons.help_outline,
                size: 18,
                color: Colors.grey[400],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _buildDecorationTile(
          const Color(0xFF4CAF50), // Зеленый для Уважение
          decorationRespectPurchased,
          decorationRespectUpgraded,
          onRespectPurchasedChanged,
          onRespectUpgradedChanged,
        ),
        const SizedBox(height: 8),
        _buildDecorationTile(
          const Color(0xFF26A69A), // Бирюзовый для Почтение
          decorationHonorPurchased,
          decorationHonorUpgraded,
          onHonorPurchasedChanged,
          onHonorUpgradedChanged,
        ),
        const SizedBox(height: 8),
        _buildDecorationTile(
          const Color(0xFF2196F3), // Синий для Преклонение
          decorationAdorationPurchased,
          decorationAdorationUpgraded,
          onAdorationPurchasedChanged,
          onAdorationUpgradedChanged,
        ),
      ],
    );
  }

  Widget _buildDecorationTile(
    Color decorationColor,
    bool purchased,
    bool upgraded,
    ValueChanged<bool> onPurchasedChanged,
    ValueChanged<bool> onUpgradedChanged,
  ) {
    return Card(
      margin: EdgeInsets.zero,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border(
            left: BorderSide(
              color: decorationColor,
              width: 4,
            ),
          ),
        ),
        padding: const EdgeInsets.only(right: 14),
        child: Row(
          spacing: 16,
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Row(
              children: [
                Checkbox(
                  value: purchased,
                  onChanged: (value) {
                    onPurchasedChanged(value ?? false);
                  },
                  activeColor: decorationColor,
                ),
                const Text('Куплено', style: TextStyle(fontSize: 14)),
              ],
            ),
            Row(
              children: [
                Checkbox(
                  value: upgraded,
                  onChanged: purchased
                      ? (value) {
                          onUpgradedChanged(value ?? false);
                        }
                      : null,
                  activeColor: decorationColor,
                ),
                const Text('Улучшено', style: TextStyle(fontSize: 14)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

