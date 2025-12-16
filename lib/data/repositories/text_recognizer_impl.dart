import '../../domain/repositories/text_recognizer.dart';
import '../datasources/tesseract_text_recognizer.dart';

/// Реализация TextRecognizer через Tesseract OCR
class TextRecognizerImpl implements TextRecognizer {
  final TesseractTextRecognizer _tesseractRecognizer;

  TextRecognizerImpl(this._tesseractRecognizer);

  @override
  Future<String> recognizeTextFromImage(String imagePath) async {
    return _tesseractRecognizer.extractText(imagePath);
  }
}


