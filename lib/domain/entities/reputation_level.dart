import 'package:flutter/material.dart';

enum ReputationLevel {
  indifference, // равнодушие
  friendliness, // дружелюбие
  respect, // уважение
  honor, // почтение
  adoration, // преклонение
  deification, // обожествление
}

extension ReputationLevelExtension on ReputationLevel {
  String get displayName {
    switch (this) {
      case ReputationLevel.indifference:
        return 'Равнодушие';
      case ReputationLevel.friendliness:
        return 'Дружелюбие';
      case ReputationLevel.respect:
        return 'Уважение';
      case ReputationLevel.honor:
        return 'Почтение';
      case ReputationLevel.adoration:
        return 'Преклонение';
      case ReputationLevel.deification:
        return 'Обожествление';
    }
  }

  int get value {
    switch (this) {
      case ReputationLevel.indifference:
        return 0;
      case ReputationLevel.friendliness:
        return 1;
      case ReputationLevel.respect:
        return 2;
      case ReputationLevel.honor:
        return 3;
      case ReputationLevel.adoration:
        return 4;
      case ReputationLevel.deification:
        return 5;
    }
  }

  static ReputationLevel fromValue(int value) {
    return ReputationLevel.values.firstWhere(
      (level) => level.value == value,
      orElse: () => ReputationLevel.indifference,
    );
  }
}

extension ReputationLevelColorExtension on ReputationLevel {
  Color get color {
    switch (this) {
      case ReputationLevel.indifference:
        return const Color(0xFFA1887F); // Бледно-коричневый
      case ReputationLevel.friendliness:
        return const Color(0xFF388E3C); // Темно-зеленый
      case ReputationLevel.respect:
        return const Color(0xFF4CAF50);
      case ReputationLevel.honor:
        return const Color(0xFF26A69A);
      case ReputationLevel.adoration:
        return const Color(0xFF2196F3);
      case ReputationLevel.deification:
        return const Color(0xFF9C27B0);
    }
  }
}

