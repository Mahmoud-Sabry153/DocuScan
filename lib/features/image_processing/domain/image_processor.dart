enum EnhancementMode { original, document, blackAndWhite, colorBoost, grayscale, sepia }
abstract interface class ImageProcessor {
  Future<String> enhance(String sourcePath, {EnhancementMode mode = EnhancementMode.document});
  Future<String> rotate(String sourcePath, int quarterTurns);
}
