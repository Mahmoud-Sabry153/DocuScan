import 'package:flutter/services.dart';
import '../domain/document_detector.dart';

class NativeDocumentDetector implements DocumentDetector {
  static const _channel = MethodChannel('com.docuscan/native_cv');
  @override
  Future<DocumentQuad?> detect(String imagePath) async {
    final map = await _channel.invokeMapMethod<String, double>('detectDocument', {'path': imagePath});
    if (map == null) return null;
    return DocumentQuad(Offset(map['tlx']!,map['tly']!),Offset(map['trx']!,map['try']!),Offset(map['brx']!,map['bry']!),Offset(map['blx']!,map['bly']!));
  }
  @override
  Future<String> perspectiveCorrect(String imagePath, DocumentQuad q) async => (await _channel.invokeMethod<String>('perspectiveCorrect', {
    'path': imagePath,
    'points':[q.topLeft.dx,q.topLeft.dy,q.topRight.dx,q.topRight.dy,q.bottomRight.dx,q.bottomRight.dy,q.bottomLeft.dx,q.bottomLeft.dy]
  }))!;
}
