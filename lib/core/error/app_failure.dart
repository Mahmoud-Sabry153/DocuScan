sealed class AppFailure implements Exception {
  const AppFailure(this.message, [this.cause]);
  final String message;
  final Object? cause;
}
class CameraFailure extends AppFailure { const CameraFailure(super.message, [super.cause]); }
class OcrFailure extends AppFailure { const OcrFailure(super.message, [super.cause]); }
class StorageFailure extends AppFailure { const StorageFailure(super.message, [super.cause]); }
class PdfFailure extends AppFailure { const PdfFailure(super.message, [super.cause]); }
class ProcessingFailure extends AppFailure { const ProcessingFailure(super.message, [super.cause]); }
