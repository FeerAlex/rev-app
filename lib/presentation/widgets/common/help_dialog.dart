import 'package:flutter/material.dart';

/// Переиспользуемый компонент для отображения модалки помощи
class HelpDialog extends StatelessWidget {
  final String title;
  final String content;

  const HelpDialog({
    super.key,
    required this.title,
    required this.content,
  });

  /// Показать модалку помощи
  static void show(BuildContext context, String title, String content) {
    showDialog(
      context: context,
      builder: (context) => HelpDialog(
        title: title,
        content: content,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(title),
      content: Text(content),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Понятно'),
        ),
      ],
    );
  }
}

