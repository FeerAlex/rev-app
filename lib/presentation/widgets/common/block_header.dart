import 'package:flutter/material.dart';

/// Переиспользуемый компонент для заголовка блока с иконкой и кнопкой помощи
class BlockHeader extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final VoidCallback onHelpTap;

  const BlockHeader({
    super.key,
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.onHelpTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      spacing: 8,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Row(
            spacing: 8,
            children: [
              Icon(icon, color: iconColor, size: 20),
              Text(
                title,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, height: 1),
              ),
            ],
          ),
        ),
        GestureDetector(
          onTap: onHelpTap,
          child: Icon(
            Icons.help_outline,
            size: 20,
            color: Colors.grey[400],
          ),
        ),
      ],
    );
  }
}

