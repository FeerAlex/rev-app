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
      contentPadding: EdgeInsets.only(top: 0, bottom: 14, left: 14, right: 14),
      insetPadding: EdgeInsets.all(16),
      titlePadding: EdgeInsets.all(14),
      actionsPadding: EdgeInsets.only(top: 0, bottom: 14, left: 14, right: 14),
      buttonPadding: EdgeInsets.zero,
    );
  }
}

