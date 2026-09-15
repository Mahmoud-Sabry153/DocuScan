import 'dart:ui';
class DocumentQuad { const DocumentQuad(this.topLeft,this.topRight,this.bottomRight,this.bottomLeft); final Offset topLeft,topRight,bottomRight,bottomLeft; }
abstract interface class DocumentDetector { Future<DocumentQuad?> detect(String imagePath); Future<String> perspectiveCorrect(String imagePath, DocumentQuad quad); }
