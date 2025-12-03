import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CurrencyInputDialog extends StatefulWidget {
  final int? initialValue;
  final String title;
  final String labelText;
  final String? hintText;
  final bool allowEmpty;

  const CurrencyInputDialog({
    super.key,
    this.initialValue,
    required this.title,
    required this.labelText,
    this.hintText,
    this.allowEmpty = false,
  });

  @override
  State<CurrencyInputDialog> createState() => _CurrencyInputDialogState();
}

class _CurrencyInputDialogState extends State<CurrencyInputDialog> {
  late TextEditingController _controller;
  late FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(
      text: widget.initialValue?.toString() ?? '',
    );
    _focusNode = FocusNode();
    _focusNode.addListener(() {
      if (_focusNode.hasFocus) {
        _controller.selection = TextSelection(
          baseOffset: 0,
          extentOffset: _controller.text.length,
        );
      }
    });
    // Устанавливаем фокус после построения виджета
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      content: TextField(
        controller: _controller,
        focusNode: _focusNode,
        decoration: InputDecoration(
          labelText: widget.labelText,
          hintText: widget.hintText,
          border: const OutlineInputBorder(),
        ),
        keyboardType: TextInputType.number,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          style: TextButton.styleFrom(
            foregroundColor: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
          ),
          child: const Text('Отмена'),
        ),
        TextButton(
          onPressed: () {
            final value = _controller.text.trim();
            if (widget.allowEmpty) {
              final intValue = value.isEmpty ? 0 : int.tryParse(value);
              Navigator.of(context).pop(intValue);
            } else {
              final intValue = int.tryParse(value) ?? 0;
              Navigator.of(context).pop(intValue);
            }
          },
          child: const Text('Сохранить'),
        ),
      ],
    );
  }
}

