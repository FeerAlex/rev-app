import 'dart:io';

import 'package:flutter_tesseract_ocr/flutter_tesseract_ocr.dart';

/// Data Source для распознавания текста с помощью Tesseract OCR
class TesseractTextRecognizer {
  static const String _language = 'rus';

  /// Распознаёт текст с изображения
  Future<String> extractText(String imagePath) async {
    try {
      // Проверяем, существует ли файл изображения
      final imageFile = File(imagePath);
      if (!await imageFile.exists()) {
        return '';
      }

      // Запускаем распознавание (пакет сам управляет tessdata из assets)
      final String text = await FlutterTesseractOcr.extractText(
        imagePath,
        language: _language,
        args: {
          'preserve_interword_spaces': '1',
        },
      );

      return text.trim();
    } catch (e) {
      // В случае ошибки возвращаем пустую строку
      return '';
    }
  }
}


