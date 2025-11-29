import 'package:flutter/material.dart';

class FactionActivitiesBlock extends StatelessWidget {
  final bool hasOrder;
  final bool hasWork;
  final bool showOrderCheckbox;
  final bool showWorkCheckbox;
  final ValueChanged<bool>? onHasOrderChanged;
  final ValueChanged<bool>? onHasWorkChanged;

  const FactionActivitiesBlock({
    super.key,
    required this.hasOrder,
    required this.hasWork,
    this.showOrderCheckbox = true,
    this.showWorkCheckbox = true,
    this.onHasOrderChanged,
    this.onHasWorkChanged,
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
            Icon(Icons.check_circle_outline, color: Colors.blue[300], size: 20),
            const Text(
              'Ежедневные активности',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        Row(
          spacing: 8,
          children: [
            if (showOrderCheckbox)
              Expanded(
                child: Card(
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
                    value: hasOrder,
                    activeColor: Colors.green,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
                    onChanged: onHasOrderChanged != null
                        ? (value) {
                            onHasOrderChanged!(value ?? false);
                          }
                        : null,
                  ),
                ),
              ),
            if (showWorkCheckbox)
              Expanded(
                child: Card(
                  margin: EdgeInsets.zero,
                  child: CheckboxListTile(
                    dense: true,
                    title: Row(
                      spacing: 8,
                      children: [
                        Icon(Icons.work_outline, size: 16, color: Colors.amber[300]),
                        const Text('Работы', style: TextStyle(fontSize: 14)),
                      ],
                    ),
                    value: hasWork,
                    activeColor: Colors.amber,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
                    onChanged: onHasWorkChanged != null
                        ? (value) {
                            onHasWorkChanged!(value ?? false);
                          }
                        : null,
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }
}

