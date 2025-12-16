import '../../domain/repositories/text_recognizer.dart';
import '../datasources/tesseract_text_recognizer.dart';
import 'text_recognizer_impl.dart';

/// Фабрика для создания TextRecognizer
/// Инкапсулирует создание TextRecognizer с его зависимостями внутри Data layer
class TextRecognizerFactory {
  const TextRecognizerFactory._();

  /// Создает TextRecognizer с необходимыми зависимостями
  static TextRecognizer createTextRecognizer() {
    final tesseractRecognizer = TesseractTextRecognizer();
    return TextRecognizerImpl(tesseractRecognizer);
  }
}

