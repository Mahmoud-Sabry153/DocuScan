import 'dart:io';
import 'dart:isolate';
import 'package:image/image.dart' as img;
import 'package:path/path.dart' as p;
import '../domain/image_processor.dart';
import '../../../core/error/app_failure.dart';

class IsolateImageProcessor implements ImageProcessor {
  @override
  Future<String> enhance(String sourcePath, {EnhancementMode mode = EnhancementMode.document}) async {
    try { return await Isolate.run(() => _enhanceSync(sourcePath, mode.name)); }
    catch (e) { throw ProcessingFailure('Could not enhance image.', e); }
  }
  @override
  Future<String> rotate(String sourcePath, int quarterTurns) async => Isolate.run(() {
    final bytes = File(sourcePath).readAsBytesSync();
    var decoded = img.decodeImage(bytes)!;
    decoded = img.copyRotate(decoded, angle: 90 * quarterTurns);
    final out = p.join(p.dirname(sourcePath), '${p.basenameWithoutExtension(sourcePath)}_rot.jpg');
    File(out).writeAsBytesSync(img.encodeJpg(decoded, quality: 90));
    return out;
  });
}

const _sharpenKernel = [0, -1, 0, -1, 5, -1, 0, -1, 0];

String _enhanceSync(String sourcePath, String mode) {
  final bytes = File(sourcePath).readAsBytesSync();
  var image = img.decodeImage(bytes);
  if (image == null) throw const FormatException('Unsupported image');
  if (image.width > 2400) image = img.copyResize(image, width: 2400, interpolation: img.Interpolation.linear);
  switch (mode) {
    case 'document':
      image = img.grayscale(image);
      image = img.adjustColor(image, contrast: 1.18, brightness: 1.04);
      image = img.gaussianBlur(image, radius: 1);
    case 'blackAndWhite':
      image = img.grayscale(image);
      image = img.adjustColor(image, contrast: 1.35, brightness: 1.06);
      image = img.luminanceThreshold(image, threshold: 0.52);
    case 'colorBoost':
      image = img.adjustColor(image, contrast: 1.22, saturation: 1.5, brightness: 1.04);
      image = img.convolution(image, filter: _sharpenKernel);
    case 'grayscale':
      image = img.grayscale(image);
    case 'sepia':
      image = img.adjustColor(image, contrast: 1.08, brightness: 1.02);
      image = img.sepia(image, amount: 0.85);
    case 'original':
    default:
      break;
  }
  final out = p.join(p.dirname(sourcePath), '${p.basenameWithoutExtension(sourcePath)}_$mode.jpg');
  File(out).writeAsBytesSync(img.encodeJpg(image, quality: 88), flush: true);
  return out;
}
