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
      text: widget.workReward?.currency != null && widget.workReward!.currency > 0
          ? widget.workReward!.currency.toString()
          : '',
    );
    _expController = TextEditingController(
      text: widget.workReward?.exp != null && widget.workReward!.exp > 0
          ? widget.workReward!.exp.toString()
          : '',
    );
  }

  @override
  void didUpdateWidget(FactionActivitiesBlock oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.workReward != widget.workReward) {
      _currencyController.text = widget.workReward?.currency != null && widget.workReward!.currency > 0
          ? widget.workReward!.currency.toString()
          : '';
      _expController.text = widget.workReward?.exp != null && widget.workReward!.exp > 0
          ? widget.workReward!.exp.toString()
          : '';
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
    
    final currency = currencyText.isEmpty ? 0 : (int.tryParse(currencyText) ?? 0);
    final exp = expText.isEmpty ? 0 : (int.tryParse(expText) ?? 0);
    
    // Всегда создаем WorkReward (даже если оба поля 0)
    widget.onWorkRewardChanged!(WorkReward(
      currency: currency,
      exp: exp,
    ));
  }

  void _showHelpDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('О ежедневных активностях'),
        content: const Text(
          'Блок "Ежедневные активности" позволяет настроить, какие источники дохода учитываются при расчете времени до цели.\n\n'
          '• Заказы - включите галочку, если хотите учитывать заказы в расчете. Заказы дают валюту и опыт ежедневно.\n\n'
          '• Работа - укажите валюту и опыт, которые вы получаете за работу каждый день. Эти значения используются в калькуляторе времени до цели по валюте и репутации. Можно указать только валюту, только опыт, или оба значения.\n\n'
          'Если галочка "Заказы" выключена или поля работы пустые, соответствующие источники дохода не учитываются в расчетах.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Понятно'),
          ),
        ],
      ),
    );
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
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(Icons.check_circle_outline, color: Colors.blue[300], size: 20),
            const Text(
              'Ежедневные активности',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            GestureDetector(
              onTap: _showHelpDialog,
              child: Icon(
                Icons.help_outline,
                size: 18,
                color: Colors.grey[400],
              ),
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
                              decoration: InputDecoration(
                                labelText: 'Валюта/день',
                                labelStyle: TextStyle(fontSize: 12, color: Colors.grey[400]),
                                floatingLabelStyle: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.primary),
                                isDense: true,
                                contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
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
                              decoration: InputDecoration(
                                labelText: 'Опыт/день',
                                labelStyle: TextStyle(fontSize: 12, color: Colors.grey[400]),
                                floatingLabelStyle: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.primary),
                                isDense: true,
                                contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
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

