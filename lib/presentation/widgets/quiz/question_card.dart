import 'package:flutter/material.dart';
import '../../../domain/entities/question.dart';
import '../../../domain/utils/question_source.dart';

class QuestionCard extends StatelessWidget {
  final Question question;

  const QuestionCard({super.key, required this.question});

  @override
  Widget build(BuildContext context) {
    // Цвет чипсов в зависимости от источника
    final chipColor = question.source == QuestionSource.club
        ? Color(0xFFFF6B35) // Оранжевый для клуба
        : Color(0xFF4A90E2); // Синий для экзамена
    
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: const Color(0xFF2A2A2A),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 8,
          children: [
            // Текст вопроса
            Text(
              question.question,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            Wrap(
              spacing: 4,
              runSpacing: 4,
              children: question.answers.map((answer) {
                return Chip(
                  label: Text(
                    answer,
                    style: TextStyle(
                      color: chipColor,
                      fontSize: 12,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                  backgroundColor: chipColor.withValues(alpha: 0.1),
                  side: BorderSide.none,
                  padding: EdgeInsets.zero,
                  labelPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  visualDensity: VisualDensity.compact,
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}
