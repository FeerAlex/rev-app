import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/constants/work_reward.dart';

class FactionActivitiesBlock extends StatefulWidget {
  final bool hasOrder;
  final WorkReward? workReward;
  final bool showOrderCheckbox;
  final bool showWorkInput;
  final ValueChanged<bool>? onHasOrderChanged;
  final ValueChanged<WorkReward?>? onWorkRewardChanged;

  const FactionActivitiesBlock({
    super.key,
    required this.hasOrder,
    this.workReward,
    this.showOrderCheckbox = true,
    this.showWorkInput = true,
    this.onHasOrderChanged,
    this.onWorkRewardChanged,
  });

  @override
  State<FactionActivitiesBlock> createState() => _FactionActivitiesBlockState();
}

class _FactionActivitiesBlockState extends State<FactionActivitiesBlock> {
  late TextEditingController _currencyController;
  late TextEditingController _expController;

  @override
  void initState() {
    super.initState();
    _currencyController = TextEditingController(
      text: widget.workReward?.currency?.toString() ?? '',
    );
    _expController = TextEditingController(
      text: widget.workReward?.exp?.toString() ?? '',
    );
  }

  @override
  void didUpdateWidget(FactionActivitiesBlock oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.workReward != widget.workReward) {
      _currencyController.text = widget.workReward?.currency?.toString() ?? '';
      _expController.text = widget.workReward?.exp?.toString() ?? '';
    }
  }

  @override
  void dispose() {
    _currencyController.dispose();
    _expController.dispose();
    super.dispose();
  }

  void _updateWorkReward() {
    if (widget.onWorkRewardChanged == null) return;
    
    final currencyText = _currencyController.text.trim();
    final expText = _expController.text.trim();
    
    final currency = currencyText.isEmpty ? null : int.tryParse(currencyText);
    final exp = expText.isEmpty ? null : int.tryParse(expText);
    
    // Если оба поля пустые, возвращаем null, иначе создаем WorkReward
    if (currency == null && exp == null) {
      widget.onWorkRewardChanged!(null);
    } else {
      widget.onWorkRewardChanged!(WorkReward(
        currency: currency ?? 0,
        exp: exp ?? 0,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return _buildContent();
  }

  Widget _buildContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 12,
      children: [
        Row(
          spacing: 8,
          children: [
            Icon(Icons.check_circle_outline, color: Colors.blue[300], size: 20),
            const Text(
              'Ежедневные активности',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        Column(
          spacing: 8,
          children: [
            if (widget.showOrderCheckbox)
              Card(
                margin: EdgeInsets.zero,
                child: CheckboxListTile(
                  dense: true,
                  title: Row(
                    spacing: 8,
                    children: [
                      Icon(Icons.shopping_cart, size: 16, color: Colors.green[300]),
                      const Text('Заказы', style: TextStyle(fontSize: 14)),
                    ],
                  ),
                  value: widget.hasOrder,
                  activeColor: Colors.green,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
                  onChanged: widget.onHasOrderChanged != null
                      ? (value) {
                          widget.onHasOrderChanged!(value ?? false);
                        }
                      : null,
                ),
              ),
            if (widget.showWorkInput)
              Card(
                margin: EdgeInsets.zero,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    spacing: 14,
                    children: [
                      Row(
                        spacing: 8,
                        children: [
                          Icon(Icons.work_outline, size: 16, color: Colors.amber[300]),
                          const Text('Работа', style: TextStyle(fontSize: 14)),
                        ],
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _currencyController,
                              decoration: const InputDecoration(
                                labelText: 'Валюта/день',
                                isDense: true,
                                contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                              ),
                              keyboardType: TextInputType.number,
                              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                              onChanged: (_) => _updateWorkReward(),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: TextField(
                              controller: _expController,
                              decoration: const InputDecoration(
                                labelText: 'Опыт/день',
                                isDense: true,
                                contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                              ),
                              keyboardType: TextInputType.number,
                              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                              onChanged: (_) => _updateWorkReward(),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }
}

