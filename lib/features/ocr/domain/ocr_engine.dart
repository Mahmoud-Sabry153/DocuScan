class OcrResult {
  const OcrResult({required this.text, this.confidence});
  final String text;
  final double? confidence;
}
abstract interface class OcrEngine { Future<OcrResult> recognize(String imagePath); }
