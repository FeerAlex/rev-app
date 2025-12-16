/// Интерфейс для распознавания текста с изображений
abstract class TextRecognizer {
  /// Распознает текст с изображения по указанному пути
  /// 
  /// Возвращает распознанный текст или пустую строку при ошибке
  Future<String> recognizeTextFromImage(String imagePath);
}

