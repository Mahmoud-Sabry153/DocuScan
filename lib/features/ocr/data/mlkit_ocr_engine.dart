import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import '../../../core/error/app_failure.dart';
import '../domain/ocr_engine.dart';

class MlKitOcrEngine implements OcrEngine {
  final TextRecognizer _recognizer = TextRecognizer(script: TextRecognitionScript.latin);
  @override
  Future<OcrResult> recognize(String imagePath) async {
    try {
      final input = InputImage.fromFilePath(imagePath);
      final recognized = await _recognizer.processImage(input);
      return OcrResult(text: recognized.text, confidence: null);
    } catch (e) { throw OcrFailure('Text recognition failed for this page.', e); }
  }
  Future<void> close() => _recognizer.close();
}
